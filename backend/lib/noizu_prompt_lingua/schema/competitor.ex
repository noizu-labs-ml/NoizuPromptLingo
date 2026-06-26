defmodule NoizuPromptLingua.Schema.Competitor do
  @moduledoc """
  A tracked competitor. Org-scoped (required) with an optional project; slug
  unique within the organization.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @statuses ~w(active archived)
  @tiers ~w(direct indirect aspirational)

  schema "competitors" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :slug, :string
    field :name, :string
    field :website, :string
    field :description, :string
    field :tier, :string
    field :strengths, {:array, :string}, default: []
    field :weaknesses, {:array, :string}, default: []
    field :metadata, :map, default: %{}
    field :tags, {:array, :string}, default: []
    field :status, :string, default: "active"

    timestamps(type: :utc_datetime)
  end

  @castable ~w(organization_id project_id slug name website description tier
               strengths weaknesses metadata tags status)a

  def changeset(competitor, attrs) do
    competitor
    |> cast(attrs, @castable)
    |> validate_required([:organization_id, :slug, :name])
    |> validate_inclusion(:status, @statuses)
    |> validate_inclusion(:tier, @tiers)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
    |> unique_constraint([:organization_id, :slug], name: :idx_competitors_org_slug)
  end

  def statuses, do: @statuses
  def tiers, do: @tiers
end
