defmodule NoizuPromptLingua.Repo.Migrations.CreateArtifacts do
  use Ecto.Migration

  def change do
    create table(:artifacts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :kind, :string, null: false
      add :title, :string, null: false
      add :mime_type, :string

      timestamps(type: :utc_datetime)
    end

    create index(:artifacts, [:kind])

    create table(:artifact_revisions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :artifact_id, references(:artifacts, type: :binary_id, on_delete: :delete_all), null: false
      add :content, :text, null: false
      add :note, :string
      add :revision_number, :integer, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:artifact_revisions, [:artifact_id])
    create unique_index(:artifact_revisions, [:artifact_id, :revision_number])
  end
end
