defmodule Noizu.PM.Schema.Users.Sessions.UserSession do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "user_sessions" do
    belongs_to :user, Noizu.PM.Schema.Users.User, type: Ecto.UUID

    belongs_to :credential, Noizu.PM.Schema.Users.Credentials.UserCredential,
      type: Ecto.UUID

    field :status, Ecto.Enum, values: [:active, :revoked, :disabled, :suspended, :deleted, :other]
    field :details, :map, default: %{}
    # One-time SSO hand-off code: the OIDC callback stores it on the new
    # session, the SPA exchanges it once for JWTs.
    field :claim_code, :string
    field :claim_code_expires_at, :utc_datetime_usec
    field :deleted_at, :utc_datetime_usec
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(session, attrs) do
    session
    |> cast(attrs, [:user_id, :credential_id, :status, :details, :claim_code, :claim_code_expires_at])
    |> validate_required([:user_id, :status])
  end
end
