defmodule Codefresh.Repo.Migrations.AddRubricVersionsNSamples do
  use Ecto.Migration

  def change do
    alter table(:rubric_versions) do
      add :n_samples, :integer, null: false, default: 1
    end

    execute(
      """
      ALTER TABLE rubric_versions ADD CONSTRAINT rubric_versions_n_samples_range
      CHECK (n_samples >= 1 AND n_samples <= 10)
      """,
      "ALTER TABLE rubric_versions DROP CONSTRAINT rubric_versions_n_samples_range"
    )
  end
end
