defmodule Codefresh.Results do
  @moduledoc """
  Stage-6 read-only query surface for runs, steps, scores, freeball chains,
  and saved dashboards. Covers US-025..US-032 (Wave 1), US-077..US-080 (Wave 2
  diff + dashboards + regressions), US-129..US-130 (Wave 3 cohorts + saved
  dashboards).

  Everything is strictly tenant-scoped on `organization_id` — cross-org reads
  return `nil` so controllers can translate to 404. No writes to runs, steps,
  scores, or freeball_nodes happen here; dashboards are the only write path
  and they live on their own tables (`dashboards` + `dashboard_versions`).
  """

  import Ecto.Query, only: [from: 2]
  alias Ecto.Multi
  alias Codefresh.Repo

  alias Codefresh.Runs
  alias Codefresh.Runs.{Run, RunStep, RunPersona, Score, FreeballNode, FreeballExpectation}
  alias Codefresh.Scripts.{Script, ScriptVersion, Expectation}
  alias Codefresh.Agents.{Agent, AgentVersion}
  alias Codefresh.Results.{Dashboard, DashboardVersion}

  @default_list_limit 50
  @max_list_limit 500

  # ──────────────────────────────────────────────────────────────────────────
  # US-025..US-028, US-079, US-080 — List runs with rich filters
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  List runs for an organization with optional filters + pagination.

  Options:
    * `:status` — string | [string]
    * `:script_id` — filter to runs whose script_version.script_id matches
    * `:script_version_id` — exact version filter
    * `:agent_id` — filter to runs whose agent_version.agent_id matches
    * `:agent_version_id` — exact agent version filter
    * `:persona_version_id` — single persona pin id
    * `:persona_version_ids` — list of persona pin ids (any-of)
    * `:trigger_source` — string | [string]
    * `:since` — `DateTime` lower bound on `inserted_at` (inclusive)
    * `:until` — `DateTime` upper bound on `inserted_at` (inclusive)
    * `:search` — case-insensitive substring on script name
    * `:verdict` — string | [string] — matches `summary_metrics["verdict"]`
    * `:limit` — default 50, capped at 500
    * `:offset` — default 0
    * `:order` — `:desc` (default) | `:asc` on `inserted_at`

  Returns a list of `%Run{}` (no preloads) in the requested order.
  """
  def list_runs(organization_id, opts \\ []) when is_binary(organization_id) do
    limit = opts |> Keyword.get(:limit, @default_list_limit) |> clamp_limit()
    offset = opts |> Keyword.get(:offset, 0) |> max(0)
    order = if Keyword.get(opts, :order) == :asc, do: :asc, else: :desc

    base =
      from r in Run,
        where: r.organization_id == ^organization_id,
        order_by: [{^order, r.inserted_at}],
        limit: ^limit,
        offset: ^offset

    base
    |> maybe_filter_status(opts[:status])
    |> maybe_filter_script_version(opts[:script_version_id])
    |> maybe_filter_script_head(opts[:script_id])
    |> maybe_filter_agent_version(opts[:agent_version_id])
    |> maybe_filter_agent_head(opts[:agent_id])
    |> maybe_filter_persona(opts[:persona_version_id] || opts[:persona_version_ids])
    |> maybe_filter_trigger_source(opts[:trigger_source])
    |> maybe_filter_since(opts[:since])
    |> maybe_filter_until(opts[:until])
    |> maybe_filter_verdict(opts[:verdict])
    |> maybe_filter_search(organization_id, opts[:search])
    |> Repo.all()
  rescue
    Ecto.Query.CastError -> []
  end

  @doc """
  Count runs matching the same filter set as `list_runs/2`. Useful for
  pagination UIs.
  """
  def count_runs(organization_id, opts \\ []) when is_binary(organization_id) do
    base = from r in Run, where: r.organization_id == ^organization_id

    base
    |> maybe_filter_status(opts[:status])
    |> maybe_filter_script_version(opts[:script_version_id])
    |> maybe_filter_script_head(opts[:script_id])
    |> maybe_filter_agent_version(opts[:agent_version_id])
    |> maybe_filter_agent_head(opts[:agent_id])
    |> maybe_filter_persona(opts[:persona_version_id] || opts[:persona_version_ids])
    |> maybe_filter_trigger_source(opts[:trigger_source])
    |> maybe_filter_since(opts[:since])
    |> maybe_filter_until(opts[:until])
    |> maybe_filter_verdict(opts[:verdict])
    |> maybe_filter_search(organization_id, opts[:search])
    |> Repo.aggregate(:count, :id)
  rescue
    Ecto.Query.CastError -> 0
  end

  defp clamp_limit(n) when is_integer(n) and n > 0, do: min(n, @max_list_limit)
  defp clamp_limit(_), do: @default_list_limit

  defp maybe_filter_status(q, nil), do: q
  defp maybe_filter_status(q, ""), do: q
  defp maybe_filter_status(q, s) when is_binary(s), do: from(r in q, where: r.status == ^s)
  defp maybe_filter_status(q, l) when is_list(l) and l != [], do: from(r in q, where: r.status in ^l)
  defp maybe_filter_status(q, _), do: q

  defp maybe_filter_script_version(q, nil), do: q
  defp maybe_filter_script_version(q, ""), do: q

  defp maybe_filter_script_version(q, id) when is_binary(id),
    do: from(r in q, where: r.script_version_id == ^id)

  defp maybe_filter_script_head(q, nil), do: q
  defp maybe_filter_script_head(q, ""), do: q

  defp maybe_filter_script_head(q, script_id) when is_binary(script_id) do
    from r in q,
      join: sv in ScriptVersion,
      on: sv.id == r.script_version_id,
      where: sv.script_id == ^script_id
  end

  defp maybe_filter_agent_version(q, nil), do: q
  defp maybe_filter_agent_version(q, ""), do: q

  defp maybe_filter_agent_version(q, id) when is_binary(id),
    do: from(r in q, where: r.agent_version_id == ^id)

  defp maybe_filter_agent_head(q, nil), do: q
  defp maybe_filter_agent_head(q, ""), do: q

  defp maybe_filter_agent_head(q, agent_id) when is_binary(agent_id) do
    from r in q,
      join: av in AgentVersion,
      on: av.id == r.agent_version_id,
      where: av.agent_id == ^agent_id
  end

  defp maybe_filter_persona(q, nil), do: q
  defp maybe_filter_persona(q, ""), do: q
  defp maybe_filter_persona(q, []), do: q

  defp maybe_filter_persona(q, pid) when is_binary(pid) do
    from r in q,
      where:
        fragment(
          "EXISTS (SELECT 1 FROM run_personas rp WHERE rp.run_id = ? AND rp.persona_version_id = ?)",
          r.id,
          type(^pid, :binary_id)
        )
  end

  defp maybe_filter_persona(q, ids) when is_list(ids) do
    from r in q,
      where:
        fragment(
          "EXISTS (SELECT 1 FROM run_personas rp WHERE rp.run_id = ? AND rp.persona_version_id = ANY(?))",
          r.id,
          type(^ids, {:array, :binary_id})
        )
  end

  defp maybe_filter_trigger_source(q, nil), do: q
  defp maybe_filter_trigger_source(q, ""), do: q

  defp maybe_filter_trigger_source(q, s) when is_binary(s),
    do: from(r in q, where: r.trigger_source == ^s)

  defp maybe_filter_trigger_source(q, l) when is_list(l) and l != [],
    do: from(r in q, where: r.trigger_source in ^l)

  defp maybe_filter_trigger_source(q, _), do: q

  defp maybe_filter_since(q, nil), do: q

  defp maybe_filter_since(q, %DateTime{} = dt),
    do: from(r in q, where: r.inserted_at >= ^dt)

  defp maybe_filter_until(q, nil), do: q

  defp maybe_filter_until(q, %DateTime{} = dt),
    do: from(r in q, where: r.inserted_at <= ^dt)

  defp maybe_filter_verdict(q, nil), do: q
  defp maybe_filter_verdict(q, ""), do: q

  defp maybe_filter_verdict(q, v) when is_binary(v),
    do: from(r in q, where: fragment("?->>'verdict' = ?", r.summary_metrics, ^v))

  defp maybe_filter_verdict(q, l) when is_list(l) and l != [] do
    from r in q, where: fragment("?->>'verdict' = ANY(?)", r.summary_metrics, ^l)
  end

  defp maybe_filter_verdict(q, _), do: q

  defp maybe_filter_search(q, _org_id, nil), do: q
  defp maybe_filter_search(q, _org_id, ""), do: q

  defp maybe_filter_search(q, organization_id, term) when is_binary(term) do
    pattern = "%" <> String.replace(term, ~r/[%_]/, "\\\\\\0") <> "%"

    script_ids =
      Repo.all(
        from s in Script,
          where: s.organization_id == ^organization_id and ilike(s.name, ^pattern),
          select: s.id
      )

    case script_ids do
      [] ->
        # Ensure zero results when search has no matches (don't silently drop filter).
        from(r in q, where: false)

      ids ->
        from r in q,
          join: sv in ScriptVersion,
          on: sv.id == r.script_version_id,
          where: sv.script_id in ^ids
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-029 / US-030 — Run detail with timeline + persona + agent
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Full run detail suitable for the results page. Includes:

    * `run` — the `%Run{}`
    * `script` / `script_version` — head + pinned version
    * `agent` / `agent_version` — head + pinned version
    * `persona_version_ids` — ordered list of pinned personas
    * `steps` — `%RunStep{}` ordered by step_index (the timeline)
    * `step_scores` — map of `run_step_id => [%Score{}]`
    * `freeball_nodes` — ordered freeball chain for the run
    * `verdict` — computed pass/warn/fail + aggregate score + threshold

  Returns `nil` for cross-org or unknown ids.
  """
  def get_run_detail(organization_id, run_id) do
    case Runs.get_run(organization_id, run_id) do
      nil -> nil
      %Run{} = run -> build_run_detail(run)
    end
  end

  defp build_run_detail(%Run{} = run) do
    steps =
      Repo.all(
        from s in RunStep,
          where: s.run_id == ^run.id,
          order_by: [asc: s.step_index]
      )

    step_scores =
      case steps do
        [] ->
          %{}

        _ ->
          ids = Enum.map(steps, & &1.id)

          Repo.all(
            from sc in Score,
              where: sc.run_step_id in ^ids,
              order_by: [asc: sc.inserted_at]
          )
          |> Enum.group_by(& &1.run_step_id)
      end

    freeball_nodes =
      Repo.all(
        from fb in FreeballNode,
          where: fb.run_id == ^run.id,
          order_by: [asc: fb.sequence]
      )

    persona_version_ids =
      Repo.all(
        from rp in RunPersona,
          where: rp.run_id == ^run.id,
          select: rp.persona_version_id
      )

    script_version = Repo.get(ScriptVersion, run.script_version_id)
    script = script_version && Repo.get(Script, script_version.script_id)
    agent_version = Repo.get(AgentVersion, run.agent_version_id)
    agent = agent_version && Repo.get(Agent, agent_version.agent_id)

    %{
      run: run,
      script: script,
      script_version: script_version,
      agent: agent,
      agent_version: agent_version,
      persona_version_ids: persona_version_ids,
      steps: steps,
      step_scores: step_scores,
      freeball_nodes: freeball_nodes,
      verdict: Runs.compute_verdict(run)
    }
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-031 — Step detail with prompt/response/scores
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Single step detail, scoped to the run + organization. Returns
  `%{step: step, scores: [%Score{}], freeball_node: %FreeballNode{} | nil}`
  or `nil` if not found.
  """
  def get_step_detail(organization_id, run_id, step_index)
      when is_binary(organization_id) and is_binary(run_id) and is_integer(step_index) do
    with %Run{} <- Runs.get_run(organization_id, run_id),
         %RunStep{} = step <- Runs.get_step(organization_id, run_id, step_index) do
      scores = Runs.list_step_scores(step)
      fb = step.freeball_node_id && Repo.get(FreeballNode, step.freeball_node_id)
      %{step: step, scores: scores, freeball_node: fb}
    else
      _ -> nil
    end
  end

  def get_step_detail(_org, _run, _idx), do: nil

  # ──────────────────────────────────────────────────────────────────────────
  # US-077 — Cross-run diff
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Diff two runs step-by-step. Both runs must live in `organization_id` or the
  result is `{:error, :not_found}`. Returns
  `{:ok, %{left: run_a_detail, right: run_b_detail, steps: [step_pair, ...]}}`
  where each step_pair is `%{step_index, left, right, score_delta}`.

  Alignment heuristic (US-077 notes): align by `step_index`; if both sides have
  a step at the same index, emit a pair; if only one, emit the populated side
  with the other as nil.
  """
  def diff_runs(organization_id, run_a_id, run_b_id)
      when is_binary(run_a_id) and is_binary(run_b_id) do
    with %Run{} = a <- Runs.get_run(organization_id, run_a_id),
         %Run{} = b <- Runs.get_run(organization_id, run_b_id) do
      left = build_run_detail(a)
      right = build_run_detail(b)

      indices =
        [left.steps, right.steps]
        |> Enum.flat_map(fn list -> Enum.map(list, & &1.step_index) end)
        |> Enum.uniq()
        |> Enum.sort()

      left_by_idx = Map.new(left.steps, &{&1.step_index, &1})
      right_by_idx = Map.new(right.steps, &{&1.step_index, &1})

      step_pairs =
        Enum.map(indices, fn idx ->
          ls = Map.get(left_by_idx, idx)
          rs = Map.get(right_by_idx, idx)

          %{
            step_index: idx,
            left: render_diff_step(ls, left.step_scores),
            right: render_diff_step(rs, right.step_scores),
            score_delta: score_delta(ls, rs, left.step_scores, right.step_scores),
            aligned?: not is_nil(ls) and not is_nil(rs)
          }
        end)

      {:ok,
       %{
         left: left,
         right: right,
         verdict_comparison: %{
           left: left.verdict,
           right: right.verdict
         },
         steps: step_pairs
       }}
    else
      nil -> {:error, :not_found}
    end
  end

  defp render_diff_step(nil, _scores), do: nil

  defp render_diff_step(%RunStep{} = s, scores_map) do
    scores = Map.get(scores_map, s.id, [])

    %{
      id: s.id,
      step_index: s.step_index,
      status: s.status,
      user_message: s.user_message,
      agent_message: s.agent_message,
      from_node_id: s.from_node_id,
      to_node_id: s.to_node_id,
      freeball_node_id: s.freeball_node_id,
      scores: Enum.map(scores, &render_score_map/1)
    }
  end

  defp score_delta(nil, _, _, _), do: nil
  defp score_delta(_, nil, _, _), do: nil

  defp score_delta(%RunStep{id: lid}, %RunStep{id: rid}, ls, rs) do
    l_avg = avg_score(Map.get(ls, lid, []))
    r_avg = avg_score(Map.get(rs, rid, []))

    cond do
      is_nil(l_avg) or is_nil(r_avg) -> nil
      true -> Float.round(r_avg - l_avg, 4)
    end
  end

  defp avg_score([]), do: nil

  defp avg_score(scores) do
    decimals = Enum.filter(scores, &is_struct(&1.score, Decimal))

    case decimals do
      [] ->
        nil

      rows ->
        sum = Enum.reduce(rows, Decimal.new(0), fn s, acc -> Decimal.add(acc, s.score) end)
        Decimal.div(sum, Decimal.new(length(rows))) |> Decimal.to_float()
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-078 — Verdict trend chart
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Verdict counts rolled up per UTC day for the last `n_days` (inclusive of
  today). Returns a list of
  `%{date: Date, pass: int, warn: int, fail: int, other: int, total: int}`
  in chronological order. `other` counts runs in non-terminal statuses or
  with an unknown verdict.

  Additional filter opts mirror `list_runs/2`: `:script_id`, `:agent_id`,
  `:persona_version_id(s)`, `:verdict`.
  """
  def verdict_trend(organization_id, n_days, opts \\ []) when is_integer(n_days) and n_days > 0 do
    today = Date.utc_today()
    since_date = Date.add(today, -(n_days - 1))
    since_dt = DateTime.new!(since_date, ~T[00:00:00], "Etc/UTC")

    base_opts =
      opts
      |> Keyword.put(:since, since_dt)
      |> Keyword.put(:limit, @max_list_limit)

    runs = fetch_all_runs(organization_id, base_opts)

    by_day =
      Enum.group_by(runs, fn r ->
        r.inserted_at
        |> DateTime.to_date()
      end)

    Enum.map(0..(n_days - 1), fn offset ->
      d = Date.add(since_date, offset)
      rows = Map.get(by_day, d, [])

      tally =
        Enum.reduce(rows, %{pass: 0, warn: 0, fail: 0, other: 0}, fn r, acc ->
          case verdict_for(r) do
            "pass" -> Map.update!(acc, :pass, &(&1 + 1))
            "warn" -> Map.update!(acc, :warn, &(&1 + 1))
            "fail" -> Map.update!(acc, :fail, &(&1 + 1))
            _ -> Map.update!(acc, :other, &(&1 + 1))
          end
        end)

      Map.merge(
        %{date: d, total: length(rows)},
        tally
      )
    end)
  end

  defp verdict_for(%Run{status: s, summary_metrics: sm}) do
    case sm && Map.get(sm, "verdict") do
      v when v in ["pass", "warn", "fail"] -> v
      _ -> implicit_verdict(s)
    end
  end

  defp implicit_verdict("passed"), do: "pass"
  defp implicit_verdict("warned"), do: "warn"
  defp implicit_verdict("failed"), do: "fail"
  defp implicit_verdict("errored"), do: "fail"
  defp implicit_verdict(_), do: nil

  # Page through runs up to a hard cap so trend/cohort don't blow the heap.
  defp fetch_all_runs(organization_id, opts) do
    cap = Keyword.get(opts, :cap, 10_000)
    page = @max_list_limit

    Stream.iterate(0, &(&1 + page))
    |> Enum.reduce_while([], fn offset, acc ->
      chunk = list_runs(organization_id, Keyword.merge(opts, limit: page, offset: offset))

      cond do
        chunk == [] -> {:halt, acc}
        length(acc) + length(chunk) >= cap -> {:halt, acc ++ Enum.take(chunk, cap - length(acc))}
        length(chunk) < page -> {:halt, acc ++ chunk}
        true -> {:cont, acc ++ chunk}
      end
    end)
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-129 — Cohort summary
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Summarize a cohort of runs matching the filter set — verdict mix, run count,
  aggregate score distribution, failure rate per script_version.

  Filter opts identical to `list_runs/2`. Returns
  `%{total, verdicts: %{pass, warn, fail, other}, by_script_version: [...],
     avg_score: float | nil}`.
  """
  def cohort_summary(organization_id, opts \\ []) do
    runs = fetch_all_runs(organization_id, Keyword.put_new(opts, :cap, 5_000))

    verdict_tally =
      Enum.reduce(runs, %{pass: 0, warn: 0, fail: 0, other: 0}, fn r, acc ->
        case verdict_for(r) do
          "pass" -> Map.update!(acc, :pass, &(&1 + 1))
          "warn" -> Map.update!(acc, :warn, &(&1 + 1))
          "fail" -> Map.update!(acc, :fail, &(&1 + 1))
          _ -> Map.update!(acc, :other, &(&1 + 1))
        end
      end)

    by_sv =
      runs
      |> Enum.group_by(& &1.script_version_id)
      |> Enum.map(fn {svid, group} ->
        tally =
          Enum.reduce(group, %{pass: 0, warn: 0, fail: 0, other: 0}, fn r, acc ->
            case verdict_for(r) do
              "pass" -> Map.update!(acc, :pass, &(&1 + 1))
              "warn" -> Map.update!(acc, :warn, &(&1 + 1))
              "fail" -> Map.update!(acc, :fail, &(&1 + 1))
              _ -> Map.update!(acc, :other, &(&1 + 1))
            end
          end)

        %{script_version_id: svid, total: length(group)} |> Map.merge(tally)
      end)
      |> Enum.sort_by(& &1.total, :desc)

    avg =
      runs
      |> Enum.map(fn r -> r.summary_metrics |> get_summary_aggregate() end)
      |> Enum.reject(&is_nil/1)
      |> case do
        [] -> nil
        nums -> Float.round(Enum.sum(nums) / length(nums), 4)
      end

    %{
      total: length(runs),
      verdicts: verdict_tally,
      by_script_version: by_sv,
      avg_score: avg
    }
  end

  defp get_summary_aggregate(nil), do: nil

  defp get_summary_aggregate(m) when is_map(m) do
    case Map.get(m, "aggregate") do
      n when is_number(n) -> n * 1.0
      %Decimal{} = d -> Decimal.to_float(d)
      _ -> nil
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-032 — Export run
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Export a run as `:json` (full detail) or `:csv` (one row per step+score).
  For `:csv`, the return is an `iodata`-producing stream of lines. For
  `:json`, a single binary is returned.

  Returns `{:ok, data_or_stream}` | `{:error, :not_found}`.
  """
  def export_run(organization_id, run_id, opts \\ []) do
    format = Keyword.get(opts, :format, :json)

    case get_run_detail(organization_id, run_id) do
      nil -> {:error, :not_found}
      detail -> {:ok, encode_export(detail, format)}
    end
  end

  defp encode_export(detail, :json) do
    Jason.encode!(%{
      run: run_to_map(detail.run),
      script: safe_head_map(detail.script),
      script_version_id: detail.run.script_version_id,
      agent: safe_head_map(detail.agent),
      agent_version_id: detail.run.agent_version_id,
      persona_version_ids: detail.persona_version_ids,
      verdict: detail.verdict,
      steps:
        Enum.map(detail.steps, fn s ->
          %{
            step_index: s.step_index,
            status: s.status,
            user_message: s.user_message,
            agent_message: s.agent_message,
            latency_ms: s.latency_ms,
            tokens_in: s.tokens_in,
            tokens_out: s.tokens_out,
            from_node_id: s.from_node_id,
            to_node_id: s.to_node_id,
            freeball_node_id: s.freeball_node_id,
            scores:
              detail.step_scores
              |> Map.get(s.id, [])
              |> Enum.map(&render_score_map/1)
          }
        end),
      freeball_nodes:
        Enum.map(detail.freeball_nodes, fn fb ->
          %{
            id: fb.id,
            sequence: fb.sequence,
            parent_script_node_id: fb.parent_script_node_id,
            parent_freeball_node_id: fb.parent_freeball_node_id,
            prompt_text: fb.prompt_text,
            confidence: fb.confidence,
            runner_model: fb.runner_model,
            review_status: fb.review_status
          }
        end)
    })
  end

  defp encode_export(detail, :csv) do
    header =
      [
        "run_id",
        "step_index",
        "step_status",
        "from_node_id",
        "to_node_id",
        "freeball_node_id",
        "latency_ms",
        "tokens_in",
        "tokens_out",
        "score_id",
        "expectation_id",
        "freeball_expectation_id",
        "scoring_method",
        "verdict",
        "score",
        "rationale"
      ]
      |> csv_join()

    rows =
      Enum.flat_map(detail.steps, fn s ->
        case Map.get(detail.step_scores, s.id, []) do
          [] ->
            [csv_step_row(detail.run, s, nil)]

          scores ->
            Enum.map(scores, fn sc -> csv_step_row(detail.run, s, sc) end)
        end
      end)

    [header | rows]
    |> Enum.join("\n")
    |> Kernel.<>("\n")
  end

  defp csv_step_row(run, step, nil) do
    [
      run.id,
      step.step_index,
      step.status,
      step.from_node_id,
      step.to_node_id,
      step.freeball_node_id,
      step.latency_ms,
      step.tokens_in,
      step.tokens_out,
      nil,
      nil,
      nil,
      nil,
      nil,
      nil,
      nil
    ]
    |> csv_join()
  end

  defp csv_step_row(run, step, sc) do
    score_str =
      case sc.score do
        %Decimal{} = d -> Decimal.to_string(d, :normal)
        n when is_number(n) -> to_string(n)
        _ -> ""
      end

    [
      run.id,
      step.step_index,
      step.status,
      step.from_node_id,
      step.to_node_id,
      step.freeball_node_id,
      step.latency_ms,
      step.tokens_in,
      step.tokens_out,
      sc.id,
      sc.expectation_id,
      sc.freeball_expectation_id,
      sc.scoring_method,
      sc.verdict,
      score_str,
      sc.rationale
    ]
    |> csv_join()
  end

  defp csv_join(cells) do
    cells
    |> Enum.map(&csv_cell/1)
    |> Enum.join(",")
  end

  defp csv_cell(nil), do: ""
  defp csv_cell(n) when is_integer(n), do: Integer.to_string(n)
  defp csv_cell(n) when is_float(n), do: Float.to_string(n)

  defp csv_cell(%Decimal{} = d), do: Decimal.to_string(d, :normal)

  defp csv_cell(v) when is_binary(v) do
    if String.contains?(v, [",", "\"", "\n", "\r"]) do
      "\"" <> String.replace(v, "\"", "\"\"") <> "\""
    else
      v
    end
  end

  defp csv_cell(v), do: csv_cell(to_string(v))

  defp run_to_map(%Run{} = r) do
    %{
      id: r.id,
      organization_id: r.organization_id,
      script_version_id: r.script_version_id,
      agent_version_id: r.agent_version_id,
      triggered_by_user_id: r.triggered_by_user_id,
      trigger_source: r.trigger_source,
      status: r.status,
      started_at: r.started_at,
      finished_at: r.finished_at,
      inserted_at: r.inserted_at,
      summary_metrics: r.summary_metrics || %{},
      run_config: r.run_config || %{},
      retry_parent_run_id: r.retry_parent_run_id,
      cost_estimate_usd: maybe_decimal(r.cost_estimate_usd),
      cost_cap_usd: maybe_decimal(r.cost_cap_usd),
      trace_id: r.trace_id
    }
  end

  defp safe_head_map(nil), do: nil

  defp safe_head_map(%Script{} = s),
    do: %{id: s.id, name: s.name, slug: s.slug}

  defp safe_head_map(%Agent{} = a),
    do: %{id: a.id, name: a.name, slug: a.slug}

  defp safe_head_map(_), do: nil

  defp render_score_map(%Score{} = sc) do
    %{
      id: sc.id,
      run_step_id: sc.run_step_id,
      expectation_id: sc.expectation_id,
      freeball_expectation_id: sc.freeball_expectation_id,
      rubric_version_id: sc.rubric_version_id,
      scoring_method: sc.scoring_method,
      judge_model: sc.judge_model,
      score: maybe_decimal(sc.score),
      verdict: sc.verdict,
      rationale: sc.rationale,
      scored_at: sc.scored_at
    }
  end

  defp maybe_decimal(nil), do: nil
  defp maybe_decimal(%Decimal{} = d), do: Decimal.to_float(d)
  defp maybe_decimal(v), do: v

  # ──────────────────────────────────────────────────────────────────────────
  # US-079 — Per-expectation score breakdown
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  For a single run, group scores by expectation and return
  `%{expectation_id, label, direction, total, pass, warn, fail, avg_score}`.
  Freeball expectations are grouped under `freeball_expectation_id` keys so
  authored and generated expectations can be shown separately.
  """
  def expectation_breakdown(organization_id, run_id) do
    case Runs.get_run(organization_id, run_id) do
      nil -> nil
      %Run{} = run -> compute_expectation_breakdown(run)
    end
  end

  defp compute_expectation_breakdown(%Run{id: run_id, organization_id: org_id}) do
    scores =
      Repo.all(
        from sc in Score,
          join: step in RunStep,
          on: step.id == sc.run_step_id,
          where: step.run_id == ^run_id and sc.organization_id == ^org_id
      )

    authored_ids =
      scores
      |> Enum.map(& &1.expectation_id)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    freeball_ids =
      scores
      |> Enum.map(& &1.freeball_expectation_id)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    authored_map =
      case authored_ids do
        [] ->
          %{}

        ids ->
          Repo.all(from e in Expectation, where: e.id in ^ids)
          |> Map.new(&{&1.id, &1})
      end

    freeball_map =
      case freeball_ids do
        [] ->
          %{}

        ids ->
          Repo.all(from fe in FreeballExpectation, where: fe.id in ^ids)
          |> Map.new(&{&1.id, &1})
      end

    authored_rows =
      scores
      |> Enum.filter(&(not is_nil(&1.expectation_id)))
      |> Enum.group_by(& &1.expectation_id)
      |> Enum.map(fn {eid, group} ->
        exp = Map.get(authored_map, eid)
        summarize_expectation_group(group, %{
          kind: "authored",
          expectation_id: eid,
          label: exp && exp.label,
          direction: exp && exp.direction
        })
      end)

    freeball_rows =
      scores
      |> Enum.filter(&(not is_nil(&1.freeball_expectation_id)))
      |> Enum.group_by(& &1.freeball_expectation_id)
      |> Enum.map(fn {fid, group} ->
        fe = Map.get(freeball_map, fid)
        summarize_expectation_group(group, %{
          kind: "freeball",
          freeball_expectation_id: fid,
          label: fe && fe.label,
          direction: fe && fe.direction
        })
      end)

    (authored_rows ++ freeball_rows)
    |> Enum.sort_by(& &1.total, :desc)
  end

  defp summarize_expectation_group(scores, base) do
    verdict_counts =
      Enum.reduce(scores, %{pass: 0, warn: 0, fail: 0}, fn s, acc ->
        case s.verdict do
          "pass" -> Map.update!(acc, :pass, &(&1 + 1))
          "warn" -> Map.update!(acc, :warn, &(&1 + 1))
          "fail" -> Map.update!(acc, :fail, &(&1 + 1))
          _ -> acc
        end
      end)

    avg = avg_score(scores)

    base
    |> Map.put(:total, length(scores))
    |> Map.put(:pass, verdict_counts.pass)
    |> Map.put(:warn, verdict_counts.warn)
    |> Map.put(:fail, verdict_counts.fail)
    |> Map.put(:avg_score, avg && Float.round(avg, 4))
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-080 — Regression detection
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  For each expectation that passed in an earlier run of the same script-head
  and fails in `run_id`, emit a regression row. Uses the most recent prior
  terminal run (before `run_id`) on the same `script_id` as the baseline. If
  no baseline exists, returns `%{run_id, baseline_run_id: nil, regressions: []}`.
  """
  def regression_report(organization_id, run_id) when is_binary(run_id) do
    case Runs.get_run(organization_id, run_id) do
      nil ->
        nil

      %Run{} = current ->
        with %ScriptVersion{script_id: sid} <- Repo.get(ScriptVersion, current.script_version_id),
             %Run{} = baseline <- find_regression_baseline(organization_id, sid, current) do
          cur_by_exp = breakdown_by_exp(compute_expectation_breakdown(current))
          base_by_exp = breakdown_by_exp(compute_expectation_breakdown(baseline))

          regressions =
            cur_by_exp
            |> Enum.filter(fn {_key, cur} -> cur.fail > 0 end)
            |> Enum.map(fn {key, cur} ->
              base = Map.get(base_by_exp, key)

              if base && base.fail == 0 and base.total > 0 do
                %{
                  kind: cur.kind,
                  expectation_id: cur[:expectation_id],
                  freeball_expectation_id: cur[:freeball_expectation_id],
                  label: cur.label,
                  direction: cur.direction,
                  baseline_pass: base.pass,
                  baseline_total: base.total,
                  current_fail: cur.fail,
                  current_total: cur.total,
                  score_delta: delta_or_nil(base.avg_score, cur.avg_score)
                }
              end
            end)
            |> Enum.reject(&is_nil/1)

          %{run_id: run_id, baseline_run_id: baseline.id, regressions: regressions}
        else
          _ -> %{run_id: run_id, baseline_run_id: nil, regressions: []}
        end
    end
  end

  defp find_regression_baseline(org_id, script_id, %Run{id: current_id, inserted_at: ts}) do
    Repo.one(
      from r in Run,
        join: sv in ScriptVersion,
        on: sv.id == r.script_version_id,
        where:
          r.organization_id == ^org_id and sv.script_id == ^script_id and
            r.id != ^current_id and r.inserted_at < ^ts and
            r.status in ~w(passed warned failed errored),
        order_by: [desc: r.inserted_at],
        limit: 1
    )
  end

  defp breakdown_by_exp(rows) do
    Map.new(rows, fn row ->
      key =
        cond do
          row[:expectation_id] -> {:authored, row[:expectation_id]}
          row[:freeball_expectation_id] -> {:freeball, row[:freeball_expectation_id]}
          true -> {:unknown, row.label}
        end

      {key, row}
    end)
  end

  defp delta_or_nil(nil, _), do: nil
  defp delta_or_nil(_, nil), do: nil
  defp delta_or_nil(a, b), do: Float.round(b - a, 4)

  # ──────────────────────────────────────────────────────────────────────────
  # US-130 / US-129 — Saved dashboards
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Create or update a saved dashboard + publish a new `dashboard_version` if
  the layout checksum changed.

  Attrs: `%{name, slug?, description?, layout, organization_id,
  created_by_user_id?, published_by_user_id?}`.
  """
  def save_dashboard(attrs, opts \\ []) when is_map(attrs) do
    attrs = stringify(attrs)
    organization_id = attrs["organization_id"]
    layout = Map.get(attrs, "layout") || %{}
    user_id = attrs["created_by_user_id"] || opts[:user_id]

    cond do
      is_nil(organization_id) ->
        {:error, :missing_organization}

      not is_map(layout) ->
        {:error, :invalid_layout}

      true ->
        existing =
          case attrs["id"] do
            id when is_binary(id) -> get_dashboard(organization_id, id)
            _ ->
              slug = Map.get(attrs, "slug") || Dashboard.derive_slug(attrs["name"] || "")
              Repo.get_by(Dashboard, organization_id: organization_id, slug: slug)
          end

        head = existing || %Dashboard{}
        cs = Dashboard.create_changeset(head, Map.put(attrs, "created_by_user_id", user_id))

        Multi.new()
        |> Multi.insert_or_update(:dashboard, cs)
        |> Multi.run(:version, fn _repo, %{dashboard: d} ->
          maybe_publish_version(d, layout, attrs["published_by_user_id"] || user_id)
        end)
        |> Multi.run(:finalize, fn _repo, %{dashboard: d, version: version_result} ->
          case version_result do
            {:new, %DashboardVersion{id: vid}} ->
              d
              |> Dashboard.advance_current_version_changeset(vid)
              |> Repo.update()

            :unchanged ->
              {:ok, d}
          end
        end)
        |> Repo.transaction()
        |> case do
          {:ok, %{finalize: d}} ->
            {:ok, %{d | layout: layout}}

          {:error, :dashboard, cs, _} ->
            {:error, cs}

          {:error, _step, reason, _} ->
            {:error, reason}
        end
    end
  end

  defp maybe_publish_version(%Dashboard{} = d, layout, published_by) do
    checksum = DashboardVersion.compute_checksum(layout)

    latest =
      Repo.one(
        from v in DashboardVersion,
          where: v.dashboard_id == ^d.id,
          order_by: [desc: v.version_number],
          limit: 1
      )

    cond do
      latest && latest.checksum == checksum ->
        {:ok, :unchanged}

      true ->
        next_n = (latest && latest.version_number + 1) || 1

        attrs = %{
          dashboard_id: d.id,
          organization_id: d.organization_id,
          version_number: next_n,
          checksum: checksum,
          layout: layout,
          published_by_user_id: published_by
        }

        %DashboardVersion{}
        |> DashboardVersion.create_changeset(attrs)
        |> Repo.insert()
        |> case do
          {:ok, v} -> {:ok, {:new, v}}
          {:error, cs} -> {:error, cs}
        end
    end
  end

  @doc "List dashboards in an organization."
  def list_dashboards(organization_id) when is_binary(organization_id) do
    Repo.all(
      from d in Dashboard,
        where: d.organization_id == ^organization_id and is_nil(d.archived_at),
        order_by: [asc: d.name]
    )
  end

  @doc """
  Fetch a dashboard by id, hydrating its current layout from the pinned
  `dashboard_version` when present.
  """
  def get_dashboard(organization_id, id) when is_binary(organization_id) and is_binary(id) do
    case Repo.one(
           from d in Dashboard,
             where: d.organization_id == ^organization_id and d.id == ^id
         ) do
      nil ->
        nil

      %Dashboard{current_version_id: nil} = d ->
        %{d | layout: %{}}

      %Dashboard{current_version_id: vid} = d ->
        case Repo.get(DashboardVersion, vid) do
          %DashboardVersion{layout: layout} -> %{d | layout: layout || %{}}
          _ -> %{d | layout: %{}}
        end
    end
  rescue
    Ecto.Query.CastError -> nil
  end

  def get_dashboard(_org, _id), do: nil

  @doc "Archive (soft-delete) a dashboard."
  def archive_dashboard(%Dashboard{} = d) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    d
    |> Ecto.Changeset.change(archived_at: now)
    |> Repo.update()
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Helpers
  # ──────────────────────────────────────────────────────────────────────────

  defp stringify(m) do
    for {k, v} <- m, into: %{}, do: {to_string(k), v}
  end
end
