defmodule Codefresh.Repo.Migrations.AddRunsWave3Fields do
  use Ecto.Migration

  def change do
    alter table(:runs) do
      add :cost_estimate_usd, :decimal, precision: 10, scale: 4
      add :cost_cap_usd, :decimal, precision: 10, scale: 4
      add :regression_suite_dataset_version_id, references(:dataset_versions, type: :uuid, on_delete: :nilify_all)
      add :retry_parent_run_id, references(:runs, type: :uuid, on_delete: :nilify_all)
    end

    create index(:runs, [:retry_parent_run_id])
    create index(:runs, [:regression_suite_dataset_version_id])
  end
end
