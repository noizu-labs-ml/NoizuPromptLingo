defmodule Codefresh.Repo.Migrations.CreateOtelSpansHypertable do
  use Ecto.Migration

  def up do
    # TimescaleDB requires the partitioning column to be part of every unique
    # index and the primary key. We use a composite PK `(id, start_time)` so
    # the uuid-based `id` still uniquely identifies rows while satisfying
    # TimescaleDB's constraint.
    create table(:otel_spans, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()")
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict)
      add :run_id, references(:runs, type: :uuid, on_delete: :restrict)
      add :run_step_id, references(:run_steps, type: :uuid, on_delete: :restrict)
      add :trace_id, :text, null: false
      add :span_id, :text, null: false
      add :parent_span_id, :text
      add :name, :text, null: false
      add :kind, :string, null: false
      add :service_name, :string
      add :start_time, :timestamptz, null: false
      add :end_time, :timestamptz, null: false
      add :duration_ns, :bigint, null: false
      add :status_code, :string, null: false, default: "unset"
      add :status_message, :text
      add :attributes, :map, null: false, default: %{}
      add :resource_attributes, :map, null: false, default: %{}
      add :events, :map, null: false, default: %{}
      add :inserted_at, :utc_datetime, null: false
    end

    # Composite PK must include the partitioning column for TimescaleDB.
    execute("ALTER TABLE otel_spans ADD PRIMARY KEY (id, start_time)")

    # pgvector column for optional semantic search
    execute("ALTER TABLE otel_spans ADD COLUMN name_embedding vector(1536)")

    # Convert to TimescaleDB hypertable with monthly chunks
    execute("""
    SELECT create_hypertable('otel_spans', 'start_time',
      chunk_time_interval => INTERVAL '1 month',
      if_not_exists => TRUE)
    """)

    # Compression policy (compress chunks older than 7 days, segment by trace_id)
    execute("""
    ALTER TABLE otel_spans SET (
      timescaledb.compress,
      timescaledb.compress_segmentby = 'trace_id',
      timescaledb.compress_orderby = 'start_time DESC'
    )
    """)

    execute("SELECT add_compression_policy('otel_spans', INTERVAL '7 days', if_not_exists => TRUE)")

    # Indexes
    create unique_index(:otel_spans, [:trace_id, :span_id, :start_time], name: :otel_spans_trace_span_time)
    create index(:otel_spans, [:trace_id])
    create index(:otel_spans, [:run_id, :start_time])
    create index(:otel_spans, [:run_step_id])
    create index(:otel_spans, [:organization_id, :start_time])

    # GIN index for attribute-contains queries (US-098)
    execute("CREATE INDEX otel_spans_attributes_gin ON otel_spans USING GIN (attributes jsonb_path_ops)")
  end

  def down do
    execute("SELECT remove_compression_policy('otel_spans', if_exists => TRUE)")
    drop table(:otel_spans)
  end
end
