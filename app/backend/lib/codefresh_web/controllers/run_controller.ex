defmodule CodefreshWeb.RunController do
  @moduledoc """
  HTTP endpoints for Stage-5 runner + freeball. Mirrors `AgentController`
  auth conventions: `viewer` role reads, `editor` role triggers/cancels/retries.

  Endpoints (all nested under `/organizations/:organization_id`):

    * `POST   /runs`                     — trigger a run (US-015)
    * `GET    /runs`                     — list runs (US-016 list surface)
    * `GET    /runs/:id`                 — run detail with steps + freeball nodes (US-017)
    * `GET    /runs/:id/steps/:idx`      — single step + its scores (US-017, US-020)
    * `POST   /runs/:id/cancel`          — cancel in-flight (US-018)
    * `POST   /runs/:id/retry`           — retry errored/failed run (US-021 / US-066)
    * `GET    /runs/:id/freeball-nodes`  — freeball-distinct view (US-023, US-024)
  """

  use CodefreshWeb, :controller

  alias Codefresh.{Runs, Organizations, Scripts}
  alias Codefresh.Runs.Run
  alias Codefresh.Guardian

  # ──────────────────────────────────────────────────────────────────────────
  # US-015 — Trigger a run
  # ──────────────────────────────────────────────────────────────────────────

  def create(conn, %{"organization_id" => org_id, "run" => params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         {:ok, script_id} <- require_field(params, "script_id"),
         {:ok, agent_id} <- require_field(params, "agent_id"),
         script when not is_nil(script) <- safe_get_script(org_id, script_id) do
      opts =
        [triggered_by_user_id: user.id]
        |> maybe_put(:persona_version_ids, params["persona_version_ids"])
        |> maybe_put(:run_config, params["run_config"])
        |> maybe_put(:trigger_source, params["trigger_source"])

      case Runs.trigger_run(script, agent_id, opts) do
        {:ok, run} ->
          conn
          |> put_status(:created)
          |> json(%{run: render_run(run)})

        {:error, :not_found} ->
          send_resp(conn, 404, "")

        {:error, :not_published} ->
          conn
          |> put_status(:conflict)
          |> json(%{error: "script has no published version"})

        {:error, :agent_not_published} ->
          conn
          |> put_status(:conflict)
          |> json(%{error: "agent has no published version"})

        {:error, {:persona_not_pinnable, pid}} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "persona_version not pinnable", persona_version_id: pid})

        {:error, %Ecto.Changeset{} = cs} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})

        {:error, reason} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: inspect(reason)})
      end
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
      {:error, :missing_field, f} -> conn |> put_status(:bad_request) |> json(%{error: "#{f} is required"})
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Expected {run: {script_id, agent_id, persona_version_ids?, run_config?, trigger_source?}}"})
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Listing + detail (US-016, US-017)
  # ──────────────────────────────────────────────────────────────────────────

  def index(conn, %{"organization_id" => org_id} = params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      opts =
        []
        |> maybe_put(:status, normalize_status(params["status"]))
        |> maybe_put(:script_version_id, params["script_version_id"])
        |> maybe_put(:agent_version_id, params["agent_version_id"])
        |> maybe_put(:limit, parse_int(params["limit"]))

      runs = Runs.list_runs(org_id, opts)
      json(conn, %{runs: Enum.map(runs, &render_run/1)})
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def show(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         %Run{} = run <- safe_get_run(org_id, id) do
      detail = Runs.render_run_detail(run)

      json(conn, %{
        run: render_run(detail.run),
        steps: Enum.map(detail.steps, &render_step(&1, detail.step_scores)),
        freeball_nodes: Enum.map(detail.freeball_nodes, &render_freeball_node/1),
        persona_version_ids: detail.persona_version_ids
      })
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def show_step(conn, %{"organization_id" => org_id, "id" => run_id, "step_index" => idx}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         %Run{} = _run <- safe_get_run(org_id, run_id),
         {parsed, ""} when is_integer(parsed) <- parse_int_strict(idx),
         step when not is_nil(step) <- Runs.get_step(org_id, run_id, parsed) do
      scores = Runs.list_step_scores(step)

      json(conn, %{
        step: render_step(step, %{step.id => scores}),
        scores: Enum.map(scores, &render_score/1)
      })
    else
      nil -> send_resp(conn, 404, "")
      :error -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-018 — Cancel
  # ──────────────────────────────────────────────────────────────────────────

  def cancel(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         %Run{} = run <- safe_get_run(org_id, id),
         {:ok, cancelled} <- Runs.cancel_run(run) do
      json(conn, %{run: render_run(cancelled)})
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
  # US-021 / US-066 — Retry
  # ──────────────────────────────────────────────────────────────────────────

  def retry(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         %Run{} = run <- safe_get_run(org_id, id) do
      case Runs.retry_run(run, triggered_by_user_id: user.id) do
        {:ok, new_run} ->
          conn
          |> put_status(:created)
          |> json(%{run: render_run(new_run), retry_parent_run_id: run.id})

        {:error, :not_retryable} ->
          conn
          |> put_status(:conflict)
          |> json(%{error: "run is not in a retryable terminal state"})

        {:error, reason} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: inspect(reason)})
      end
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-023 / US-024 — Freeball-distinct surface
  # ──────────────────────────────────────────────────────────────────────────

  def list_steps(conn, %{"id" => run_id} = params) do
    org_id = params["organization_id"]
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         %Run{} = run <- safe_get_run(org_id, run_id) do
      steps = Runs.list_run_steps(run)
      json(conn, %{steps: Enum.map(steps, &render_step_flat/1)})
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def list_scores(conn, %{"id" => run_id} = params) do
    org_id = params["organization_id"]
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         %Run{} = run <- safe_get_run(org_id, run_id) do
      scores = Runs.list_run_scores(run)
      json(conn, %{scores: Enum.map(scores, &render_score/1)})
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def freeball_nodes(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         %Run{} = run <- safe_get_run(org_id, id) do
      detail = Runs.render_run_detail(run)

      json(conn, %{
        run_id: run.id,
        freeball_nodes: Enum.map(detail.freeball_nodes, &render_freeball_node/1)
      })
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Renderers
  # ──────────────────────────────────────────────────────────────────────────

  defp render_run(%Run{} = r) do
    %{
      id: r.id,
      organization_id: r.organization_id,
      script_version_id: r.script_version_id,
      agent_version_id: r.agent_version_id,
      trigger_source: r.trigger_source,
      triggered_by_user_id: r.triggered_by_user_id,
      status: r.status,
      started_at: r.started_at,
      finished_at: r.finished_at,
      summary_metrics: r.summary_metrics || %{},
      run_config: r.run_config || %{},
      trace_id: r.trace_id,
      retry_parent_run_id: r.retry_parent_run_id,
      cost_estimate_usd: r.cost_estimate_usd,
      cost_cap_usd: r.cost_cap_usd,
      inserted_at: r.inserted_at,
      short_id: String.slice(r.id, 0, 8),
      script_id: if(Map.get(r, :script_version) && r.script_version, do: r.script_version.script_id, else: nil),
      script_name: if(Map.get(r, :script_version) && r.script_version && Map.get(r.script_version, :script) && r.script_version.script, do: r.script_version.script.name, else: nil),
      script_version_number: if(Map.get(r, :script_version) && r.script_version, do: r.script_version.version_number, else: nil),
      agent_id: if(Map.get(r, :agent_version) && r.agent_version, do: r.agent_version.agent_id, else: nil),
      agent_name: if(Map.get(r, :agent_version) && r.agent_version && Map.get(r.agent_version, :agent) && r.agent_version.agent, do: r.agent_version.agent.name, else: nil),
      agent_version_number: if(Map.get(r, :agent_version) && r.agent_version, do: r.agent_version.version_number, else: nil),
      persona_id: nil,
      persona_name: nil,
      verdict: get_in(r.summary_metrics || %{}, ["verdict"]),
      score: get_in(r.summary_metrics || %{}, ["score"]),
      duration_ms: if(r.started_at && r.finished_at, do: DateTime.diff(r.finished_at, r.started_at, :millisecond), else: nil)
    }
  end

  defp render_step(step, step_scores) do
    scores = Map.get(step_scores, step.id, [])

    %{
      id: step.id,
      step_index: step.step_index,
      status: step.status,
      from_node_id: step.from_node_id,
      to_node_id: step.to_node_id,
      edge_id: step.edge_id,
      freeball_node_id: step.freeball_node_id,
      user_message: step.user_message,
      agent_message: step.agent_message,
      latency_ms: step.latency_ms,
      tokens_in: step.tokens_in,
      tokens_out: step.tokens_out,
      trace_id: step.trace_id,
      span_id: step.span_id,
      error: step.error,
      inserted_at: step.inserted_at,
      scores: Enum.map(scores, &render_score/1),
      is_freeball: step.status == "freeball"
    }
  end

  # Flat message-shaped render used by list_steps (frontend voice+content shape)
  defp render_step_flat(step) do
    %{
      id: step.id,
      run_id: step.run_id,
      script_node_id: step.to_node_id || step.from_node_id,
      sequence: step.step_index,
      voice: cond do
        step.agent_message != nil -> "agent"
        step.user_message != nil -> "author"
        true -> "evaluator"
      end,
      content: step.agent_message || step.user_message || "",
      verdict: Map.get(step, :status, nil),
      rationale: nil,
      score: nil,
      started_at: step.inserted_at,
      finished_at: nil,
      duration_ms: step.latency_ms
    }
  end

  defp render_score(sc) do
    %{
      id: sc.id,
      run_id: if(Map.get(sc, :run_step) && sc.run_step, do: sc.run_step.run_id, else: nil),
      run_step_id: sc.run_step_id,
      expectation_id: sc.expectation_id,
      label: if(Map.get(sc, :expectation) && sc.expectation, do: sc.expectation.label, else: "score"),
      value: if(is_struct(sc.score, Decimal), do: Decimal.to_float(sc.score), else: sc.score),
      verdict: sc.verdict,
      rationale: sc.rationale,
      freeball_expectation_id: sc.freeball_expectation_id,
      rubric_version_id: sc.rubric_version_id,
      scoring_method: sc.scoring_method,
      judge_model: sc.judge_model,
      scored_at: sc.scored_at,
      is_freeball: not is_nil(sc.freeball_expectation_id)
    }
  end

  defp render_freeball_node(fb) do
    %{
      id: fb.id,
      run_id: fb.run_id,
      sequence: fb.sequence,
      parent_script_node_id: fb.parent_script_node_id,
      parent_freeball_node_id: fb.parent_freeball_node_id,
      prompt_text: fb.prompt_text,
      confidence: fb.confidence,
      runner_model: fb.runner_model,
      review_status: fb.review_status,
      metadata: fb.metadata || %{},
      adaptive_depth_policy: fb.adaptive_depth_policy,
      inserted_at: fb.inserted_at
    }
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Helpers
  # ──────────────────────────────────────────────────────────────────────────

  defp safe_get_run(org_id, id) do
    Runs.get_run(org_id, id)
  rescue
    Ecto.Query.CastError -> nil
  end

  defp safe_get_script(org_id, id) do
    Scripts.get_script(org_id, id)
  rescue
    Ecto.Query.CastError -> nil
  end

  defp require_field(params, k) do
    case Map.get(params, k) do
      v when is_binary(v) and v != "" -> {:ok, v}
      _ -> {:error, :missing_field, k}
    end
  end

  defp maybe_put(opts, _k, nil), do: opts
  defp maybe_put(opts, _k, ""), do: opts
  defp maybe_put(opts, _k, []), do: opts
  defp maybe_put(opts, k, v), do: Keyword.put(opts, k, v)

  defp normalize_status(nil), do: nil
  defp normalize_status(""), do: nil
  defp normalize_status(s) when is_binary(s), do: s
  defp normalize_status(list) when is_list(list), do: list
  defp normalize_status(_), do: nil

  defp parse_int(nil), do: nil
  defp parse_int(""), do: nil
  defp parse_int(n) when is_integer(n), do: n

  defp parse_int(s) when is_binary(s) do
    case Integer.parse(s) do
      {n, ""} -> n
      _ -> nil
    end
  end

  defp parse_int_strict(s) when is_binary(s), do: Integer.parse(s)
  defp parse_int_strict(_), do: :error
end
