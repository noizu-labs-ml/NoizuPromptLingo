defmodule NoizuPromptLingua.Schema.CustomerSegment do
  @moduledoc """
  A customer/market segment: a named grouping of the target audience, scoped to
  an organization (required) with an optional project. Slug is unique within the
  organization. Distinct from the agent `Persona` domain.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @statuses ~w(active archived)

  schema "customer_segments" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :slug, :string
    field :name, :string
    field :description, :string
    field :criteria, :map, default: %{}
    field :tags, {:array, :string}, default: []
    field :status, :string, default: "active"

    timestamps(type: :utc_datetime)
  end

  def changeset(segment, attrs) do
    segment
    |> cast(attrs, [:organization_id, :project_id, :slug, :name, :description, :criteria, :tags, :status])
    |> validate_required([:organization_id, :slug, :name])
    |> validate_inclusion(:status, @statuses)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
    |> unique_constraint([:organization_id, :slug], name: :idx_customer_segments_org_slug)
  end

  def statuses, do: @statuses
end
