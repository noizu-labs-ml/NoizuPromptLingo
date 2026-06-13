defmodule Codefresh.Repo.Migrations.CreateExpectations do
  use Ecto.Migration

  def change do
    create table(:expectations) do
      add :script_node_id, references(:script_nodes, type: :uuid, on_delete: :delete_all), null: false
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :label, :text, null: false
      add :weight, :decimal, precision: 4, scale: 3, null: false, default: 1.000
      add :direction, :string, null: false, default: "positive"
      add :scoring_method, :string, null: false
      add :config, :map, null: false, default: %{}
      add :rubric_version_id, references(:rubric_versions, type: :uuid, on_delete: :restrict)
      add :metadata, :map, null: false, default: %{}
      add :inserted_at, :utc_datetime, null: false
    end

    create index(:expectations, [:script_node_id])
    create index(:expectations, [:organization_id, :scoring_method])

    # pgvector column for :semantic scoring method
    execute(
      "ALTER TABLE expectations ADD COLUMN reference_embedding vector(1536)",
      "ALTER TABLE expectations DROP COLUMN reference_embedding"
    )

    # Method coherence CHECK constraints
    execute(
      """
      ALTER TABLE expectations ADD CONSTRAINT expectations_rubric_required_for_rubric_method
      CHECK (scoring_method <> 'rubric' OR rubric_version_id IS NOT NULL)
      """,
      "ALTER TABLE expectations DROP CONSTRAINT expectations_rubric_required_for_rubric_method"
    )

    execute(
      """
      ALTER TABLE expectations ADD CONSTRAINT expectations_embedding_required_for_semantic_method
      CHECK (scoring_method <> 'semantic' OR reference_embedding IS NOT NULL)
      """,
      "ALTER TABLE expectations DROP CONSTRAINT expectations_embedding_required_for_semantic_method"
    )
  end
end
