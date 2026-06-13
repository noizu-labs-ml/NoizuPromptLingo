defmodule Codefresh.Scripts.Expectation do
  @moduledoc """
  Expectation row on a script node. `scoring_method` determines the config
  shape: `lm_judge` (judge_prompt_version_id + rubric), `rubric` (rubric_version
  required), `regex` (pattern), `semantic` (reference_embedding — populated
  async in Wave 2), `structural` (shape assertions).

  DB-level coherence checks: rubric method requires `rubric_version_id`;
  semantic method requires `reference_embedding` (enforced in Wave 2 embed job).
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @directions ~w(positive negative)
  @scoring_methods ~w(lm_judge rubric regex semantic structural)

  schema "expectations" do
    field :label, :string
    field :weight, :decimal, default: Decimal.new("1.000")
    field :direction, :string, default: "positive"
    field :scoring_method, :string
    field :config, :map, default: %{}
    field :metadata, :map, default: %{}

    belongs_to :script_node, Codefresh.Scripts.ScriptNode
    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :rubric_version, Codefresh.Rubrics.RubricVersion

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def create_changeset(exp, attrs) do
    exp
    |> cast(attrs, [
      :script_node_id,
      :organization_id,
      :label,
      :weight,
      :direction,
      :scoring_method,
      :config,
      :rubric_version_id,
      :metadata
    ])
    |> validate_required([:script_node_id, :organization_id, :label, :scoring_method])
    |> validate_length(:label, min: 1, max: 400)
    |> validate_inclusion(:direction, @directions)
    |> validate_inclusion(:scoring_method, @scoring_methods)
    |> validate_rubric_required_when_rubric()
    |> foreign_key_constraint(:script_node_id)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:rubric_version_id)
    |> check_constraint(:rubric_version_id,
      name: :expectations_rubric_required_for_rubric_method
    )
  end

  defp validate_rubric_required_when_rubric(cs) do
    case {get_field(cs, :scoring_method), get_field(cs, :rubric_version_id)} do
      {"rubric", nil} ->
        add_error(cs, :rubric_version_id, "required when scoring_method is 'rubric'")

      _ ->
        cs
    end
  end
end
