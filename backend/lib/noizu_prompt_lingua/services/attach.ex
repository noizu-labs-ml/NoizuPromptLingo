defmodule NoizuPromptLingua.Services.Attach do
  import Ecto.Query
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Attachment

  def add(entity_type, entity_id, attrs) do
    %Attachment{}
    |> Attachment.changeset(Map.merge(attrs, %{entity_type: entity_type, entity_id: entity_id}))
    |> Repo.insert()
  end

  def list(entity_type, entity_id) do
    Attachment
    |> where([a], a.entity_type == ^entity_type and a.entity_id == ^entity_id)
    |> order_by([a], asc: a.inserted_at)
    |> Repo.all()
  end

  def remove(attachment_id) do
    case Repo.get(Attachment, attachment_id) do
      nil -> {:error, :not_found}
      att -> Repo.delete(att)
    end
  end
end
