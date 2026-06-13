defmodule TheRobotWars.Authz.ScopedMemberships.ScopedMembership do
  use Noizu.Entities

  @vsn 1.0
  @repo TheRobotWars.Authz.ScopedMemberships
  @sref "scoped-membership"
  @persistence ecto_store(TheRobotWars.Schema.Authz.ScopedMembership, TheRobotWars.Repo)
  @derive Noizu.Entity.Store.Ecto.EntityProtocol

  def_entity do
    id(:uuid)

    @config auto: false
    @store name: :group_id
    field :group, nil, TheRobotWars.Authz.Groups.GroupReference

    field :resource_type, nil, :string
    field :resource_id, nil, :uuid
    field :member_type, nil, :string
    field :member_id, nil, :uuid
    field :expires_at, nil, :utc_datetime_usec
    field :time_stamp, nil, Noizu.Entity.TimeStamp
  end

  jason_encoder()
end
