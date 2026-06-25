defmodule NoizuPromptLingua.Workers.Memory.ReinforcementWorker do
  @moduledoc """
  Durable tail of recall reinforcement: bump the recalled memories' decay_weight/recall_count,
  strengthen existing edges among the returned set, and add Hebbian `co_occurrence` edges among
  co-recalled memories. Idempotent-ish (bumps clamp at 1.0; Hebbian inserts are `on_conflict: :nothing`).
  """
  use Oban.Worker, queue: :memory, max_attempts: 3

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Memory.AssociationEdge

  def config, do: Application.get_env(:noizu_prompt_lingua, :reinforcement, [])
  defp mem_boost, do: config()[:recall_memory_boost] || 0.02
  defp edge_boost, do: config()[:recall_edge_boost] || 0.05
  defp hebbian_initial, do: config()[:hebbian_initial] || 0.3

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"memory_ids" => ids}}) when is_list(ids) and ids != [] do
    bump_memories(ids)
    strengthen_edges(ids)
    hebbian(ids)
    :ok
  end

  def perform(_), do: :ok

  defp bump_memories(ids) do
    Repo.query!(
      "UPDATE memories SET decay_weight = LEAST(1.0, decay_weight + $2), recall_count = recall_count + 1, " <>
        "last_recalled_at = now(), last_reinforced_at = now(), updated_at = now() " <>
        "WHERE id = ANY(string_to_array($1, ',')::uuid[])",
      [Enum.join(ids, ","), mem_boost()]
    )
  end

  defp strengthen_edges(ids) do
    arr = Enum.join(ids, ",")

    Repo.query!(
      "UPDATE association_edges SET weight = LEAST(1.0, weight + $2), reinforcement_count = reinforcement_count + 1, " <>
        "last_reinforced_at = now(), updated_at = now() " <>
        "WHERE source_memory_id = ANY(string_to_array($1, ',')::uuid[]) " <>
        "AND target_memory_id = ANY(string_to_array($1, ',')::uuid[])",
      [arr, edge_boost()]
    )
  end

  # Hebbian: co-recalled memories that fire together wire together. Cap to the first 6 to bound
  # the pair count; insert one directional co_occurrence edge per unordered pair.
  defp hebbian(ids) do
    top = Enum.take(ids, 6)

    for {a, i} <- Enum.with_index(top), {b, j} <- Enum.with_index(top), i < j do
      %AssociationEdge{}
      |> AssociationEdge.changeset(%{
        source_memory_id: a,
        target_memory_id: b,
        edge_type: :co_occurrence,
        weight: hebbian_initial(),
        created_by: "hebbian",
        reason: "co-recalled",
        last_reinforced_at: DateTime.utc_now()
      })
      |> Repo.insert(on_conflict: :nothing, conflict_target: [:source_memory_id, :target_memory_id, :edge_type])
    end

    :ok
  end
end
