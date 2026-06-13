defmodule CodefreshWeb.OtelController do
  @moduledoc """
  OTLP ingest + query endpoints (Stage 10).

  Ingest endpoints (`ingest_spans/2`, `ingest_logs/2`) are mounted behind the
  `:api_token_authenticated` pipeline — they derive `organization_id` from
  the authenticated CodeFresh API token, never from the request body.

  Query + sampling-policy endpoints are mounted behind the usual user JWT
  pipeline and authorize via `Codefresh.Organizations.authorize/3`.

  User stories: US-081, US-082, US-098, US-099, US-100, US-131-133.
  """

  use CodefreshWeb, :controller

  alias Codefresh.{Otel, Organizations, Guardian}

  action_fallback CodefreshWeb.FallbackController

  # ─────────────────────────────────────────────────────────────────────────
  # Ingest (API-token auth) — US-081
  # ─────────────────────────────────────────────────────────────────────────

  # POST /otel/v1/traces
  def ingest_spans(conn, params) do
    org_id = conn.assigns[:organization_id]

    case Otel.ingest_spans(params, org_id) do
      {:ok, count} ->
        conn |> put_status(:accepted) |> json(%{accepted: count})

      {:error, :invalid_payload} ->
        conn |> put_status(:bad_request) |> json(%{error: "invalid OTLP payload"})
    end
  end

  # POST /otel/v1/logs
  def ingest_logs(conn, params) do
    org_id = conn.assigns[:organization_id]

    case Otel.ingest_logs(params, org_id) do
      {:ok, count} ->
        conn |> put_status(:accepted) |> json(%{accepted: count})

      {:error, :invalid_payload} ->
        conn |> put_status(:bad_request) |> json(%{error: "invalid OTLP payload"})
    end
  end

  # ─────────────────────────────────────────────────────────────────────────
  # Query (JWT auth) — US-098, US-099
  # ─────────────────────────────────────────────────────────────────────────

  # GET /api/v1/organizations/:organization_id/runs/:run_id/otel-spans
  def spans_by_run(conn, %{"organization_id" => org_id, "run_id" => run_id} = params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      limit = parse_int(Map.get(params, "limit"), 500)
      spans = Otel.query_spans_by_run(org_id, run_id, limit: limit)
      json(conn, %{spans: Enum.map(spans, &render_span/1)})
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # GET /api/v1/organizations/:organization_id/otel-spans?attr[llm.model]=gpt-4.1
  def spans_by_attr(conn, %{"organization_id" => org_id} = params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      attrs = normalize_attr_filter(Map.get(params, "attr"))
      limit = parse_int(Map.get(params, "limit"), 100)
      since = parse_dt(Map.get(params, "since"))
      until_ = parse_dt(Map.get(params, "until"))

      spans =
        Otel.query_spans_by_attr(org_id, attrs,
          limit: limit,
          since: since,
          until: until_
        )

      json(conn, %{spans: Enum.map(spans, &render_span/1)})
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ─────────────────────────────────────────────────────────────────────────
  # Sampling policies (JWT auth, admin) — US-132
  # ─────────────────────────────────────────────────────────────────────────

  # GET /api/v1/organizations/:organization_id/otel-sampling-policies
  def list_policies(conn, %{"organization_id" => org_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "admin") do
      policies = Otel.list_policies(org_id)
      json(conn, %{policies: Enum.map(policies, &render_policy/1)})
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # PUT /api/v1/organizations/:organization_id/otel-sampling-policies
  def upsert_policy(conn, %{"organization_id" => org_id, "policy" => attrs}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "admin") do
      case Otel.upsert_policy(org_id, attrs) do
        {:ok, policy} ->
          json(conn, %{policy: render_policy(policy)})

        {:error, %Ecto.Changeset{} = cs} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
      end
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def upsert_policy(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Expected {policy: {name, head_sampling_rate?, tail_rules?, metadata?}}"})
  end

  # ─────────────────────────────────────────────────────────────────────────
  # Log query (JWT auth) — US-100
  # ─────────────────────────────────────────────────────────────────────────

  def logs_by_attr(conn, params) do
    org = conn.assigns.organization
    query = %{
      run_id: params["run_id"],
      attributes: params["attributes"],
      page: params["page"]
    }
    {logs, total} = Otel.search_logs(org.id, query)
    json(conn, %{logs: Enum.map(logs, &render_log/1), total: total})
  end

  # ─────────────────────────────────────────────────────────────────────────
  # Render helpers
  # ─────────────────────────────────────────────────────────────────────────

  defp render_span(s) do
    %{
      id: s.id,
      trace_id: s.trace_id,
      span_id: s.span_id,
      parent_span_id: s.parent_span_id,
      name: s.name,
      kind: s.kind,
      service_name: s.service_name,
      start_time_unix_nano: DateTime.to_unix(s.start_time, :nanosecond) |> Integer.to_string(),
      end_time_unix_nano: DateTime.to_unix(s.end_time, :nanosecond) |> Integer.to_string(),
      duration_ns: DateTime.diff(s.end_time, s.start_time, :nanosecond),
      status_code: s.status_code,
      status_message: s.status_message,
      attributes: s.attributes,
      resource_attributes: s.resource_attributes,
      run_id: s.run_id,
      run_step_id: s.run_step_id
    }
  end

  defp render_policy(p) do
    %{
      id: p.id,
      organization_id: p.organization_id,
      name: p.name,
      sample_rate: p.head_sampling_rate,
      enabled: Map.get(p, :enabled, true),
      tail_rules: p.tail_rules,
      effective_from: p.effective_from,
      metadata: p.metadata,
      inserted_at: p.inserted_at,
      updated_at: p.updated_at
    }
  end

  defp render_log(l) do
    %{
      id: l.id,
      trace_id: l.trace_id,
      span_id: l.span_id,
      run_id: l.run_id,
      severity_text: l.severity_text,
      body: l.body,
      attributes: l.attributes,
      timestamp: l.timestamp
    }
  end

  defp normalize_attr_filter(nil), do: %{}
  defp normalize_attr_filter(m) when is_map(m), do: m
  defp normalize_attr_filter(_), do: %{}

  defp parse_int(nil, default), do: default

  defp parse_int(v, default) when is_binary(v) do
    case Integer.parse(v) do
      {i, _} when i > 0 -> i
      _ -> default
    end
  end

  defp parse_int(v, _default) when is_integer(v) and v > 0, do: v
  defp parse_int(_, default), do: default

  defp parse_dt(nil), do: nil

  defp parse_dt(s) when is_binary(s) do
    case DateTime.from_iso8601(s) do
      {:ok, dt, _} -> dt
      _ -> nil
    end
  end

  defp parse_dt(_), do: nil
end
