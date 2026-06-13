defmodule NoizuPromptLingua.Repo.Migrations.CreateWikiTables do
  use Ecto.Migration

  def change do
    create table(:wiki_spaces, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :slug, :string, null: false
      add :name, :string, null: false
      add :description, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:wiki_spaces, [:slug])

    create table(:wiki_pages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :space_id, references(:wiki_spaces, type: :binary_id, on_delete: :delete_all), null: false
      add :slug, :string, null: false
      add :title, :string, null: false
      add :artifact_id, :binary_id
      add :tags, {:array, :string}, default: []
      add :parent_page_id, references(:wiki_pages, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:wiki_pages, [:space_id])
    create unique_index(:wiki_pages, [:space_id, :slug])
    create index(:wiki_pages, [:parent_page_id])
    create index(:wiki_pages, [:tags], using: :gin)

    create table(:wiki_permissions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :entity_type, :string, null: false
      add :entity_id, :binary_id, null: false
      add :persona, :string, null: false
      add :permission, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:wiki_permissions, [:entity_type, :entity_id, :persona])
  end
end
