defmodule NoizuPromptLingua.Schema.WikiPage do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "wiki_pages" do
    belongs_to :space, NoizuPromptLingua.Schema.WikiSpace
    field :slug, :string
    field :title, :string
    field :artifact_id, :binary_id
    field :tags, {:array, :string}, default: []
    belongs_to :parent_page, NoizuPromptLingua.Schema.WikiPage

    timestamps(type: :utc_datetime)
  end

  def changeset(page, attrs) do
    page
    |> cast(attrs, [:space_id, :slug, :title, :artifact_id, :tags, :parent_page_id])
    |> validate_required([:space_id, :slug, :title])
    |> unique_constraint([:space_id, :slug])
    |> foreign_key_constraint(:space_id)
    |> foreign_key_constraint(:parent_page_id)
  end
end
