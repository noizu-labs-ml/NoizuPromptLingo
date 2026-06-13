# Worked Example: Migrating 500M Rows from PostgreSQL to TimescaleDB

> A complete end-to-end migration walkthrough for converting a large PostgreSQL events table to a TimescaleDB hypertable. This reads like a senior DBA walking you through the scariest migration of the quarter -- every decision is justified, every timing estimate is realistic, and every rollback point is tested.

---

## Scenario Brief

**Starting state:** A standard PostgreSQL 16 table `events` in a production analytics pipeline.

| Attribute | Value |
|-----------|-------|
| Table name | `public.events` |
| Row count | ~500M |
| Table size (data + toast) | ~200 GB |
| Total size (indexes + toast) | ~320 GB |
| Partitioning | Declarative range on `created_at` (quarterly, 8 partitions) |
| Indexes | 4 (see below) |
| Write rate | ~3,000 rows/sec (~260M rows/day) |
| Retention | 2 years, then `DELETE WHERE created_at < cutoff` (slow, painful) |
| Consumers | Grafana dashboards (15-min to 90-day windows), REST API (recent events by entity), nightly ETL |

**Current schema:**

```sql
CREATE TABLE events (
    id          bigint GENERATED ALWAYS AS IDENTITY,
    created_at  timestamptz NOT NULL,
    device_id   text NOT NULL,
    event_type  text NOT NULL,
    severity    smallint NOT NULL DEFAULT 0,
    payload     jsonb NOT NULL DEFAULT '{}',
    processed   boolean NOT NULL DEFAULT false
) PARTITION BY RANGE (created_at);

-- Quarterly partitions: events_2024_q1, events_2024_q2, ..., events_2026_q2

-- Indexes (on each partition):
CREATE INDEX idx_events_device_created ON events (device_id, created_at DESC);
CREATE INDEX idx_events_type_created ON events (event_type, created_at DESC);
CREATE INDEX idx_events_created ON events (created_at DESC);
CREATE INDEX idx_events_unprocessed ON events (created_at) WHERE processed = false;
```

**Current pain points:**

1. `DELETE` for retention takes 4-6 hours and generates massive WAL, bloats the table, triggers aggressive autovacuum
2. Dashboards querying 90-day windows run 3-8 seconds (table scan across 3 partitions)
3. Storage growing at ~50 GB/quarter with no end in sight
4. Nightly ETL aggregation queries hammer the OLTP workload

**Why TimescaleDB:** Compression (10-20x storage reduction), instant chunk drops (replaces 6-hour DELETE), continuous aggregates (pre-computed dashboards), chunk exclusion (faster queries).

---

## Phase 1: Assessment

### 1.1 Confirm Time-Series Characteristics

Before committing to TimescaleDB, verify the table actually behaves as time-series data:

```sql
-- Is the data append-mostly? Check UPDATE/DELETE frequency:
SELECT
    n_tup_ins AS inserts,
    n_tup_upd AS updates,
    n_tup_del AS deletes,
    round(100.0 * n_tup_upd / NULLIF(n_tup_ins, 0), 2) AS update_pct,
    round(100.0 * n_tup_del / NULLIF(n_tup_ins, 0), 2) AS delete_pct
FROM pg_stat_user_tables
WHERE relname = 'events';
```

**Expected result for a good candidate:**

| inserts | updates | deletes | update_pct | delete_pct |
|---------|---------|---------|------------|------------|
| 500M    | 12M     | 80M     | 2.4%       | 16.0%      |

Updates at <5% is ideal. The 16% deletes are the retention `DELETE` -- TimescaleDB's `drop_chunks` eliminates those entirely. The 2.4% updates are probably the `processed = false → true` flip -- we'll handle this.

```sql
-- Is there a natural time dimension? Check created_at distribution:
SELECT
    date_trunc('month', created_at) AS month,
    count(*) AS rows,
    pg_size_pretty(sum(pg_column_size(events.*))::bigint) AS estimated_size
FROM events
WHERE created_at > now() - INTERVAL '6 months'
GROUP BY 1
ORDER BY 1;
```

Verify rows arrive roughly in time order (minor out-of-order is fine; hours-late data is common in IoT).

### 1.2 Analyze Current Query Patterns

Pull the actual queries hitting this table from `pg_stat_statements`:

```sql
SELECT
    queryid,
    calls,
    round(mean_exec_time::numeric, 1) AS mean_ms,
    round(total_exec_time::numeric / 1000, 1) AS total_sec,
    rows,
    left(query, 200) AS query_preview
FROM pg_stat_statements
WHERE query ILIKE '%events%'
  AND query NOT ILIKE '%pg_stat%'
ORDER BY total_exec_time DESC
LIMIT 20;
```

**Typical findings for this table:**

| Pattern | Frequency | Current Latency | TimescaleDB Improvement |
|---------|-----------|-----------------|------------------------|
| Dashboard: `SELECT avg(severity), count(*) FROM events WHERE device_id = $1 AND created_at > now() - '1h'` | 500/min | 15-50 ms | Chunk exclusion → same or faster |
| Dashboard: `SELECT date_trunc('hour', created_at), count(*) FROM events WHERE created_at > now() - '90d' GROUP BY 1` | 50/min | 3-8 sec | **CAgg → 10-50 ms** |
| API: `SELECT * FROM events WHERE device_id = $1 ORDER BY created_at DESC LIMIT 50` | 200/min | 5-20 ms | Chunk exclusion → same |
| ETL: `SELECT device_id, event_type, count(*), avg(severity) FROM events WHERE created_at BETWEEN $1 AND $2 GROUP BY 1, 2` | 1/day | 45-120 sec | **CAgg → 1-5 sec** |
| Retention: `DELETE FROM events WHERE created_at < $1` | 1/week | 4-6 hours | **drop_chunks → instant** |

The two big wins are the 90-day dashboard and the retention delete. Those alone justify the migration.

### 1.3 Estimate Compression Ratio

Before migrating, estimate what compression will give you:

```sql
-- Sample data characteristics for compression estimation:
SELECT
    avg(pg_column_size(created_at)) AS avg_ts_bytes,
    avg(pg_column_size(device_id)) AS avg_device_bytes,
    count(DISTINCT device_id) AS device_cardinality,
    avg(pg_column_size(event_type)) AS avg_type_bytes,
    count(DISTINCT event_type) AS type_cardinality,
    avg(pg_column_size(payload)) AS avg_payload_bytes,
    avg(pg_column_size(events.*)) AS avg_row_bytes
FROM events
TABLESAMPLE SYSTEM (0.1);  -- 0.1% sample, fast enough
```

**Estimation rules of thumb (from the timescaledb-tuning reference):**

- `timestamptz` at regular intervals: 20-50x (delta encoding)
- `text` with low cardinality (device_id with ~5000 devices): 5-15x (dictionary encoding)
- `text` with low cardinality (event_type with ~20 types): 10-30x
- `smallint` (severity): 10-20x (run-length encoding on repeated values)
- `jsonb` (payload, varied): 2-5x
- `boolean` (processed): 20-50x (run-length encoding)

**Overall estimate for this dataset:** 8-15x compression. At 200 GB raw data, expect 13-25 GB compressed. Conservative estimate: 25 GB.

### 1.4 Benchmark Current Performance

Capture before-metrics. You will need these for the post-migration validation:

```sql
-- Save these results somewhere permanent:

-- Query 1: Recent device events (API pattern)
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM events
WHERE device_id = 'sensor-42' AND created_at > now() - INTERVAL '1 hour'
ORDER BY created_at DESC LIMIT 50;
-- Record: execution time, buffers hit/read, rows scanned

-- Query 2: 90-day hourly aggregation (dashboard pattern)
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT date_trunc('hour', created_at) AS hour, count(*), avg(severity)
FROM events
WHERE created_at > now() - INTERVAL '90 days'
GROUP BY 1 ORDER BY 1;
-- Record: execution time (this will be 3-8 seconds)

-- Query 3: Device+type aggregation (ETL pattern)
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT device_id, event_type, count(*), avg(severity)
FROM events
WHERE created_at BETWEEN '2026-01-01' AND '2026-04-01'
GROUP BY 1, 2;
-- Record: execution time

-- Overall stats:
SELECT
    pg_size_pretty(pg_total_relation_size('events')) AS total_size,
    pg_size_pretty(pg_indexes_size('events')) AS index_size,
    (SELECT count(*) FROM events) AS row_count;
```

---

## Phase 2: Migration Plan

### 2.1 Decision: Chunk Interval

The chunk interval determines how much data is in each chunk. Use this math:

```
Write rate:          3,000 rows/sec
Average row size:    ~400 bytes (data + overhead)
Bytes per second:    3,000 × 400 = 1.2 MB/sec
Bytes per day:       1.2 × 86,400 = ~104 MB/day (raw data only)
Bytes per day with indexes: ~250 MB/day

shared_buffers:      8 GB (assumed)
Target chunk size:   25% of shared_buffers = 2 GB

Days per chunk:      2 GB / 250 MB = 8 days
```

**Decision: 7-day (1 week) chunk interval.** This aligns with the 25% rule, gives round calendar boundaries, and at 2 years of retention produces ~104 chunks -- well under the 2000-chunk planner overhead threshold.

### 2.2 Decision: Compression Settings

Based on the query patterns from 1.2:

| Decision | Value | Reasoning |
|----------|-------|-----------|
| `compress_segmentby` | `device_id` | Most queries filter by `device_id`. This means only segments matching the target device are decompressed. |
| `compress_orderby` | `time DESC` | Within each device's segment, time-ordering gives excellent delta-encoding compression on timestamps and groups temporally-adjacent events for efficient range scans. |
| Compress after | 7 days | Keep the most recent week uncompressed for low-latency writes and the `processed` flag updates. Everything older is read-mostly. |

**Why not `segmentby = 'device_id, event_type'`?** Adding `event_type` would improve queries that filter on both, but at the cost of compression ratio (more segments = fewer rows per segment = less repetition). Since only the ETL query filters on `event_type` (and it runs nightly, not real-time), the trade-off favors better compression.

### 2.3 Decision: Continuous Aggregates

Two CAggs to build:

```
1. events_hourly:  time_bucket('1 hour'), device_id
   - Serves: Grafana dashboards, 90-day window queries
   - Refresh: every 5 minutes, end_offset = 5 minutes (near-real-time)

2. events_daily:   time_bucket('1 day'), device_id, event_type
   - Serves: Nightly ETL, monthly reports
   - Built on: events_hourly (hierarchical CAgg)
   - Refresh: every hour
```

### 2.4 Decision: Retention Policy

```
Raw data retention:     90 days (drop_chunks)
events_hourly retention: 1 year
events_daily retention:  5 years (or no retention -- tiny)
```

**The CAgg retention must be longer than the raw data retention.** The CAggs preserve the aggregated historical data after the raw data is dropped.

### 2.5 High-Level Migration Steps

```
Step 1: Install TimescaleDB extension                    [5 min,  reversible]
Step 2: Create new hypertable schema                     [1 min,  reversible]
Step 3: Migrate data from old partitioned table          [4-8 hr, reversible until step 7]
Step 4: Create indexes on hypertable                     [1-3 hr, reversible]
Step 5: Validate data integrity                          [30 min, checkpoint]
Step 6: Swap table names (cutover)                       [<1 sec, POINT OF NO RETURN for writes]
Step 7: Enable compression + retention policies          [5 min,  reversible]
Step 8: Create continuous aggregates                     [30-60 min, reversible]
Step 9: Validate performance                             [30 min]
Step 10: Clean up old partitioned table                  [5 min,  irreversible]
```

**Total estimated time: 6-14 hours.** The bulk is data migration (step 3). This can run during off-peak with the old table still serving live traffic.

---

## Phase 3: Execution

### Step 1: Install TimescaleDB Extension

**Estimated time:** 5 minutes.
**Locks acquired:** None on user tables.
**Rollback:** `DROP EXTENSION timescaledb CASCADE;`

```sql
-- Prerequisite: TimescaleDB package must be installed on the server.
-- Verify it's available:
SELECT * FROM pg_available_extensions WHERE name = 'timescaledb';

-- If not listed, install the package first (OS-level, requires server restart):
-- Debian/Ubuntu: apt install timescaledb-2-postgresql-16
-- RHEL/Fedora:   dnf install timescaledb-2-postgresql-16

-- Add to shared_preload_libraries (requires restart):
-- In postgresql.conf:
--   shared_preload_libraries = 'timescaledb'
-- Then: systemctl restart postgresql

-- After restart, create the extension:
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- Verify:
SELECT extversion FROM pg_extension WHERE extname = 'timescaledb';
-- Should return 2.x
```

**Rollback (Step 1):**
```sql
DROP EXTENSION timescaledb CASCADE;
-- Remove from shared_preload_libraries in postgresql.conf
-- Restart PostgreSQL
```

### Step 2: Create New Hypertable Schema

**Estimated time:** 1 minute.
**Locks acquired:** None on existing tables.
**Rollback:** `DROP TABLE events_ts;`

We create the hypertable as a new table, NOT by converting the existing table. Why? The existing table is partitioned, has 500M rows, and is serving live traffic. Converting in-place with `create_hypertable(migrate_data => true)` would:
- Lock the table for the entire migration duration (hours)
- Require memory proportional to the largest batch being sorted (~2x working set for the sort)
- Leave no rollback path if something goes wrong mid-migration

Instead, we use a **side-by-side migration**: create a new hypertable, copy data, swap names.

```sql
-- Create the new table (not yet a hypertable):
CREATE TABLE events_ts (
    created_at  timestamptz NOT NULL,
    device_id   text NOT NULL,
    event_type  text NOT NULL,
    severity    smallint NOT NULL DEFAULT 0,
    payload     jsonb NOT NULL DEFAULT '{}',
    processed   boolean NOT NULL DEFAULT false
);

-- Notice: no 'id' column. The bigint identity PK was never used in queries --
-- it was a holdover from OLTP design. In time-series, the natural key is
-- (device_id, created_at). If you need a unique row identifier, use
-- (device_id, created_at) as a composite, or add a UUID column.
-- Dropping 'id' saves 8 bytes/row × 500M = 4 GB of storage.

-- Convert to hypertable:
SELECT create_hypertable('events_ts', by_range('created_at', INTERVAL '7 days'));
```

**Why `INTERVAL '7 days'`?** See the math in Phase 2.1. One week of data at our write rate fits within 25% of an 8 GB `shared_buffers` allocation.

**Rollback (Step 2):**
```sql
DROP TABLE events_ts;
```

### Step 3: Migrate Data

**Estimated time:** 4-8 hours for 500M rows.
**Locks acquired:** `ACCESS SHARE` on source table (does not block writes).
**Rollback:** `TRUNCATE events_ts;` (or `DROP TABLE events_ts;`)

**Critical: Do NOT try to migrate all 500M rows in a single `INSERT...SELECT`.** It will:
- Consume massive memory for sorting into chunk boundaries
- Generate enormous WAL (potentially filling your disk)
- Create a single long-running transaction that blocks autovacuum

Instead, migrate in time-range batches:

```sql
-- First, check the time range to migrate:
SELECT min(created_at), max(created_at) FROM events;
-- e.g., 2024-07-01 00:00:00+00 to 2026-05-27 12:00:00+00

-- Migrate one month at a time (adjust batch size based on your I/O capacity):
-- This can be scripted. Each batch is an independent transaction.

-- Example: migrate January 2025
INSERT INTO events_ts (created_at, device_id, event_type, severity, payload, processed)
SELECT created_at, device_id, event_type, severity, payload, processed
FROM events
WHERE created_at >= '2025-01-01' AND created_at < '2025-02-01';

-- Check progress:
SELECT count(*) FROM events_ts;
-- Check chunk creation:
SELECT chunk_name, range_start, range_end
FROM timescaledb_information.chunks
WHERE hypertable_name = 'events_ts'
ORDER BY range_start DESC;
```

**Realistic timing per monthly batch:**

| Batch Size | Rows | Duration | WAL Generated |
|-----------|------|----------|---------------|
| 1 month (~26M rows) | ~26M | 15-25 min | ~10-15 GB |
| 1 week (~7M rows) | ~7M | 4-7 min | ~3-4 GB |

**Total for 24 months: ~6-10 hours** at 1-month batches, less with parallelism.

**Speeding it up with parallel batches:**

If you have the I/O headroom, run multiple month batches in parallel from separate sessions:

```bash
# Shell script (simplified) -- run 3-4 in parallel:
for month in 2024-07 2024-08 2024-09 ...; do
  start="${month}-01"
  end=$(date -d "${start} + 1 month" +%Y-%m-%d)
  psql -c "INSERT INTO events_ts (created_at, device_id, event_type, severity, payload, processed)
           SELECT created_at, device_id, event_type, severity, payload, processed
           FROM events WHERE created_at >= '${start}' AND created_at < '${end}';" &
done
wait
```

**Warning on parallel migration:** Each session writes to different chunks (different time ranges), so there is no row-level contention. But they all compete for I/O bandwidth and WAL writes. Monitor disk throughput and WAL generation rate:

```sql
-- In a separate session, monitor during migration:
SELECT
    pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), '0/0')) AS total_wal_generated,
    pg_size_pretty(pg_total_relation_size('events_ts')) AS new_table_size;

-- Monitor I/O wait:
SELECT wait_event_type, wait_event, count(*)
FROM pg_stat_activity
WHERE state = 'active' AND pid != pg_backend_pid()
GROUP BY 1, 2
ORDER BY 3 DESC;
```

**Handling the gap: data arriving during migration.**

While the migration runs (4-8 hours), new rows are being inserted into the old `events` table at 3,000/sec. That's up to ~86M rows that arrive during migration and are not yet in `events_ts`.

Strategy: After migrating historical data, run a "catch-up" batch:

```sql
-- After all historical batches complete, catch up:
INSERT INTO events_ts (created_at, device_id, event_type, severity, payload, processed)
SELECT created_at, device_id, event_type, severity, payload, processed
FROM events
WHERE created_at >= '2026-05-27'  -- start of migration day
  AND created_at < now() - INTERVAL '1 minute';  -- small buffer to avoid race conditions
```

**Rollback (Step 3):**
```sql
-- If something goes wrong during data migration:
TRUNCATE events_ts;
-- Or drop and recreate:
DROP TABLE events_ts;
-- Then start over from Step 2
```

### Step 4: Create Indexes on Hypertable

**Estimated time:** 1-3 hours.
**Locks acquired:** `ShareLock` per chunk (does NOT block reads or writes if using CONCURRENTLY-equivalent approach, but TimescaleDB index creation on hypertables is NOT `CONCURRENTLY` by default).
**Rollback:** `DROP INDEX idx_name;`

```sql
-- IMPORTANT: Create indexes AFTER data migration, not before.
-- Building indexes on an empty table and then bulk-loading forces index
-- maintenance on every INSERT. Building afterward does a single efficient sort.

-- Primary access pattern: device + time range
CREATE INDEX idx_events_ts_device_time
    ON events_ts (device_id, created_at DESC);

-- Event type filtering (for ETL and filtered dashboards)
CREATE INDEX idx_events_ts_type_time
    ON events_ts (event_type, created_at DESC);

-- Unprocessed events (partial index -- tiny, only covers recent unprocessed rows)
CREATE INDEX idx_events_ts_unprocessed
    ON events_ts (created_at)
    WHERE processed = false;

-- NOTE: We dropped idx_events_created (standalone time index).
-- Chunk exclusion handles time filtering -- a standalone time index
-- within a chunk has very low selectivity (all rows in the chunk are
-- in the chunk's time range). It wastes space and slows writes.
-- See timescaledb-tuning.md, Section 5: "Indexes You Don't Need"
```

**Index creation timing:** Each index on 500M rows across ~104 chunks takes 20-40 minutes. Three indexes: 60-120 minutes total.

**Monitoring index creation:**

```sql
-- Check progress of long-running index builds:
SELECT pid, phase, blocks_total, blocks_done,
       round(100.0 * blocks_done / NULLIF(blocks_total, 0), 1) AS pct_done
FROM pg_stat_progress_create_index;
```

**Rollback (Step 4):**
```sql
DROP INDEX idx_events_ts_device_time;
DROP INDEX idx_events_ts_type_time;
DROP INDEX idx_events_ts_unprocessed;
```

### Step 5: Validate Data Integrity

**Estimated time:** 30 minutes.
**Locks acquired:** None (read-only queries).

```sql
-- 1. Row count comparison:
SELECT
    (SELECT count(*) FROM events) AS old_count,
    (SELECT count(*) FROM events_ts) AS new_count;
-- The new count should be slightly less (we excluded the most recent minute in the catch-up).
-- Difference should be < write_rate × 60 = ~180,000 rows.

-- 2. Per-month row count comparison:
SELECT
    date_trunc('month', created_at) AS month,
    count(*) AS new_rows
FROM events_ts
GROUP BY 1
ORDER BY 1;

-- Compare with:
SELECT
    date_trunc('month', created_at) AS month,
    count(*) AS old_rows
FROM events
GROUP BY 1
ORDER BY 1;

-- Counts should match exactly for all completed months.

-- 3. Checksum a sample of rows:
-- Pick a random hour and verify all columns match:
SELECT md5(string_agg(
    device_id || event_type || severity::text || payload::text || processed::text,
    '' ORDER BY created_at, device_id
)) AS checksum
FROM events
WHERE created_at >= '2025-06-15 10:00' AND created_at < '2025-06-15 11:00';

SELECT md5(string_agg(
    device_id || event_type || severity::text || payload::text || processed::text,
    '' ORDER BY created_at, device_id
)) AS checksum
FROM events_ts
WHERE created_at >= '2025-06-15 10:00' AND created_at < '2025-06-15 11:00';

-- Checksums must match.

-- 4. Verify chunk structure:
SELECT
    chunk_name,
    range_start,
    range_end,
    pg_size_pretty(
        pg_total_relation_size(format('%I.%I', chunk_schema, chunk_name)::regclass)
    ) AS chunk_size
FROM timescaledb_information.chunks
WHERE hypertable_name = 'events_ts'
ORDER BY range_start;

-- Verify: chunks cover the full time range, no gaps, sizes are reasonable.

-- 5. Verify indexes exist on chunks:
SELECT count(DISTINCT chunk_name) AS chunks_with_device_idx
FROM timescaledb_information.chunks c
WHERE hypertable_name = 'events_ts'
  AND EXISTS (
    SELECT 1 FROM pg_indexes
    WHERE tablename = c.chunk_name
      AND indexname LIKE '%device_time%'
  );
-- Should equal total chunk count.
```

**If validation fails:** Go back to Step 3. Do NOT proceed to the cutover.

### Step 6: Cutover (Swap Table Names)

**Estimated time:** <1 second (DDL, almost instant).
**Locks acquired:** `ACCESS EXCLUSIVE` on both tables (brief).
**THIS IS THE POINT OF NO RETURN FOR WRITES.** After this, new writes go to the hypertable.

The cutover must be atomic. We rename both tables in a single transaction:

```sql
BEGIN;

-- Final catch-up: migrate any rows written since the last catch-up batch.
-- This is a small batch (seconds of data) because we're in a transaction holding a lock.
INSERT INTO events_ts (created_at, device_id, event_type, severity, payload, processed)
SELECT created_at, device_id, event_type, severity, payload, processed
FROM events
WHERE created_at >= (SELECT max(created_at) FROM events_ts);

-- Swap names:
ALTER TABLE events RENAME TO events_old;
ALTER TABLE events_ts RENAME TO events;

COMMIT;
```

**The lock duration is milliseconds.** The `INSERT` in the transaction is tiny (a few hundred rows at most). The `ALTER TABLE ... RENAME` is instant DDL.

**Application impact:** Any in-flight queries on the old table will fail with "relation does not exist" if they started between the rename and their execution. In practice, with a <100ms lock window, this is indistinguishable from a brief network hiccup. Connection pools will retry transparently.

**Rollback (Step 6):**
```sql
BEGIN;
ALTER TABLE events RENAME TO events_ts;
ALTER TABLE events_old RENAME TO events;
COMMIT;
-- Application is back on the old partitioned table.
```

### Step 7: Enable Compression and Retention Policies

**Estimated time:** 5 minutes (policy creation is instant; actual compression runs asynchronously).
**Locks acquired:** None on user data (metadata only).

```sql
-- Enable compression settings:
ALTER TABLE events SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'device_id',
    timescaledb.compress_orderby = 'created_at DESC'
);

-- Add compression policy: compress chunks older than 7 days
SELECT add_compression_policy('events', compress_after => INTERVAL '7 days');

-- Add retention policy: drop chunks older than 90 days
SELECT add_retention_policy('events', drop_after => INTERVAL '90 days');

-- Verify policies are registered:
SELECT * FROM timescaledb_information.jobs
WHERE hypertable_name = 'events';
```

**What happens next:** TimescaleDB's background workers will start compressing chunks older than 7 days. With ~90 chunks to compress, this will take several hours but runs entirely in the background with no impact on reads or writes.

**Monitoring compression progress:**

```sql
-- Check which chunks are compressed:
SELECT
    chunk_name,
    range_start,
    is_compressed,
    pg_size_pretty(before_compression_total_bytes) AS raw_size,
    pg_size_pretty(after_compression_total_bytes) AS compressed_size,
    CASE WHEN before_compression_total_bytes > 0
        THEN round(before_compression_total_bytes::numeric /
                    NULLIF(after_compression_total_bytes, 0), 1)
        ELSE NULL END AS ratio
FROM timescaledb_information.chunks
WHERE hypertable_name = 'events'
ORDER BY range_start DESC;
```

**Rollback (Step 7):**
```sql
-- Remove policies:
SELECT remove_compression_policy('events');
SELECT remove_retention_policy('events');

-- Decompress all chunks (if any were compressed):
SELECT decompress_chunk(chunk, if_compressed => true)
FROM show_chunks('events') AS chunk;

-- Disable compression:
ALTER TABLE events SET (timescaledb.compress = false);
```

### Step 8: Create Continuous Aggregates

**Estimated time:** 30-60 minutes (initial materialization scans raw data).
**Locks acquired:** `ACCESS SHARE` on raw data during refresh.

```sql
-- Hourly aggregate (from raw data):
CREATE MATERIALIZED VIEW events_hourly
WITH (timescaledb.continuous) AS
SELECT
    time_bucket('1 hour', created_at) AS bucket,
    device_id,
    count(*) AS event_count,
    avg(severity) AS avg_severity,
    sum(CASE WHEN severity >= 3 THEN 1 ELSE 0 END) AS critical_count,
    count(DISTINCT event_type) AS type_count
FROM events
GROUP BY bucket, device_id
WITH NO DATA;  -- Don't populate yet

-- Add refresh policy (near-real-time):
SELECT add_continuous_aggregate_policy('events_hourly',
    start_offset  => INTERVAL '3 days',     -- Re-aggregate up to 3 days back
    end_offset    => INTERVAL '5 minutes',   -- Don't aggregate the last 5 minutes
    schedule_interval => INTERVAL '5 minutes' -- Refresh every 5 minutes
);

-- Daily aggregate (from hourly -- hierarchical):
CREATE MATERIALIZED VIEW events_daily
WITH (timescaledb.continuous) AS
SELECT
    time_bucket('1 day', bucket) AS bucket,
    device_id,
    sum(event_count) AS event_count,
    -- IMPORTANT: weighted average, not avg(avg_severity)
    -- avg(avg_severity) would be WRONG unless all hours have equal event counts
    sum(avg_severity * event_count) / NULLIF(sum(event_count), 0) AS avg_severity,
    sum(critical_count) AS critical_count
FROM events_hourly
GROUP BY 1, device_id
WITH NO DATA;

SELECT add_continuous_aggregate_policy('events_daily',
    start_offset  => INTERVAL '7 days',
    end_offset    => INTERVAL '1 hour',
    schedule_interval => INTERVAL '1 hour'
);

-- Now trigger initial materialization:
-- This will scan all raw data and populate the CAggs.
-- Do the hourly first (daily depends on it).
CALL refresh_continuous_aggregate('events_hourly', '2024-07-01', now());
-- This takes 20-40 minutes for 500M rows.

CALL refresh_continuous_aggregate('events_daily', '2024-07-01', now());
-- This takes 2-5 minutes (reads from events_hourly, not raw data).
```

**The weighted average trap:** Notice the daily CAgg uses `sum(avg_severity * event_count) / sum(event_count)` instead of `avg(avg_severity)`. This is mathematically correct. If hour 1 has 100 events with avg severity 2.0, and hour 2 has 10,000 events with avg severity 4.0, `avg(2.0, 4.0) = 3.0` but the true average is `(100×2 + 10000×4) / 10100 = 3.98`. The naive `avg(avg())` gives 3.0, which is wrong.

**Real-time mode is enabled by default.** Queries against `events_hourly` will UNION the materialized data with a live aggregation of the last 5 minutes. This means dashboards always show current data, with a ~5-minute delay on the historical portion.

**Rollback (Step 8):**
```sql
DROP MATERIALIZED VIEW events_daily;
DROP MATERIALIZED VIEW events_hourly;
```

### Step 9: Validate Performance

**Estimated time:** 30 minutes.
**This is the before/after comparison from Phase 1.4.**

```sql
-- Query 1: Recent device events (API pattern)
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM events
WHERE device_id = 'sensor-42' AND created_at > now() - INTERVAL '1 hour'
ORDER BY created_at DESC LIMIT 50;
-- Expected: chunk exclusion reduces scan to 1 chunk, index scan within chunk.
-- Target: <20 ms (same or better than before)

-- Query 2: 90-day hourly aggregation (dashboard pattern) -- USE THE CAGG
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT bucket, sum(event_count), avg(avg_severity)
FROM events_hourly
WHERE bucket > now() - INTERVAL '90 days'
GROUP BY 1 ORDER BY 1;
-- Expected: scans pre-aggregated data (~2160 hourly buckets × N devices)
-- Target: <100 ms (was 3-8 seconds)

-- Query 3: Device+type aggregation (ETL pattern) -- USE THE DAILY CAGG
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT device_id, sum(event_count) AS total_events
FROM events_daily
WHERE bucket >= '2026-01-01' AND bucket < '2026-04-01'
GROUP BY 1;
-- Expected: scans ~90 daily buckets × N devices
-- Target: <1 sec (was 45-120 seconds)

-- Storage comparison:
SELECT
    hypertable_name,
    pg_size_pretty(hypertable_size(format('%I.%I', hypertable_schema, hypertable_name)::regclass)) AS total_size
FROM timescaledb_information.hypertables;

-- Compare with original size:
SELECT pg_size_pretty(pg_total_relation_size('events_old')) AS old_total_size;
```

**Expected results after compression completes (hours/days later):**

| Metric | Before | After |
|--------|--------|-------|
| Total storage | 320 GB | 20-40 GB |
| 90-day dashboard query | 3-8 sec | 10-50 ms |
| ETL aggregation | 45-120 sec | 1-5 sec |
| Device API query | 5-20 ms | 5-20 ms |
| Weekly retention | 4-6 hours DELETE | Instant (drop_chunks) |

### Step 10: Clean Up Old Table

**Estimated time:** 5 minutes.
**THIS IS IRREVERSIBLE.** Do not run until you are confident the migration is successful. Wait at least 1-2 weeks.

```sql
-- After 1-2 weeks of stable operation:
DROP TABLE events_old;

-- Also clean up any migration artifacts:
-- (None in this approach -- the old table was the only artifact)
```

---

## Phase 4: Post-Migration Tuning

### PostgreSQL Settings Adjustments

TimescaleDB workloads need different PostgreSQL tuning than generic OLTP. Adjust these in `postgresql.conf`:

```ini
# Increase for chunk-per-table autovacuum (more tables = more vacuum workers needed):
autovacuum_max_workers = 6              # up from 3-5

# Lower naptime since there are many more tables (chunks) to check:
autovacuum_naptime = 15s                # down from 30-60s

# Increase WAL capacity for ingest + compression I/O:
max_wal_size = 8GB                      # up from 1-4 GB
checkpoint_timeout = 15min              # up from 5 min

# Higher work_mem for time-series aggregations (more sorting):
work_mem = 64MB                         # up from 16-32 MB

# More parallel workers (aggregation queries benefit):
max_parallel_workers_per_gather = 4     # up from 2
max_parallel_workers = 8

# TimescaleDB background workers (compression + CAgg refresh + retention):
timescaledb.max_background_workers = 8

# Ensure WAL compression is on (heavy write workload):
wal_compression = lz4
```

### Per-Hypertable Autovacuum Tuning

The most recent chunk (actively receiving writes) needs aggressive vacuuming. Old chunks are append-only and need very little.

```sql
ALTER TABLE events SET (
    autovacuum_vacuum_scale_factor = 0.02,    -- 2% dead tuples, not 20%
    autovacuum_analyze_scale_factor = 0.01     -- re-analyze at 1%
);
```

### Monitoring Setup

Add these to your monitoring/alerting:

```sql
-- 1. Chunk count (alert if >2000):
SELECT count(*) FROM timescaledb_information.chunks WHERE hypertable_name = 'events';

-- 2. Compression ratio (alert if <3x):
SELECT * FROM hypertable_compression_stats('events');

-- 3. Job health (alert on failures):
SELECT
    j.proc_name,
    js.last_run_status,
    js.last_run_started_at,
    js.total_failures
FROM timescaledb_information.jobs j
JOIN timescaledb_information.job_stats js USING (job_id)
WHERE j.hypertable_name = 'events';

-- 4. Buffer pool hit ratio on recent chunks (alert if <95%):
-- Use pg_statio_user_tables on the most recent chunk:
SELECT
    relname,
    heap_blks_hit,
    heap_blks_read,
    round(100.0 * heap_blks_hit /
          NULLIF(heap_blks_hit + heap_blks_read, 0), 2) AS hit_ratio
FROM pg_statio_user_tables
WHERE relname LIKE '_hyper%'
ORDER BY heap_blks_read DESC
LIMIT 5;

-- 5. CAgg freshness (alert if materialized_end is >30min behind now()):
SELECT
    view_name,
    completed_threshold
FROM timescaledb_information.continuous_aggregate_stats;
```

---

## Phase 5: Rollback Plan (At Each Stage)

### If Things Go Wrong During Migration (Steps 1-5)

The old table is untouched. Simply:

```sql
DROP TABLE IF EXISTS events_ts CASCADE;
DROP EXTENSION IF EXISTS timescaledb CASCADE;
-- Remove timescaledb from shared_preload_libraries, restart PostgreSQL.
-- You're back to exactly where you started.
```

### If Things Go Wrong After Cutover (Step 6)

```sql
-- Swap names back:
BEGIN;
ALTER TABLE events RENAME TO events_ts;
ALTER TABLE events_old RENAME TO events;
COMMIT;
-- Application is back on the old partitioned table.
-- You've lost writes that went to events_ts during the outage.
-- If the window is small (minutes), export them:
--   COPY (SELECT * FROM events_ts WHERE created_at > 'cutover_timestamp') TO '/tmp/missed.csv';
-- Then import into events:
--   COPY events FROM '/tmp/missed.csv';
```

### If Things Go Wrong After Old Table Is Dropped (Step 10)

You cannot go back to the old partitioned table. But you can:
1. Disable TimescaleDB features: drop CAggs, remove policies, decompress chunks
2. The hypertable still functions as a normal (chunked) PostgreSQL table
3. If you must go back to plain PG partitioning, create the old schema and `INSERT INTO events_old SELECT * FROM events` -- a long operation, but possible

### The Golden Rule

**Do not drop the old table until you have run on the new table for at least 1-2 weeks in production.** The old table costs ~320 GB of storage. That is cheap insurance against a surprise that doesn't show up until the second Tuesday of the month.

---

## Gotchas and War Stories

### 1. The `migrate_data => true` Trap

`create_hypertable('existing_table', ..., migrate_data => true)` will convert a regular table to a hypertable and move data into chunks in a single operation. Do NOT use this on a 500M-row table because:

- It acquires `ACCESS EXCLUSIVE` lock for the entire duration (hours)
- It sorts the entire table by time column -- requiring `work_mem` proportional to the dataset (or spilling to disk, which is even slower)
- There is no resume-from-checkpoint if it fails mid-way
- There is no rollback -- the original table structure is destroyed

We used the side-by-side migration (Steps 2-6) specifically to avoid this.

### 2. Out-of-Order Inserts into Compressed Chunks

After compression is enabled, if your application tries to INSERT a late-arriving event (timestamp older than 7 days), the INSERT will route to a compressed chunk and **fail** on TimescaleDB versions before 2.11. On 2.11+, it will decompress the target chunk segment, insert the row, and leave it for the next compression cycle.

**If your application regularly receives late data (>7 days late):**

```sql
-- Option A: Increase the compression delay:
SELECT remove_compression_policy('events');
SELECT add_compression_policy('events', compress_after => INTERVAL '30 days');

-- Option B: Accept the decompression cost (2.11+):
-- Just make sure the chunk gets re-compressed eventually.
-- The compression policy will handle this on its next run.
```

### 3. The `processed` Flag Problem

We have `UPDATE events SET processed = true WHERE ...` running on recent data. After compression, this UPDATE hits compressed chunks and either fails (pre-2.11) or triggers decompression (2.11+). Solutions:

1. **Keep the compression window larger than the processing window.** If events are processed within 24 hours, compressing after 7 days is safe.
2. **Move the `processed` flag to a separate table.** A small `event_processing_status` table with `(device_id, created_at, processed)` avoids touching the hypertable entirely.
3. **Redesign the pipeline** to not need an UPDATE -- process events via a queue or streaming system and never mark them in the database.

### 4. Chunk Creation Lock

When TimescaleDB creates a new chunk (a new 7-day interval starts), it briefly acquires an `ACCESS EXCLUSIVE` lock on the hypertable's catalog metadata. This is milliseconds-long but can cause a brief stall in high-concurrency INSERT workloads.

The mitigation is simple: the first INSERT into a new time interval triggers chunk creation. If your ingest runs continuously (3,000 rows/sec), the first row at midnight Sunday creates the chunk, and all subsequent rows that week route to it without any lock.

### 5. Planner Overhead with Many Chunks

At 104 chunks (2 years × 52 weeks / 7-day intervals... well, 104 weeks), planning overhead is negligible. But if you later change to 1-day chunks or extend retention, you could hit 700+ chunks. At that point:

- `EXPLAIN` starts taking 50-100ms just for planning
- Increase `plan_cache_mode = force_custom_plan` if you see poor plans from generic plans
- Consider increasing chunk interval or being more aggressive with retention

### 6. pg_dump and Hypertables

`pg_dump` does NOT back up TimescaleDB hypertable data correctly by default. The dump will include the parent table DDL and chunk DDL, but restoring it requires TimescaleDB to be installed and configured on the target.

Use `timescaledb-backup` or ensure your restore target has TimescaleDB:

```bash
# Dump with TimescaleDB support:
pg_dump -Fc -f backup.dump mydb

# Restore to a server with TimescaleDB installed:
pg_restore -d mydb backup.dump
# TimescaleDB's restore hooks handle hypertable reconstruction.
```

---

## Quick Reference Card

| Operation | Command |
|-----------|---------|
| Check chunk count | `SELECT count(*) FROM timescaledb_information.chunks WHERE hypertable_name = 'events';` |
| Check compression status | `SELECT * FROM hypertable_compression_stats('events');` |
| Manually compress a chunk | `SELECT compress_chunk('_timescaledb_internal._hyper_X_Y_chunk');` |
| Manually decompress | `SELECT decompress_chunk('_timescaledb_internal._hyper_X_Y_chunk');` |
| Drop old chunks | `SELECT drop_chunks('events', older_than => INTERVAL '90 days');` |
| Refresh CAgg manually | `CALL refresh_continuous_aggregate('events_hourly', '2026-05-01', now());` |
| Check job health | `SELECT * FROM timescaledb_information.job_stats;` |
| Change chunk interval | `SELECT set_chunk_time_interval('events', INTERVAL '1 day');` (future chunks only) |
| List all policies | `SELECT * FROM timescaledb_information.jobs WHERE hypertable_name = 'events';` |
| Total hypertable size | `SELECT pg_size_pretty(hypertable_size('events'));` |
