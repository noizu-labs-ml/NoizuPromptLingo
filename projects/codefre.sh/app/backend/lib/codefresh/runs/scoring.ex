defmodule Codefresh.Runs.Scoring do
  @moduledoc """
  Evaluate expectations against a step's agent output. Stage-5 implementations:

    * `"regex"` — `Regex.match?/2` over `config["pattern"]`; pass=1.0, fail=0.0.
    * `"rubric"` — delegates to `Codefresh.Rubrics.Scoring.weighted_average/2`
      when `config["subscores"]` is supplied (test hook); otherwise stub.
    * `"lm_judge"` / `"semantic"` / `"structural"` — stub to `0.5` with
      `rationale: "not_implemented"`. Real implementations land in Stage 6.

  Returns `%{score: float, verdict: "pass"|"warn"|"fail", rationale: binary,
              raw_output: map}`.

  Pure — no Ecto, no Repo. Composable with freeball_expectations (same shape).
  """

  alias Codefresh.Rubrics.Scoring, as: RubricScoring

  @type result :: %{
          score: float(),
          verdict: String.t(),
          rationale: String.t(),
          raw_output: map()
        }

  @doc """
  Evaluate one expectation-like row (either %Expectation{} or
  %FreeballExpectation{}) against the agent_message text.

  The `direction` field (`"positive"` | `"negative"`) flips the verdict:
  a `negative` expectation that matches is a FAIL.
  """
  def evaluate(expectation, agent_message, opts \\ [])

  def evaluate(expectation, agent_message, opts)
      when is_binary(agent_message) do
    method = Map.get(expectation, :scoring_method)
    direction = Map.get(expectation, :direction) || "positive"
    config = Map.get(expectation, :config) || %{}

    base = dispatch(method, config, agent_message, opts)
    apply_direction(base, direction)
  end

  def evaluate(_expectation, nil, _opts),
    do: %{score: 0.0, verdict: "fail", rationale: "no agent_message", raw_output: %{}}

  # ──────────────────────────────────────────────────────────────────────────
  # Method dispatch
  # ──────────────────────────────────────────────────────────────────────────

  defp dispatch("regex", config, message, _opts) do
    pattern = Map.get(config, "pattern") || Map.get(config, :pattern) || ""

    case compile_regex(pattern) do
      {:ok, re} ->
        if Regex.match?(re, message) do
          %{score: 1.0, verdict: "pass", rationale: "regex matched", raw_output: %{pattern: pattern}}
        else
          %{score: 0.0, verdict: "fail", rationale: "regex did not match", raw_output: %{pattern: pattern}}
        end

      {:error, reason} ->
        %{
          score: 0.0,
          verdict: "fail",
          rationale: "regex compile error: #{inspect(reason)}",
          raw_output: %{pattern: pattern, error: inspect(reason)}
        }
    end
  end

  defp dispatch("rubric", config, _message, opts) do
    subscores = Keyword.get(opts, :subscores) || Map.get(config, "subscores") || %{}
    criteria = Map.get(config, "criteria") || Map.get(config, :criteria) || %{"items" => []}

    cond do
      subscores == %{} ->
        stub_score("rubric", "subscores not provided (stub)")

      not is_map(subscores) ->
        stub_score("rubric", "subscores must be a map")

      true ->
        case RubricScoring.weighted_average(criteria, subscores) do
          {:error, reason} ->
            %{
              score: 0.0,
              verdict: "fail",
              rationale: "rubric aggregation failed: #{inspect(reason)}",
              raw_output: %{subscores: subscores}
            }

          score when is_number(score) ->
            threshold = Map.get(config, "threshold") || 0.85

            verdict =
              cond do
                score >= threshold -> "pass"
                score >= threshold - 0.05 -> "warn"
                true -> "fail"
              end

            %{
              score: score * 1.0,
              verdict: verdict,
              rationale: "weighted_average=#{Float.round(score * 1.0, 4)}",
              raw_output: %{subscores: subscores, threshold: threshold}
            }
        end
    end
  end

  defp dispatch(method, _config, _message, _opts)
       when method in ~w(lm_judge semantic structural),
       do: stub_score(method, "#{method} scoring not implemented (stub)")

  defp dispatch(nil, _config, _message, _opts),
    do: %{score: 0.0, verdict: "fail", rationale: "missing scoring_method", raw_output: %{}}

  defp dispatch(other, _config, _message, _opts),
    do: %{
      score: 0.0,
      verdict: "fail",
      rationale: "unknown scoring_method: #{inspect(other)}",
      raw_output: %{}
    }

  # ──────────────────────────────────────────────────────────────────────────
  # Helpers
  # ──────────────────────────────────────────────────────────────────────────

  defp stub_score(method, msg) do
    %{
      score: 0.5,
      verdict: "warn",
      rationale: msg,
      raw_output: %{stub: true, method: method}
    }
  end

  defp apply_direction(result, "positive"), do: result

  defp apply_direction(%{verdict: verdict} = result, "negative") do
    # For a negative (must-not) expectation: matching (pass) flips to fail.
    flipped =
      case verdict do
        "pass" -> "fail"
        "fail" -> "pass"
        "warn" -> "warn"
        other -> other
      end

    %{result | verdict: flipped, rationale: "[negated] " <> result.rationale}
  end

  defp apply_direction(result, _), do: result

  defp compile_regex(""), do: {:error, :empty_pattern}

  defp compile_regex(pattern) when is_binary(pattern) do
    try do
      {:ok, Regex.compile!(pattern)}
    rescue
      e in Regex.CompileError -> {:error, e.message}
    end
  end

  defp compile_regex(_), do: {:error, :not_a_string}
end
