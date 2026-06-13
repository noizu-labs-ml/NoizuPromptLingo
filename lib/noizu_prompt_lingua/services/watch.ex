defmodule NoizuPromptLingua.Services.Watch do
  import Ecto.Query
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Watch

  def watch(entity_type, entity_id, persona) do
    %Watch{}
    |> Watch.changeset(%{entity_type: entity_type, entity_id: entity_id, persona: persona})
    |> Repo.insert(on_conflict: :nothing)
  end

  def unwatch(entity_type, entity_id, persona) do
    case Repo.get_by(Watch, entity_type: entity_type, entity_id: entity_id, persona: persona) do
      nil -> {:error, :not_found}
      watch -> Repo.delete(watch)
    end
  end

  def watchers(entity_type, entity_id) do
    Watch
    |> where([w], w.entity_type == ^entity_type and w.entity_id == ^entity_id)
    |> select([w], w.persona)
    |> Repo.all()
  end

  def watching?(entity_type, entity_id, persona) do
    Watch
    |> where([w], w.entity_type == ^entity_type and w.entity_id == ^entity_id and w.persona == ^persona)
    |> Repo.exists?()
  end
end
