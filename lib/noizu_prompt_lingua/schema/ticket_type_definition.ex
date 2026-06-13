defmodule NoizuPromptLingua.Schema.TicketTypeDefinition do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "ticket_type_definitions" do
    field :slug, :string
    field :name, :string
    field :description, :string
    field :icon, :string
    field :status_workflow, :map
    field :deleted_at, :utc_datetime

    has_many :type_fields, NoizuPromptLingua.Schema.TicketTypeField,
      foreign_key: :ticket_type_definition_id

    timestamps(type: :utc_datetime)
  end

  def changeset(type_def, attrs) do
    type_def
    |> cast(attrs, [:slug, :name, :description, :icon, :status_workflow, :deleted_at])
    |> validate_required([:slug, :name])
    |> unique_constraint(:slug)
  end
end
