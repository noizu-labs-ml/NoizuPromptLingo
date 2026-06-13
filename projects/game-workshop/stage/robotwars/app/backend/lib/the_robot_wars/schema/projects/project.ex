defmodule TheRobotWars.Schema.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "projects" do
    belongs_to :organization, TheRobotWars.Schema.Organizations.Organization, type: Ecto.UUID
    field :name, :string
    field :slug, :string
    field :description, :string
    field :settings, :map, default: %{}
    field :status, :string, default: "active"
    belongs_to :created_by_user, TheRobotWars.Schema.Users.User, type: Ecto.UUID, foreign_key: :created_by
    field :archived_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(project, attrs) do
    project
    |> cast(attrs, [:organization_id, :name, :slug, :description, :settings, :status, :created_by, :archived_at])
    |> validate_required([:organization_id, :name, :slug])
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9-]*[a-z0-9]$|^[a-z0-9]$/, message: "must be lowercase alphanumeric with hyphens, no leading/trailing hyphens")
    |> validate_inclusion(:status, ["active", "archived", "deleted"])
    |> unique_constraint([:organization_id, :slug])
  end
end
