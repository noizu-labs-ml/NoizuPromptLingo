defmodule CodefreshWeb.OtelControllerTest do
  # async: false — TimescaleDB hypertables deadlock across concurrent sandbox conns
  use CodefreshWeb.ConnCase, async: false
  import Codefresh.Fixtures

  defp put_bearer(conn, raw), do: put_req_header(conn, "authorization", "Bearer " <> raw)

  defp span_payload(trace_id \\ "trace-abc", span_id \\ "span-xyz", overrides \\ %{}) do
    now_ns = System.system_time(:nanosecond)

    span =
      Map.merge(
        %{
          "traceId" => trace_id,
          "spanId" => span_id,
          "name" => "llm.generate",
          "kind" => 3,
          "startTimeUnixNano" => to_string(now_ns),
          "endTimeUnixNano" => to_string(now_ns + 500_000),
          "status" => %{"code" => 1},
          "attributes" => [
            %{"key" => "llm.model", "value" => %{"stringValue" => "gpt-4.1"}}
          ]
        },
        overrides
      )

    %{
      "resourceSpans" => [
        %{
          "resource" => %{
            "attributes" => [
              %{"key" => "service.name", "value" => %{"stringValue" => "svc"}}
            ]
          },
          "scopeSpans" => [%{"spans" => [span]}]
        }
      ]
    }
  end

  describe "POST /otel/v1/traces (US-081)" do
    test "accepts spans with valid API token; stamps caller org", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()
      {_tok, raw} = api_token_fixture(org, owner)

      resp =
        conn
        |> put_bearer(raw)
        |> post("/otel/v1/traces", span_payload())

      assert %{"accepted" => 1} = json_response(resp, 202)
    end

    test "rejects missing Authorization header (401)", %{conn: conn} do
      resp = post(conn, "/otel/v1/traces", span_payload())
      assert response(resp, 401)
    end

    test "rejects bogus bearer token (401)", %{conn: conn} do
      resp =
        conn
        |> put_bearer("not-a-real-token")
        |> post("/otel/v1/traces", span_payload())

      assert response(resp, 401)
    end

    test "rejects malformed OTLP envelope (400)", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()
      {_tok, raw} = api_token_fixture(org, owner)

      resp =
        conn
        |> put_bearer(raw)
        |> post("/otel/v1/traces", %{"notResourceSpans" => []})

      assert json_response(resp, 400)["error"] =~ "invalid"
    end

    test "revoked token rejected", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()
      {tok, raw} = api_token_fixture(org, owner)
      {:ok, _} = Codefresh.ApiTokens.revoke_token(tok)

      resp =
        conn
        |> put_bearer(raw)
        |> post("/otel/v1/traces", span_payload())

      assert response(resp, 401)
    end
  end

  describe "POST /otel/v1/logs (US-081)" do
    test "accepts log records", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()
      {_tok, raw} = api_token_fixture(org, owner)

      now_ns = System.system_time(:nanosecond)

      payload = %{
        "resourceLogs" => [
          %{
            "resource" => %{"attributes" => []},
            "scopeLogs" => [
              %{
                "logRecords" => [
                  %{
                    "timeUnixNano" => to_string(now_ns),
                    "severityText" => "WARN",
                    "body" => %{"stringValue" => "slow retrieval"}
                  }
                ]
              }
            ]
          }
        ]
      }

      resp =
        conn
        |> put_bearer(raw)
        |> post("/otel/v1/logs", payload)

      assert %{"accepted" => 1} = json_response(resp, 202)
    end
  end

  describe "GET /api/v1/organizations/:id/otel-spans (US-098)" do
    test "returns spans matching attribute filter, scoped to org", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()
      {_tok, raw} = api_token_fixture(org, owner)

      # Ingest as the API-token-authenticated agent
      conn
      |> put_bearer(raw)
      |> post("/otel/v1/traces", span_payload("t-a", "s-a"))

      # Query as the JWT-authenticated owner
      resp =
        conn
        |> auth_conn(owner)
        |> get(~p"/api/v1/organizations/#{org.id}/otel-spans", %{
          "attr" => %{"llm.model" => "gpt-4.1"}
        })

      %{"spans" => spans} = json_response(resp, 200)
      assert length(spans) == 1
      assert hd(spans)["trace_id"] == "t-a"
    end

    test "viewer in another org cannot read spans (404)", %{conn: conn} do
      %{user: _owner_a, organization: org_a} = org_with_owner()
      %{user: owner_b, organization: _org_b} = org_with_owner()

      resp =
        conn
        |> auth_conn(owner_b)
        |> get(~p"/api/v1/organizations/#{org_a.id}/otel-spans", %{"attr" => %{}})

      assert response(resp, 404)
    end
  end

  describe "PUT /api/v1/organizations/:id/otel-sampling-policies (US-132)" do
    test "admin upserts a sampling policy", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()

      resp =
        conn
        |> auth_conn(owner)
        |> put(~p"/api/v1/organizations/#{org.id}/otel-sampling-policies", %{
          "policy" => %{
            "name" => "prod",
            "head_sampling_rate" => "0.25",
            "tail_rules" => %{"keep_error_traces" => true}
          }
        })

      assert %{"policy" => %{"name" => "prod"}} = json_response(resp, 200)
    end

    test "editor cannot edit policies (403)", %{conn: conn} do
      %{user: _owner, organization: org} = org_with_owner()
      editor = user_fixture()
      membership_fixture(editor, org, "editor")

      resp =
        conn
        |> auth_conn(editor)
        |> put(~p"/api/v1/organizations/#{org.id}/otel-sampling-policies", %{
          "policy" => %{"name" => "x"}
        })

      assert response(resp, 403)
    end

    test "rejects invalid head_sampling_rate (422)", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()

      resp =
        conn
        |> auth_conn(owner)
        |> put(~p"/api/v1/organizations/#{org.id}/otel-sampling-policies", %{
          "policy" => %{"name" => "bad", "head_sampling_rate" => "2.0"}
        })

      assert %{"errors" => %{"head_sampling_rate" => _}} = json_response(resp, 422)
    end
  end

  describe "GET /api/v1/organizations/:id/otel-sampling-policies (US-132)" do
    test "admin lists policies", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()

      {:ok, _} = Codefresh.Otel.upsert_policy(org.id, %{"name" => "p1"})

      resp =
        conn
        |> auth_conn(owner)
        |> get(~p"/api/v1/organizations/#{org.id}/otel-sampling-policies")

      assert %{"policies" => [%{"name" => "p1"}]} = json_response(resp, 200)
    end
  end
end
