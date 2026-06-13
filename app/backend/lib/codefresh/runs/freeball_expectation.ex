defmodule Codefresh.Runs.FreeballExpectation do
  @moduledoc """
  An expectation generated alongside a freeball_node (US-023, US-024). Mirrors
  the shape of a script-authored expectation but is owned by a freeball_node
  and carries a runner-reported `confidence`.

  `reference_embedding` (vector(1536)) is populated async for `semantic`-method
  rows; not loaded here to keep the schema independent of pgvector encoding.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @directions ~w(positive negative)
  @scoring_methods ~w(lm_judge rubric regex semantic structural)

  schema "freeball_expectations" do
    field :label, :string
    field :weight, :decimal, default: Decimal.new("1.000")
    field :direction, :string, default: "positive"
    field :scoring_method, :string
    field :config, :map, default: %{}
    field :confidence, :decimal

    belongs_to :freeball_node, Codefresh.Runs.FreeballNode
    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :rubric_version, Codefresh.Rubrics.RubricVersion

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def scoring_methods, do: @scoring_methods

  def create_changeset(fe, attrs) do
    fe
    |> cast(attrs, [
      :freeball_node_id,
      :organization_id,
      :label,
      :weight,
      :direction,
      :scoring_method,
      :config,
      :rubric_version_id,
      :confidence
    ])
    |> validate_required([
      :freeball_node_id,
      :organization_id,
      :label,
      :scoring_method,
      :confidence
    ])
    |> validate_inclusion(:direction, @directions)
    |> validate_inclusion(:scoring_method, @scoring_methods)
    |> foreign_key_constraint(:freeball_node_id)
    |> foreign_key_constraint(:organization_id)
  end
end
