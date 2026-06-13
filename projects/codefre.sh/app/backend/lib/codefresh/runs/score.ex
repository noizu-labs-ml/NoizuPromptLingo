defmodule Codefresh.Runs.Score do
  @moduledoc """
  A score produced by evaluating an expectation (or freeball_expectation)
  against a run_step. Exactly one of `expectation_id` / `freeball_expectation_id`
  is set — the DB enforces this via the `scores_exactly_one_expectation`
  constraint.

  `verdict` is one of `pass|warn|fail`. `score` is a decimal 0..1.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @verdicts ~w(pass warn fail)

  schema "scores" do
    field :scoring_method, :string
    field :judge_model, :string
    field :score, :decimal
    field :verdict, :string
    field :rationale, :string
    field :raw_output, :map, default: %{}
    field :scored_at, :utc_datetime

    belongs_to :run_step, Codefresh.Runs.RunStep
    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :expectation, Codefresh.Scripts.Expectation
    belongs_to :freeball_expectation, Codefresh.Runs.FreeballExpectation
    belongs_to :rubric_version, Codefresh.Rubrics.RubricVersion
    belongs_to :judge_prompt_version, Codefresh.Prompts.PromptVersion,
      foreign_key: :judge_prompt_version_id

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def verdicts, do: @verdicts

  def create_changeset(score, attrs) do
    score
    |> cast(attrs, [
      :run_step_id,
      :organization_id,
      :expectation_id,
      :freeball_expectation_id,
      :rubric_version_id,
      :scoring_method,
      :judge_model,
      :judge_prompt_version_id,
      :score,
      :verdict,
      :rationale,
      :raw_output,
      :scored_at
    ])
    |> validate_required([
      :run_step_id,
      :organization_id,
      :scoring_method,
      :score,
      :verdict,
      :scored_at
    ])
    |> validate_inclusion(:verdict, @verdicts)
    |> foreign_key_constraint(:run_step_id)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:expectation_id)
    |> foreign_key_constraint(:freeball_expectation_id)
    |> check_constraint(:expectation_id, name: :scores_exactly_one_expectation)
  end
end
