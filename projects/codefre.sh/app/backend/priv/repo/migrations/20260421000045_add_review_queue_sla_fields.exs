defmodule Codefresh.Repo.Migrations.AddReviewQueueSlaFields do
  use Ecto.Migration

  def change do
    alter table(:review_queue) do
      add :assigned_at, :utc_datetime
      add :sla_warning_sent_at, :utc_datetime
    end

    create index(:review_queue, [:assigned_to_user_id], where: "status IN ('pending', 'claimed')")
  end
end
