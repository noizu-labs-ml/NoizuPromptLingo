defmodule Starter.Schema.Organizations.CustomRole do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "custom_roles" do
    belongs_to :organization, Starter.Schema.Organizations.Organization, type: Ecto.UUID
    field :name, :string
    field :display_name, :string
    field :description, :string
    field :is_active, :boolean, default: true

    has_many :permissions, Starter.Schema.Organizations.CustomRolePermission, foreign_key: :role_id

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(role, attrs) do
    role
    |> cast(attrs, [:organization_id, :name, :display_name, :description, :is_active])
    |> validate_required([:organization_id, :name, :display_name])
    |> unique_constraint([:organization_id, :name])
  end
end
