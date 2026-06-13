defmodule CodefreshWeb.ResultsController do
  @moduledoc """
  HTTP endpoints for Stage-6 Results + Dashboards. Read-only over runs with
  a small dashboards write surface (US-130). Every action is tenant-scoped
  via `Organizations.authorize/3`; cross-org ids 404.

  Routes (mounted under `/api/v1/organizations/:organization_id`):

    * `GET /results/runs`                       — list w/ filters (US-025..US-028,079,080)
    * `GET /results/runs/:run_id`               — run detail + timeline (US-029/US-030)
    * `GET /results/runs/:run_id/steps/:idx`    — step detail (US-031)
    * `GET /results/runs/:run_id/freeball`      — freeball chain (US-028)
    * `GET /results/runs/:run_id/expectations`  — per-expectation breakdown (US-079)
    * `GET /results/runs/:run_id/regressions`   — regression vs. prior (US-080)
    * `GET /results/runs/:run_id/export`        — export JSON or CSV (US-032/US-078)
    * `GET /results/runs/diff`                  — diff two runs (US-077)
    * `GET /results/trend`                      — verdict trend chart (US-078)
    * `GET /results/cohort`                     — cohort summary (US-129)
    * `GET /results/dashboards`                 — list saved dashboards (US-130)
    * `POST /results/dashboards`                — create/update dashboard (US-130)
    * `GET /results/dashboards/:id`             — get dashboard detail (US-130)
    * `DELETE /results/dashboards/:id`          — archive dashboard (US-130)
  """

  use CodefreshWeb, :controller

  alias Codefresh.{Results, Organizations}
  alias Codefresh.Results.Dashboard
  alias Codefresh.Guardian

  # ──────────────────────────────────────────────────────────────────────────
  # Runs listing + detail
  # ──────────────────────────────────────────────────────────────────────────

  def index_runs(conn, %{"organization_id" => org_id} = params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      opts = build_list_opts(params)
      runs = Results.list_runs(org_id, opts)
      total = Results.count_runs(org_id, opts)

      json(conn, %{
        runs: Enum.map(runs, &render_run_summary/1),
        pagination: %{
          limit: Keyword.get(opts, :limit, 50),
          offset: Keyword.get(opts, :offset, 0),
          total: total,
          returned: length(runs)
        }
      })
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def show_run(conn, %{"organization_id" => org_id, "run_id" => run_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         %{} = detail <- Results.get_run_detail(org_id, run_id) do
      json(conn, render_run_detail(detail))
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def show_step(conn, %{"organization_id" => org_id, "run_id" => run_id, "step_index" => idx}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         {parsed, ""} <- Integer.parse(idx),
         %{} = detail <- Results.get_step_detail(org_id, run_id, parsed) do
      json(conn, %{
        step: render_step(detail.step, detail.scores),
        scores: Enum.map(detail.scores, &render_score/1),
        freeball_node: detail.freeball_node && render_freeball_node(detail.freeball_node)
      })
    else
      :error -> send_resp(conn, 404, "")
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def show_freeball_chain(conn, %{"organization_id" => org_id, "run_id" => run_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         %{freeball_nodes: nodes} <- Results.get_run_detail(org_id, run_id) do
      json(conn, %{
        run_id: run_id,
        freeball_nodes: Enum.map(nodes, &render_freeball_node/1)
      })
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Analytics endpoints
  # ──────────────────────────────────────────────────────────────────────────

  def expectation_breakdown(conn, %{"organization_id" => org_id, "run_id" => run_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         rows when is_list(rows) <- Results.expectation_breakdown(org_id, run_id) do
      json(conn, %{run_id: run_id, expectations: rows})
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def regressions(conn, %{"organization_id" => org_id, "run_id" => run_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         %{} = report <- Results.regression_report(org_id, run_id) do
      json(conn, report)
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def diff_runs(conn, %{"organization_id" => org_id} = params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         {:ok, a} <- require_param(params, "run_a_id"),
         {:ok, b} <- require_param(params, "run_b_id"),
         {:ok, diff} <- Results.diff_runs(org_id, a, b) do
      json(conn, %{
        left: render_run_detail(diff.left),
        right: render_run_detail(diff.right),
        verdict_comparison: diff.verdict_comparison,
        steps: diff.steps
      })
    else
      {:error, :not_found} -> send_resp(conn, 404, "")
      {:error, :missing_field, f} -> conn |> put_status(:bad_request) |> json(%{error: "#{f} is required"})
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def trend(conn, %{"organization_id" => org_id} = params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      n_days = parse_int(params["days"]) || 14
      n_days = min(max(n_days, 1), 180)
      opts = build_list_opts(params) |> Keyword.drop([:limit, :offset, :since, :until])
      rows = Results.verdict_trend(org_id, n_days, opts)
      json(conn, %{days: n_days, trend: rows})
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def cohort(conn, %{"organization_id" => org_id} = params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      opts = build_list_opts(params) |> Keyword.drop([:limit, :offset])
      summary = Results.cohort_summary(org_id, opts)
      json(conn, summary)
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Export run (US-032 JSON / US-078 CSV)
  # ──────────────────────────────────────────────────────────────────────────

  def export_run(conn, %{"organization_id" => org_id, "run_id" => run_id} = params) do
    user = Guardian.Plug.current_resource(conn)
    format = normalize_format(params["format"])

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         {:ok, data} <- Results.export_run(org_id, run_id, format: format) do
      case format do
        :json ->
          conn
          |> put_resp_content_type("application/json")
          |> put_resp_header(
            "content-disposition",
            "attachment; filename=\"run-#{run_id}.json\""
          )
          |> send_resp(200, data)

        :csv ->
          conn
          |> put_resp_content_type("text/csv")
          |> put_resp_header(
            "content-disposition",
            "attachment; filename=\"run-#{run_id}.csv\""
          )
          |> send_resp(200, data)
      end
    else
      {:error, :not_found} -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Dashboards (US-130)
  # ──────────────────────────────────────────────────────────────────────────

  def index_dashboards(conn, %{"organization_id" => org_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      list = Results.list_dashboards(org_id)
      json(conn, %{dashboards: Enum.map(list, &render_dashboard(&1, hydrate: false))})
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def save_dashboard(conn, %{"organization_id" => org_id, "dashboard" => params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor") do
      attrs =
        params
        |> Map.put("organization_id", org_id)
        |> Map.put_new("created_by_user_id", user.id)
        |> Map.put_new("published_by_user_id", user.id)

      case Results.save_dashboard(attrs) do
        {:ok, d} ->
          conn
          |> put_status(:created)
          |> json(%{dashboard: render_dashboard(d)})

        {:error, %Ecto.Changeset{} = cs} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})

        {:error, :missing_organization} ->
          conn |> put_status(:bad_request) |> json(%{error: "organization_id required"})

        {:error, :invalid_layout} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: "layout must be an object"})

        {:error, reason} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: inspect(reason)})
      end
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def save_dashboard(conn, _) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Expected {dashboard: {name, slug?, description?, layout}}"})
  end

  def show_dashboard(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         %Dashboard{} = d <- Results.get_dashboard(org_id, id) do
      json(conn, %{dashboard: render_dashboard(d)})
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def delete_dashboard(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         %Dashboard{} = d <- Results.get_dashboard(org_id, id),
         {:ok, _archived} <- Results.archive_dashboard(d) do
      send_resp(conn, 204, "")
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")

      {:error, %Ecto.Changeset{} = cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Renderers
  # ──────────────────────────────────────────────────────────────────────────

  defp render_run_summary(r) do
    %{
      id: r.id,
      status: r.status,
      trigger_source: r.trigger_source,
      triggered_by_user_id: r.triggered_by_user_id,
      script_version_id: r.script_version_id,
      agent_version_id: r.agent_version_id,
      started_at: r.started_at,
      finished_at: r.finished_at,
      inserted_at: r.inserted_at,
      summary_metrics: r.summary_metrics || %{},
      retry_parent_run_id: r.retry_parent_run_id
    }
  end

  defp render_run_detail(detail) do
    %{
      run: render_run_summary(detail.run),
      script:
        detail.script &&
          %{
            id: detail.script.id,
            name: detail.script.name,
            slug: detail.script.slug
          },
      script_version_id: detail.run.script_version_id,
      agent:
        detail.agent &&
          %{
            id: detail.agent.id,
            name: detail.agent.name,
            slug: detail.agent.slug
          },
      agent_version_id: detail.run.agent_version_id,
      persona_version_ids: detail.persona_version_ids,
      steps: Enum.map(detail.steps, &render_step_with_scores(&1, detail.step_scores)),
      freeball_nodes: Enum.map(detail.freeball_nodes, &render_freeball_node/1),
      verdict: detail.verdict
    }
  end

  defp render_step_with_scores(step, step_scores_map) do
    scores = Map.get(step_scores_map, step.id, [])
    render_step(step, scores)
  end

  defp render_step(step, scores) do
    %{
      id: step.id,
      step_index: step.step_index,
      status: step.status,
      user_message: step.user_message,
      agent_message: step.agent_message,
      latency_ms: step.latency_ms,
      tokens_in: step.tokens_in,
      tokens_out: step.tokens_out,
      from_node_id: step.from_node_id,
      to_node_id: step.to_node_id,
      edge_id: step.edge_id,
      freeball_node_id: step.freeball_node_id,
      is_freeball: step.status == "freeball",
      scores: Enum.map(scores, &render_score/1)
    }
  end

  defp render_score(sc) do
    %{
      id: sc.id,
      run_step_id: sc.run_step_id,
      expectation_id: sc.expectation_id,
      freeball_expectation_id: sc.freeball_expectation_id,
      rubric_version_id: sc.rubric_version_id,
      scoring_method: sc.scoring_method,
      judge_model: sc.judge_model,
      score: sc.score,
      verdict: sc.verdict,
      rationale: sc.rationale,
      scored_at: sc.scored_at,
      is_freeball: not is_nil(sc.freeball_expectation_id)
    }
  end

  defp render_freeball_node(fb) do
    %{
      id: fb.id,
      sequence: fb.sequence,
      parent_script_node_id: fb.parent_script_node_id,
      parent_freeball_node_id: fb.parent_freeball_node_id,
      prompt_text: fb.prompt_text,
      confidence: fb.confidence,
      runner_model: fb.runner_model,
      review_status: fb.review_status,
      adaptive_depth_policy: fb.adaptive_depth_policy,
      metadata: fb.metadata || %{}
    }
  end

  defp render_dashboard(%Dashboard{} = d, opts \\ []) do
    hydrate? = Keyword.get(opts, :hydrate, true)

    base = %{
      id: d.id,
      organization_id: d.organization_id,
      slug: d.slug,
      name: d.name,
      description: d.description,
      current_version_id: d.current_version_id,
      archived_at: d.archived_at,
      inserted_at: d.inserted_at,
      updated_at: d.updated_at
    }

    if hydrate? do
      Map.put(base, :layout, d.layout || %{})
    else
      base
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Param helpers
  # ──────────────────────────────────────────────────────────────────────────

  defp build_list_opts(params) do
    []
    |> put_opt(:status, split_csv_or_nil(params["status"]))
    |> put_opt(:trigger_source, split_csv_or_nil(params["trigger_source"]))
    |> put_opt(:verdict, split_csv_or_nil(params["verdict"]))
    |> put_opt(:script_id, params["script_id"])
    |> put_opt(:script_version_id, params["script_version_id"])
    |> put_opt(:agent_id, params["agent_id"])
    |> put_opt(:agent_version_id, params["agent_version_id"])
    |> put_opt(:persona_version_id, params["persona_version_id"])
    |> put_opt(:persona_version_ids, split_csv_or_nil(params["persona_version_ids"]))
    |> put_opt(:search, params["search"])
    |> put_opt(:since, parse_datetime(params["since"]))
    |> put_opt(:until, parse_datetime(params["until"]))
    |> put_opt(:limit, parse_int(params["limit"]))
    |> put_opt(:offset, parse_int(params["offset"]))
    |> maybe_put_order(params["order"])
  end

  defp maybe_put_order(opts, "asc"), do: Keyword.put(opts, :order, :asc)
  defp maybe_put_order(opts, _), do: opts

  defp put_opt(opts, _k, nil), do: opts
  defp put_opt(opts, _k, ""), do: opts
  defp put_opt(opts, _k, []), do: opts
  defp put_opt(opts, k, v), do: Keyword.put(opts, k, v)

  defp split_csv_or_nil(nil), do: nil
  defp split_csv_or_nil(""), do: nil

  defp split_csv_or_nil(s) when is_binary(s) do
    case String.split(s, ",", trim: true) |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == "")) do
      [] -> nil
      [only] -> only
      many -> many
    end
  end

  defp split_csv_or_nil(l) when is_list(l), do: l

  defp parse_int(nil), do: nil
  defp parse_int(""), do: nil
  defp parse_int(n) when is_integer(n), do: n

  defp parse_int(s) when is_binary(s) do
    case Integer.parse(s) do
      {n, ""} -> n
      _ -> nil
    end
  end

  defp parse_datetime(nil), do: nil
  defp parse_datetime(""), do: nil

  defp parse_datetime(s) when is_binary(s) do
    case DateTime.from_iso8601(s) do
      {:ok, dt, _} -> dt
      _ -> nil
    end
  end

  defp require_param(params, key) do
    case Map.get(params, key) do
      v when is_binary(v) and v != "" -> {:ok, v}
      _ -> {:error, :missing_field, key}
    end
  end

  defp normalize_format(nil), do: :json
  defp normalize_format(""), do: :json
  defp normalize_format("json"), do: :json
  defp normalize_format("csv"), do: :csv
  defp normalize_format(_), do: :json
end
