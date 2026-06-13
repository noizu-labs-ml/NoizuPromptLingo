defmodule Codefresh.OtelTest do
  # async: false — TimescaleDB hypertable compression policies take AccessShareLock
  # on the hypertable which can deadlock with concurrent sandbox connections
  # during INSERT tests.
  use Codefresh.DataCase, async: false

  import Codefresh.Fixtures

  alias Codefresh.Otel

  defp otlp_span_envelope(trace_id, span_id, overrides \\ %{}) do
    now_ns = System.system_time(:nanosecond)

    base_span =
      %{
        "traceId" => trace_id,
        "spanId" => span_id,
        "name" => "llm.generate",
        "kind" => 3,
        "startTimeUnixNano" => to_string(now_ns),
        "endTimeUnixNano" => to_string(now_ns + 1_000_000),
        "status" => %{"code" => 1, "message" => "ok"},
        "attributes" => [
          %{"key" => "llm.model", "value" => %{"stringValue" => "gpt-4.1"}},
          %{"key" => "llm.tokens.out", "value" => %{"intValue" => "42"}}
        ]
      }
      |> Map.merge(overrides)

    %{
      "resourceSpans" => [
        %{
          "resource" => %{
            "attributes" => [
              %{"key" => "service.name", "value" => %{"stringValue" => "agent-runtime"}}
            ]
          },
          "scopeSpans" => [%{"spans" => [base_span]}]
        }
      ]
    }
  end

  defp otlp_log_envelope(body) do
    now_ns = System.system_time(:nanosecond)

    %{
      "resourceLogs" => [
        %{
          "resource" => %{"attributes" => []},
          "scopeLogs" => [
            %{
              "logRecords" => [
                %{
                  "timeUnixNano" => to_string(now_ns),
                  "severityNumber" => 9,
                  "severityText" => "INFO",
                  "body" => %{"stringValue" => body},
                  "attributes" => [
                    %{"key" => "log.source", "value" => %{"stringValue" => "agent"}}
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  end

  describe "ingest_spans/2 (US-081)" do
    test "persists spans, derives organization_id from caller, not payload" do
      %{organization: org} = org_with_owner()
      payload = otlp_span_envelope("trace-aaa", "span-1")

      assert {:ok, 1} = Otel.ingest_spans(payload, org.id)

      [span] = Otel.query_spans_by_attr(org.id, %{"llm.model" => "gpt-4.1"})
      assert span.trace_id == "trace-aaa"
      assert span.span_id == "span-1"
      assert span.organization_id == org.id
      assert span.service_name == "agent-runtime"
      assert span.status_code == "ok"
      assert span.kind == "client"
      assert span.run_id == nil
      assert span.duration_ns > 0
    end

    test "rejects malformed payload" do
      %{organization: org} = org_with_owner()
      assert {:error, :invalid_payload} = Otel.ingest_spans(%{"wrong" => []}, org.id)
    end

    test "skips incomplete span rows (missing trace_id)" do
      %{organization: org} = org_with_owner()

      payload = %{
        "resourceSpans" => [
          %{
            "resource" => %{"attributes" => []},
            "scopeSpans" => [
              %{
                "spans" => [
                  %{
                    "spanId" => "x",
                    "name" => "n",
                    "startTimeUnixNano" => "1",
                    "endTimeUnixNano" => "2"
                  }
                ]
              }
            ]
          }
        ]
      }

      assert {:ok, 0} = Otel.ingest_spans(payload, org.id)
    end
  end

  describe "ingest_logs/2 (US-082)" do
    test "persists log records" do
      %{organization: org} = org_with_owner()
      assert {:ok, 1} = Otel.ingest_logs(otlp_log_envelope("hello world"), org.id)
    end

    test "rejects malformed payload" do
      %{organization: org} = org_with_owner()
      assert {:error, :invalid_payload} = Otel.ingest_logs(%{"nope" => 1}, org.id)
    end
  end

  describe "query_spans_by_attr/3 (US-098)" do
    test "filters by attribute containment and scopes to org" do
      # Create orgs up-front before touching the hypertable — reduces the
      # window for TimescaleDB chunk-creation locks to collide with the
      # other pre-ingest index activity (api_tokens unique index on
      # org_with_owner).
      %{organization: org_a} = org_with_owner()
      %{organization: org_b} = org_with_owner()

      {:ok, 1} = Otel.ingest_spans(otlp_span_envelope("t1", "s1"), org_a.id)

      {:ok, 1} =
        Otel.ingest_spans(
          otlp_span_envelope("t2", "s2", %{
            "attributes" => [
              %{"key" => "llm.model", "value" => %{"stringValue" => "claude-sonnet-4.5"}}
            ]
          }),
          org_a.id
        )

      {:ok, 1} = Otel.ingest_spans(otlp_span_envelope("t3", "s3"), org_b.id)

      found = Otel.query_spans_by_attr(org_a.id, %{"llm.model" => "gpt-4.1"})
      assert length(found) == 1
      assert hd(found).organization_id == org_a.id
    end

    test "returns empty list for non-matching filter" do
      %{organization: org} = org_with_owner()
      {:ok, 1} = Otel.ingest_spans(otlp_span_envelope("t", "s"), org.id)
      assert Otel.query_spans_by_attr(org.id, %{"llm.model" => "nonexistent"}) == []
    end
  end

  describe "query_spans_by_run/2 (US-099)" do
    # A full end-to-end correlator test would require creating a real run
    # (script_version + agent_version chain), which sits in the runs/
    # context owned by a parallel agent in this stage. We verify the query
    # contract here (org scoping + shape) and leave run-stamping coverage
    # to US-082 when the correlator lands.
    test "returns empty when no spans linked" do
      %{organization: org} = org_with_owner()
      assert Otel.query_spans_by_run(org.id, Ecto.UUID.generate()) == []
    end

    test "does not leak uncorrelated spans into query_spans_by_run results" do
      %{organization: org} = org_with_owner()
      {:ok, 1} = Otel.ingest_spans(otlp_span_envelope("t-orphan", "s-orphan"), org.id)

      # Ingested spans have run_id = nil until the correlator sets it, so
      # querying by any run_id must return [].
      assert Otel.query_spans_by_run(org.id, Ecto.UUID.generate()) == []
    end
  end

  describe "sampling policy CRUD (US-132)" do
    test "upsert_policy/2 creates then updates existing by name" do
      %{organization: org} = org_with_owner()

      assert {:ok, p1} =
               Otel.upsert_policy(org.id, %{
                 "name" => "default",
                 "head_sampling_rate" => Decimal.new("0.50"),
                 "tail_rules" => %{"keep_error_traces" => true}
               })

      assert Decimal.equal?(p1.head_sampling_rate, Decimal.new("0.50"))
      assert p1.tail_rules == %{"keep_error_traces" => true}

      assert {:ok, p2} =
               Otel.upsert_policy(org.id, %{
                 "name" => "default",
                 "head_sampling_rate" => Decimal.new("0.10")
               })

      assert p2.id == p1.id
      assert Decimal.equal?(p2.head_sampling_rate, Decimal.new("0.10"))

      assert [_] = Otel.list_policies(org.id)
    end

    test "upsert_policy/2 rejects out-of-range rate" do
      %{organization: org} = org_with_owner()

      assert {:error, cs} =
               Otel.upsert_policy(org.id, %{
                 "name" => "bad",
                 "head_sampling_rate" => Decimal.new("1.50")
               })

      refute cs.valid?
    end

    test "list_policies/1 scopes to organization" do
      %{organization: org_a} = org_with_owner()
      %{organization: org_b} = org_with_owner()

      {:ok, _} = Otel.upsert_policy(org_a.id, %{"name" => "a"})
      {:ok, _} = Otel.upsert_policy(org_b.id, %{"name" => "b"})

      assert [a] = Otel.list_policies(org_a.id)
      assert a.name == "a"
    end
  end
end
