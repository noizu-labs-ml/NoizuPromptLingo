defmodule NoizuPromptLingua.Domains.Memory.Monitor do
  @moduledoc """
  Owns a scope's emotional/hormonal harness state.

  PHASE 0 STUB: returns static config baselines. Later this becomes a per-scope process whose
  hormone levels rise on interaction events and relax toward baseline — the value stamped onto
  each memory at formation. `scope` is accepted for the future per-scope state but unused here.
  """
  alias NoizuPromptLingua.Domains.Memory.Emotion

  @doc "Current hormone snapshot (stamped onto memories at formation)."
  def current_hormones(_scope), do: Emotion.hormone_baseline()

  @doc "Current full emotional state (mood + hormones) — default recall_by_emotion anchor."
  def current_emotional(scope) do
    %{mood: Emotion.neutral_mood(), hormones: current_hormones(scope)}
  end

  @doc "Phase 2+: nudge hormone state from an interaction event. No-op in the stub."
  def observe(_scope, _event), do: :ok
end
