defmodule Noizu.PM.Users.Sessions.UserSession do
  use Noizu.Entities

  @vsn 1.0
  @repo Noizu.PM.Users.Sessions
  @sref "user-session"
  @persistence ecto_store(
                 Noizu.PM.Schema.Users.Sessions.UserSession,
                 Noizu.PM.Repo
               )
  @derive Noizu.Entity.Store.Ecto.EntityProtocol
  def_entity do
    id(:uuid)

    @config auto: false
    @store name: :user_id
    field :user, nil, Noizu.PM.Users.UserReference

    @config auto: false
    @store name: :credential_id
    field :credential, nil, Noizu.PM.Users.Credentials.UserCredentialReference

    field :status, nil, {:ecto, Noizu.PM.Schema.Users.Sessions.UserSession.__schema__(:type, :status)}
    field :details, %{}, :map
    field :claim_code, nil, :string
    field :claim_code_expires_at, nil, :utc_datetime_usec
    field :time_stamp, nil, Noizu.Entity.TimeStamp
  end

  jason_encoder()
end
