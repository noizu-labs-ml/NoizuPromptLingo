defmodule NoizuPromptLingua.Schema.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "users" do
    field :user_name, :string
    field :handle, :string
    belongs_to :name, NoizuPromptLingua.Schema.Versioned.Names.Name, type: Ecto.UUID
    belongs_to :description, NoizuPromptLingua.Schema.Versioned.Descriptions.Description, type: Ecto.UUID
    field :email, :string
    field :role, Ecto.Enum,
      values: [:user, :moderator, :admin, :owner, :service, :other],
      default: :user
    field :bio, :string
    field :status, Ecto.Enum,
      values: [:active, :unverified, :waitlist, :suspended, :deleted],
      default: :active
    field :verified, :boolean, default: false
    field :flagged, :boolean, default: false
    field :deleted_at, :utc_datetime_usec
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:user_name, :handle, :name_id, :description_id, :email,
                    :role, :bio, :status, :verified, :flagged])
    |> unique_constraint(:email)
    |> unique_constraint(:user_name)
    |> unique_constraint(:handle)
  end
end
