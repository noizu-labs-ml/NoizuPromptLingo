defmodule NoizuPromptLingua.Schema.Reaction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "npl_reactions" do
    field :entity_type, :string
    field :entity_id, :binary_id
    field :persona, :string
    field :emoji, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(reaction, attrs) do
    reaction
    |> cast(attrs, [:entity_type, :entity_id, :persona, :emoji])
    |> validate_required([:entity_type, :entity_id, :persona, :emoji])
    |> unique_constraint([:entity_type, :entity_id, :persona, :emoji])
  end
end
