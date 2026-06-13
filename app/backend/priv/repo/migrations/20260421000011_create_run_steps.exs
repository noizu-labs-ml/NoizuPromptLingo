defmodule Codefresh.Repo.Migrations.CreateRunSteps do
  use Ecto.Migration

  def change do
    create table(:run_steps) do
      add :run_id, references(:runs, type: :uuid, on_delete: :delete_all), null: false
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :step_index, :integer, null: false
      add :from_node_id, references(:script_nodes, type: :uuid, on_delete: :restrict)
      add :to_node_id, references(:script_nodes, type: :uuid, on_delete: :restrict)
      add :freeball_node_id, :uuid  # FK added in freeball migration (circular dep)
      add :edge_id, references(:script_edges, type: :uuid, on_delete: :restrict)
      add :persona_version_id, references(:persona_versions, type: :uuid, on_delete: :restrict)
      add :user_message, :text
      add :agent_message, :text
      add :agent_raw, :map, null: false, default: %{}
      add :latency_ms, :integer
      add :tokens_in, :integer
      add :tokens_out, :integer
      add :trace_id, :text
      add :span_id, :text
      add :status, :string, null: false, default: "ok"
      add :error, :map
      add :inserted_at, :utc_datetime, null: false
    end

    create unique_index(:run_steps, [:run_id, :step_index])
    create index(:run_steps, [:to_node_id])
    create index(:run_steps, [:freeball_node_id])
    create index(:run_steps, [:trace_id])
  end
end
