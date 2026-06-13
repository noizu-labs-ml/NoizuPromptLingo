defmodule Codefresh.Rubrics.Scoring do
  @moduledoc """
  Pure functions for aggregating judge outputs into final scores and
  confidence bands. Consumed by the Stage 5 runner — kept free of Ecto / Repo
  so it can be unit-tested without a DB.
  """

  @doc """
  Weighted average across criteria (US-056). Weights need not sum to 1; this
  function normalizes. Accepts either atom or string keys.

      iex> criteria = %{"items" => [
      ...>   %{"name" => "accuracy", "weight" => 0.6},
      ...>   %{"name" => "tone",     "weight" => 0.4}
      ...> ]}
      iex> subscores = %{"accuracy" => 0.8, "tone" => 0.5}
      iex> Codefresh.Rubrics.Scoring.weighted_average(criteria, subscores)
      0.68

  Returns `{:error, :missing_subscore}` if a criterion has no matching subscore.
  """
  def weighted_average(%{} = criteria, subscores) when is_map(subscores) do
    items = criteria |> Map.get("items", Map.get(criteria, :items, [])) |> List.wrap()

    total_weight = items |> Enum.map(&weight/1) |> Enum.sum()

    if total_weight <= 0 do
      {:error, :zero_total_weight}
    else
      weighted_sum =
        items
        |> Enum.reduce_while(0.0, fn item, acc ->
          name = name_of(item)
          w = weight(item)

          case Map.get(subscores, name) || Map.get(subscores, String.to_atom(name)) do
            nil -> {:halt, {:error, {:missing_subscore, name}}}
            v when is_number(v) -> {:cont, acc + w * v}
            _ -> {:halt, {:error, {:non_numeric_subscore, name}}}
          end
        end)

      case weighted_sum do
        {:error, _} = e -> e
        sum -> sum / total_weight
      end
    end
  end

  def weighted_average(_, _), do: {:error, :invalid_criteria}

  @doc """
  Sample statistics for US-120 confidence bands. Takes a list of numeric
  judge samples, returns `%{mean, stddev, n, low, high}` (low/high at ±1σ).

      iex> Codefresh.Rubrics.Scoring.confidence_band([0.80, 0.82, 0.78, 0.84, 0.80])
      %{n: 5, mean: 0.808, stddev: 0.0228, low: 0.7852, high: 0.8308}

  Returns `{:error, :insufficient_samples}` if fewer than 1 sample, or
  `{:error, :non_numeric}` if any sample is not a number.
  """
  def confidence_band([]), do: {:error, :insufficient_samples}

  def confidence_band(samples) when is_list(samples) do
    cond do
      not Enum.all?(samples, &is_number/1) ->
        {:error, :non_numeric}

      true ->
        n = length(samples)
        mean = Enum.sum(samples) / n

        stddev =
          if n <= 1 do
            0.0
          else
            variance =
              samples
              |> Enum.map(fn x -> (x - mean) * (x - mean) end)
              |> Enum.sum()
              |> Kernel./(n - 1)

            :math.sqrt(variance)
          end

        %{
          n: n,
          mean: round_f(mean, 4),
          stddev: round_f(stddev, 4),
          low: round_f(mean - stddev, 4),
          high: round_f(mean + stddev, 4)
        }
    end
  end

  @doc """
  Map a numeric judge score to a ladder/enum label (US-057). Chooses the
  highest-score label whose threshold is `<=` the score; monotonicity is
  assumed (enforced by `RubricVersion.validate_scale`).

  Returns `{:ok, label}` or `{:error, :no_match}`.
  """
  def label_for_score(%{"values" => values}, score) when is_number(score) do
    match =
      values
      |> Enum.reverse()
      |> Enum.find(fn v -> score >= score_of(v) end)

    case match do
      nil -> {:error, :no_match}
      v -> {:ok, label_of(v)}
    end
  end

  def label_for_score(%{values: _} = scale, score),
    do: label_for_score(%{"values" => Map.get(scale, :values)}, score)

  def label_for_score(_, _), do: {:error, :not_a_ladder}

  @doc "Inverse of `label_for_score/2`."
  def score_for_label(%{"values" => values}, label) when is_binary(label) do
    case Enum.find(values, fn v -> label_of(v) == label end) do
      nil -> {:error, :unknown_label}
      v -> {:ok, score_of(v)}
    end
  end

  def score_for_label(%{values: _} = scale, label),
    do: score_for_label(%{"values" => Map.get(scale, :values)}, label)

  def score_for_label(_, _), do: {:error, :not_a_ladder}

  defp name_of(m), do: Map.get(m, "name") || Map.get(m, :name)
  defp weight(m), do: Map.get(m, "weight") || Map.get(m, :weight) || 0
  defp label_of(m), do: Map.get(m, "label") || Map.get(m, :label)
  defp score_of(m), do: Map.get(m, "score") || Map.get(m, :score)

  defp round_f(f, digits) do
    mult = :math.pow(10, digits)
    Float.round(f * mult) / mult
  end
end
