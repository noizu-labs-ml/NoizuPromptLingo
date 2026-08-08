defmodule NoizuPromptLingua.Users.Credentials.UserCredential do
  use Noizu.Entities
  @vsn 1.0
  @repo NoizuPromptLingua.Users.Credentials
  @sref "user-credential"
  @persistence ecto_store(
                 NoizuPromptLingua.Schema.Users.Credentials.UserCredential,
                 NoizuPromptLingua.Repo
               )
  @derive Noizu.Entity.Store.Ecto.EntityProtocol
  def_entity do
    id(:uuid)
    @config auto: false
    @store name: :user_id
    field :user, nil, NoizuPromptLingua.Users.UserReference
    @config auto: true
    @store name: :auth_provider_id
    field :auth_provider, nil, NoizuPromptLingua.Auth.Providers.ProviderReference
    @config auto: true
    @store name: :description_id
    field :description, nil, NoizuPromptLingua.Versioned.Descriptions.DescriptionReference

    field :status,
          nil,
          {:ecto,
           NoizuPromptLingua.Schema.Users.Credentials.UserCredential.__schema__(:type, :status)}

    field :settings, %{}, :map
    field :state, %{}, :map
    field :fingerprint, nil, :string
    field :time_stamp, nil, Noizu.Entity.TimeStamp
  end

  jason_encoder()
end
