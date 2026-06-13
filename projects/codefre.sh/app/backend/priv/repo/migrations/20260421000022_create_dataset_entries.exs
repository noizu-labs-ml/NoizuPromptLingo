defmodule Codefresh.Repo.Migrations.CreateDatasetEntries do
  use Ecto.Migration

  def change do
    create table(:dataset_entries) do
      add :dataset_version_id, references(:dataset_versions, type: :uuid, on_delete: :delete_all), null: false
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :entry_key, :string, null: false
      add :input, :map, null: false, default: %{}
      add :expected_output, :map
      add :tags, {:array, :string}, null: false, default: []
      add :notes, :text
      add :inserted_at, :utc_datetime, null: false
    end

    create unique_index(:dataset_entries, [:dataset_version_id, :entry_key])
    create index(:dataset_entries, [:dataset_version_id])

    # Optional pgvector column for semantic search (candidate to move to Weaviate later)
    execute(
      "ALTER TABLE dataset_entries ADD COLUMN reference_embedding vector(1536)",
      "ALTER TABLE dataset_entries DROP COLUMN reference_embedding"
    )
  end
end
