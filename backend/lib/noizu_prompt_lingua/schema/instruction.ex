defmodule NoizuPromptLingua.Schema.Instruction do
  @moduledoc """
  A reusable, versioned instruction document — a prompt saved once and handed to
  many parallel sub-agents by reference (org-scoped `slug` handle) plus per-task
  params. Bound to an organization (required) with an optional project.

  `parameters` declares the template params the body expects: a list of maps
  `%{"name" => ..., "description" => ..., "required" => bool, "default" => ...}`.
  Bodies are versioned in `InstructionVersion`; `active_version` points at the
  one served by default.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @statuses ~w(active archived)

  schema "instructions" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :slug, :string
    field :title, :string
    field :description, :string
    field :tags, {:array, :string}, default: []
    field :parameters, {:array, :map}, default: []
    field :active_version, :integer, default: 1
    field :status, :string, default: "active"

    timestamps(type: :utc_datetime)
  end

  def changeset(instruction, attrs) do
    instruction
    |> cast(attrs, [
      :organization_id,
      :project_id,
      :slug,
      :title,
      :description,
      :tags,
      :parameters,
      :active_version,
      :status
    ])
    |> validate_required([:organization_id, :slug, :title])
    |> validate_inclusion(:status, @statuses)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
    |> unique_constraint([:organization_id, :slug], name: :idx_instructions_org_slug)
  end

  def statuses, do: @statuses
end
