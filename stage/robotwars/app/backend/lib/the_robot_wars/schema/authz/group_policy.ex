defmodule TheRobotWars.Schema.Authz.GroupPolicy do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "group_policies" do
    belongs_to :group, TheRobotWars.Schema.Authz.Group, type: Ecto.UUID
    belongs_to :policy, TheRobotWars.Schema.Authz.Policy, type: Ecto.UUID
    field :priority, :integer, default: 0

    timestamps(type: :utc_datetime_usec, inserted_at: :created_at, updated_at: false)
  end

  def changeset(group_policy, attrs) do
    group_policy
    |> cast(attrs, [:group_id, :policy_id, :priority])
    |> validate_required([:group_id, :policy_id])
    |> unique_constraint([:group_id, :policy_id])
  end
end
