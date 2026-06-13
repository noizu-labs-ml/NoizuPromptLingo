defmodule Codefresh.Repo.Migrations.CreateDatasetsAndVersions do
  use Ecto.Migration

  def change do
    create table(:datasets) do
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :slug, :citext, null: false
      add :name, :string, null: false
      add :description, :text
      add :type, :string, null: false, default: "request_response"
      add :current_version_id, :uuid
      add :archived_at, :utc_datetime
      add :created_by_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      timestamps(type: :utc_datetime)
    end

    create unique_index(:datasets, [:organization_id, :slug])

    create table(:dataset_versions) do
      add :dataset_id, references(:datasets, type: :uuid, on_delete: :restrict), null: false
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :version_number, :integer, null: false
      add :yaml_source, :text
      add :parent_version_id, references(:dataset_versions, type: :uuid, on_delete: :nilify_all)
      add :checksum, :binary, null: false
      add :published_by_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      add :inserted_at, :utc_datetime, null: false
    end

    create unique_index(:dataset_versions, [:dataset_id, :version_number])
    create unique_index(:dataset_versions, [:dataset_id, :checksum])
    create index(:dataset_versions, [:parent_version_id])

    alter table(:datasets) do
      modify :current_version_id, references(:dataset_versions, type: :uuid, on_delete: :nilify_all)
    end
  end
end
