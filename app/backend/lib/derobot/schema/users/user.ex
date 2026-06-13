defmodule Derobot.Schema.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  schema "users" do
    field :user_name, :string
    field :handle, :string
    field :email, :string
    field :hashed_password, :string
    field :status, Ecto.Enum, values: [:active, :unverified, :waitlist, :suspended, :deleted]
    field :verified, :boolean, default: false
    field :flagged, :boolean, default: false
    field :deleted_at, :utc_datetime_usec
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:user_name, :handle, :email, :hashed_password, :status, :verified, :flagged])
    |> validate_required([:email])
    |> unique_constraint(:email)
    |> unique_constraint(:handle)
    |> unique_constraint(:user_name)
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :hashed_password, :user_name, :handle])
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email address")
    |> validate_length(:email, max: 160)
    |> unique_constraint(:email)
    |> hash_password(attrs)
  end

  defp hash_password(changeset, attrs) do
    case attrs[:password] || attrs["password"] do
      nil -> changeset
      password ->
        changeset
        |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
    end
  end
end
