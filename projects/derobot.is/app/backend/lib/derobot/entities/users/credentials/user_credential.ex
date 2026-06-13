defmodule Derobot.Users.Credentials.UserCredential do
  use Noizu.Entities

  @vsn 1.0
  @repo Derobot.Users.Credentials
  @sref "user-credential"
  @persistence ecto_store(Derobot.Schema.Users.Credentials.UserCredential, Derobot.Repo)
  @derive Noizu.Entity.Store.Ecto.EntityProtocol

  def_entity do
    id(:uuid)

    @config auto: false
    @store name: :user_id
    field :user, nil, Derobot.Users.UserReference

    @config auto: true
    @store name: :auth_provider_id
    field :auth_provider, nil, Derobot.Auth.Providers.ProviderReference

    field :status, nil, {:ecto, Derobot.Schema.Users.Credentials.UserCredential.__schema__(:type, :status)}
    field :settings, %{}, :map
    field :state, %{}, :map
    field :fingerprint, nil, :string
    field :time_stamp, nil, Noizu.Entity.TimeStamp
  end

  jason_encoder()
end
