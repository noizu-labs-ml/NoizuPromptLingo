defmodule Codefresh.Repo.Migrations.CreateOtelSamplingPolicies do
  use Ecto.Migration

  def change do
    create table(:otel_sampling_policies) do
      add :organization_id, references(:organizations, type: :uuid, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :head_sampling_rate, :decimal, precision: 4, scale: 3
      add :tail_rules, :map, null: false, default: %{}
      add :effective_from, :utc_datetime
      add :metadata, :map, null: false, default: %{}
      timestamps(type: :utc_datetime)
    end

    create index(:otel_sampling_policies, [:organization_id])
  end
end
