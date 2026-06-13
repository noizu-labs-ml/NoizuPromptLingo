defmodule NoizuPromptLingua.Schema.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime_usec]

  schema "users" do
    field :sub, :string
    field :email, :string
    field :name, :string
    field :status, :string, default: "active"
    timestamps(inserted_at: :inserted_at, updated_at: :updated_at)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:sub, :email, :name, :status])
    |> validate_required([:sub, :email])
    |> unique_constraint(:sub)
    |> unique_constraint(:email)
  end
end
