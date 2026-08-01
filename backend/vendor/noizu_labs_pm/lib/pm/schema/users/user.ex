defmodule Noizu.PM.Schema.Users.User do
  @moduledoc """
  UNION of the npl and therobotplans user schemas.

  npl contributes `role` (Ecto.Enum) + `bio`; therobotplans contributes the
  invite/approval, password, consent, and admin columns. The `status` enum is
  widened to therobotplans' superset (adds `:pending`).
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "users" do
    field :user_name, :string
    field :handle, :string
    belongs_to :name, Noizu.PM.Schema.Versioned.Names.Name, type: Ecto.UUID

    belongs_to :description, Noizu.PM.Schema.Versioned.Descriptions.Description,
      type: Ecto.UUID

    # therobotplans invite/approval flow.
    belongs_to :invite_token, Noizu.PM.Schema.Organizations.InviteToken, type: Ecto.UUID
    belongs_to :approved_by_user, __MODULE__, type: Ecto.UUID

    field :email, :string
    field :hashed_password, :string

    # npl role enum (platform role; RBAC is handled via authz groups).
    field :role, Ecto.Enum,
      values: [:user, :moderator, :admin, :owner, :service, :other],
      default: :user

    field :bio, :string

    # Widened status enum: therobotplans superset (adds :pending).
    field :status, Ecto.Enum,
      values: [:active, :pending, :unverified, :waitlist, :suspended, :deleted, :other],
      default: :active

    field :mobile_phone, :string
    field :profile_completed_at, :utc_datetime_usec
    field :approved_at, :utc_datetime_usec
    field :verified, :boolean, default: false
    field :flagged, :boolean, default: false
    field :admin, :boolean, default: false
    field :consent_preferences, :map
    field :consent_updated_at, :utc_datetime_usec
    field :deleted_at, :utc_datetime_usec
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :user_name,
      :handle,
      :name_id,
      :description_id,
      :invite_token_id,
      :approved_by_user_id,
      :email,
      :hashed_password,
      :role,
      :bio,
      :status,
      :mobile_phone,
      :profile_completed_at,
      :approved_at,
      :verified,
      :flagged,
      :admin,
      :consent_preferences,
      :consent_updated_at
    ])
    |> validate_required([:email])
    |> unique_constraint(:email)
    |> unique_constraint(:user_name)
    |> unique_constraint(:handle)
  end
end
