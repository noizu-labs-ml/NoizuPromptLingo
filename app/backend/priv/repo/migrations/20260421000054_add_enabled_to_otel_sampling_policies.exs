defmodule Codefresh.Repo.Migrations.AddEnabledToOtelSamplingPolicies do
  use Ecto.Migration

  def change do
    alter table(:otel_sampling_policies) do
      add :enabled, :boolean, null: false, default: true
    end
  end
end
