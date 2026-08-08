defmodule Noizu.PM.Schema.Items.ItemTypeField do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "item_type_fields" do
    belongs_to :item_type_definition, Noizu.PM.Schema.Items.ItemTypeDefinition
    belongs_to :item_field_definition, Noizu.PM.Schema.Items.ItemFieldDefinition
    field :required, :boolean, default: false
    field :position, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  def changeset(type_field, attrs) do
    type_field
    |> cast(attrs, [:item_type_definition_id, :item_field_definition_id, :required, :position])
    |> validate_required([:item_type_definition_id, :item_field_definition_id])
    |> unique_constraint([:item_type_definition_id, :item_field_definition_id])
  end
end
