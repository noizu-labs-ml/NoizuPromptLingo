defmodule Codefresh.Repo.Migrations.CreatePersonasAndVersions do
  use Ecto.Migration

  def change do
    create table(:personas) do
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :slug, :citext, null: false
      add :name, :string, null: false
      add :description, :text
      add :current_version_id, :uuid
      add :archived_at, :utc_datetime
      add :created_by_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      timestamps(type: :utc_datetime)
    end

    create unique_index(:personas, [:organization_id, :slug])

    create table(:persona_versions) do
      add :persona_id, references(:personas, type: :uuid, on_delete: :restrict), null: false
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :version_number, :integer, null: false
      add :tone, :string
      add :description, :text
      add :system_prompt_version_id, references(:prompt_versions, type: :uuid, on_delete: :restrict)
      add :metadata, :map, null: false, default: %{}
      add :checksum, :binary, null: false
      add :published_by_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      add :inserted_at, :utc_datetime, null: false
    end

    create unique_index(:persona_versions, [:persona_id, :version_number])
    create unique_index(:persona_versions, [:persona_id, :checksum])

    alter table(:personas) do
      modify :current_version_id, references(:persona_versions, type: :uuid, on_delete: :nilify_all)
    end
  end
end
