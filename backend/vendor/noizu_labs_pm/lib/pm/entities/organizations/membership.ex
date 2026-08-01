defmodule Noizu.PM.Organizations.Membership do
  use Noizu.Entities

  @vsn 1.0
  @repo Noizu.PM.Organizations.Memberships
  @sref "membership"
  @persistence ecto_store(
                 Noizu.PM.Schema.Organizations.Membership,
                 Noizu.PM.Repo
               )
  @derive Noizu.Entity.Store.Ecto.EntityProtocol
  def_entity do
    id(:uuid)
    @config auto: false
    @store name: :organization_id
    field :organization, nil, Noizu.PM.Organizations.OrganizationReference
    @config auto: false
    @store name: :user_id
    field :user, nil, Noizu.PM.Users.UserReference
    field :role, nil, :string
    field :time_stamp, nil, Noizu.Entity.TimeStamp
  end

  jason_encoder()
end
