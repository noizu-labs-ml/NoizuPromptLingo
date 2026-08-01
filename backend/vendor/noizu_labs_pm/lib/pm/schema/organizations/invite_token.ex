defmodule Noizu.PM.Schema.Organizations.InviteToken do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "invite_tokens" do
    belongs_to :organization, Noizu.PM.Schema.Organizations.Organization, type: Ecto.UUID
    belongs_to :created_by_user, Noizu.PM.Schema.Users.User, type: Ecto.UUID
    field :token_hash, :string
    field :key_prefix, :string
    field :email, :string
    # Inviter-chosen join role: admin | member | viewer (never owner).
    field :role, :string, default: "viewer"
    field :max_uses, :integer
    field :uses, :integer, default: 0
    field :expires_at, :utc_datetime_usec
    field :revoked, :boolean, default: false
    timestamps(type: :utc_datetime_usec)
  end

  @roles ~w(admin member viewer)

  def changeset(token, attrs) do
    token
    |> cast(attrs, [
      :organization_id,
      :created_by_user_id,
      :token_hash,
      :key_prefix,
      :email,
      :role,
      :max_uses,
      :uses,
      :expires_at,
      :revoked
    ])
    |> validate_required([:token_hash, :key_prefix])
    |> validate_inclusion(:role, @roles)
    |> unique_constraint(:token_hash)
  end
end
