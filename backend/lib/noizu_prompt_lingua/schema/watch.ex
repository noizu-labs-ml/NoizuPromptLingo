defmodule NoizuPromptLingua.Schema.Watch do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "npl_watches" do
    field :entity_type, :string
    field :entity_id, :binary_id
    field :persona, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(watch, attrs) do
    watch
    |> cast(attrs, [:entity_type, :entity_id, :persona])
    |> validate_required([:entity_type, :entity_id, :persona])
    |> unique_constraint([:entity_type, :entity_id, :persona])
  end
end
