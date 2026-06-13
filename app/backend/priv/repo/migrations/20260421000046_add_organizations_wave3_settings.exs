defmodule Codefresh.Repo.Migrations.AddOrganizationsWave3Settings do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add :otel_retention_days, :integer
      add :otel_head_sampling_rate, :decimal, precision: 4, scale: 3
      add :freeball_review_sla_days, :integer, null: false, default: 7
    end
  end
end
