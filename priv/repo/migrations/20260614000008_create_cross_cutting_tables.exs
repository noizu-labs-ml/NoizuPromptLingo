defmodule NoizuPromptLingua.Repo.Migrations.CreateCrossCuttingTables do
  use Ecto.Migration

  def change do
    create table(:npl_comments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :entity_type, :string, null: false
      add :entity_id, :binary_id, null: false
      add :content, :text, null: false
      add :author, :string
      add :location, :string
      add :reply_to_id, :binary_id

      timestamps(type: :utc_datetime)
    end

    create index(:npl_comments, [:entity_type, :entity_id])
    create index(:npl_comments, [:reply_to_id])

    create table(:npl_attachments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :entity_type, :string, null: false
      add :entity_id, :binary_id, null: false
      add :artifact_type, :string, null: false
      add :url, :text
      add :git_branch, :string
      add :description, :text
      add :created_by, :string

      timestamps(type: :utc_datetime)
    end

    create index(:npl_attachments, [:entity_type, :entity_id])

    create table(:npl_watches, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :entity_type, :string, null: false
      add :entity_id, :binary_id, null: false
      add :persona, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:npl_watches, [:entity_type, :entity_id, :persona])
  end
end
