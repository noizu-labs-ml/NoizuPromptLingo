defmodule NoizuPromptLingua.Schema.TicketTypeDefinition do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  # Scope is determined by which owner columns are set:
  #   organization_id NULL, project_id NULL → global (system-wide)
  #   organization_id set,  project_id NULL → organization-level
  #   organization_id set,  project_id set  → project-level
  schema "ticket_type_definitions" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :slug, :string
    field :name, :string
    field :description, :string
    field :icon, :string
    field :status_workflow, :map
    # When true at a more-specific scope, suppresses the inherited type for
    # this slug (a tombstone).
    field :disabled, :boolean, default: false
    field :deleted_at, :utc_datetime

    has_many :type_fields, NoizuPromptLingua.Schema.TicketTypeField,
      foreign_key: :ticket_type_definition_id

    timestamps(type: :utc_datetime)
  end

  def changeset(type_def, attrs) do
    type_def
    |> cast(attrs, [:organization_id, :project_id, :slug, :name, :description, :icon, :status_workflow, :disabled, :deleted_at])
    |> validate_required([:slug, :name])
    |> validate_scope()
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
    |> unique_constraint(:slug, name: :idx_ticket_type_definitions_global_slug)
    |> unique_constraint(:slug, name: :idx_ticket_type_definitions_org_slug)
    |> unique_constraint(:slug, name: :idx_ticket_type_definitions_project_slug)
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
end
