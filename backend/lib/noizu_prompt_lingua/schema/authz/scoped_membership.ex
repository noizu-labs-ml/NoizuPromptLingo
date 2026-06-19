defmodule NoizuPromptLingua.Schema.Authz.ScopedMembership do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "scoped_memberships" do
    belongs_to :group, NoizuPromptLingua.Schema.Authz.Group, type: Ecto.UUID
    field :resource_type, :string
    field :resource_id, Ecto.UUID
    field :member_type, :string
    field :member_id, Ecto.UUID
    field :expires_at, :utc_datetime_usec
    belongs_to :added_by_user, NoizuPromptLingua.Schema.Users.User, type: Ecto.UUID, foreign_key: :added_by

    timestamps(type: :utc_datetime_usec, inserted_at: :created_at, updated_at: false)
  end

  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:group_id, :resource_type, :resource_id, :member_type, :member_id, :expires_at, :added_by])
    |> validate_required([:group_id, :resource_type, :resource_id, :member_type, :member_id])
    |> validate_inclusion(:resource_type, ["organization", "project"])
    |> validate_inclusion(:member_type, ["user", "group"])
    |> unique_constraint([:resource_type, :resource_id, :member_type, :member_id])
  end
end
