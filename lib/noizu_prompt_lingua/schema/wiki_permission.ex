defmodule NoizuPromptLingua.Schema.WikiPermission do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "wiki_permissions" do
    field :entity_type, :string
    field :entity_id, :binary_id
    field :persona, :string
    field :permission, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(perm, attrs) do
    perm
    |> cast(attrs, [:entity_type, :entity_id, :persona, :permission])
    |> validate_required([:entity_type, :entity_id, :persona, :permission])
    |> validate_inclusion(:entity_type, ~w(space page))
    |> validate_inclusion(:permission, ~w(read write admin))
    |> unique_constraint([:entity_type, :entity_id, :persona])
  end
end
