defmodule NoizuPromptLingua.PromptBuilder.Limiter do
  @moduledoc """
  Token-bucket rate limiting for the Prompt Builder over Hammer (ETS backend,
  config.exs). Three buckets per IP+session key — requests/min, tokens/min,
  tokens/hour — with thresholds from the admin-editable config row.

  Pre-flight charges the estimated input size against the token buckets
  (denied up-front when it exceeds the remaining budget); after a successful
  build, `charge/3` trues the buckets up with the actual usage delta. Daily
  spend cap is checked against the `prompt_builder_usage` accumulator.
  """

  alias NoizuPromptLingua.PromptBuilder

  @minute_ms 60_000
  @hour_ms 3_600_000

  @type decision ::
          :ok
          | {:error, {:rate_limited, retry_after_seconds :: pos_integer()}}
          | {:error, {:budget_exceeded, resets_at :: DateTime.t()}}

  @doc """
  Pre-flight check for one build attempt. Charges `est_input_tokens` against
  the token buckets; the caller trues up with `charge/3` after the model
  returns. A denied pre-flight consumes the request slot (anti-abuse: failed
  attempts still count against requests/min).
  """
  @spec check(String.t(), PromptBuilderConfig.t(), est_input_tokens :: pos_integer()) :: decision()
  def check(key_hash, config, est_input_tokens) do
    case Hammer.check_rate(bucket(:req, key_hash), @minute_ms, config.requests_per_minute) do
      {:deny, _} ->
        {:error, {:rate_limited, 60}}

      {:allow, _} ->
        with :ok <- reserve_tokens(key_hash, est_input_tokens, @minute_ms),
             :ok <- reserve_tokens(key_hash, est_input_tokens, @hour_ms) do
          :ok
        end
    end
  end

  defp reserve_tokens(key_hash, est, scale) do
    case Hammer.check_rate_inc(bucket(:tok, key_hash), scale, 1_000_000_000, est) do
      # check+increment is atomic — a denied request keeps its charge (anti-abuse).
      {:allow, _count} -> :ok
      {:deny, _limit} -> {:error, {:rate_limited, div(scale, 1000)}}
      {:error, _} -> :ok
    end
  end

  @doc """
  True up the token buckets with (actual − pre-charged estimate) after a
  successful call, so real usage above the estimate still erodes the budget.
  """
  @spec charge(String.t(), non_neg_integer(), non_neg_integer()) :: :ok
  def charge(key_hash, charged_estimate, actual_total) do
    delta = max(0, actual_total - charged_estimate)

    if delta > 0 do
      Hammer.check_rate_inc(bucket(:tok, key_hash), @hour_ms, 1_000_000_000, delta)
    end

    :ok
  end

  @doc "Daily spend-cap check against the usage accumulator."
  @spec check_budget(String.t(), PromptBuilderConfig.t()) ::
          :ok | {:error, {:budget_exceeded, resets_at :: DateTime.t()}}
  def check_budget(key_hash, config) do
    spent = PromptBuilder.today_cost(key_hash)

    if Decimal.compare(spent, config.daily_cost_cap_usd) == :lt do
      :ok
    else
      {:error, {:budget_exceeded, PromptBuilder.budget_resets_at()}}
    end
  end

  defp bucket(kind, key_hash), do: "pb:#{kind}:#{key_hash}"
end
