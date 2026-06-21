defmodule NoizuPromptLingua.Schema.Persona do
  @moduledoc """
  A persona: a named character/agent identity with a bio, a work log/journal,
  and a personal knowledge base. Bound to an organization (required); a project
  is optional. Slug is unique within the organization.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @statuses ~w(active archived)

  schema "personas" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :slug, :string
    field :name, :string
    field :role, :string
    field :bio, :string
    field :avatar, :string
    field :tags, {:array, :string}, default: []
    field :metadata, :map, default: %{}
    field :status, :string, default: "active"

    timestamps(type: :utc_datetime)
  end

  def changeset(persona, attrs) do
    persona
    |> cast(attrs, [:organization_id, :project_id, :slug, :name, :role, :bio, :avatar, :tags, :metadata, :status])
    |> validate_required([:organization_id, :slug, :name])
    |> validate_inclusion(:status, @statuses)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
    |> unique_constraint([:organization_id, :slug], name: :idx_personas_org_slug)
  end

  def statuses, do: @statuses
end
