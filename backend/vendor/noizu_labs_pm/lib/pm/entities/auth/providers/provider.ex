defmodule Noizu.PM.Auth.Providers.Provider do
  use Noizu.Entities

  @vsn 1.0
  @repo Noizu.PM.Auth.Providers
  @sref "auth-provider"
  @persistence ecto_store(
                 Noizu.PM.Schema.Auth.Providers.Provider,
                 Noizu.PM.Repo
               )
  @derive Noizu.Entity.Store.Ecto.EntityProtocol
  def_entity do
    id(:uuid)
    field :title, nil, :string
    field :description, nil, :string
    field :settings, nil, Noizu.PM.Ecto.SerializedTerm
    field :time_stamp, nil, Noizu.Entity.TimeStamp
  end

  jason_encoder()
end
