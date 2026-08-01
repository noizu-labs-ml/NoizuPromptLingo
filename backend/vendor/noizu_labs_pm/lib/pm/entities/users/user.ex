defmodule Noizu.PM.Users.User do
  @moduledoc """
  UNION entity of the npl + therobotplans user schemas (see
  `Noizu.PM.Schema.Users.User`).
  """
  use Noizu.Entities

  @vsn 1.0
  @repo Noizu.PM.Users
  @sref "user"
  @persistence ecto_store(Noizu.PM.Schema.Users.User, Noizu.PM.Repo)
  @derive Noizu.Entity.Store.Ecto.EntityProtocol
  def_entity do
    id(:uuid)
    field :user_name, nil, :string
    field :handle, nil, :string

    @config auto: true
    @store name: :name_id
    field :name, nil, Noizu.PM.Versioned.Names.NameReference

    @config auto: true
    @store name: :description_id
    field :description, nil, Noizu.PM.Versioned.Descriptions.DescriptionReference

    # therobotplans invite/approval flow.
    @config auto: false
    @store name: :invite_token_id
    field :invite_token, nil, Noizu.PM.Organizations.InviteTokenReference

    @config auto: false
    @store name: :approved_by_user_id
    field :approved_by_user, nil, Noizu.PM.Users.UserReference

    field :email, nil, :string
    field :hashed_password, nil, :string
    field :role, nil, {:ecto, Noizu.PM.Schema.Users.User.__schema__(:type, :role)}
    field :bio, nil, :string
    field :status, nil, {:ecto, Noizu.PM.Schema.Users.User.__schema__(:type, :status)}
    field :mobile_phone, nil, :string
    field :profile_completed_at, nil, :utc_datetime_usec
    field :approved_at, nil, :utc_datetime_usec
    field :verified, nil, :boolean
    field :flagged, nil, :boolean
    field :admin, nil, :boolean
    field :consent_preferences, nil, :map
    field :consent_updated_at, nil, :utc_datetime_usec
    field :time_stamp, nil, Noizu.Entity.TimeStamp
  end

  jason_encoder()
end
