defmodule Codefresh.Repo.Migrations.CreatePromptsAndVersions do
  use Ecto.Migration

  def change do
    create table(:prompts) do
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :slug, :citext, null: false
      add :name, :string, null: false
      add :description, :text
      add :current_version_id, :uuid
      add :archived_at, :utc_datetime
      add :created_by_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      timestamps(type: :utc_datetime)
    end

    create unique_index(:prompts, [:organization_id, :slug])
    create index(:prompts, [:organization_id])

    create table(:prompt_versions) do
      add :prompt_id, references(:prompts, type: :uuid, on_delete: :restrict), null: false
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :version_number, :integer, null: false
      add :body, :text, null: false
      add :template_vars, :map, null: false, default: %{}
      add :tool_defs, :map, null: false, default: %{}
      add :metadata, :map, null: false, default: %{}
      add :checksum, :binary, null: false
      add :published_by_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      add :inserted_at, :utc_datetime, null: false
    end

    create unique_index(:prompt_versions, [:prompt_id, :version_number])
    create unique_index(:prompt_versions, [:prompt_id, :checksum])
    create index(:prompt_versions, [:organization_id, :prompt_id])

    # current_version_id now valid; add FK (deferred until after prompt_versions exists)
    alter table(:prompts) do
      modify :current_version_id, references(:prompt_versions, type: :uuid, on_delete: :nilify_all)
    end
  end
end
