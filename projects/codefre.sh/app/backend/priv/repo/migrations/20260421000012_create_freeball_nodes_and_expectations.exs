defmodule Codefresh.Repo.Migrations.CreateFreeballNodesAndExpectations do
  use Ecto.Migration

  def change do
    create table(:freeball_nodes) do
      add :run_id, references(:runs, type: :uuid, on_delete: :delete_all), null: false
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :parent_script_node_id, references(:script_nodes, type: :uuid, on_delete: :restrict), null: false
      add :parent_freeball_node_id, references(:freeball_nodes, type: :uuid, on_delete: :restrict)
      add :sequence, :integer, null: false
      add :prompt_text, :text, null: false
      add :confidence, :decimal, precision: 4, scale: 3, null: false
      add :runner_model, :string
      add :runner_prompt_version_id, references(:prompt_versions, type: :uuid, on_delete: :restrict)
      add :review_status, :string, null: false, default: "pending"
      add :metadata, :map, null: false, default: %{}
      add :inserted_at, :utc_datetime, null: false
    end

    create index(:freeball_nodes, [:run_id, :sequence])
    create index(:freeball_nodes, [:parent_script_node_id])
    create index(:freeball_nodes, [:review_status])

    # Wire up run_steps.freeball_node_id FK now that freeball_nodes exists
    alter table(:run_steps) do
      modify :freeball_node_id, references(:freeball_nodes, type: :uuid, on_delete: :restrict)
    end

    create table(:freeball_expectations) do
      add :freeball_node_id, references(:freeball_nodes, type: :uuid, on_delete: :delete_all), null: false
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :label, :text, null: false
      add :weight, :decimal, precision: 4, scale: 3, null: false, default: 1.000
      add :direction, :string, null: false, default: "positive"
      add :scoring_method, :string, null: false
      add :config, :map, null: false, default: %{}
      add :rubric_version_id, references(:rubric_versions, type: :uuid, on_delete: :restrict)
      add :confidence, :decimal, precision: 4, scale: 3, null: false
      add :inserted_at, :utc_datetime, null: false
    end

    create index(:freeball_expectations, [:freeball_node_id])

    execute(
      "ALTER TABLE freeball_expectations ADD COLUMN reference_embedding vector(1536)",
      "ALTER TABLE freeball_expectations DROP COLUMN reference_embedding"
    )
  end
end
