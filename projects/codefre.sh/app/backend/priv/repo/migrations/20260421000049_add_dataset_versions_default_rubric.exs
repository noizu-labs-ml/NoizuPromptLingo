defmodule Codefresh.Repo.Migrations.AddDatasetVersionsDefaultRubric do
  use Ecto.Migration

  def change do
    alter table(:dataset_versions) do
      add :default_rubric_version_id, references(:rubric_versions, type: :uuid, on_delete: :nilify_all)
    end

    create index(:dataset_versions, [:default_rubric_version_id], where: "default_rubric_version_id IS NOT NULL")
  end
end
