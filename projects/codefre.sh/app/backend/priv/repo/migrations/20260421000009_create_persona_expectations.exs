defmodule Codefresh.Repo.Migrations.CreatePersonaExpectations do
  use Ecto.Migration

  def change do
    create table(:persona_expectations) do
      add :persona_version_id, references(:persona_versions, type: :uuid, on_delete: :delete_all), null: false
      add :script_node_id, references(:script_nodes, type: :uuid, on_delete: :delete_all), null: false
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :label, :text, null: false
      add :weight, :decimal, precision: 4, scale: 3, null: false, default: 1.000
      add :direction, :string, null: false, default: "positive"
      add :scoring_method, :string, null: false
      add :config, :map, null: false, default: %{}
      add :rubric_version_id, references(:rubric_versions, type: :uuid, on_delete: :restrict)
      add :inserted_at, :utc_datetime, null: false
    end

    create unique_index(:persona_expectations, [:persona_version_id, :script_node_id, :label])
    create index(:persona_expectations, [:script_node_id])
    create index(:persona_expectations, [:persona_version_id])

    execute(
      "ALTER TABLE persona_expectations ADD COLUMN reference_embedding vector(1536)",
      "ALTER TABLE persona_expectations DROP COLUMN reference_embedding"
    )
  end
end
