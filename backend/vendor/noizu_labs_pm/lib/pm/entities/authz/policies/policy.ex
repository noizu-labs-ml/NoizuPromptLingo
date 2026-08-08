defmodule Noizu.PM.Authz.Policies.Policy do
  use Noizu.Entities

  @vsn 1.0
  @repo Noizu.PM.Authz.Policies
  @sref "authz-policy"
  @persistence ecto_store(Noizu.PM.Schema.Authz.Policy, Noizu.PM.Repo)
  @derive Noizu.Entity.Store.Ecto.EntityProtocol

  def_entity do
    id(:uuid)
    field :name, nil, :string
    field :description, nil, :string
    field :policy_document, %{}, :map
    field :is_system, false, :boolean
    field :is_active, true, :boolean
    field :time_stamp, nil, Noizu.Entity.TimeStamp
  end

  jason_encoder()
end
