defmodule NoizuPromptLingua.Schema.CustomerPersona do
  @moduledoc """
  A customer/user persona (ICP — Ideal Customer Profile): the marketing audience
  model — demographics, goals, pains, channels — distinct from the agent
  `Persona` domain (which models agent identities). Org-scoped (required) with an
  optional project; slug unique within the organization. An optional `summary` /
  long-form `artifact_id` may be LLM-generated.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @statuses ~w(active archived)

  schema "customer_personas" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :segment_id, :binary_id
    field :slug, :string
    field :name, :string
    field :archetype, :string
    field :demographics, :map, default: %{}
    field :goals, {:array, :string}, default: []
    field :pains, {:array, :string}, default: []
    field :channels, {:array, :string}, default: []
    field :motivations, :string
    field :objections, :string
    field :summary, :string
    field :artifact_id, :binary_id
    field :tags, {:array, :string}, default: []
    field :status, :string, default: "active"

    timestamps(type: :utc_datetime)
  end

  @castable ~w(organization_id project_id segment_id slug name archetype demographics
               goals pains channels motivations objections summary artifact_id tags status)a

  def changeset(persona, attrs) do
    persona
    |> cast(attrs, @castable)
    |> validate_required([:organization_id, :slug, :name])
    |> validate_inclusion(:status, @statuses)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:segment_id)
    |> unique_constraint([:organization_id, :slug], name: :idx_customer_personas_org_slug)
  end

  def statuses, do: @statuses
end
