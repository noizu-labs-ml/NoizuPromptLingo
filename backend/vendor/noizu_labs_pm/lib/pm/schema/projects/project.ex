defmodule Noizu.PM.Schema.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "projects" do
    belongs_to :organization, Noizu.PM.Schema.Organizations.Organization, type: Ecto.UUID
    field :name, :string
    field :slug, :string
    field :description, :string
    field :settings, :map, default: %{}
    field :status, :string, default: "active"
    field :key_prefix, :string

    belongs_to :created_by_user, Noizu.PM.Schema.Users.User,
      type: Ecto.UUID,
      foreign_key: :created_by

    field :archived_at, :utc_datetime_usec

    # TRP superset (035-projects-methodology): the project's default board
    # methodology + the queue an item is routed to when none is specified. Both
    # nullable so npl orgs (which don't use boards) are unaffected.
    field :default_methodology, :string
    belongs_to :default_queue, Noizu.PM.Schema.Items.ItemQueue,
      type: Ecto.UUID,
      foreign_key: :default_queue_id

    # Optimistic-concurrency guardrail (shared-core table).
    field :lock_version, :integer, default: 0

    timestamps(type: :utc_datetime_usec)
  end

  # Keep in sync with DB CHECK on projects.default_methodology (includes custom).
  @methodologies ~w(kanban scrum waterfall spiral custom)

  def changeset(project, attrs) do
    project
    |> cast(attrs, [
      :organization_id,
      :name,
      :slug,
      :description,
      :settings,
      :status,
      :created_by,
      :archived_at,
      :key_prefix,
      :default_methodology,
      :default_queue_id,
      :lock_version
    ])
    |> validate_required([:organization_id, :name, :slug])
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9-]*[a-z0-9]$|^[a-z0-9]$/,
      message: "must be lowercase alphanumeric with hyphens, no leading/trailing hyphens"
    )
    |> validate_inclusion(:status, ["active", "archived", "deleted"])
    |> validate_inclusion(:default_methodology, @methodologies ++ [nil])
    # Human-key prefix (f8bc7fab): uppercase alnum, 2-16 chars; unique per org.
    |> validate_format(:key_prefix, ~r/^[A-Z0-9]{2,16}$/,
      message: "must be 2-16 uppercase letters/digits"
    )
    |> unique_constraint([:organization_id, :slug])
    |> unique_constraint(:key_prefix, name: :idx_projects_org_key_prefix)
    |> optimistic_lock(:lock_version)
  end

  def methodologies, do: @methodologies
end
