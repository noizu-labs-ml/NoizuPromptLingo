defmodule NoizuPromptLingua.Schema.Authz.Group do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "groups" do
    field :name, :string
    field :display_name, :string
    field :description, :string
    field :is_system, :boolean, default: true

    has_many :group_policies, NoizuPromptLingua.Schema.Authz.GroupPolicy

    timestamps(type: :utc_datetime_usec, inserted_at: :created_at, updated_at: :updated_at)
  end

  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :display_name, :description, :is_system])
    |> validate_required([:name, :display_name])
    |> validate_inclusion(:name, ["owner", "admin", "member", "viewer"])
    |> unique_constraint(:name)
  end
end
