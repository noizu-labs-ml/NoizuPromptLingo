defmodule Codefresh.Runs.Worker do
  @moduledoc """
  Oban worker that executes a single run end-to-end: walks the script graph,
  invokes the adapter (stubbed — see `Codefresh.Agents.Adapters.Stub`),
  persists steps + scores, creates freeball_node rows on fall-through
  (US-022 / US-023 / US-024), and finalizes the run with a pass/warn/fail
  verdict (US-019).

  Runs on the `:runner` queue. In `:test` Oban is configured as `testing: :manual`
  so jobs must be drained explicitly (`Oban.drain_queue/1`) or the worker can
  be invoked directly via `Codefresh.Runs.Worker.execute_run/1`.
  """

  use Oban.Worker, queue: :runner, max_attempts: 3

  import Ecto.Query, only: [from: 2]
  alias Codefresh.Repo
  alias Codefresh.Runs
  alias Codefresh.Runs.{Run, RunStep, Score, FreeballNode, FreeballExpectation}
  alias Codefresh.Scripts.{ScriptVersion, ScriptNode, ScriptEdge, Expectation}
  alias Codefresh.Agents
  alias Codefresh.Agents.AgentVersion
  alias Codefresh.Runs.Scoring

  # Hard cap on steps per run to prevent runaway cycles in Stage-5 MVP.
  @max_steps 50
  # Default freeball threshold — if no authored edge's confidence >= this, we
  # trigger freeball. Overridable via run_config["freeball_threshold"].
  @default_freeball_threshold 0.5

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"run_id" => run_id}}), do: execute_run(run_id)

  @doc """
  Execute a run to completion (or cancellation). Returns `:ok | {:error, reason}`.
  Safe to call directly from tests.
  """
  def execute_run(run_id) when is_binary(run_id) do
    case Repo.get(Run, run_id) do
      nil ->
        {:error, :run_not_found}

      %Run{status: s} = run when s in ["cancelled", "passed", "failed", "warned", "errored"] ->
        {:ok, run}

      %Run{} = run ->
        with {:ok, started} <- mark_started(run),
             {:ok, version} <- load_version(started),
             {:ok, root_node} <- load_root(version) do
          walk_graph(started, version, root_node, 0, [])
          |> finalize()
        end
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Transition helpers
  # ──────────────────────────────────────────────────────────────────────────

  defp mark_started(%Run{} = run) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    updated =
      run
      |> Run.status_changeset("running", %{started_at: now})
      |> Repo.update!()

    Runs.broadcast(updated, :run_started)
    {:ok, updated}
  end

  defp load_version(%Run{script_version_id: vid}) do
    case Repo.get(ScriptVersion, vid) do
      nil -> {:error, :script_version_missing}
      v -> {:ok, v}
    end
  end

  defp load_root(%ScriptVersion{root_node_id: nil}), do: {:error, :root_node_missing}

  defp load_root(%ScriptVersion{root_node_id: root_id}) do
    case Repo.get(ScriptNode, root_id) do
      nil -> {:error, :root_node_missing}
      n -> {:ok, n}
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Graph walk
  # ──────────────────────────────────────────────────────────────────────────

  # `{:ok, run}` | `{:error, reason, run}` once the walk terminates.
  defp walk_graph(run, _version, _node, step_index, _history) when step_index >= @max_steps do
    {:max_steps, run}
  end

  defp walk_graph(%Run{} = run, %ScriptVersion{} = version, %ScriptNode{} = node, step_index, history) do
    run = Repo.get!(Run, run.id)

    cond do
      run.status == "cancelled" ->
        {:cancelled, run}

      node.kind == "terminal" ->
        # Record a terminal step so the caller can see where the run ended.
        {:ok, _} = record_terminal_step(run, node, step_index)
        {:done, run}

      true ->
        case execute_node(run, version, node, step_index) do
          {:ok, :advance, next_node} ->
            walk_graph(run, version, next_node, step_index + 1, [node.id | history])

          {:ok, :freeball_advance, next_node} ->
            # When there's no next_node (freeball terminates because the parent
            # was not a terminal and no follow-on edge exists), stop.
            if next_node do
              walk_graph(run, version, next_node, step_index + 1, [node.id | history])
            else
              {:done, run}
            end

          {:ok, :done} ->
            {:done, run}

          {:ok, :cancelled_for_cost} ->
            {:cancelled_for_cost, Repo.get!(Run, run.id)}

          {:error, reason, step} ->
            {:error_step, run, reason, step}
        end
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Node execution: invoke adapter, persist step + scores, pick next edge
  # ──────────────────────────────────────────────────────────────────────────

  defp execute_node(%Run{} = run, version, %ScriptNode{} = node, step_index) do
    agent_version = Repo.get!(AgentVersion, run.agent_version_id)

    request = build_request(run, node)

    adapter_mod = adapter_module(agent_version.adapter)
    config = version_to_adapter_config(agent_version)

    start_us = System.monotonic_time(:microsecond)

    case adapter_mod.invoke(config, request) do
      {:ok, response, usage} ->
        latency_ms = div(System.monotonic_time(:microsecond) - start_us, 1000)
        edges = list_outgoing_edges(version, node)

        chosen =
          pick_edge(edges, response, run.run_config)
          |> apply_freeball_policy(node)

        case chosen do
          {:deny_freeball, _} ->
            # US-074: node forbids freeball and no edge matched — hard fail
            {step, _} = persist_step(run, node, request, response, usage, latency_ms, :dead_end)
            Runs.broadcast(run, :step_appended, %{step_id: step.id, step_index: step.step_index})
            score_step(run, node, step, response)
            update_step_fields(step, %{status: "error", error: %{"type" => "strict_no_match"}})
            {:error, %{"type" => "strict_no_match", "reason" => "node forbids freeball"}, step}

          other ->
            {step, _scores} =
              persist_step(run, node, request, response, usage, latency_ms, other)

            Runs.broadcast(run, :step_appended, %{step_id: step.id, step_index: step.step_index})

            score_step(run, node, step, response)

            maybe_accumulate_cost(run, step, agent_version)

            case cost_cap_exceeded?(run) do
              {:exceeded, run2} ->
                # US-067: auto-cancel when accumulated cost exceeds ceiling
                cancel_for_cost!(run2)
                {:ok, :cancelled_for_cost}

              :ok ->
                case other do
                  {:matched, edge, to_node} ->
                    update_step_fields(step, %{
                      edge_id: edge.id,
                      to_node_id: to_node.id,
                      status: "ok"
                    })

                    {:ok, :advance, to_node}

                  :freeball ->
                    handle_freeball(run, version, node, step, response)

                  :dead_end ->
                    # No outgoing edges authored; this is effectively the end of the walk.
                    update_step_fields(step, %{status: "terminal"})
                    {:ok, :done}
                end
            end
        end

      {:error, err} ->
        {:ok, step} = persist_error_step(run, node, request, err, step_index)
        Runs.broadcast(run, :step_appended, %{step_id: step.id, step_index: step.step_index})
        {:error, err, step}
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Freeball policy (US-074 deny / US-075 anchor) — applied AFTER pick_edge
  # ──────────────────────────────────────────────────────────────────────────

  # `"allow"` (default) — no override
  defp apply_freeball_policy(chosen, %ScriptNode{freeball_policy: policy})
       when policy in [nil, "", "allow"],
       do: chosen

  # US-074: deny — reject freeball. If there is no match, signal deny_freeball.
  defp apply_freeball_policy(:freeball, %ScriptNode{freeball_policy: "deny"}),
    do: {:deny_freeball, :no_edge_matched}

  defp apply_freeball_policy(:dead_end, %ScriptNode{freeball_policy: "deny"}),
    do: {:deny_freeball, :no_outgoing_edges}

  # Matched edges are fine under deny.
  defp apply_freeball_policy({:matched, _e, _n} = matched, %ScriptNode{freeball_policy: "deny"}),
    do: matched

  # US-075: anchor — force freeball regardless of match.
  defp apply_freeball_policy(_chosen, %ScriptNode{freeball_policy: "anchor"}),
    do: :freeball

  defp apply_freeball_policy(chosen, _node), do: chosen

  # ──────────────────────────────────────────────────────────────────────────
  # US-067 — run-level cost cap
  # ──────────────────────────────────────────────────────────────────────────

  # Rates (micro-USD per 1k tokens). Tier fallbacks used when explicit
  # rates aren't present in the agent version's request_template.
  @default_rates %{
    "frontier" => %{input: 5_000, output: 15_000},
    "standard" => %{input: 1_000, output: 3_000},
    "cheap" => %{input: 100, output: 300}
  }

  defp maybe_accumulate_cost(%Run{} = run, %RunStep{} = step, %AgentVersion{} = av) do
    cost_cents = step_cost_cents(step, av)

    if cost_cents > 0 do
      run_reloaded = Repo.get!(Run, run.id)
      prior = get_in(run_reloaded.summary_metrics, ["cost_cents"]) || 0
      new_total = prior + cost_cents

      updated_metrics = Map.put(run_reloaded.summary_metrics || %{}, "cost_cents", new_total)

      run_reloaded
      |> Run.summary_changeset(%{summary_metrics: updated_metrics})
      |> Repo.update!()
    else
      :ok
    end
  end

  defp step_cost_cents(%RunStep{tokens_in: ti, tokens_out: to}, %AgentVersion{} = av) do
    ti = ti || 0
    to = to || 0
    {in_rate, out_rate} = rates_for(av)
    # rates are micro-USD per 1k tokens → cents = micro_usd / 10_000
    micro_usd = div(ti * in_rate, 1000) + div(to * out_rate, 1000)
    div(micro_usd, 10_000)
  end

  defp rates_for(%AgentVersion{request_template: tmpl, model_tier: tier}) do
    tmpl = tmpl || %{}

    explicit_in =
      Map.get(tmpl, "cost_input_micro_usd_per_1k") ||
        Map.get(tmpl, "cost_per_1k_input_micro_usd")

    explicit_out =
      Map.get(tmpl, "cost_output_micro_usd_per_1k") ||
        Map.get(tmpl, "cost_per_1k_output_micro_usd")

    default = Map.get(@default_rates, tier || "standard", @default_rates["standard"])

    {
      safe_int(explicit_in, default[:input]),
      safe_int(explicit_out, default[:output])
    }
  end

  defp safe_int(nil, fallback), do: fallback
  defp safe_int(v, _fallback) when is_integer(v), do: v

  defp safe_int(v, fallback) when is_binary(v) do
    case Integer.parse(v) do
      {n, _} -> n
      :error -> fallback
    end
  end

  defp safe_int(_, fallback), do: fallback

  # Returns `{:exceeded, updated_run}` | `:ok`.
  defp cost_cap_exceeded?(%Run{} = run) do
    run = Repo.get!(Run, run.id)
    ceiling = cost_ceiling_cents(run)

    cost = get_in(run.summary_metrics || %{}, ["cost_cents"]) || 0

    if is_integer(ceiling) and ceiling > 0 and cost > ceiling do
      {:exceeded, run}
    else
      :ok
    end
  end

  defp cost_ceiling_cents(%Run{run_config: cfg, agent_version_id: avid}) do
    cfg = cfg || %{}

    case cfg["cost_ceiling_cents"] do
      n when is_integer(n) and n > 0 ->
        n

      n when is_binary(n) ->
        case Integer.parse(n) do
          {v, _} when v > 0 -> v
          _ -> agent_cost_ceiling(avid)
        end

      _ ->
        agent_cost_ceiling(avid)
    end
  end

  defp agent_cost_ceiling(nil), do: nil

  defp agent_cost_ceiling(avid) do
    case Repo.get(AgentVersion, avid) do
      %AgentVersion{request_template: tmpl} when is_map(tmpl) ->
        case Map.get(tmpl, "cost_ceiling_cents") do
          n when is_integer(n) and n > 0 -> n
          _ -> nil
        end

      _ ->
        nil
    end
  end

  defp cancel_for_cost!(%Run{} = run) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    summary =
      Map.merge(run.summary_metrics || %{}, %{
        "verdict" => "fail",
        "reason" => "cost_cap_exceeded",
        "error" => %{"type" => "cost_cap_exceeded"}
      })

    updated =
      run
      |> Run.summary_changeset(%{
        summary_metrics: summary,
        finished_at: now,
        status: "cancelled"
      })
      |> Repo.update!()

    Runs.broadcast(updated, :run_cancelled, %{reason: "cost_cap_exceeded"})
    updated
  end

  defp build_request(run, %ScriptNode{} = node) do
    prompt = resolve_prompt_body(node)

    %{
      prompt: prompt,
      system: nil,
      history: [],
      metadata:
        Map.get(run.run_config, "adapter_metadata") || %{run_id: run.id, node_key: node.node_key}
    }
  end

  defp resolve_prompt_body(%ScriptNode{prompt_version_id: nil, node_key: key}),
    do: "[no prompt attached to node #{key}]"

  defp resolve_prompt_body(%ScriptNode{prompt_version_id: pvid}) do
    case Repo.get(Codefresh.Prompts.PromptVersion, pvid) do
      %Codefresh.Prompts.PromptVersion{body: body} when is_binary(body) -> body
      _ -> "[prompt missing]"
    end
  end

  defp adapter_module(name) do
    Map.get(Agents.adapter_modules(), name) || Codefresh.Agents.Adapters.OpenAI
  end

  defp version_to_adapter_config(%AgentVersion{} = v) do
    %{
      adapter: v.adapter,
      endpoint_url: v.endpoint_url,
      model: v.model,
      auth_ref: v.auth_ref || %{},
      headers: v.headers || %{},
      request_template: v.request_template || %{},
      response_jsonpath: v.response_jsonpath,
      model_tier: v.model_tier
    }
  end

  defp list_outgoing_edges(%ScriptVersion{id: vid}, %ScriptNode{id: nid}) do
    Repo.all(
      from e in ScriptEdge,
        where: e.script_version_id == ^vid and e.from_node_id == ^nid,
        order_by: [asc: e.priority, asc: e.inserted_at]
    )
  end

  # Returns `{:matched, edge, to_node}` | `:freeball` | `:dead_end`.
  defp pick_edge([], _response, _cfg), do: :dead_end

  defp pick_edge(edges, response, cfg) do
    threshold = Map.get(cfg, "freeball_threshold") || @default_freeball_threshold

    scored =
      Enum.map(edges, fn e -> {e, edge_confidence(e, response)} end)

    {best_edge, best_conf} = Enum.max_by(scored, fn {_e, c} -> c end)

    cond do
      best_conf >= threshold ->
        to_node = Repo.get!(ScriptNode, best_edge.to_node_id)
        {:matched, best_edge, to_node}

      true ->
        :freeball
    end
  end

  defp edge_confidence(%ScriptEdge{match_method: "always"}, _response), do: 1.0

  defp edge_confidence(%ScriptEdge{match_method: "regex", match_config: cfg}, response) do
    pattern = Map.get(cfg || %{}, "pattern") || Map.get(cfg || %{}, :pattern) || ""

    case pattern do
      "" ->
        0.0

      p ->
        try do
          if Regex.match?(Regex.compile!(p), response || ""), do: 1.0, else: 0.0
        rescue
          _ -> 0.0
        end
    end
  end

  # semantic / lm_judge / structural / freeball: stubbed at 0 for now (forces
  # freeball fall-through when those are the only options, matching US-022).
  defp edge_confidence(_edge, _response), do: 0.0

  # ──────────────────────────────────────────────────────────────────────────
  # Persist run_step rows
  # ──────────────────────────────────────────────────────────────────────────

  defp persist_step(%Run{} = run, %ScriptNode{} = node, request, response, usage, latency_ms, chosen) do
    {status, to_node_id, edge_id, freeball_node_id} =
      case chosen do
        {:matched, edge, to_node} -> {"ok", to_node.id, edge.id, nil}
        :freeball -> {"freeball", nil, nil, nil}
        :dead_end -> {"terminal", nil, nil, nil}
      end

    attrs = %{
      run_id: run.id,
      organization_id: run.organization_id,
      step_index: next_step_index(run),
      from_node_id: node.id,
      to_node_id: to_node_id,
      edge_id: edge_id,
      freeball_node_id: freeball_node_id,
      user_message: request.prompt,
      agent_message: response,
      agent_raw: %{"usage" => usage},
      latency_ms: latency_ms,
      tokens_in: Map.get(usage, :input_tokens, 0),
      tokens_out: Map.get(usage, :output_tokens, 0),
      status: status
    }

    step =
      %RunStep{}
      |> RunStep.create_changeset(attrs)
      |> Repo.insert!()

    {step, []}
  end

  defp persist_error_step(%Run{} = run, %ScriptNode{} = node, request, err, _step_index) do
    attrs = %{
      run_id: run.id,
      organization_id: run.organization_id,
      step_index: next_step_index(run),
      from_node_id: node.id,
      user_message: request.prompt,
      status: "error",
      error: to_string_keys(err)
    }

    step =
      %RunStep{}
      |> RunStep.create_changeset(attrs)
      |> Repo.insert!()

    {:ok, step}
  end

  defp record_terminal_step(%Run{} = run, %ScriptNode{} = node, _step_index) do
    attrs = %{
      run_id: run.id,
      organization_id: run.organization_id,
      step_index: next_step_index(run),
      from_node_id: node.id,
      to_node_id: node.id,
      status: "terminal",
      user_message: "[terminal: #{node.node_key}]"
    }

    step =
      %RunStep{}
      |> RunStep.create_changeset(attrs)
      |> Repo.insert!()

    {:ok, step}
  end

  defp next_step_index(%Run{id: run_id}) do
    (Repo.one(from s in RunStep, where: s.run_id == ^run_id, select: max(s.step_index)) || -1) + 1
  end

  defp update_step_fields(%RunStep{} = step, attrs) do
    step
    |> Ecto.Changeset.change(Map.new(attrs))
    |> Repo.update!()
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Scoring — evaluate each expectation on the node, persist a scores row
  # ──────────────────────────────────────────────────────────────────────────

  defp score_step(%Run{} = run, %ScriptNode{} = node, %RunStep{} = step, response) do
    expectations =
      Repo.all(from e in Expectation, where: e.script_node_id == ^node.id)

    Enum.each(expectations, fn e ->
      result = Scoring.evaluate(e, response || "")

      %Score{}
      |> Score.create_changeset(%{
        run_step_id: step.id,
        organization_id: run.organization_id,
        expectation_id: e.id,
        rubric_version_id: e.rubric_version_id,
        scoring_method: e.scoring_method,
        score: Decimal.from_float(result.score * 1.0),
        verdict: result.verdict,
        rationale: result.rationale,
        raw_output: result.raw_output,
        scored_at: DateTime.utc_now() |> DateTime.truncate(:second)
      })
      |> Repo.insert!()
    end)
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Freeball fall-through (US-022, US-023, US-024)
  # ──────────────────────────────────────────────────────────────────────────

  defp handle_freeball(%Run{} = run, %ScriptVersion{} = version, %ScriptNode{} = parent_node, %RunStep{} = step, response) do
    # For Stage 5: create a freeball_node anchored at parent_node with a
    # minimal generated prompt + one runtime-generated expectation. A real
    # generator runs in Stage 6. We pull the next node (if any) from the
    # outgoing edges regardless of confidence, preferring the highest-priority
    # one — that captures the "runner resumes with freeball-generated prompt"
    # contract without recursing indefinitely.

    sequence = next_freeball_sequence(run.id)

    fb =
      %FreeballNode{}
      |> FreeballNode.create_changeset(%{
        run_id: run.id,
        organization_id: run.organization_id,
        parent_script_node_id: parent_node.id,
        sequence: sequence,
        prompt_text:
          "[freeball-generated from #{parent_node.node_key}]\nAgent response: #{String.slice(response || "", 0, 200)}",
        confidence: Decimal.new("0.500"),
        runner_model: "stub-runner",
        review_status: "pending",
        metadata: %{"reason" => "no_edge_matched"}
      })
      |> Repo.insert!()

    # Seed one default freeball expectation for test coverage.
    fe =
      %FreeballExpectation{}
      |> FreeballExpectation.create_changeset(%{
        freeball_node_id: fb.id,
        organization_id: run.organization_id,
        label: "response is non-empty",
        weight: Decimal.new("1.000"),
        direction: "positive",
        scoring_method: "regex",
        config: %{"pattern" => ".+"},
        confidence: Decimal.new("0.700")
      })
      |> Repo.insert!()

    # Score the freeball expectation against the *same* step so users can see
    # what the runner thought (US-024 — see freeball confidence).
    result = Scoring.evaluate(fe, response || "")

    %Score{}
    |> Score.create_changeset(%{
      run_step_id: step.id,
      organization_id: run.organization_id,
      freeball_expectation_id: fe.id,
      scoring_method: fe.scoring_method,
      score: Decimal.from_float(result.score * 1.0),
      verdict: result.verdict,
      rationale: "[freeball] " <> result.rationale,
      raw_output: result.raw_output,
      scored_at: DateTime.utc_now() |> DateTime.truncate(:second)
    })
    |> Repo.insert!()

    update_step_fields(step, %{freeball_node_id: fb.id, status: "freeball"})

    Runs.broadcast(run, :freeball_created, %{
      freeball_node_id: fb.id,
      parent_script_node_id: parent_node.id
    })

    # Try to advance to the highest-priority outgoing edge (if any) so the
    # walk progresses. If none, we're done.
    edges = list_outgoing_edges(version, parent_node)

    case edges do
      [] ->
        {:ok, :done}

      [best | _] ->
        to_node = Repo.get!(ScriptNode, best.to_node_id)
        {:ok, :freeball_advance, to_node}
    end
  end

  defp next_freeball_sequence(run_id) do
    (Repo.one(
       from fn_node in FreeballNode,
         where: fn_node.run_id == ^run_id,
         select: max(fn_node.sequence)
     ) || 0) + 1
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Finalize — compute verdict, set summary_metrics, transition to terminal
  # ──────────────────────────────────────────────────────────────────────────

  defp finalize({:done, %Run{} = run}), do: finalize_run(run)
  defp finalize({:max_steps, %Run{} = run}), do: finalize_run(run, extra: %{"reason" => "max_steps"})
  defp finalize({:cancelled, %Run{} = run}), do: {:ok, run}
  defp finalize({:cancelled_for_cost, %Run{} = run}), do: {:ok, run}

  defp finalize({:error_step, %Run{} = run, err, _step}) do
    finalize_errored(run, err)
  end

  defp finalize({:error, _reason} = err), do: err

  defp finalize_run(%Run{} = run, opts \\ []) do
    extra = Keyword.get(opts, :extra, %{})

    %{verdict: v, aggregate: agg, threshold: thr} = Runs.compute_verdict(run)

    summary =
      run.summary_metrics
      |> Map.merge(%{
        "verdict" => v,
        "aggregate_score" => agg,
        "threshold" => thr
      })
      |> Map.merge(extra)

    status =
      case v do
        "pass" -> "passed"
        "warn" -> "warned"
        "fail" -> "failed"
      end

    now = DateTime.utc_now() |> DateTime.truncate(:second)

    updated =
      run
      |> Run.summary_changeset(%{
        summary_metrics: summary,
        finished_at: now,
        status: status
      })
      |> Repo.update!()

    Runs.broadcast(updated, :run_finished, %{verdict: v, status: status})
    schedule_autoflag(updated)
    {:ok, updated}
  end

  defp schedule_autoflag(%Run{id: id}) do
    _ = Codefresh.AutoFlag.schedule_eval(id)
    :ok
  rescue
    _ -> :ok
  end

  defp finalize_errored(%Run{} = run, err) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    summary =
      Map.merge(run.summary_metrics || %{}, %{
        "verdict" => "fail",
        "error" => to_string_keys(err)
      })

    updated =
      run
      |> Run.summary_changeset(%{
        summary_metrics: summary,
        finished_at: now,
        status: "errored"
      })
      |> Repo.update!()

    Runs.broadcast(updated, :run_errored, %{error: to_string_keys(err)})
    schedule_autoflag(updated)
    {:ok, updated}
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Misc
  # ──────────────────────────────────────────────────────────────────────────

  defp to_string_keys(m) when is_map(m) do
    for {k, v} <- m, into: %{}, do: {to_string(k), v}
  end

  defp to_string_keys(other), do: %{"message" => inspect(other)}
end
