defmodule Codefresh.Repo.Migrations.CreateReviewQueue do
  use Ecto.Migration

  def change do
    create table(:review_queue) do
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :freeball_node_id, references(:freeball_nodes, type: :uuid, on_delete: :delete_all), null: false
      add :status, :string, null: false, default: "pending"
      add :priority, :integer, null: false, default: 0
      add :assigned_to_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      add :claimed_at, :utc_datetime
      add :resolved_at, :utc_datetime
      add :resolution_notes, :text
      timestamps(type: :utc_datetime)
    end

    create unique_index(:review_queue, [:freeball_node_id])
    create index(:review_queue, [:organization_id, :status, :priority])
  end
end
