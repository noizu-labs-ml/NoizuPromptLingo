defmodule Codefresh.Repo.Migrations.CreateRunsAndPersonas do
  use Ecto.Migration

  def change do
    create table(:runs) do
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :script_version_id, references(:script_versions, type: :uuid, on_delete: :restrict), null: false
      add :agent_version_id, references(:agent_versions, type: :uuid, on_delete: :restrict), null: false
      add :triggered_by_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      add :trigger_source, :string, null: false, default: "manual"
      add :status, :string, null: false, default: "pending"
      add :started_at, :utc_datetime
      add :finished_at, :utc_datetime
      add :run_config, :map, null: false, default: %{}
      add :trace_id, :text
      add :summary_metrics, :map, null: false, default: %{}
      add :inserted_at, :utc_datetime, null: false
    end

    create index(:runs, [:organization_id, :inserted_at])
    create index(:runs, [:script_version_id])
    create index(:runs, [:agent_version_id])
    create index(:runs, [:trace_id])

    create table(:run_personas) do
      add :run_id, references(:runs, type: :uuid, on_delete: :delete_all), null: false
      add :persona_version_id, references(:persona_versions, type: :uuid, on_delete: :restrict), null: false
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :inserted_at, :utc_datetime, null: false
    end

    create unique_index(:run_personas, [:run_id, :persona_version_id])
    create index(:run_personas, [:persona_version_id])
  end
end
