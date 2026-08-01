defmodule Noizu.PM.Schema.Organizations.Membership do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "memberships" do
    belongs_to :organization, Noizu.PM.Schema.Organizations.Organization, type: Ecto.UUID
    belongs_to :user, Noizu.PM.Schema.Users.User, type: Ecto.UUID
    field :role, :string, default: "viewer"
    # Optimistic-concurrency guardrail (shared-core table): bumped on every
    # write so concurrent membership edits in different apps don't silently
    # clobber each other.
    field :lock_version, :integer, default: 0
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:organization_id, :user_id, :role, :lock_version])
    |> validate_required([:organization_id, :user_id, :role])
    |> validate_inclusion(:role, ["owner", "admin", "editor", "viewer"])
    |> unique_constraint([:organization_id, :user_id])
    |> optimistic_lock(:lock_version)
  end
end
