defmodule Starter.Authz.Policies.Policy do
  use Noizu.Entities

  @vsn 1.0
  @repo Starter.Authz.Policies
  @sref "authz-policy"
  @persistence ecto_store(Starter.Schema.Authz.Policy, Starter.Repo)
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
