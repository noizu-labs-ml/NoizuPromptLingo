defmodule Codefresh.Repo.Migrations.CreateAuditEventsHypertable do
  use Ecto.Migration

  def up do
    # Composite PK `(id, timestamp)` — TimescaleDB requires the partitioning
    # column in every unique index/PK.
    create table(:audit_events, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()")
      add :organization_id, references(:organizations, type: :uuid, on_delete: :restrict), null: false
      add :actor_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      add :action, :string, null: false
      add :subject_type, :string, null: false
      add :subject_id, :uuid
      add :subject_slug, :string
      add :diff, :map
      add :metadata, :map, null: false, default: %{}
      add :timestamp, :timestamptz, null: false
      add :inserted_at, :utc_datetime, null: false
    end

    execute("ALTER TABLE audit_events ADD PRIMARY KEY (id, timestamp)")

    # Hypertable on timestamp, monthly chunks
    execute("""
    SELECT create_hypertable('audit_events', 'timestamp',
      chunk_time_interval => INTERVAL '1 month',
      if_not_exists => TRUE)
    """)

    # Compression after 30 days (later than OTel since audit queries often reach back further)
    execute("""
    ALTER TABLE audit_events SET (
      timescaledb.compress,
      timescaledb.compress_segmentby = 'organization_id',
      timescaledb.compress_orderby = 'timestamp DESC'
    )
    """)

    execute("SELECT add_compression_policy('audit_events', INTERVAL '30 days', if_not_exists => TRUE)")

    create index(:audit_events, [:organization_id, :timestamp])
    create index(:audit_events, [:subject_type, :subject_id])
    create index(:audit_events, [:action, :timestamp])
  end

  def down do
    execute("SELECT remove_compression_policy('audit_events', if_exists => TRUE)")
    drop table(:audit_events)
  end
end
