defmodule Codefresh.Repo.Migrations.AddOtelSpansSamplingFields do
  use Ecto.Migration

  def change do
    alter table(:otel_spans) do
      add :sampled, :boolean
      add :sample_decision_reason, :string
      add :sample_rate, :decimal, precision: 4, scale: 3
    end

    # Partial index for sampled-traces-only queries
    execute(
      "CREATE INDEX otel_spans_sampled_idx ON otel_spans (organization_id, start_time) WHERE sampled = TRUE",
      "DROP INDEX otel_spans_sampled_idx"
    )
  end
end
