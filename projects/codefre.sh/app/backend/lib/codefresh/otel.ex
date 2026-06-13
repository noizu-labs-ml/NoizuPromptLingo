defmodule Codefresh.Otel do
  @moduledoc """
  OpenTelemetry ingest + query context (Stage 10).

  Two ingest entry points for OTLP/JSON payloads:

    * `ingest_spans/2` — accepts `{resourceSpans: [...]}` OTLP envelopes
    * `ingest_logs/2`  — accepts `{resourceLogs: [...]}` OTLP envelopes

  Both decode minimally (the fields we actually query) and bulk-insert via
  `Repo.insert_all/3`. `organization_id` is supplied by the authenticated
  API token, never by the client payload. `run_id` / `run_step_id` are left
  `nil` at ingest — the async correlator (US-082) sets them once the trace
  is linked to a run step.

  Query surface:

    * `query_spans_by_run/2`   — spans for a given run, ordered by start_time
    * `query_spans_by_attr/3`  — attribute-filter search backed by the GIN
                                 index on `otel_spans.attributes jsonb_path_ops`
    * `list_policies/1`, `upsert_policy/2` — sampling-policy CRUD (US-132)

  User stories: US-081, US-082, US-098, US-099, US-100, US-131-133.
  """

  import Ecto.Query, only: [from: 2]

  alias Codefresh.Repo
  alias Codefresh.Otel.{Span, Log, SamplingPolicy}

  # Map OTLP span kind integer → string (per OTLP spec)
  @span_kind_map %{
    0 => "unspecified",
    1 => "internal",
    2 => "server",
    3 => "client",
    4 => "producer",
    5 => "consumer"
  }

  # Map OTLP status code integer → string
  @status_code_map %{
    0 => "unset",
    1 => "ok",
    2 => "error"
  }

  # ─────────────────────────────────────────────────────────────────────────
  # Ingest — spans
  # ─────────────────────────────────────────────────────────────────────────

  @doc """
  Ingest an OTLP/JSON spans payload. `payload` is the decoded JSON map with
  shape `%{"resourceSpans" => [...]}`.

  Returns `{:ok, inserted_count}` on success or `{:error, reason}` on
  malformed payload. Per-row failures are logged but do not abort the batch.
  """
  @spec ingest_spans(map, binary) :: {:ok, non_neg_integer} | {:error, term}
  def ingest_spans(%{"resourceSpans" => rs}, organization_id)
      when is_list(rs) and is_binary(organization_id) do
    rows =
      rs
      |> Enum.flat_map(&decode_resource_spans(&1, organization_id))
      |> Enum.filter(&valid_span_row?/1)

    do_insert_all(Span, rows)
  end

  def ingest_spans(_, _), do: {:error, :invalid_payload}

  # ─────────────────────────────────────────────────────────────────────────
  # Ingest — logs
  # ─────────────────────────────────────────────────────────────────────────

  @doc """
  Ingest an OTLP/JSON logs payload. `payload` is the decoded JSON map with
  shape `%{"resourceLogs" => [...]}`.
  """
  @spec ingest_logs(map, binary) :: {:ok, non_neg_integer} | {:error, term}
  def ingest_logs(%{"resourceLogs" => rl}, organization_id)
      when is_list(rl) and is_binary(organization_id) do
    rows =
      rl
      |> Enum.flat_map(&decode_resource_logs(&1, organization_id))
      |> Enum.filter(&valid_log_row?/1)

    do_insert_all(Log, rows)
  end

  def ingest_logs(_, _), do: {:error, :invalid_payload}

  defp do_insert_all(_schema, []), do: {:ok, 0}

  defp do_insert_all(schema, rows) do
    {count, _} = Repo.insert_all(schema, rows)
    {:ok, count}
  end

  # ─────────────────────────────────────────────────────────────────────────
  # Query — by run / by attribute
  # ─────────────────────────────────────────────────────────────────────────

  @doc """
  List spans linked to a given `run_id`, scoped to `organization_id`.
  Ordered ascending by `start_time` so callers render a waterfall directly.
  """
  @spec query_spans_by_run(binary, binary, keyword) :: [Span.t()]
  def query_spans_by_run(organization_id, run_id, opts \\ [])
      when is_binary(organization_id) and is_binary(run_id) do
    limit = Keyword.get(opts, :limit, 500)

    Repo.all(
      from s in Span,
        where: s.organization_id == ^organization_id and s.run_id == ^run_id,
        order_by: [asc: s.start_time],
        limit: ^limit
    )
  end

  @doc """
  Search spans by attribute map. Uses the GIN `jsonb_path_ops` index on
  `otel_spans.attributes` via the `@>` contains operator (US-098).

  `attr_filter` is a map — rows whose `attributes` jsonb contains the filter
  map are returned. Example: `%{"llm.model" => "gpt-4.1"}`.

  Supports optional `:limit`, `:since` (DateTime), `:until` (DateTime).
  """
  @spec query_spans_by_attr(binary, map, keyword) :: [Span.t()]
  def query_spans_by_attr(organization_id, attr_filter, opts \\ [])
      when is_binary(organization_id) and is_map(attr_filter) do
    limit = Keyword.get(opts, :limit, 100)
    since = Keyword.get(opts, :since)
    until_ = Keyword.get(opts, :until)

    q =
      from s in Span,
        where: s.organization_id == ^organization_id,
        where: fragment("? @> ?", s.attributes, ^attr_filter),
        order_by: [desc: s.start_time],
        limit: ^limit

    q
    |> maybe_since(since)
    |> maybe_until(until_)
    |> Repo.all()
  end

  defp maybe_since(q, nil), do: q
  defp maybe_since(q, %DateTime{} = dt), do: from(s in q, where: s.start_time >= ^dt)

  defp maybe_until(q, nil), do: q
  defp maybe_until(q, %DateTime{} = dt), do: from(s in q, where: s.start_time <= ^dt)

  # ─────────────────────────────────────────────────────────────────────────
  # Sampling policy admin (US-132)
  # ─────────────────────────────────────────────────────────────────────────

  def list_policies(organization_id) when is_binary(organization_id) do
    Repo.all(
      from p in SamplingPolicy,
        where: p.organization_id == ^organization_id,
        order_by: [desc: p.inserted_at]
    )
  end

  def get_policy(organization_id, id) when is_binary(organization_id) do
    Repo.one(
      from p in SamplingPolicy,
        where: p.organization_id == ^organization_id and p.id == ^id
    )
  end

  @doc """
  Upsert a sampling policy by `(organization_id, name)`.
  """
  def upsert_policy(organization_id, attrs) when is_binary(organization_id) and is_map(attrs) do
    name = Map.get(attrs, "name") || Map.get(attrs, :name)

    existing =
      if is_binary(name) do
        Repo.one(
          from p in SamplingPolicy,
            where: p.organization_id == ^organization_id and p.name == ^name
        )
      end

    record = existing || %SamplingPolicy{}
    attrs_norm = Map.put(stringify(attrs), "organization_id", organization_id)

    record
    |> SamplingPolicy.changeset(attrs_norm)
    |> case do
      %Ecto.Changeset{valid?: false} = cs ->
        {:error, cs}

      cs ->
        if existing, do: Repo.update(cs), else: Repo.insert(cs)
    end
  end

  def delete_policy(%SamplingPolicy{} = policy), do: Repo.delete(policy)

  # ─────────────────────────────────────────────────────────────────────────
  # OTLP decoders (minimal — extract only what we persist)
  # ─────────────────────────────────────────────────────────────────────────

  defp decode_resource_spans(%{} = rs, organization_id) do
    resource_attrs = decode_attributes(get_in(rs, ["resource", "attributes"]))

    service_name =
      Map.get(resource_attrs, "service.name") || Map.get(resource_attrs, "service_name")

    scope_spans = Map.get(rs, "scopeSpans") || Map.get(rs, "instrumentationLibrarySpans") || []

    for ss <- scope_spans,
        span <- Map.get(ss, "spans", []) do
      decode_span(span, organization_id, resource_attrs, service_name)
    end
  end

  defp decode_resource_spans(_, _), do: []

  defp decode_span(span, organization_id, resource_attrs, service_name) do
    start_ns = to_int(span["startTimeUnixNano"] || span["start_time_unix_nano"])
    end_ns = to_int(span["endTimeUnixNano"] || span["end_time_unix_nano"])

    start_dt = ns_to_datetime(start_ns)
    end_dt = ns_to_datetime(end_ns)
    duration_ns = if end_ns && start_ns, do: end_ns - start_ns, else: nil

    status = Map.get(span, "status") || %{}
    status_code_int = to_int(Map.get(status, "code", 0)) || 0

    kind_int = to_int(Map.get(span, "kind", 1)) || 1

    now = DateTime.utc_now() |> DateTime.truncate(:second)

    %{
      id: Ecto.UUID.generate(),
      organization_id: organization_id,
      run_id: nil,
      run_step_id: nil,
      trace_id: to_str(span["traceId"] || span["trace_id"]),
      span_id: to_str(span["spanId"] || span["span_id"]),
      parent_span_id: nilable_str(span["parentSpanId"] || span["parent_span_id"]),
      name: to_str(Map.get(span, "name")),
      kind: Map.get(@span_kind_map, kind_int, "internal"),
      service_name: service_name,
      start_time: start_dt,
      end_time: end_dt,
      duration_ns: duration_ns,
      status_code: Map.get(@status_code_map, status_code_int, "unset"),
      status_message: nilable_str(Map.get(status, "message")),
      attributes: decode_attributes(Map.get(span, "attributes")),
      resource_attributes: resource_attrs,
      events: %{"list" => Map.get(span, "events", [])},
      sampled: nil,
      sample_decision_reason: nil,
      sample_rate: nil,
      inserted_at: now
    }
  end

  defp decode_resource_logs(%{} = rl, organization_id) do
    resource_attrs = decode_attributes(get_in(rl, ["resource", "attributes"]))
    scope_logs = Map.get(rl, "scopeLogs") || Map.get(rl, "instrumentationLibraryLogs") || []

    for sl <- scope_logs,
        rec <- Map.get(sl, "logRecords") || Map.get(sl, "log_records") || [] do
      decode_log(rec, organization_id, resource_attrs)
    end
  end

  defp decode_resource_logs(_, _), do: []

  defp decode_log(rec, organization_id, resource_attrs) do
    ts_ns =
      to_int(
        rec["timeUnixNano"] ||
          rec["time_unix_nano"] ||
          rec["observedTimeUnixNano"] ||
          rec["observed_time_unix_nano"]
      )

    ts_dt = ns_to_datetime(ts_ns)

    body =
      case Map.get(rec, "body") do
        %{"stringValue" => s} -> s
        %{"string_value" => s} -> s
        s when is_binary(s) -> s
        other -> inspect(other)
      end

    now = DateTime.utc_now() |> DateTime.truncate(:second)

    %{
      id: Ecto.UUID.generate(),
      organization_id: organization_id,
      run_id: nil,
      run_step_id: nil,
      trace_id: nilable_str(rec["traceId"] || rec["trace_id"]),
      span_id: nilable_str(rec["spanId"] || rec["span_id"]),
      timestamp: ts_dt,
      severity_number: to_int(rec["severityNumber"] || rec["severity_number"]),
      severity_text: nilable_str(rec["severityText"] || rec["severity_text"]),
      body: body || "",
      attributes: decode_attributes(Map.get(rec, "attributes")),
      resource_attributes: resource_attrs,
      inserted_at: now
    }
  end

  # OTLP attribute list [%{"key" => k, "value" => %{"stringValue"/"intValue"/...}}]
  # → plain %{k => v} map.
  defp decode_attributes(nil), do: %{}
  defp decode_attributes([]), do: %{}

  defp decode_attributes(attrs) when is_list(attrs) do
    for a <- attrs, is_map(a), into: %{} do
      k = Map.get(a, "key") || ""
      {k, extract_any_value(Map.get(a, "value"))}
    end
  end

  defp decode_attributes(attrs) when is_map(attrs), do: attrs

  defp extract_any_value(%{"stringValue" => v}), do: v
  defp extract_any_value(%{"string_value" => v}), do: v
  defp extract_any_value(%{"boolValue" => v}), do: v
  defp extract_any_value(%{"bool_value" => v}), do: v
  defp extract_any_value(%{"intValue" => v}), do: to_int(v)
  defp extract_any_value(%{"int_value" => v}), do: to_int(v)
  defp extract_any_value(%{"doubleValue" => v}) when is_number(v), do: v
  defp extract_any_value(%{"double_value" => v}) when is_number(v), do: v
  defp extract_any_value(%{"arrayValue" => %{"values" => vs}}) when is_list(vs),
    do: Enum.map(vs, &extract_any_value/1)

  defp extract_any_value(v) when is_binary(v) or is_number(v) or is_boolean(v), do: v
  defp extract_any_value(_), do: nil

  # ─────────────────────────────────────────────────────────────────────────
  # Coercion helpers
  # ─────────────────────────────────────────────────────────────────────────

  defp to_int(nil), do: nil
  defp to_int(n) when is_integer(n), do: n

  defp to_int(n) when is_binary(n) do
    case Integer.parse(n) do
      {i, _} -> i
      :error -> nil
    end
  end

  defp to_int(n) when is_float(n), do: trunc(n)
  defp to_int(_), do: nil

  defp to_str(nil), do: nil
  defp to_str(s) when is_binary(s), do: s
  defp to_str(s), do: to_string(s)

  defp nilable_str(nil), do: nil
  defp nilable_str(""), do: nil
  defp nilable_str(s) when is_binary(s), do: s
  defp nilable_str(s), do: to_string(s)

  defp ns_to_datetime(nil), do: nil

  defp ns_to_datetime(ns) when is_integer(ns) and ns > 0 do
    microseconds = div(ns, 1_000)
    DateTime.from_unix!(microseconds, :microsecond)
  end

  defp ns_to_datetime(_), do: nil

  defp valid_span_row?(%{trace_id: t, span_id: s, name: n, start_time: st, end_time: et})
       when is_binary(t) and t != "" and is_binary(s) and s != "" and is_binary(n) and n != "" and
              not is_nil(st) and not is_nil(et),
       do: true

  defp valid_span_row?(_), do: false

  defp valid_log_row?(%{timestamp: ts, body: b})
       when not is_nil(ts) and is_binary(b) and b != "",
       do: true

  defp valid_log_row?(_), do: false

  defp stringify(m) when is_map(m) do
    for {k, v} <- m, into: %{} do
      if is_atom(k), do: {Atom.to_string(k), v}, else: {k, v}
    end
  end
end
