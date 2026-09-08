defmodule NoizuPromptLingua.PromptBuilder.Showcase do
  @moduledoc """
  NPL showcase pipeline: turn logged prompts into a public OP-vs-NPL gallery.

  For each pending `prompt_logs` row:
  1. **Rewrite** the user's raw description into a full NPL prompt — the
     rewrite pass runs with the vendored prompt-engineer skill
     (priv/prompt_engineer_skill, copied from the Mac keyboard's VendorSkills)
     embedded at compile time.
  2. **Execute** BOTH prompts (original vs NPL) against one fixed canonical
     test input.
  3. **Judge** with a fixed rubric (structure, clarity, completeness,
     convention adherence, fitness — 0–25 each, total 0–100 per prompt),
     winner, and a difference analysis.
  4. Record everything — outputs, totals, rubric breakdown, OP-vs-NPL context
     sizes (chars + est tokens; the size comparison the user asked for), and
     the analysis — in `showcase_entries`. Prompts are processed ONCE:
     pending → processed | failed, failures recorded in `error`.

  Budget: showcase runs bill the SYSTEM key ("system_showcase") against
  `showcase_daily_cost_cap_usd` — never against a user's IP+session quota.
  Batch entrypoints: `process_batch/1` (admin endpoint + `mix pb.process_showcase`).
  """

  import Ecto.Query
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{PromptLog, ShowcaseEntry}
  alias NoizuPromptLingua.PromptBuilder
  alias NoizuPromptLingua.PromptBuilder.Generator
  alias NoizuPromptLingua.PromptBuilder.Guardrails

  @system_key "system_showcase"

  # ── Vendored skill (compile-time embed) ─────────────────────────────────

  skill_dir = Path.expand("../../../priv/prompt_engineer_skill", __DIR__)

  skill_files = [
    Path.join(skill_dir, "SKILL.md"),
    Path.join(skill_dir, "npl-syntax-reference.md")
  ]

  Enum.each(skill_files, &@external_resource(&1))

  @skill_digest Enum.map_join(skill_files, "\n\n---\n\n", &File.read!/1)

  # Fixed canonical input used for BOTH candidates (fair comparison).
  @canonical_test_input ~S(A new user sends their first message: "Hi — I need help, this is my first time. What can you do for me, and how do we start?")

  @rewrite_system """
  You are the NPL Rewrite pass of the Noizu Prompt Lingua showcase, operating
  under the vendored prompt-engineer skill below. Convert the user's raw prompt
  description into a COMPLETE, production-quality Noizu Prompt Lingua (NPL)
  prompt that preserves the described behavior and, where the description is
  underspecified, fills professional gaps (tone, structure, output format)
  consistent with the skill's philosophy: behavior is the invariant; structure
  beats cleverness.

  Output rules: reply with ONLY the finished NPL prompt text — ⌜NPL@1.0⌝ ...
  ⌞NPL@1.0⌟ frame with :persona/:context/:syntax sections and @directives as
  appropriate. No preamble, no explanation, no code fences, no questions.

  ===================== VENDORED PROMPT-ENGINEER SKILL =====================

  #{@skill_digest}
  """

  @judge_system """
  You are a strict, fixed-rubric prompt evaluator for the Noizu Prompt Lingua
  showcase. Two candidate SYSTEM prompts were each executed against the SAME
  canonical user input. Score BOTH candidates on this rubric, each dimension
  0–25 (0 = absent/broken, 25 = excellent), then total them (0–100):

  - structure: internal organization, instruction hierarchy, unambiguity
  - clarity: a competent model receives an understandable, actionable brief
  - completeness: covers the stated purpose without critical gaps
  - conventions: syntactic discipline (NPL frame/sections/directives count for
    the NPL candidate; coherent formatting counts for the plain one)
  - fitness: whether the candidate's output actually serves the user's message

  Tie rule: if the totals are within 5 points of each other, winner = "tie".
  Reply with ONLY minified JSON, no prose, no code fences:
  {"original": {"structure": 0, "clarity": 0, "completeness": 0, "conventions": 0, "fitness": 0, "total": 0},
   "npl": {"structure": 0, "clarity": 0, "completeness": 0, "conventions": 0, "fitness": 0, "total": 0},
   "winner": "original"|"npl"|"tie",
   "analysis": "<= 120 words on what the NPL rewrite changed and why it did or did not win"}
  """

  # ── Public API ──────────────────────────────────────────────────────────

  @doc "Gallery listing: successful entries, newest first."
  @spec list_entries(keyword()) :: [ShowcaseEntry.t()]
  def list_entries(opts \\ []) do
    limit = Keyword.get(opts, :limit, 50)

    Repo.all(
      from e in ShowcaseEntry,
        where: is_nil(e.error),
        order_by: [desc: e.inserted_at],
        limit: ^limit
    )
  end

  @doc "Pending log count (admin surface)."
  @spec pending_count() :: non_neg_integer()
  def pending_count do
    Repo.one(from l in PromptLog, where: l.showcase_status == "pending", select: count()) || 0
  end

  @doc """
  Process up to `limit` pending logs. Returns {processed, failed, skipped} —
  skipped = budget cap reached (or lost claim races). Each log is claimed by
  flipping pending → processing first, so concurrent batches don't
  double-process; a log is processed at most once per status lifecycle.
  """
  @spec process_batch(pos_integer()) ::
          {:ok, %{processed: non_neg_integer(), failed: non_neg_integer(), skipped: non_neg_integer()}}
  def process_batch(limit \\ 5) when is_integer(limit) and limit > 0 do
    config = PromptBuilder.get_config()

    case system_budget_remaining(config) do
      :ok ->
        logs =
          Repo.all(
            from l in PromptLog,
              where: l.showcase_status == "pending",
              order_by: [asc: l.inserted_at],
              limit: ^limit
          )

        results = Enum.map(logs, &claim_and_process/1)

        {:ok,
         %{
           processed: Enum.count(results, &(&1 == :processed)),
           failed: Enum.count(results, &(&1 == :failed)),
           skipped: Enum.count(results, &(&1 == :skipped))
         }}

      {:error, {:budget_exceeded, _resets}} ->
        {:ok, %{processed: 0, failed: 0, skipped: limit}}
    end
  end

  @doc "Process one log end-to-end. Marks it processed or failed."
  @spec process_log(PromptLog.t()) :: :processed | :failed
  def process_log(%PromptLog{} = log) do
    case run_pipeline(log) do
      {:ok, attrs} ->
        %ShowcaseEntry{}
        |> ShowcaseEntry.changeset(Map.put(attrs, :log_id, log.id))
        |> Repo.insert()

        mark_status(log, "processed")
        :processed

      {:error, reason} ->
        # Failure is recorded, not silent — the entry keeps the original prompt
        # plus the error; the log is marked failed (processed once, per spec).
        %ShowcaseEntry{}
        |> ShowcaseEntry.changeset(%{log_id: log.id, original_prompt: log.description, error: reason_to_text(reason)})
        |> Repo.insert()

        mark_status(log, "failed")
        :failed
    end
  end

  # ── Pipeline ────────────────────────────────────────────────────────────

  defp claim_and_process(log) do
    claimed =
      Repo.update_all(
        from(l in PromptLog, where: l.id == ^log.id and l.showcase_status == "pending"),
        set: [showcase_status: "processing", updated_at: DateTime.utc_now()]
      )

    case claimed do
      {1, _} -> process_log(log)
      {0, _} -> :skipped
    end
  end

  defp run_pipeline(log) do
    config = PromptBuilder.get_config()

    with {:ok, npl_prompt} <- rewrite(log, config),
         {:ok, %{text: original_output}} <- generate(log.description, @canonical_test_input, config),
         {:ok, %{text: npl_output}} <- generate(npl_prompt, @canonical_test_input, config),
         original_output = String.trim(original_output),
         npl_output = String.trim(npl_output),
         {:ok, verdict} <- judge(log.description, npl_prompt, original_output, npl_output) do
      {:ok,
       %{
         original_prompt: log.description,
         original_output: original_output,
         npl_prompt: npl_prompt,
         npl_output: npl_output,
         score_original: get_in(verdict, ["original", "total"]),
         score_npl: get_in(verdict, ["npl", "total"]),
         winner: verdict["winner"],
         ctx_original_chars: String.length(log.description),
         ctx_original_tokens: PromptBuilder.estimate_tokens(log.description),
         ctx_npl_chars: String.length(npl_prompt),
         ctx_npl_tokens: PromptBuilder.estimate_tokens(npl_prompt),
         rubric: %{"original" => verdict["original"], "npl" => verdict["npl"]},
         difference_analysis: verdict["analysis"]
       }}
    end
  end

  # Reasoning models (gpt-oss-120b) intermittently return empty content when
  # reasoning consumes the output budget — validate the rewrite and retry once
  # with a corrective nudge before recording a failure.
  defp rewrite(log, config) do
    case generate(rewrite_system(), rewrite_user_prompt(log), config) do
      {:ok, %{text: text}} ->
        case Guardrails.validate_output(text) do
          {:ok, prompt} ->
            {:ok, prompt}

          {:error, :invalid_output} ->
            case generate(rewrite_system() <> Guardrails.retry_system_suffix(), rewrite_user_prompt(log), config) do
              {:ok, %{text: text2}} ->
                Guardrails.validate_output(text2)

              {:error, reason} ->
                {:error, reason}
            end
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp rewrite_system, do: @rewrite_system

  defp rewrite_user_prompt(log) do
    ctx =
      if log.context in [nil, ""],
        do: "",
        else: "\n\nCONTEXT:\n\"\"\"\n#{String.slice(log.context || "", 0, 2000)}\n\"\"\""

    """
    RAW PROMPT DESCRIPTION (rewrite this as a full NPL prompt):
    \"\"\"
    #{String.slice(log.description, 0, 4000)}
    \"\"\"#{ctx}
    """
  end

  defp judge(original_prompt, npl_prompt, original_output, npl_output) do
    config = PromptBuilder.get_config()

    user = """
    ORIGINAL CANDIDATE (system prompt):
    \"\"\"
    #{String.slice(original_prompt, 0, 4000)}
    \"\"\"

    ORIGINAL OUTPUT:
    \"\"\"
    #{String.slice(original_output, 0, 4000)}
    \"\"\"

    NPL CANDIDATE (system prompt):
    \"\"\"
    #{String.slice(npl_prompt, 0, 8000)}
    \"\"\"

    NPL OUTPUT:
    \"\"\"
    #{String.slice(npl_output, 0, 4000)}
    \"\"\"

    Canonical test input given to both: #{@canonical_test_input}
    Score both per the rubric. JSON verdict only.
    """

    with {:ok, %{text: text}} <- generate(@judge_system, user, config),
         {:ok, decoded} <- decode_verdict(text) do
      {:ok, decoded}
    end
  end

  defp decode_verdict(text) do
    case Regex.run(~r/\{.*\}/s, String.trim(text)) do
      [json] ->
        case Jason.decode(json) do
          {:ok, %{"original" => %{"total" => _}, "npl" => %{"total" => _}, "winner" => w}} when w in ["original", "npl", "tie"] ->
            {:ok, Jason.decode!(json)}

          {:ok, _} ->
            {:error, :unparseable_verdict}

          {:error, _} ->
            {:error, :unparseable_verdict}
        end

      _ ->
        {:error, :unparseable_verdict}
    end
  end

  # Every showcase call bills the SYSTEM key against its own daily cap.
  defp generate(system, user, config) do
    result = Generator.complete(system, user)

    case result do
      {:ok, %{tokens_in: ti, tokens_out: to}} ->
        PromptBuilder.record(@system_key,
          tokens_in: ti,
          tokens_out: to,
          cost: est_cost(config, ti, to)
        )

        result

      _ ->
        result
    end
  end

  defp est_cost(config, tokens_in, tokens_out) do
    Decimal.add(
      Decimal.mult(config.input_price_per_1k_usd, Decimal.new(div(tokens_in, 1000))),
      Decimal.mult(config.output_price_per_1k_usd, Decimal.new(div(tokens_out, 1000)))
    )
  end

  defp system_budget_remaining(config) do
    spent = PromptBuilder.today_cost(@system_key)

    if Decimal.compare(spent, config.showcase_daily_cost_cap_usd) == :lt do
      :ok
    else
      {:error, {:budget_exceeded, PromptBuilder.budget_resets_at()}}
    end
  end

  defp mark_status(log, status) do
    log
    |> PromptLog.changeset(%{showcase_status: status})
    |> Repo.update()
  end

  defp reason_to_text(reason) when is_binary(reason), do: String.slice(reason, 0, 500)

  defp reason_to_text(reason), do: reason |> inspect(limit: 20) |> String.slice(0, 500)
end
