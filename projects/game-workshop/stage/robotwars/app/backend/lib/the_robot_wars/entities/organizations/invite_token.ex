defmodule TheRobotWars.Organizations.InviteToken do
  use Noizu.Entities

  @vsn 1.0
  @repo TheRobotWars.Organizations.InviteTokens
  @sref "invite-token"
  @persistence ecto_store(TheRobotWars.Schema.Organizations.InviteToken, TheRobotWars.Repo)
  @derive Noizu.Entity.Store.Ecto.EntityProtocol
  def_entity do
    id(:uuid)
    @config auto: false
    @store name: :organization_id
    field :organization, nil, TheRobotWars.Organizations.OrganizationReference
    @config auto: false
    @store name: :created_by_user_id
    field :created_by, nil, TheRobotWars.Users.UserReference
    field :token_hash, nil, :string
    field :key_prefix, nil, :string
    field :email, nil, :string
    field :max_uses, nil, :integer
    field :uses, 0, :integer
    field :expires_at, nil, :utc_datetime_usec
    field :revoked, false, :boolean
    field :time_stamp, nil, Noizu.Entity.TimeStamp
  end

  jason_encoder()
end
