defmodule Codefresh.Repo.Migrations.AddDatasetsRunLinkingFields do
  use Ecto.Migration

  def change do
    alter table(:run_steps) do
      add :dataset_entry_ref, :map
    end

    # GIN index on runs.run_config for dataset_version_id / batch_id / cost_cap lookups
    execute(
      "CREATE INDEX runs_run_config_gin ON runs USING GIN (run_config)",
      "DROP INDEX runs_run_config_gin"
    )
  end
end
