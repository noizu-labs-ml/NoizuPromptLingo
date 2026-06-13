defmodule Codefresh.Repo.Migrations.CreateDashboardsAndVersions do
  use Ecto.Migration

  def change do
    create table(:dashboards) do
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :slug, :citext, null: false
      add :name, :string, null: false
      add :description, :text
      add :current_version_id, :uuid
      add :archived_at, :utc_datetime
      add :created_by_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      timestamps(type: :utc_datetime)
    end

    create unique_index(:dashboards, [:organization_id, :slug])

    create table(:dashboard_versions) do
      add :dashboard_id, references(:dashboards, type: :uuid, on_delete: :delete_all), null: false
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :version_number, :integer, null: false
      add :checksum, :binary, null: false
      add :layout, :map, null: false, default: %{}
      add :published_by_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      add :inserted_at, :utc_datetime, null: false
    end

    create unique_index(:dashboard_versions, [:dashboard_id, :version_number])
    execute(
      "CREATE INDEX dashboard_versions_layout_gin ON dashboard_versions USING GIN (layout jsonb_path_ops)",
      "DROP INDEX dashboard_versions_layout_gin"
    )

    alter table(:dashboards) do
      modify :current_version_id, references(:dashboard_versions, type: :uuid, on_delete: :nilify_all)
    end
  end
end
