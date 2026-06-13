defmodule Codefresh.AutoFlag do
  @moduledoc """
  Context for automated flagging rules (US-147) and the post-run evaluation
  pipeline that turns rule matches into `flagged_captures` rows attributed to
  the rule (`auto_rule_id` set, `flagged_by_user_id` nil).

  Evaluation walks a completed run's `run_steps` + correlated `otel_spans` and
  applies every active, same-org rule. Matches are deduplicated within a
  single evaluation pass so a rule never produces more than one capture per
  run_step. Cross-org safety: `list_rules/1` and the evaluator filter on
  `organization_id` — passing a run from a different org is a no-op.
  """

  import Ecto.Query, only: [from: 2]
  alias Codefresh.Repo
  alias Codefresh.AutoFlag.Rule
  alias Codefresh.Datasets
  alias Codefresh.Runs.{Run, RunStep, Score}
  alias Codefresh.Otel.Span

  # ──────────────────────────────────────────────────────────────────────────
  # CRUD
  # ──────────────────────────────────────────────────────────────────────────

  def create_rule(organization_id, attrs) when is_binary(organization_id) and is_map(attrs) do
    attrs =
      attrs
      |> stringify_keys()
      |> Map.put("organization_id", organization_id)

    %Rule{}
    |> Rule.create_changeset(attrs)
    |> Repo.insert()
  end

  def update_rule(%Rule{} = rule, attrs) do
    rule |> Rule.update_changeset(attrs) |> Repo.update()
  end

  def soft_delete_rule(%Rule{} = rule) do
    rule |> Rule.soft_delete_changeset() |> Repo.update()
  end

  @doc """
  List rules for an org. `include_deleted: true` to include soft-deleted rows;
  `only_enabled: true` to return only live + enabled rules.
  """
  def list_rules(organization_id, opts \\ []) do
    include_deleted = Keyword.get(opts, :include_deleted, false)
    only_enabled = Keyword.get(opts, :only_enabled, false)

    q =
      from r in Rule,
        where: r.organization_id == ^organization_id,
        order_by: [asc: r.name]

    q
    |> maybe_hide_deleted(include_deleted)
    |> maybe_only_enabled(only_enabled)
    |> Repo.all()
  end

  defp maybe_hide_deleted(q, true), do: q
  defp maybe_hide_deleted(q, false), do: from(r in q, where: is_nil(r.soft_deleted_at))

  defp maybe_only_enabled(q, false), do: q
  defp maybe_only_enabled(q, true), do: from(r in q, where: r.enabled == true)

  def get_rule(organization_id, id) do
    Repo.one(
      from r in Rule,
        where: r.organization_id == ^organization_id and r.id == ^id
    )
  rescue
    Ecto.Query.CastError -> nil
  end

  def get_rule!(organization_id, id) do
    case get_rule(organization_id, id) do
      nil -> raise Ecto.NoResultsError, queryable: Rule
      r -> r
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Scheduling + evaluation
  # ──────────────────────────────────────────────────────────────────────────

  @doc """
  Enqueue an Oban job that will evaluate this run's steps against every active
  rule in its org. In `:test` (Oban `testing: :manual`) the job sits in the
  queue until drained — tests may call `eval_rules_against_run/1` directly.
  """
  def schedule_eval(run_id) when is_binary(run_id) do
    case Codefresh.AutoFlag.Worker.new(%{"run_id" => run_id}) |> Oban.insert() do
      {:ok, job} -> {:ok, job}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Run the evaluator synchronously. Returns
  `{:ok, %{rules_applied: n, captures_created: m}}`.
  """
  def eval_rules_against_run(run_id) when is_binary(run_id) do
    case Repo.get(Run, run_id) do
      nil ->
        {:error, :run_not_found}

      %Run{} = run ->
        eval_rules_against_run(run, list_rules(run.organization_id, only_enabled: true))
    end
  end

  def eval_rules_against_run(%Run{} = run, rules) when is_list(rules) do
    steps =
      Repo.all(
        from s in RunStep,
          where: s.run_id == ^run.id,
          order_by: [asc: s.step_index]
      )

    spans_by_step = load_spans_by_step(run)
    scores_by_step = load_scores_by_step(steps)

    {captures_created, _seen} =
      Enum.reduce(rules, {0, MapSet.new()}, fn rule, {acc_count, seen} ->
        {n, seen} =
          Enum.reduce(steps, {0, seen}, fn step, {count, seen_inner} ->
            key = {rule.id, step.id}

            cond do
              MapSet.member?(seen_inner, key) ->
                {count, seen_inner}

              evaluate_rule(rule, step, Map.get(spans_by_step, step.id, []), Map.get(scores_by_step, step.id, [])) ->
                case create_auto_capture(rule, run, step) do
                  {:ok, _cap} ->
                    bump_match_count!(rule, 1)
                    {count + 1, MapSet.put(seen_inner, key)}

                  _ ->
                    {count, MapSet.put(seen_inner, key)}
                end

              true ->
                {count, seen_inner}
            end
          end)

        {acc_count + n, seen}
      end)

    {:ok, %{rules_applied: length(rules), captures_created: captures_created}}
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Rule evaluation — pure predicates
  # ──────────────────────────────────────────────────────────────────────────

  defp evaluate_rule(%Rule{rule_type: "score_threshold", config: cfg}, _step, _spans, scores) do
    threshold = numeric(cfg, ["score_below"])

    cond do
      is_nil(threshold) -> false
      scores == [] -> false
      true ->
        Enum.any?(scores, fn s ->
          case s.score do
            %Decimal{} = d -> Decimal.compare(d, Decimal.from_float(threshold * 1.0)) == :lt
            n when is_number(n) -> n < threshold
            _ -> false
          end
        end)
    end
  end

  defp evaluate_rule(%Rule{rule_type: "regex", config: cfg}, step, _spans, _scores) do
    target = Map.get(cfg, "target") || "response"
    pattern = Map.get(cfg, "pattern") || ""

    subject =
      case target do
        "input" -> step.user_message || ""
        _ -> step.agent_message || ""
      end

    case safe_compile(pattern) do
      {:ok, re} -> Regex.match?(re, subject)
      _ -> false
    end
  end

  defp evaluate_rule(%Rule{rule_type: "attribute_equals", config: cfg}, _step, spans, _scores) do
    attr = Map.get(cfg, "attribute") || ""
    value = Map.get(cfg, "value")

    Enum.any?(spans, fn span ->
      case Map.get(span.attributes || %{}, attr) do
        nil -> false
        v -> attr_equals?(v, value)
      end
    end)
  end

  defp evaluate_rule(%Rule{rule_type: "attribute_contains", config: cfg}, _step, spans, _scores) do
    attr = Map.get(cfg, "attribute") || ""
    sub = Map.get(cfg, "substring") || ""

    Enum.any?(spans, fn span ->
      case Map.get(span.attributes || %{}, attr) do
        v when is_binary(v) -> String.contains?(v, sub)
        _ -> false
      end
    end)
  end

  defp evaluate_rule(%Rule{rule_type: "latency_exceeds_ms", config: cfg}, step, spans, _scores) do
    threshold = numeric(cfg, ["threshold_ms"])

    cond do
      is_nil(threshold) ->
        false

      is_integer(step.latency_ms) and step.latency_ms >= threshold ->
        true

      true ->
        Enum.any?(spans, fn span ->
          case span.duration_ns do
            n when is_integer(n) -> div(n, 1_000_000) >= threshold
            _ -> false
          end
        end)
    end
  end

  defp evaluate_rule(%Rule{rule_type: "token_count_exceeds", config: cfg}, step, _spans, _scores) do
    threshold = numeric(cfg, ["threshold"])
    total = (step.tokens_in || 0) + (step.tokens_out || 0)

    if is_nil(threshold), do: false, else: total >= threshold
  end

  defp evaluate_rule(_rule, _step, _spans, _scores), do: false

  defp attr_equals?(v, target) when is_binary(v) and is_binary(target), do: v == target
  defp attr_equals?(v, target) when is_number(v) and is_number(target), do: v == target
  defp attr_equals?(v, target) when is_boolean(v) and is_boolean(target), do: v == target
  defp attr_equals?(v, target), do: to_string(v) == to_string(target)

  defp safe_compile(pattern) do
    Regex.compile(pattern)
  rescue
    _ -> :error
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Data loaders
  # ──────────────────────────────────────────────────────────────────────────

  defp load_spans_by_step(%Run{id: run_id, organization_id: org_id}) do
    Repo.all(
      from s in Span,
        where: s.organization_id == ^org_id and s.run_id == ^run_id and not is_nil(s.run_step_id)
    )
    |> Enum.group_by(& &1.run_step_id)
  end

  defp load_scores_by_step([]), do: %{}

  defp load_scores_by_step(steps) do
    step_ids = Enum.map(steps, & &1.id)

    Repo.all(from sc in Score, where: sc.run_step_id in ^step_ids)
    |> Enum.group_by(& &1.run_step_id)
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Capture emission
  # ──────────────────────────────────────────────────────────────────────────

  defp create_auto_capture(%Rule{} = rule, %Run{} = run, %RunStep{} = step) do
    attrs = %{
      "organization_id" => run.organization_id,
      "title" => "[auto:#{rule.name}] run=#{String.slice(run.id, 0, 8)} step=#{step.step_index}",
      "reason" => rule.default_reason,
      "tags" => Enum.uniq((rule.default_tags || []) ++ ["auto-flag"]),
      "notes" => auto_notes(rule),
      "source_trace_id" => step.trace_id,
      "source_span_id" => step.span_id,
      "source_run_step_id" => step.id,
      "input" => %{"text" => step.user_message || ""},
      "agent_response" => %{"text" => step.agent_message || ""},
      "captured_attributes" => %{
        "rule_type" => rule.rule_type,
        "rule_config" => rule.config,
        "run_id" => run.id
      },
      "auto_rule_id" => rule.id
    }

    Datasets.flag_capture(attrs)
  end

  defp auto_notes(%Rule{rule_type: type, config: cfg}) do
    "Auto-flagged by rule (#{type}). Config: #{inspect(cfg)}"
  end

  defp bump_match_count!(%Rule{} = rule, by) do
    from(r in Rule, where: r.id == ^rule.id)
    |> Repo.update_all(inc: [match_count: by])
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Helpers
  # ──────────────────────────────────────────────────────────────────────────

  defp numeric(cfg, keys) do
    Enum.find_value(keys, fn k ->
      case Map.get(cfg, k) || Map.get(cfg, to_string(k)) do
        nil -> nil
        n when is_number(n) -> n
        s when is_binary(s) ->
          case Float.parse(s) do
            {f, ""} -> f
            _ -> nil
          end

        _ ->
          nil
      end
    end)
  end

  defp stringify_keys(m) do
    for {k, v} <- m, into: %{} do
      {if(is_atom(k), do: Atom.to_string(k), else: k), v}
    end
  end
end
