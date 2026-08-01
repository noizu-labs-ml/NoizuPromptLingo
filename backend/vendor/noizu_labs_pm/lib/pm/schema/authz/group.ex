defmodule Noizu.PM.Schema.Authz.Group do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "groups" do
    field :name, :string
    field :display_name, :string
    field :description, :string
    field :is_system, :boolean, default: true

    has_many :group_policies, Noizu.PM.Schema.Authz.GroupPolicy

    timestamps(type: :utc_datetime_usec, inserted_at: :created_at, updated_at: :updated_at)
  end

  # `groups.name` is the Postgres enum `role_name_enum` (Liquibase 014, plus
  # 'lead' from 053), NOT free text. Comparing that column against a string
  # outside the enum does not return zero rows — Postgres *raises*
  # `invalid input value for enum role_name_enum`. So every read path has to
  # screen the value before it reaches a query.
  @role_names ~w(owner admin lead member viewer)

  @doc "The `role_name_enum` values, in rank order. The only legal `name`s."
  @spec role_names() :: [String.t()]
  def role_names, do: @role_names

  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :display_name, :description, :is_system])
    |> validate_required([:name, :display_name])
    |> validate_inclusion(:name, @role_names)
    |> unique_constraint(:name)
  end
end
