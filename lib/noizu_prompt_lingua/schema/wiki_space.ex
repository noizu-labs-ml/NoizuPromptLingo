defmodule NoizuPromptLingua.Schema.WikiSpace do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "wiki_spaces" do
    field :slug, :string
    field :name, :string
    field :description, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(space, attrs) do
    space
    |> cast(attrs, [:slug, :name, :description])
    |> validate_required([:slug, :name])
    |> unique_constraint(:slug)
  end
end
