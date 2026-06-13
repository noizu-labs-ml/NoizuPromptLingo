defmodule Codefresh.Repo.Migrations.CreateOtelLogsHypertable do
  use Ecto.Migration

  def up do
    # Composite PK `(id, timestamp)` — TimescaleDB requires the partitioning
    # column in every unique index/PK.
    create table(:otel_logs, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()")
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict)
      add :run_id, references(:runs, type: :uuid, on_delete: :restrict)
      add :run_step_id, references(:run_steps, type: :uuid, on_delete: :restrict)
      add :trace_id, :text
      add :span_id, :text
      add :timestamp, :timestamptz, null: false
      add :severity_number, :smallint
      add :severity_text, :string
      add :body, :text, null: false
      add :attributes, :map, null: false, default: %{}
      add :resource_attributes, :map, null: false, default: %{}
      add :inserted_at, :utc_datetime, null: false
    end

    execute("ALTER TABLE otel_logs ADD PRIMARY KEY (id, timestamp)")

    execute("""
    SELECT create_hypertable('otel_logs', 'timestamp',
      chunk_time_interval => INTERVAL '1 month',
      if_not_exists => TRUE)
    """)

    execute("""
    ALTER TABLE otel_logs SET (
      timescaledb.compress,
      timescaledb.compress_segmentby = 'trace_id',
      timescaledb.compress_orderby = 'timestamp DESC'
    )
    """)

    execute("SELECT add_compression_policy('otel_logs', INTERVAL '7 days', if_not_exists => TRUE)")

    create index(:otel_logs, [:trace_id])
    create index(:otel_logs, [:run_id, :timestamp])
    create index(:otel_logs, [:run_step_id])
    execute("CREATE INDEX otel_logs_attributes_gin ON otel_logs USING GIN (attributes jsonb_path_ops)")
  end

  def down do
    execute("SELECT remove_compression_policy('otel_logs', if_exists => TRUE)")
    drop table(:otel_logs)
  end
end
