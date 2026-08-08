defmodule NoizuPromptLingua.Schema.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "projects" do
    belongs_to :organization, NoizuPromptLingua.Schema.Organizations.Organization, type: Ecto.UUID
    field :name, :string
    field :slug, :string
    field :description, :string
    field :settings, :map, default: %{}
    field :status, :string, default: "active"
    field :key_prefix, :string

    belongs_to :created_by_user, NoizuPromptLingua.Schema.Users.User,
      type: Ecto.UUID,
      foreign_key: :created_by

    field :archived_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

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
      :key_prefix
    ])
    |> validate_required([:organization_id, :name, :slug])
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9-]*[a-z0-9]$|^[a-z0-9]$/,
      message: "must be lowercase alphanumeric with hyphens, no leading/trailing hyphens"
    )
    |> validate_inclusion(:status, ["active", "archived", "deleted"])
    # Human-key prefix (f8bc7fab): uppercase alnum, 2-16 chars; unique per org.
    |> validate_format(:key_prefix, ~r/^[A-Z0-9]{2,16}$/,
      message: "must be 2-16 uppercase letters/digits"
    )
    |> unique_constraint([:organization_id, :slug],
      name: :uq_projects_org_slug,
      message: "already exists in this organization"
    )
    |> unique_constraint(:key_prefix, name: :idx_projects_org_key_prefix)
  end
end
