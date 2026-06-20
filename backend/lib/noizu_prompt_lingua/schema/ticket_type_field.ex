defmodule NoizuPromptLingua.Schema.TicketTypeField do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "ticket_type_fields" do
    belongs_to :ticket_type_definition, NoizuPromptLingua.Schema.TicketTypeDefinition
    belongs_to :ticket_field_definition, NoizuPromptLingua.Schema.TicketFieldDefinition
    field :required, :boolean, default: false
    field :position, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  def changeset(type_field, attrs) do
    type_field
    |> cast(attrs, [:ticket_type_definition_id, :ticket_field_definition_id, :required, :position])
    |> validate_required([:ticket_type_definition_id, :ticket_field_definition_id])
    |> unique_constraint([:ticket_type_definition_id, :ticket_field_definition_id])
  end
end
