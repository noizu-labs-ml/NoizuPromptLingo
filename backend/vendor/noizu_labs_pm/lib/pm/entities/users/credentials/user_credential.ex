defmodule Noizu.PM.Users.Credentials.UserCredential do
  use Noizu.Entities

  @vsn 1.0
  @repo Noizu.PM.Users.Credentials
  @sref "user-credential"
  @persistence ecto_store(
                 Noizu.PM.Schema.Users.Credentials.UserCredential,
                 Noizu.PM.Repo
               )
  @derive Noizu.Entity.Store.Ecto.EntityProtocol
  def_entity do
    id(:uuid)

    @config auto: false
    @store name: :user_id
    field :user, nil, Noizu.PM.Users.UserReference

    @config auto: false
    @store name: :auth_provider_id
    field :auth_provider, nil, Noizu.PM.Auth.Providers.ProviderReference

    @config auto: true
    @store name: :description_id
    field :description, nil, Noizu.PM.Versioned.Descriptions.DescriptionReference

    field :status, nil, {:ecto, Noizu.PM.Schema.Users.Credentials.UserCredential.__schema__(:type, :status)}
    field :settings, %{}, :map
    field :state, %{}, :map
    field :fingerprint, nil, :string
    field :time_stamp, nil, Noizu.Entity.TimeStamp
  end

  jason_encoder()
end
