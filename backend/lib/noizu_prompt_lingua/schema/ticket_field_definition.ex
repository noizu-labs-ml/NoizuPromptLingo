defmodule NoizuPromptLingua.Schema.TicketFieldDefinition do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @field_types ~w(text rich_text markdown radio select multi_select number date persona url)

  # Scope is determined by which owner columns are set:
  #   organization_id NULL, project_id NULL → global (system-wide)
  #   organization_id set,  project_id NULL → organization-level
  #   organization_id set,  project_id set  → project-level
  schema "ticket_field_definitions" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :slug, :string
    field :label, :string
    field :field_type, :string
    field :options, :map
    field :default_value, :string
    field :description, :string
    # When true at a more-specific scope, suppresses the inherited definition
    # for this slug (a tombstone). field_type/label may be placeholders.
    field :disabled, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  def changeset(field_def, attrs) do
    field_def
    |> cast(attrs, [:organization_id, :project_id, :slug, :label, :field_type, :options, :default_value, :description, :disabled])
    |> validate_required([:slug, :label, :field_type])
    |> validate_inclusion(:field_type, @field_types)
    |> validate_scope()
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
    |> unique_constraint(:slug, name: :idx_ticket_field_definitions_global_slug)
    |> unique_constraint(:slug, name: :idx_ticket_field_definitions_org_slug)
    |> unique_constraint(:slug, name: :idx_ticket_field_definitions_project_slug)
  end

  # A project-scoped definition must also carry its organization.
  defp validate_scope(changeset) do
    org = get_field(changeset, :organization_id)
    project = get_field(changeset, :project_id)

    if project && is_nil(org) do
      add_error(changeset, :organization_id, "is required for a project-scoped definition")
    else
      changeset
    end
  end

  def field_types, do: @field_types
end
