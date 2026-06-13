defmodule NoizuPromptLingua.Repo.Migrations.AddProjectIdToArtifactsAndScopeAssets do
  use Ecto.Migration

  def change do
    alter table(:artifacts) do
      add :project_id, references(:projects, type: :binary_id, on_delete: :nilify_all)
    end

    create index(:artifacts, [:project_id])

    # Drop the old global unique constraint, replace with project-scoped
    drop_if_exists unique_index(:asset_entries, [:slug])
    create unique_index(:asset_entries, [:project_id, :slug])
  end
end
