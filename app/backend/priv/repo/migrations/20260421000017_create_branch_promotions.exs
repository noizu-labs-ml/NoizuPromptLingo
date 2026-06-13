defmodule Codefresh.Repo.Migrations.CreateBranchPromotions do
  use Ecto.Migration

  def change do
    create table(:branch_promotions) do
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :source_freeball_node_id, references(:freeball_nodes, type: :uuid, on_delete: :restrict), null: false
      add :source_script_version_id, references(:script_versions, type: :uuid, on_delete: :restrict), null: false
      add :target_script_version_id, references(:script_versions, type: :uuid, on_delete: :restrict), null: false
      add :promoted_by_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      add :node_mapping, :map, null: false, default: %{}
      add :edge_additions, :map, null: false, default: %{}
      add :notes, :text
      add :inserted_at, :utc_datetime, null: false
    end

    create unique_index(:branch_promotions, [:source_freeball_node_id])
    create index(:branch_promotions, [:target_script_version_id])
    create index(:branch_promotions, [:source_script_version_id])
  end
end
