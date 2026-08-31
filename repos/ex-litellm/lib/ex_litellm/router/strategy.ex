defmodule ExLiteLLM.Router.Strategy do
  @moduledoc """
  Deployment-selection strategies — litellm's `router_strategy/*`.

  `pick/2` chooses one deployment from a non-empty candidate pool per the named
  strategy. `simple-shuffle` (the default) is a weight-aware random pick.
  Usage/latency/cost strategies need per-deployment telemetry state; they are
  registered here and fall back to weighted shuffle until that telemetry lands,
  so an unknown or not-yet-implemented strategy never breaks routing.
  """

  @doc "Pick one deployment from a non-empty pool for the given strategy."
  @spec pick(String.t(), [map()]) :: map()
  def pick(_strategy, [only]), do: only

  def pick("simple-shuffle", pool), do: weighted_shuffle(pool)

  def pick(strategy, pool)
      when strategy in ~w(least-busy usage-based-routing usage-based-routing-v2 latency-based-routing cost-based-routing) do
    # These need runtime telemetry (TPM/RPM/latency/cost) that lands with the
    # spend/metrics phase. Until then, weighted shuffle is a safe, fair default.
    weighted_shuffle(pool)
  end

  def pick(_unknown, pool), do: weighted_shuffle(pool)

  # Weighted random selection by each deployment's `weight` (default 1).
  defp weighted_shuffle(pool) do
    weights = Enum.map(pool, &weight/1)
    total = Enum.sum(weights)

    if total <= 0 do
      Enum.random(pool)
    else
      target = :rand.uniform() * total
      pick_by_weight(pool, weights, target)
    end
  end

  defp pick_by_weight([dep | _], [_w], _target), do: dep

  defp pick_by_weight([dep | rest_pool], [w | rest_w], target) do
    if target <= w, do: dep, else: pick_by_weight(rest_pool, rest_w, target - w)
  end

  defp pick_by_weight([], _, _), do: nil

  defp weight(%{"litellm_params" => %{"weight" => w}}) when is_number(w) and w > 0, do: w
  defp weight(%{"model_info" => %{"weight" => w}}) when is_number(w) and w > 0, do: w
  defp weight(_), do: 1
end
