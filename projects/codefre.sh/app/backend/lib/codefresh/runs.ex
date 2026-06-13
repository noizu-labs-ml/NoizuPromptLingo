defmodule Codefresh.Runs do
  @moduledoc """
  Context for the Stage-5 runner: trigger one-off runs (US-015), stream status
  updates via Phoenix.PubSub (US-016), inspect steps + scores (US-017 / US-020),
  cancel in-flight runs (US-018), compute pass/warn/fail verdicts (US-019),
  retry failures (US-021 / US-066), and persist freeball fall-through
  (US-022 / US-023 / US-024).

  The executor lives in `Codefresh.Runs.Worker` (Oban `:runner` queue).
  """

  import Ecto.Query, only: [from: 2]
  alias Ecto.Multi
  alias Codefresh.Repo

  alias Codefresh.Runs.{
    Run,
    RunPersona,
    RunStep,
    Score,
    FreeballNode,
    FreeballExpectation,
    Worker
  }

  alias Codefresh.Scripts.{Script, ScriptVersion}
  alias Codefresh.Agents
  alias Codefresh.Agents.{Agent, AgentVersion}
  alias Codefresh.Personas

  @pubsub Codefresh.PubSub

  # ──────────────────────────────────────────────────────────────────────────
  # US-015 — Trigger a one-off run
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Trigger a run for the published version of `script` against the given
  `agent_id`'s current version. Cross-org is rejected as `{:error, :not_found}`.

  Options:
    * `:persona_version_ids` — list of persona_version ids to pin (US-036 / US-052)
    * `:run_config` — map stored on the run (timeouts, thresholds, freeball budget)
    * `:triggered_by_user_id` — optional user id
    * `:trigger_source` — `"manual"` (default) | `"scheduled"` | `"api"` | `"cli"`
    * `:enqueue` — whether to enqueue the Oban job (default true)
    * `:batch_agent_version_ids` — list of agent ids (US-070); fans out to N runs
    * `:batch_persona_version_ids` — list of persona_version ids (US-052); one run per persona

  Returns `{:ok, run}` for single-run; `{:ok, [run1, run2, ...]}` for batch modes.
  """
  def trigger_run(%Script{} = script, agent_id, opts \\ []) when is_binary(agent_id) do
    cond do
      is_list(opts[:batch_agent_version_ids]) and opts[:batch_agent_version_ids] != [] ->
        trigger_batch_agents(script, opts[:batch_agent_version_ids], opts)

      is_list(opts[:batch_persona_version_ids]) and opts[:batch_persona_version_ids] != [] ->
        trigger_batch_personas(script, agent_id, opts[:batch_persona_version_ids], opts)

      true ->
        do_trigger_run(script, agent_id, opts)
    end
  end

  defp do_trigger_run(%Script{} = script, agent_id, opts) do
    organization_id = script.organization_id

    with {:ok, script_version} <- resolve_script_version(script),
         {:ok, agent_version} <- resolve_agent_version(organization_id, agent_id),
         {:ok, persona_ids} <- validate_persona_scope(organization_id, opts[:persona_version_ids] || []) do
      run_attrs = %{
        organization_id: organization_id,
        script_version_id: script_version.id,
        agent_version_id: agent_version.id,
        triggered_by_user_id: opts[:triggered_by_user_id],
        trigger_source: opts[:trigger_source] || "manual",
        status: "pending",
        run_config: opts[:run_config] || %{},
        retry_parent_run_id: opts[:retry_parent_run_id]
      }

      Multi.new()
      |> Multi.insert(:run, Run.create_changeset(%Run{}, run_attrs))
      |> Multi.run(:personas, fn _repo, %{run: run} ->
        insert_personas(run, persona_ids)
      end)
      |> Repo.transaction()
      |> case do
        {:ok, %{run: run}} ->
          maybe_enqueue(run, Keyword.get(opts, :enqueue, true))
          broadcast(run, :run_created)
          {:ok, run}

        {:error, :run, cs, _} ->
          {:error, cs}

        {:error, _step, reason, _} ->
          {:error, reason}
      end
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-070 — Batch fan-out across agents
  # ──────────────────────────────────────────────────────────────────────────

  defp trigger_batch_agents(%Script{} = script, agent_ids, opts)
       when is_list(agent_ids) do
    batch_id =
      opts[:batch_id] || Ecto.UUID.generate()

    base_config = opts[:run_config] || %{}
    tagged_config = Map.merge(base_config, %{"batch_id" => batch_id, "batch_kind" => "agents"})

    # Strip batch keys so per-run trigger isn't re-dispatched as a batch.
    per_run_opts =
      opts
      |> Keyword.delete(:batch_agent_version_ids)
      |> Keyword.delete(:batch_persona_version_ids)
      |> Keyword.put(:run_config, tagged_config)

    agent_ids
    |> Enum.reduce_while({:ok, []}, fn aid, {:ok, acc} ->
      case do_trigger_run(script, aid, per_run_opts) do
        {:ok, %Run{} = r} -> {:cont, {:ok, [r | acc]}}
        {:error, reason} -> {:halt, {:error, {:batch_member_failed, aid, reason}}}
      end
    end)
    |> case do
      {:ok, runs} -> {:ok, Enum.reverse(runs)}
      err -> err
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-052 — Fan-out across personas
  # ──────────────────────────────────────────────────────────────────────────

  defp trigger_batch_personas(%Script{} = script, agent_id, persona_ids, opts)
       when is_list(persona_ids) do
    batch_id = opts[:batch_id] || Ecto.UUID.generate()

    base_config = opts[:run_config] || %{}
    tagged_config = Map.merge(base_config, %{"batch_id" => batch_id, "batch_kind" => "personas"})

    per_run_opts =
      opts
      |> Keyword.delete(:batch_agent_version_ids)
      |> Keyword.delete(:batch_persona_version_ids)
      |> Keyword.put(:run_config, tagged_config)

    persona_ids
    |> Enum.reduce_while({:ok, []}, fn pid, {:ok, acc} ->
      run_opts = Keyword.put(per_run_opts, :persona_version_ids, [pid])

      case do_trigger_run(script, agent_id, run_opts) do
        {:ok, %Run{} = r} -> {:cont, {:ok, [r | acc]}}
        {:error, reason} -> {:halt, {:error, {:batch_member_failed, pid, reason}}}
      end
    end)
    |> case do
      {:ok, runs} -> {:ok, Enum.reverse(runs)}
      err -> err
    end
  end

  defp resolve_script_version(%Script{current_version_id: nil}), do: {:error, :not_published}

  defp resolve_script_version(%Script{} = script) do
    case Repo.get(ScriptVersion, script.current_version_id) do
      nil -> {:error, :not_published}
      %ScriptVersion{yaml_source: nil} -> {:error, :not_published}
      %ScriptVersion{} = v -> {:ok, v}
    end
  end

  defp resolve_agent_version(organization_id, agent_id) do
    case Agents.get_agent(organization_id, agent_id) do
      nil -> {:error, :not_found}
      %Agent{current_version_id: nil} -> {:error, :agent_not_published}
      %Agent{current_version_id: vid} -> {:ok, Repo.get!(AgentVersion, vid)}
    end
  end

  defp validate_persona_scope(_org_id, []), do: {:ok, []}

  defp validate_persona_scope(org_id, ids) when is_list(ids) do
    bad = Enum.find(ids, fn id -> not Personas.pinnable?(org_id, id) end)

    if bad, do: {:error, {:persona_not_pinnable, bad}}, else: {:ok, ids}
  end

  defp insert_personas(_run, []), do: {:ok, []}

  defp insert_personas(%Run{} = run, ids) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    rows =
      Enum.map(ids, fn pvid ->
        %{
          run_id: run.id,
          organization_id: run.organization_id,
          persona_version_id: pvid,
          inserted_at: now
        }
      end)

    case Repo.insert_all(Codefresh.Runs.RunPersona, rows, returning: [:id]) do
      {n, inserted} when n == length(rows) -> {:ok, inserted}
      other -> {:error, {:run_persona_insert_failed, other}}
    end
  end

  defp maybe_enqueue(_run, false), do: :ok

  defp maybe_enqueue(%Run{id: run_id}, true) do
    %{"run_id" => run_id}
    |> Worker.new(queue: :runner)
    |> Oban.insert()
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-018 — Cancel in-flight run
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Cancel a run. No-ops if the run is already in a terminal status.
  Returns `{:ok, run}` (with possibly-unchanged status) or `{:error, reason}`.
  """
  def cancel_run(%Run{} = run, _opts \\ []) do
    cond do
      terminal?(run) ->
        {:ok, run}

      true ->
        now = DateTime.utc_now() |> DateTime.truncate(:second)

        run
        |> Run.status_changeset("cancelled", %{finished_at: now})
        |> Repo.update()
        |> case do
          {:ok, cancelled} ->
            broadcast(cancelled, :run_cancelled)
            {:ok, cancelled}

          err ->
            err
        end
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-021 / US-066 — Retry a failed run
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Retry a run in an errored/failed terminal state. The new run pins the same
  script_version + agent_version + personas; `retry_parent_run_id` records
  lineage. Returns `{:ok, new_run}` | `{:error, reason}`.

  Only runs with terminal status `errored|failed|cancelled` can be retried;
  a still-running or passed run returns `{:error, :not_retryable}`.
  """
  def retry_run(%Run{} = parent, opts \\ []) do
    cond do
      parent.status not in ~w(errored failed cancelled) ->
        {:error, :not_retryable}

      true ->
        persona_ids = list_persona_version_ids(parent)

        trigger_attrs = [
          persona_version_ids: persona_ids,
          run_config: Map.put(parent.run_config || %{}, "retry_parent_run_id", parent.id),
          retry_parent_run_id: parent.id,
          triggered_by_user_id: opts[:triggered_by_user_id],
          trigger_source: opts[:trigger_source] || "manual",
          enqueue: Keyword.get(opts, :enqueue, true)
        ]

        with {:ok, script_head} <- resolve_script_head_from_version(parent.script_version_id),
             {:ok, agent_head} <- resolve_agent_head_from_version(parent.agent_version_id) do
          trigger_run(script_head, agent_head.id, trigger_attrs)
        end
    end
  end

  defp resolve_script_head_from_version(script_version_id) do
    case Repo.get(ScriptVersion, script_version_id) do
      nil -> {:error, :parent_script_version_missing}
      %ScriptVersion{script_id: sid} -> {:ok, Repo.get!(Script, sid)}
    end
  end

  defp resolve_agent_head_from_version(agent_version_id) do
    case Repo.get(AgentVersion, agent_version_id) do
      nil -> {:error, :parent_agent_version_missing}
      %AgentVersion{agent_id: aid} -> {:ok, Repo.get!(Agent, aid)}
    end
  end

  defp list_persona_version_ids(%Run{id: rid}) do
    Repo.all(
      from rp in RunPersona,
        where: rp.run_id == ^rid,
        select: rp.persona_version_id
    )
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Listing + fetch
  # ──────────────────────────────────────────────────────────────────────────

  def list_runs(organization_id, opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)

    q =
      from r in Run,
        where: r.organization_id == ^organization_id,
        order_by: [desc: r.inserted_at],
        limit: ^limit

    q
    |> maybe_filter_status(opts[:status])
    |> maybe_filter_script(opts[:script_version_id])
    |> maybe_filter_agent(opts[:agent_version_id])
    |> Repo.all()
  end

  defp maybe_filter_status(q, nil), do: q
  defp maybe_filter_status(q, ""), do: q

  defp maybe_filter_status(q, statuses) when is_list(statuses),
    do: from(r in q, where: r.status in ^statuses)

  defp maybe_filter_status(q, status) when is_binary(status),
    do: from(r in q, where: r.status == ^status)

  defp maybe_filter_script(q, nil), do: q
  defp maybe_filter_script(q, id), do: from(r in q, where: r.script_version_id == ^id)

  defp maybe_filter_agent(q, nil), do: q
  defp maybe_filter_agent(q, id), do: from(r in q, where: r.agent_version_id == ^id)

  def get_run(organization_id, id) do
    Repo.one(from r in Run, where: r.id == ^id and r.organization_id == ^organization_id)
  rescue
    Ecto.Query.CastError -> nil
  end

  def get_run!(organization_id, id) do
    case get_run(organization_id, id) do
      nil -> raise Ecto.NoResultsError, queryable: Run
      r -> r
    end
  end

  def list_steps(%Run{id: run_id}) do
    Repo.all(
      from s in RunStep,
        where: s.run_id == ^run_id,
        order_by: [asc: s.step_index]
    )
  end

  def get_step(organization_id, run_id, step_index) when is_integer(step_index) do
    Repo.one(
      from s in RunStep,
        where:
          s.run_id == ^run_id and s.organization_id == ^organization_id and
            s.step_index == ^step_index
    )
  end

  def list_step_scores(%RunStep{id: step_id}) do
    Repo.all(from sc in Score, where: sc.run_step_id == ^step_id, order_by: [asc: sc.inserted_at])
  end

  @doc """
  Render a run with its steps, freeball nodes, and aggregated scores for the
  run detail view (US-017).
  """
  def render_run_detail(%Run{} = run) do
    steps = list_steps(run)

    step_scores =
      case steps do
        [] ->
          %{}

        _ ->
          step_ids = Enum.map(steps, & &1.id)

          Repo.all(
            from sc in Score,
              where: sc.run_step_id in ^step_ids,
              order_by: [asc: sc.inserted_at]
          )
          |> Enum.group_by(& &1.run_step_id)
      end

    freeball_nodes =
      Repo.all(
        from fn_node in FreeballNode,
          where: fn_node.run_id == ^run.id,
          order_by: [asc: fn_node.sequence]
      )

    personas =
      Repo.all(
        from rp in RunPersona,
          where: rp.run_id == ^run.id,
          select: rp.persona_version_id
      )

    %{
      run: run,
      steps: steps,
      step_scores: step_scores,
      freeball_nodes: freeball_nodes,
      persona_version_ids: personas
    }
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-019 — Compute pass/warn/fail verdict for a run
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Compute a run verdict given the current scores and step statuses. Rules
  (US-019):

    * Any step with status `"error"` → `"fail"`
    * Any `verdict == "fail"` score on a `direction="negative"` expectation → `"fail"`
    * Aggregate score below `run_config["threshold"]` (default 0.85) → `"fail"`
    * Within `[threshold, threshold+0.05]` → `"warn"`
    * Above → `"pass"`

  Returns `%{verdict: verdict, aggregate: float | nil, threshold: float}`.

  Used by `Worker.finalize_run/1` and directly by tests.
  """
  def compute_verdict(%Run{} = run) do
    threshold =
      run.run_config
      |> Map.get("threshold")
      |> to_float(0.85)

    steps = list_steps(run)
    any_error? = Enum.any?(steps, &(&1.status == "error"))

    scores =
      case steps do
        [] ->
          []

        _ ->
          ids = Enum.map(steps, & &1.id)
          Repo.all(from sc in Score, where: sc.run_step_id in ^ids)
      end

    any_negative_fail? =
      Enum.any?(scores, fn sc ->
        sc.verdict == "fail" and negative_expectation?(sc)
      end)

    aggregate =
      case Enum.filter(scores, &is_struct(&1.score, Decimal)) do
        [] -> nil
        rows -> avg_decimal(Enum.map(rows, & &1.score))
      end

    verdict =
      cond do
        any_error? -> "fail"
        any_negative_fail? -> "fail"
        aggregate == nil -> if steps == [], do: "pass", else: "warn"
        aggregate < threshold -> "fail"
        aggregate < threshold + 0.05 -> "warn"
        true -> "pass"
      end

    %{verdict: verdict, aggregate: aggregate, threshold: threshold}
  end

  defp negative_expectation?(%Score{expectation_id: nil, freeball_expectation_id: fid})
       when not is_nil(fid) do
    case Repo.get(FreeballExpectation, fid) do
      %FreeballExpectation{direction: "negative"} -> true
      _ -> false
    end
  end

  defp negative_expectation?(%Score{expectation_id: eid}) when not is_nil(eid) do
    case Repo.get(Codefresh.Scripts.Expectation, eid) do
      %Codefresh.Scripts.Expectation{direction: "negative"} -> true
      _ -> false
    end
  end

  defp negative_expectation?(_), do: false

  defp avg_decimal([]), do: nil

  defp avg_decimal(decimals) do
    sum = Enum.reduce(decimals, Decimal.new(0), &Decimal.add/2)
    n = Decimal.new(length(decimals))
    Decimal.div(sum, n) |> Decimal.to_float()
  end

  defp to_float(nil, default), do: default
  defp to_float(%Decimal{} = d, _), do: Decimal.to_float(d)
  defp to_float(n, _) when is_number(n), do: n * 1.0
  defp to_float(_, default), do: default

  # ──────────────────────────────────────────────────────────────────────────
  # PubSub (US-016)
  # ──────────────────────────────────────────────────────────────────────────

  @doc "Topic for a run's live updates. Used by LiveView/channels later."
  def topic(%Run{id: id}), do: "run:#{id}"
  def topic(id) when is_binary(id), do: "run:#{id}"

  def subscribe(%Run{} = run), do: Phoenix.PubSub.subscribe(@pubsub, topic(run))
  def subscribe(id) when is_binary(id), do: Phoenix.PubSub.subscribe(@pubsub, topic(id))

  @doc false
  def broadcast(%Run{} = run, event, payload \\ %{}) do
    Phoenix.PubSub.broadcast(@pubsub, topic(run), {event, Map.put(payload, :run_id, run.id)})
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Helpers used by Worker
  # ──────────────────────────────────────────────────────────────────────────

  @doc false
  def terminal?(%Run{status: s}), do: s in Run.terminal_statuses()

  @doc false
  def transition_to!(%Run{} = run, status, attrs \\ %{}) do
    run
    |> Run.status_changeset(status, attrs)
    |> Repo.update!()
  end
end
