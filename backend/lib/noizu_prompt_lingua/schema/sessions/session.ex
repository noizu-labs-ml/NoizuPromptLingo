defmodule NoizuPromptLingua.Schema.Sessions.Session do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "sessions" do
    belongs_to :organization, NoizuPromptLingua.Schema.Organizations.Organization, type: Ecto.UUID
    belongs_to :project, NoizuPromptLingua.Schema.Projects.Project, type: Ecto.UUID
    field :title, :string
    field :description, :string
    field :status, :string, default: "active"
    # Last user/agent activity, maintained by the Sessions context touch points
    # (create/update/get, chat posts to session rooms, memory writes carrying a
    # session_id). Drives the inactivity sweep (SessionInactivityWorker).
    field :last_activity_at, :utc_datetime_usec
    # Optional harness/model tailoring the session's tool descriptions target
    # (spec §3). Both change dynamically mid-session.
    field :model, :string
    field :runner, :string

    belongs_to :created_by_user, NoizuPromptLingua.Schema.Users.User,
      type: Ecto.UUID,
      foreign_key: :created_by

    field :archived_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(session, attrs) do
    session
    |> cast(attrs, [
      :organization_id,
      :project_id,
      :title,
      :description,
      :status,
      :model,
      :runner,
      :created_by,
      :archived_at,
      :last_activity_at
    ])
    |> validate_required([:organization_id, :title])
    |> validate_inclusion(:status, ["active", "archived", "completed", "inactive"])
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
  end
end
