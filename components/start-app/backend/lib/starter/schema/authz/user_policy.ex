defmodule Starter.Schema.Authz.UserPolicy do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "user_policies" do
    belongs_to :user, Starter.Schema.Users.User, type: Ecto.UUID
    belongs_to :policy, Starter.Schema.Authz.Policy, type: Ecto.UUID
    field :resource_type, :string
    field :resource_id, Ecto.UUID
    field :priority, :integer, default: 0

    timestamps(type: :utc_datetime_usec, inserted_at: :created_at, updated_at: false)
  end

  def changeset(user_policy, attrs) do
    user_policy
    |> cast(attrs, [:user_id, :policy_id, :resource_type, :resource_id, :priority])
    |> validate_required([:user_id, :policy_id])
    |> unique_constraint([:user_id, :policy_id, :resource_type, :resource_id])
  end
end
