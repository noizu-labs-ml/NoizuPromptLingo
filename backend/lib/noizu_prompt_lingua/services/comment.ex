defmodule NoizuPromptLingua.Services.Comment do
  import Ecto.Query
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Comment

  def add(entity_type, entity_id, attrs) do
    %Comment{}
    |> Comment.changeset(Map.merge(attrs, %{entity_type: entity_type, entity_id: entity_id}))
    |> Repo.insert()
  end

  def list(entity_type, entity_id, opts \\ []) do
    Comment
    |> where([c], c.entity_type == ^entity_type and c.entity_id == ^entity_id)
    |> order_by([c], asc: c.inserted_at)
    |> limit(^(opts[:limit] || 50))
    |> Repo.all()
  end
end
