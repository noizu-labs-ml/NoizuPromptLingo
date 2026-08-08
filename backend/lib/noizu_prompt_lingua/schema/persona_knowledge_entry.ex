defmodule NoizuPromptLingua.Schema.PersonaKnowledgeEntry do
  @moduledoc """
  A personal knowledge-base article belonging to a persona. Slug is unique
  within the persona's knowledge base.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "persona_knowledge_entries" do
    field :persona_id, :binary_id
    field :slug, :string
    field :title, :string
    field :body, :string
    field :tags, {:array, :string}, default: []
    field :source, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:persona_id, :slug, :title, :body, :tags, :source])
    |> validate_required([:persona_id, :slug, :title, :body])
    |> foreign_key_constraint(:persona_id)
    |> unique_constraint([:persona_id, :slug], name: :idx_persona_kb_persona_slug)
  end
end
