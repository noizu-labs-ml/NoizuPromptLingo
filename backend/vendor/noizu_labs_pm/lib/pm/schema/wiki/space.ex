defmodule Noizu.PM.Schema.Wiki.Space do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "wiki_spaces" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :slug, :string
    field :name, :string
    field :description, :string

    has_many :pages, Noizu.PM.Schema.Wiki.Page

    timestamps(type: :utc_datetime)
  end

  def changeset(space, attrs) do
    space
    |> cast(attrs, [:organization_id, :project_id, :slug, :name, :description])
    |> validate_required([:organization_id, :slug, :name])
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/,
      message: "must be lowercase letters, numbers, and hyphens"
    )
    |> unique_constraint([:organization_id, :slug], name: :idx_wiki_spaces_org_slug)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
  end
end
