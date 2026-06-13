defmodule Codefresh.Personas.PersonaExpectation do
  @moduledoc """
  Persona-layered expectation on a script node (US-051). Effectively immutable —
  edits produce a new persona version + new expectation rows.

  Mirrors the field shape of base `expectations` (label, weight, direction,
  scoring_method, config, optional rubric_version/embedding) but pins to a
  `persona_version_id` rather than to the script version.

  The runner (Stage 5) unions base expectations + persona expectations at
  evaluation time when a persona is attached to the run.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @directions ~w(positive negative)
  @scoring_methods ~w(regex embedding rubric semantic heuristic)

  schema "persona_expectations" do
    field :label, :string
    field :weight, :decimal, default: Decimal.new("1.000")
    field :direction, :string, default: "positive"
    field :scoring_method, :string
    field :config, :map, default: %{}

    belongs_to :persona_version, Codefresh.Personas.PersonaVersion
    # NOTE: Codefresh.Scripts.ScriptNode schema ships in Stage 3; we belong_to it by
    # raw column for now so this module doesn't force a Stage 3 dependency.
    field :script_node_id, Ecto.UUID
    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :rubric_version, Codefresh.Rubrics.RubricVersion

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def create_changeset(pe, attrs) do
    pe
    |> cast(attrs, [
      :persona_version_id,
      :script_node_id,
      :organization_id,
      :label,
      :weight,
      :direction,
      :scoring_method,
      :config,
      :rubric_version_id
    ])
    |> validate_required([
      :persona_version_id,
      :script_node_id,
      :organization_id,
      :label,
      :scoring_method
    ])
    |> validate_length(:label, min: 1, max: 400)
    |> validate_inclusion(:direction, @directions)
    |> validate_inclusion(:scoring_method, @scoring_methods)
    |> validate_rubric_required_when_rubric()
    |> unique_constraint([:persona_version_id, :script_node_id, :label])
    |> foreign_key_constraint(:persona_version_id)
    |> foreign_key_constraint(:script_node_id)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:rubric_version_id)
  end

  defp validate_rubric_required_when_rubric(changeset) do
    case {get_field(changeset, :scoring_method), get_field(changeset, :rubric_version_id)} do
      {"rubric", nil} ->
        add_error(
          changeset,
          :rubric_version_id,
          "required when scoring_method is 'rubric'"
        )

      _ ->
        changeset
    end
  end
end
