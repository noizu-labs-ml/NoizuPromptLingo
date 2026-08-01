defmodule Noizu.PM.Schema.Users.Credentials.UserCredential do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "user_credentials" do
    belongs_to :user, Noizu.PM.Schema.Users.User, type: Ecto.UUID
    belongs_to :auth_provider, Noizu.PM.Schema.Auth.Providers.Provider, type: Ecto.UUID

    belongs_to :description, Noizu.PM.Schema.Versioned.Descriptions.Description,
      type: Ecto.UUID

    field :status, Ecto.Enum, values: [:active, :disabled, :suspended, :deleted, :other]
    field :settings, :map, default: %{}
    field :state, :map, default: %{}
    field :fingerprint, :string
    field :deleted_at, :utc_datetime_usec
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [
      :user_id,
      :auth_provider_id,
      :description_id,
      :status,
      :settings,
      :state,
      :fingerprint
    ])
    |> validate_required([:user_id, :auth_provider_id, :status])
  end
end
