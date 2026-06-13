defmodule Codefresh.Repo.Migrations.CreateFlaggedCaptures do
  use Ecto.Migration

  def change do
    create table(:flagged_captures) do
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :title, :text, null: false
      add :notes, :text
      add :tags, {:array, :string}, null: false, default: []
      add :reason, :string, null: false
      add :source_trace_id, :text
      add :source_span_id, :text
      add :source_run_step_id, references(:run_steps, type: :uuid, on_delete: :nilify_all)
      add :input, :map, null: false, default: %{}
      add :agent_response, :map, null: false, default: %{}
      add :captured_attributes, :map, null: false, default: %{}
      add :promoted_to_script_node_id, references(:script_nodes, type: :uuid, on_delete: :nilify_all)
      add :promoted_to_dataset_entry_id, references(:dataset_entries, type: :uuid, on_delete: :nilify_all)
      add :flagged_by_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      timestamps(type: :utc_datetime)
    end

    create index(:flagged_captures, [:organization_id, :inserted_at])
    create index(:flagged_captures, [:source_trace_id])
    create index(:flagged_captures, [:promoted_to_script_node_id])
    create index(:flagged_captures, [:promoted_to_dataset_entry_id])
  end
end
