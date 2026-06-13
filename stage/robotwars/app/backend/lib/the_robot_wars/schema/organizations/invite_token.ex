defmodule TheRobotWars.Schema.Organizations.InviteToken do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "invite_tokens" do
    belongs_to :organization, TheRobotWars.Schema.Organizations.Organization, type: Ecto.UUID
    belongs_to :created_by_user, TheRobotWars.Schema.Users.User, type: Ecto.UUID
    field :token_hash, :string
    field :key_prefix, :string
    field :email, :string
    field :max_uses, :integer
    field :uses, :integer, default: 0
    field :expires_at, :utc_datetime_usec
    field :revoked, :boolean, default: false
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(token, attrs) do
    token
    |> cast(attrs, [:organization_id, :created_by_user_id, :token_hash, :key_prefix,
                    :email, :max_uses, :uses, :expires_at, :revoked])
    |> validate_required([:token_hash, :key_prefix])
    |> unique_constraint(:token_hash)
  end
end
