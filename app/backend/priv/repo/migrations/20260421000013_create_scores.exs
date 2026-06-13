defmodule Codefresh.Repo.Migrations.CreateScores do
  use Ecto.Migration

  def change do
    create table(:scores) do
      add :run_step_id, references(:run_steps, type: :uuid, on_delete: :delete_all), null: false
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :expectation_id, references(:expectations, type: :uuid, on_delete: :restrict)
      add :freeball_expectation_id, references(:freeball_expectations, type: :uuid, on_delete: :restrict)
      add :rubric_version_id, references(:rubric_versions, type: :uuid, on_delete: :restrict)
      add :scoring_method, :string, null: false
      add :judge_model, :string
      add :judge_prompt_version_id, references(:prompt_versions, type: :uuid, on_delete: :restrict)
      add :score, :decimal, precision: 6, scale: 4, null: false
      add :verdict, :string, null: false
      add :rationale, :text
      add :raw_output, :map, null: false, default: %{}
      add :scored_at, :utc_datetime, null: false
      add :inserted_at, :utc_datetime, null: false
    end

    # Partial unique indexes for the two expectation flavours
    create unique_index(:scores, [:run_step_id, :expectation_id, :rubric_version_id],
             where: "expectation_id IS NOT NULL",
             name: :scores_unique_expectation
           )

    create unique_index(:scores, [:run_step_id, :freeball_expectation_id, :rubric_version_id],
             where: "freeball_expectation_id IS NOT NULL",
             name: :scores_unique_freeball_expectation
           )

    create index(:scores, [:run_step_id])
    create index(:scores, [:expectation_id])
    create index(:scores, [:freeball_expectation_id])
    create index(:scores, [:organization_id, :verdict])

    # Exactly one of expectation_id / freeball_expectation_id must be set
    execute(
      """
      ALTER TABLE scores ADD CONSTRAINT scores_exactly_one_expectation
      CHECK ((expectation_id IS NOT NULL)::int + (freeball_expectation_id IS NOT NULL)::int = 1)
      """,
      "ALTER TABLE scores DROP CONSTRAINT scores_exactly_one_expectation"
    )
  end
end
