defmodule Derobot.Users.User do
  use Noizu.Entities

  @vsn 1.0
  @repo Derobot.Users
  @sref "user"
  @persistence ecto_store(Derobot.Schema.Users.User, Derobot.Repo)
  @derive Noizu.Entity.Store.Ecto.EntityProtocol

  def_entity do
    id(:uuid)
    field :user_name, nil, :string
    field :handle, nil, :string
    field :email, nil, :string
    field :hashed_password, nil, :string
    field :status, nil, {:ecto, Derobot.Schema.Users.User.__schema__(:type, :status)}
    field :verified, nil, :boolean
    field :flagged, nil, :boolean
    field :time_stamp, nil, Noizu.Entity.TimeStamp
  end

  jason_encoder()
end
