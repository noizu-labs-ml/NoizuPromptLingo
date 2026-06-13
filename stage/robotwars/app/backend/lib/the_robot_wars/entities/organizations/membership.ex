defmodule TheRobotWars.Organizations.Membership do
  use Noizu.Entities

  @vsn 1.0
  @repo TheRobotWars.Organizations.Memberships
  @sref "membership"
  @persistence ecto_store(TheRobotWars.Schema.Organizations.Membership, TheRobotWars.Repo)
  @derive Noizu.Entity.Store.Ecto.EntityProtocol
  def_entity do
    id(:uuid)
    @config auto: false
    @store name: :organization_id
    field :organization, nil, TheRobotWars.Organizations.OrganizationReference
    @config auto: false
    @store name: :user_id
    field :user, nil, TheRobotWars.Users.UserReference
    field :role, nil, :string
    field :time_stamp, nil, Noizu.Entity.TimeStamp
  end

  jason_encoder()
end
