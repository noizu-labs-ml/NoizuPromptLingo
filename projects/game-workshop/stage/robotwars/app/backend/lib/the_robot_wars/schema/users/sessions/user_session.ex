defmodule TheRobotWars.Schema.Users.Sessions.UserSession do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "user_sessions" do
    belongs_to :user, TheRobotWars.Schema.Users.User, type: Ecto.UUID
    belongs_to :credential, TheRobotWars.Schema.Users.Credentials.UserCredential, type: Ecto.UUID
    field :status, Ecto.Enum, values: [:active, :revoked, :disabled, :suspended, :deleted, :other]
    field :details, :map, default: %{}
    field :deleted_at, :utc_datetime_usec
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(session, attrs) do
    session
    |> cast(attrs, [:user_id, :credential_id, :status, :details])
    |> validate_required([:user_id, :status])
  end
end
