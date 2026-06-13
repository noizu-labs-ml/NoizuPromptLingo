defmodule Codefresh.Repo.Migrations.CreateNodeComments do
  use Ecto.Migration

  def change do
    create table(:node_comments) do
      add :script_node_id, references(:script_nodes, type: :uuid, on_delete: :delete_all), null: false
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :thread_id, :uuid, null: false
      add :parent_comment_id, references(:node_comments, type: :uuid, on_delete: :nilify_all)
      add :author_user_id, references(:users, type: :uuid, on_delete: :nilify_all), null: false
      add :body, :text, null: false
      add :resolved_at, :utc_datetime
      add :resolved_by_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      timestamps(type: :utc_datetime)
    end

    create index(:node_comments, [:script_node_id, :thread_id, :inserted_at])
    create index(:node_comments, [:author_user_id])
  end
end
