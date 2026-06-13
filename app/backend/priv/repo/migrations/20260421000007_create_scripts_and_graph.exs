defmodule Codefresh.Repo.Migrations.CreateScriptsAndGraph do
  use Ecto.Migration

  def change do
    create table(:scripts) do
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :slug, :citext, null: false
      add :name, :string, null: false
      add :description, :text
      add :current_version_id, :uuid
      add :archived_at, :utc_datetime
      add :created_by_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      timestamps(type: :utc_datetime)
    end

    create unique_index(:scripts, [:organization_id, :slug])

    create table(:script_versions) do
      add :script_id, references(:scripts, type: :uuid, on_delete: :restrict), null: false
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :version_number, :integer, null: false
      add :root_node_id, :uuid  # deferred FK; added later
      add :description, :text
      add :yaml_source, :text
      add :checksum, :binary, null: false
      add :published_by_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      add :parent_version_id, references(:script_versions, type: :uuid, on_delete: :nilify_all)
      add :inserted_at, :utc_datetime, null: false
    end

    create unique_index(:script_versions, [:script_id, :version_number])
    create unique_index(:script_versions, [:script_id, :checksum])
    create index(:script_versions, [:parent_version_id])

    create table(:script_nodes) do
      add :script_version_id, references(:script_versions, type: :uuid, on_delete: :delete_all), null: false
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :node_key, :string, null: false
      add :kind, :string, null: false
      add :prompt_version_id, references(:prompt_versions, type: :uuid, on_delete: :restrict)
      add :tone, :string
      add :eval_tags, {:array, :string}, null: false, default: []
      add :freeball_policy, :string, null: false, default: "allow"
      add :position, :map, null: false, default: %{}
      add :metadata, :map, null: false, default: %{}
      add :inserted_at, :utc_datetime, null: false
    end

    create unique_index(:script_nodes, [:script_version_id, :node_key])
    create unique_index(:script_nodes, [:script_version_id, :id])  # composite for edge FKs
    create index(:script_nodes, [:prompt_version_id])

    # Wire up script_versions.root_node_id now that script_nodes exists
    alter table(:script_versions) do
      modify :root_node_id, references(:script_nodes, type: :uuid, on_delete: :nilify_all)
    end

    # Wire up scripts.current_version_id
    alter table(:scripts) do
      modify :current_version_id, references(:script_versions, type: :uuid, on_delete: :nilify_all)
    end

    create table(:script_edges) do
      add :script_version_id, references(:script_versions, type: :uuid, on_delete: :delete_all), null: false
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :from_node_id, references(:script_nodes, type: :uuid, on_delete: :delete_all), null: false
      add :to_node_id, references(:script_nodes, type: :uuid, on_delete: :delete_all), null: false
      add :priority, :integer, null: false, default: 0
      add :match_method, :string, null: false
      add :match_config, :map, null: false, default: %{}
      add :label, :text
      add :inserted_at, :utc_datetime, null: false
    end

    create index(:script_edges, [:from_node_id, :priority])
    create index(:script_edges, [:to_node_id])

    # Add vector column via execute (pgvector)
    execute(
      "ALTER TABLE script_edges ADD COLUMN match_embedding vector(1536)",
      "ALTER TABLE script_edges DROP COLUMN match_embedding"
    )

    # Edge self-loop check: allow only when match_method = 'always'
    execute(
      "ALTER TABLE script_edges ADD CONSTRAINT script_edges_no_self_loop CHECK (from_node_id <> to_node_id OR match_method = 'always')",
      "ALTER TABLE script_edges DROP CONSTRAINT script_edges_no_self_loop"
    )
  end
end
