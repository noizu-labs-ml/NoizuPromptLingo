defmodule Codefresh.Repo.Migrations.CreateRubricsAndVersions do
  use Ecto.Migration

  def change do
    create table(:rubrics) do
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :slug, :citext, null: false
      add :name, :string, null: false
      add :description, :text
      add :current_version_id, :uuid
      add :archived_at, :utc_datetime
      add :created_by_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      timestamps(type: :utc_datetime)
    end

    create unique_index(:rubrics, [:organization_id, :slug])

    create table(:rubric_versions) do
      add :rubric_id, references(:rubrics, type: :uuid, on_delete: :restrict), null: false
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :version_number, :integer, null: false
      add :judge_prompt_version_id, references(:prompt_versions, type: :uuid, on_delete: :restrict)
      add :judge_model, :string
      add :scale, :map, null: false, default: %{}
      add :criteria, :map, null: false, default: %{}
      add :checksum, :binary, null: false
      add :published_by_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      add :inserted_at, :utc_datetime, null: false
    end

    create unique_index(:rubric_versions, [:rubric_id, :version_number])
    create unique_index(:rubric_versions, [:rubric_id, :checksum])

    alter table(:rubrics) do
      modify :current_version_id, references(:rubric_versions, type: :uuid, on_delete: :nilify_all)
    end
  end
end
