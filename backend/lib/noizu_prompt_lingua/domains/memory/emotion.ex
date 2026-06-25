defmodule NoizuPromptLingua.Domains.Memory.Emotion do
  @moduledoc """
  Emotional-vector math. The 7-d resonance vector is `agent VAD ++ Monitor hormones`,
  pre-weighted so distance reflects the VAD-vs-hormone split. Valence is normalized from
  [-1,1] to [0,1] for the vector; the raw components are kept on the row for explainability.
  This 7-d vector is stored in Weaviate as the named vector "emotional".
  """

  @order ~w(valence arousal dominance cortisol dopamine oxytocin serotonin)a

  def config, do: Application.get_env(:noizu_prompt_lingua, :emotion, [])
  def vad_weight, do: config()[:vad_weight] || 0.6
  def hormone_weight, do: config()[:hormone_weight] || 0.4

  def hormone_baseline,
    do: config()[:hormone_baseline] || %{cortisol: 0.3, dopamine: 0.4, oxytocin: 0.4, serotonin: 0.5}

  @doc "Neutral default mood when the caller supplies none."
  def neutral_mood, do: %{valence: 0.0, arousal: 0.5, dominance: 0.5}

  @doc """
  Build the pre-weighted 7-element vector (list of floats) from a VAD mood map and a
  hormone map. Missing components fall back to neutral / baseline.
  """
  def build_vector(mood, hormones) do
    m = normalize_mood(mood)
    h = Map.merge(hormone_baseline(), atomize(hormones))

    vad = [(m.valence + 1.0) / 2.0, m.arousal, m.dominance] |> Enum.map(&(&1 * vad_weight()))
    horm = [h.cortisol, h.dopamine, h.oxytocin, h.serotonin] |> Enum.map(&(&1 * hormone_weight()))
    vad ++ horm
  end

  @doc "Raw component map (unweighted, valence kept in [-1,1]) for persisting on the row."
  def components(mood, hormones) do
    m = normalize_mood(mood)
    h = Map.merge(hormone_baseline(), atomize(hormones))

    %{
      valence: m.valence, arousal: m.arousal, dominance: m.dominance,
      cortisol: h.cortisol, dopamine: h.dopamine, oxytocin: h.oxytocin, serotonin: h.serotonin
    }
  end

  @doc "Reconstruct the mood + hormone maps from a persisted memory row's raw columns."
  def from_row(row) do
    mood = %{valence: row.valence, arousal: row.arousal, dominance: row.dominance}
    hormones = %{cortisol: row.cortisol, dopamine: row.dopamine, oxytocin: row.oxytocin, serotonin: row.serotonin}
    {mood, hormones}
  end

  @doc "Coarse VAD-only bucket: 4 valence × 3 arousal × 3 dominance = 36 buckets."
  def bucket(valence, arousal, dominance) do
    v = cond do valence < -0.5 -> 0; valence < 0.0 -> 1; valence < 0.5 -> 2; true -> 3 end
    a = cond do arousal < 0.34 -> 0; arousal < 0.67 -> 1; true -> 2 end
    d = cond do dominance < 0.34 -> 0; dominance < 0.67 -> 1; true -> 2 end
    "#{v}#{a}#{d}"
  end

  @doc "Resonance in [0,1] between two 7-d vectors (1 - normalized L2)."
  def resonance(a, b) when is_list(a) and is_list(b) do
    sumsq = a |> Enum.zip(b) |> Enum.reduce(0.0, fn {x, y}, acc -> acc + (x - y) * (x - y) end)
    max = :math.sqrt(length(a))
    1.0 - min(:math.sqrt(sumsq) / max, 1.0)
  end

  def order, do: @order

  defp normalize_mood(mood) do
    m = atomize(mood || %{})
    n = neutral_mood()

    %{
      valence: clampf(Map.get(m, :valence, n.valence), -1.0, 1.0),
      arousal: clampf(Map.get(m, :arousal, n.arousal), 0.0, 1.0),
      dominance: clampf(Map.get(m, :dominance, n.dominance), 0.0, 1.0)
    }
  end

  defp atomize(map) when is_map(map) do
    Map.new(map, fn
      {k, v} when is_binary(k) -> {String.to_existing_atom(k), v}
      {k, v} -> {k, v}
    end)
  rescue
    ArgumentError -> map
  end

  defp clampf(v, lo, hi) when is_number(v), do: v |> max(lo) |> min(hi)
  defp clampf(_, _lo, hi), do: hi
end
