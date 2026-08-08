defmodule NoizuPromptLingua.Schema.Organizations.Membership do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "memberships" do
    belongs_to :organization, NoizuPromptLingua.Schema.Organizations.Organization, type: Ecto.UUID
    belongs_to :user, NoizuPromptLingua.Schema.Users.User, type: Ecto.UUID
    field :role, :string, default: "viewer"
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:organization_id, :user_id, :role])
    |> validate_required([:organization_id, :user_id, :role])
    |> validate_inclusion(:role, ["owner", "admin", "editor", "viewer"])
    |> unique_constraint([:organization_id, :user_id])
  end
end
