defmodule Codefresh.Accounts.Membership do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @roles ~w(owner admin editor viewer ci)

  schema "memberships" do
    field :role, :string

    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :user, Codefresh.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def roles, do: @roles

  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:organization_id, :user_id, :role])
    |> validate_required([:organization_id, :user_id, :role])
    |> validate_inclusion(:role, @roles)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint([:organization_id, :user_id],
      message: "user is already a member of this organization"
    )
  end
end
