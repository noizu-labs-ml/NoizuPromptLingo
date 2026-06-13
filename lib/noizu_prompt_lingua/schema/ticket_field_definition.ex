defmodule NoizuPromptLingua.Schema.TicketFieldDefinition do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @field_types ~w(text rich_text markdown radio select multi_select number date persona url)

  schema "ticket_field_definitions" do
    field :slug, :string
    field :label, :string
    field :field_type, :string
    field :options, :map
    field :default_value, :string
    field :description, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(field_def, attrs) do
    field_def
    |> cast(attrs, [:slug, :label, :field_type, :options, :default_value, :description])
    |> validate_required([:slug, :label, :field_type])
    |> validate_inclusion(:field_type, @field_types)
    |> unique_constraint(:slug)
  end

  def field_types, do: @field_types
end
