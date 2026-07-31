defmodule NoizuPromptLingua.Domains.Memory.Reinforcement do
  @moduledoc """
  Weight dynamics. On recall, the *decision* of what to reinforce is computed inline (the
  returned set) and the durable *write* is an Oban job (`ReinforcementWorker`) so recall returns
  immediately. Explicit `reinforce`/`denforce` are applied synchronously, scoped to the caller.
  All weights clamp to [0.05, 1.0].
  """
  import Ecto.Query

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Memory.{Memory, AssociationEdge}
  alias NoizuPromptLingua.Domains.Memory.{Sentinel, Jobs}
  alias NoizuPromptLingua.Workers.Memory.ReinforcementWorker

  def config, do: Application.get_env(:noizu_prompt_lingua, :reinforcement, [])
  defp explicit_boost, do: config()[:explicit_boost] || 0.1
  defp denforce_penalty, do: config()[:denforce_penalty] || 0.05

  @doc "Async, durable light reinforcement of a recall result set (memories + edges + Hebbian)."
  def on_recall([], _context), do: :ok

  def on_recall(rows, _context) do
    ids = rows |> Enum.map(& &1.id) |> Enum.filter(&is_binary/1) |> Enum.uniq()

    if ids == [] do
      :ok
    else
      Jobs.enqueue(ReinforcementWorker, %{"memory_ids" => ids})
      :ok
    end
  rescue
    _ -> :ok
  catch
    :exit, _ -> :ok
  end

  @doc "Explicit, synchronous reinforce of one memory. Returns {:ok, new_decay_weight}."
  def reinforce(memory_id, context \\ %{}), do: adjust(memory_id, context, explicit_boost(), :up)

  @doc "Explicit, synchronous denforce of one memory. Returns {:ok, new_decay_weight}."
  def denforce(memory_id, context \\ %{}),
    do: adjust(memory_id, context, denforce_penalty(), :down)

  defp adjust(memory_id, context, delta, dir) do
    scope = Sentinel.scope(context)
    query = from(m in Memory, where: m.id == ^memory_id) |> Sentinel.scope_filter(scope)

    case Repo.one(query) do
      nil ->
        {:error, :not_found}

      mem ->
        changes =
          case dir do
            :up ->
              %{
                decay_weight: min(1.0, mem.decay_weight + delta),
                reinforcement_count: mem.reinforcement_count + 1,
                last_reinforced_at: DateTime.utc_now()
              }

            :down ->
              %{
                decay_weight: max(0.05, mem.decay_weight - delta),
                denforcement_count: mem.denforcement_count + 1
              }
          end

        case mem |> Ecto.Changeset.change(changes) |> Repo.update() do
          {:ok, updated} -> {:ok, updated.decay_weight}
          {:error, _} = err -> err
        end
    end
  end

  @doc "Existing edges of a memory (for the `memory_associations` tool), scope-checked."
  def associations(memory_id, context \\ %{}) do
    scope = Sentinel.scope(context)

    edges =
      from(e in AssociationEdge,
        where: e.source_memory_id == ^memory_id or e.target_memory_id == ^memory_id,
        order_by: [desc: e.weight]
      )
      |> Repo.all()

    mine =
      from(m in Memory, where: m.id == ^memory_id)
      |> Sentinel.scope_filter(scope)
      |> Repo.exists?()

    if mine, do: edges, else: []
  end
end
