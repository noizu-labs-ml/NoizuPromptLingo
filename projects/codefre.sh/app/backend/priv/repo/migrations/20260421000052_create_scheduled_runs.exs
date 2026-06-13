defmodule Codefresh.Repo.Migrations.CreateScheduledRuns do
  use Ecto.Migration

  def change do
    create table(:scheduled_runs) do
      add :organization_id, references(:organizations, type: :uuid, on_delete: :delete_all),
        null: false

      add :script_version_id, references(:script_versions, type: :uuid, on_delete: :restrict),
        null: false

      add :agent_version_id, references(:agent_versions, type: :uuid, on_delete: :restrict),
        null: false

      add :cron_expression, :string, null: false
      add :timezone, :string, null: false, default: "Etc/UTC"
      add :enabled, :boolean, null: false, default: true
      add :next_run_at, :utc_datetime
      add :last_triggered_at, :utc_datetime
      add :last_run_id, references(:runs, type: :uuid, on_delete: :nilify_all)

      add :created_by_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      add :metadata, :map, null: false, default: %{}

      timestamps(type: :utc_datetime)
    end

    create index(:scheduled_runs, [:organization_id])
    create index(:scheduled_runs, [:script_version_id])
    create index(:scheduled_runs, [:agent_version_id])
    create index(:scheduled_runs, [:enabled, :next_run_at])
  end
end
