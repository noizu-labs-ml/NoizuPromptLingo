# TimescaleDB Performance Tuning Reference

> Target audience: senior developers running TimescaleDB 2.x on PostgreSQL 14-17.
> Philosophy: TimescaleDB is PostgreSQL with time-series superpowers. Tune PostgreSQL first, then tune the superpowers. Most TimescaleDB performance problems are PostgreSQL problems wearing a trench coat.

---

## 1. Architecture: Hypertables and Chunks

### How Hypertables Work Internally

A hypertable is a virtual table. When you create one, TimescaleDB replaces the single PostgreSQL table with a parent table (empty, never stores data) and a set of **chunks** — real PostgreSQL tables partitioned by time (and optionally by space).

```sql
-- This:
SELECT create_hypertable('metrics', by_range('time'));

-- Creates a parent table 'metrics' and will auto-create child tables like:
-- _timescaledb_internal._hyper_1_1_chunk  (2024-01-01 to 2024-01-08)
-- _timescaledb_internal._hyper_1_2_chunk  (2024-01-08 to 2024-01-15)
-- ...
```

**Each chunk is a regular PostgreSQL table.** It has its own indexes, its own TOAST tables, its own autovacuum schedule. This is both the power and the complexity:

- VACUUM operates per-chunk (much faster than vacuuming a single massive table)
- Indexes are per-chunk (smaller, fit in cache, faster to rebuild)
- `DROP CHUNKS` detaches and drops the chunk table (instant, no dead tuples)
- But: the planner must consider many child tables (planning overhead with 1000+ chunks)

### Chunk Sizing — The Decision Nobody Gets Right

```sql
-- Default chunk interval: 7 days
-- You can set it at creation or change it later:
SELECT create_hypertable('metrics', by_range('time', INTERVAL '1 day'));

-- Change for future chunks (existing chunks are unaffected):
SELECT set_chunk_time_interval('metrics', INTERVAL '1 day');
```

**The 25% Rule and When It Breaks**

TimescaleDB's documentation recommends each chunk should fit in ~25% of `shared_buffers`. The reasoning: active queries typically touch 1-2 chunks; at 25% per chunk, 2 active chunks + overhead still fit in the buffer pool.

```
Target chunk_interval = time_needed_to_write(shared_buffers * 0.25 / avg_row_size_with_indexes)
```

**When this rule breaks:**

| Scenario | Problem | Fix |
|----------|---------|-----|
| **Very high ingest rate** (100k+ rows/sec) | 25% of shared_buffers fills in minutes; chunks are tiny; thousands of chunks accumulate | Increase `shared_buffers` or accept larger chunks. Having 10,000+ chunks degrades planner performance. |
| **Wide rows** (50+ columns, JSONB payloads) | Each chunk has large indexes; 25% fills fast | Consider column pruning: move wide/infrequently-queried columns to a separate hypertable joined by time+id |
| **Queries span many chunks** (dashboards showing 90 days) | Even at 25%, 90 daily chunks don't all fit in cache | Use continuous aggregates for dashboard queries; keep raw data queries narrow |
| **Mixed workload** (ingest + real-time queries) | Ingest heats up the newest chunk; queries need older chunks | Ensure recent 2-3 chunks fit in memory; accept cache misses on older chunks |
| **Compression enabled** | Compressed chunks are much smaller than raw; the 25% rule overestimates | Compressed chunks can be larger time intervals since their memory footprint is 5-20x smaller |

**The real answer:** Start with 1-day intervals for high-ingest (>10k rows/sec), 1-week for moderate (1k-10k rows/sec), 1-month for low (<1k rows/sec). Then monitor chunk count and query patterns. Adjust if:
- Total chunk count exceeds ~2000 (planner overhead)
- `shared_buffers` hit ratio drops below 99% on recent-chunk queries
- `EXPLAIN ANALYZE` shows many chunks being scanned for typical queries

### The Chunk Cache

TimescaleDB maintains an in-memory cache mapping time ranges to chunk OIDs. This avoids catalog lookups on every INSERT/SELECT. The cache is per-backend (not shared).

**When the chunk cache causes problems:**
- After `DROP CHUNKS`, backends may hold stale cache entries. This is usually self-healing but can cause brief errors if you drop chunks while queries are running.
- With thousands of chunks, the cache consumes per-backend memory. On 500+ connections × 5000 chunks, this adds up.

---

## 2. INSERT Path — Understanding the Routing Cost

### How Inserts are Routed

When you `INSERT INTO metrics (time, value) VALUES (now(), 42)`:

1. TimescaleDB intercepts the INSERT via a custom executor hook
2. Looks up the target chunk using the time column value
3. If the chunk doesn't exist, creates it (including indexes, constraints)
4. Routes the row to the chunk table
5. The insert executes as a normal PostgreSQL INSERT into the chunk

**Step 3 is expensive.** Chunk creation acquires locks, creates a table, creates all indexes that exist on the parent. On a cold start with auto-creation, the first INSERT into a new time interval can take 50-500ms. Subsequent inserts into the same chunk are normal-speed.

**Mitigation:**
```sql
-- Pre-create future chunks to avoid creation delay during ingest:
SELECT add_dimension_slice('metrics', 'time', 
  INTERVAL '1 day',
  if_not_exists => TRUE
);

-- Or use the chunks API to pre-create:
-- (In practice, just ensure your ingest starts a few seconds before the new interval)
```

### Batched Inserts — The 10x Speedup

Single-row INSERTs into hypertables have ~2-3x overhead versus a regular PostgreSQL table (routing logic). Batched inserts amortize this cost.

```sql
-- Bad: single-row inserts (N round trips, N routing lookups)
INSERT INTO metrics (time, device_id, value) VALUES (now(), 1, 42);
INSERT INTO metrics (time, device_id, value) VALUES (now(), 2, 43);

-- Good: multi-row INSERT (1 round trip, routing batched)
INSERT INTO metrics (time, device_id, value) VALUES
  (now(), 1, 42),
  (now(), 2, 43),
  (now(), 3, 44),
  ...;  -- 1000+ rows per batch

-- Best: COPY (bypasses SQL parser, fastest path)
COPY metrics (time, device_id, value) FROM STDIN;
```

**Realistic benchmarks** (single-node, 16 cores, NVMe):

| Method | Rows/sec | Notes |
|--------|----------|-------|
| Single INSERT | 5,000-10,000 | Connection overhead dominates |
| Batched INSERT (1000 rows) | 50,000-100,000 | Sweet spot for most applications |
| COPY | 200,000-500,000 | Best for bulk loading; requires driver support |
| COPY with parallel workers | 500,000-1,000,000+ | TimescaleDB parallel COPY (2.12+) |

### Out-of-Order Inserts

TimescaleDB handles out-of-order inserts (late-arriving data) by routing to the correct historical chunk. But there are costs:

- The historical chunk may not be in the buffer pool → cold read
- If the chunk is compressed → **INSERT FAILS by default.** You must decompress first or enable `INSERT ... ON CONFLICT` handling for compressed chunks
- Autovacuum may have already cleaned the chunk → additional cleanup needed

```sql
-- Allow inserts into compressed chunks (TimescaleDB 2.11+):
ALTER TABLE metrics SET (
  timescaledb.compress_orderby = 'time DESC',
  timescaledb.compress_segmentby = 'device_id'
);

-- For older versions: decompress, insert, re-compress
SELECT decompress_chunk('_timescaledb_internal._hyper_1_42_chunk');
INSERT INTO metrics VALUES (...);
SELECT compress_chunk('_timescaledb_internal._hyper_1_42_chunk');
```

---

## 3. Compression — The Make-or-Break Decision

### How Compression Works

TimescaleDB compression converts row-oriented chunk data into columnar arrays. Each compressed row in the compressed chunk contains an array of values for a "segment" of the original data.

```sql
-- Enable compression:
ALTER TABLE metrics SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'device_id',      -- Group by this column
  timescaledb.compress_orderby = 'time DESC'          -- Sort within each segment
);

-- Compress a specific chunk:
SELECT compress_chunk('_timescaledb_internal._hyper_1_1_chunk');

-- Or set a policy (compress chunks older than 7 days automatically):
SELECT add_compression_policy('metrics', INTERVAL '7 days');
```

### `compress_segmentby` — The Critical Decision

This is the most important compression decision. It determines how data is physically grouped within compressed chunks.

**Rule: `compress_segmentby` = the column(s) you filter by in WHERE clauses.**

```sql
-- If your queries look like:
SELECT * FROM metrics WHERE device_id = 'sensor-42' AND time > now() - INTERVAL '1 hour';

-- Then segmentby should be device_id:
timescaledb.compress_segmentby = 'device_id'
-- Each compressed "row" contains all data for one device_id.
-- The query only decompresses segments matching device_id='sensor-42'.
```

**What happens with the wrong segmentby:**

| Scenario | Symptom | Fix |
|----------|---------|-----|
| **Missing segmentby entirely** | Every query decompresses the entire chunk | Add the column you filter by to segmentby |
| **Too many segmentby columns** | Poor compression ratio (fewer rows per segment = less repetition to exploit) | Only include columns you actually filter by |
| **High-cardinality segmentby** | Thousands of segments per chunk; decompression overhead per segment | Consider whether you really need per-entity queries on old data; use continuous aggregates instead |
| **Segmentby on time** | Destroys compression (time is already the chunk boundary) | Never segmentby the time column |

### `compress_orderby` — Compression Ratio Booster

`compress_orderby` determines the sort order within each segment. Adjacent values that are similar compress better (delta encoding).

```sql
-- For metrics with natural time ordering:
timescaledb.compress_orderby = 'time DESC'

-- For multi-metric tables:
timescaledb.compress_orderby = 'metric_name, time DESC'
-- Groups same metric together, then sorts by time.
-- Delta encoding on time values yields excellent compression.
```

### Compression Ratio Expectations

| Data Type | Typical Compression Ratio | Notes |
|-----------|--------------------------|-------|
| `TIMESTAMPTZ` (regular intervals) | 20-50x | Delta + run-length encoding exploits regularity |
| `DOUBLE PRECISION` (sensor values) | 3-8x | Gorilla encoding; volatile data compresses less |
| `INTEGER` (counters, IDs) | 5-20x | Delta encoding works well on sequential/repeated values |
| `TEXT` (short, repeated) | 5-15x | Dictionary encoding for repeated strings |
| `TEXT` (long, unique) | 1.5-3x | LZ compression; unique strings compress poorly |
| `JSONB` | 2-5x | Depends on structural repetition |
| **Overall for IoT/metrics** | **10-20x** | With good segmentby/orderby choices |
| **Overall for event logs** | **3-8x** | More varied data compresses less |

### Querying Compressed Data

Queries on compressed chunks are transparent — you query the hypertable normally. But performance differs:

```sql
-- Fast on compressed data (segmentby filter):
SELECT avg(value) FROM metrics
WHERE device_id = 'sensor-42' AND time > now() - INTERVAL '30 days';
-- Only decompresses segments for device_id='sensor-42'. Excellent.

-- Slow on compressed data (no segmentby filter):
SELECT avg(value) FROM metrics
WHERE value > 100 AND time > now() - INTERVAL '30 days';
-- Must decompress ALL segments in matching chunks to check value > 100.

-- Very slow (aggregation across all segments):
SELECT device_id, avg(value) FROM metrics
WHERE time > now() - INTERVAL '90 days'
GROUP BY device_id;
-- Decompresses every segment in 90 days of chunks.
-- This is exactly what continuous aggregates are for.
```

---

## 4. Continuous Aggregates — Materialized Views That Actually Work

### How They Work Internally

A continuous aggregate (CAgg) is a materialized view that incrementally updates. Instead of recomputing the entire result on refresh, TimescaleDB tracks which chunks have changed and only re-aggregates those chunks.

```sql
CREATE MATERIALIZED VIEW metrics_hourly
WITH (timescaledb.continuous) AS
SELECT
  time_bucket('1 hour', time) AS bucket,
  device_id,
  avg(value) AS avg_value,
  min(value) AS min_value,
  max(value) AS max_value,
  count(*) AS sample_count
FROM metrics
GROUP BY bucket, device_id;

-- Add a refresh policy:
SELECT add_continuous_aggregate_policy('metrics_hourly',
  start_offset => INTERVAL '3 days',   -- Re-aggregate data this far back
  end_offset   => INTERVAL '1 hour',   -- Don't aggregate the most recent hour
  schedule_interval => INTERVAL '1 hour'  -- Run every hour
);
```

### Real-Time Mode vs Non-Real-Time

```sql
-- Real-time mode (default in 2.x):
ALTER MATERIALIZED VIEW metrics_hourly SET (timescaledb.materialized_only = false);

-- Non-real-time mode:
ALTER MATERIALIZED VIEW metrics_hourly SET (timescaledb.materialized_only = true);
```

**Real-time mode** queries combine the materialized data with a live query on un-materialized recent data. The user gets up-to-the-second results without waiting for the next refresh.

**Inside baseball: how real-time mode works:**

1. For time ranges already materialized: reads from the CAgg (fast, pre-aggregated)
2. For the time range between the last materialization and now: executes the original aggregation query on the raw hypertable (live, potentially slow)
3. UNIONs the two result sets

**When real-time mode hurts:**
- If the un-materialized window is large (e.g., 24 hours of raw data at 100k rows/sec = 8.6B rows to aggregate live)
- If the raw data is compressed (decompression + aggregation on every dashboard query)
- If many users hit the same dashboard simultaneously

**The fix:** Keep the `end_offset` small (1-5 minutes) and refresh frequently (every 1-5 minutes). This minimizes the live-query window.

### CAgg Refresh and Retention Interaction

**The trap:** If you have a retention policy (`drop_chunks`) and a continuous aggregate, and the retention policy drops chunks that the CAgg hasn't materialized yet, you lose data.

```sql
-- Safe ordering:
-- 1. CAgg refresh: materializes raw data into the aggregate
SELECT add_continuous_aggregate_policy('metrics_hourly',
  start_offset => INTERVAL '7 days',
  end_offset   => INTERVAL '1 hour',
  schedule_interval => INTERVAL '1 hour'
);

-- 2. Raw data retention: drops chunks AFTER they've been materialized
SELECT add_retention_policy('metrics', INTERVAL '7 days');

-- The start_offset MUST be >= the retention interval.
-- Otherwise: retention drops chunks before the CAgg reads them.
```

### Hierarchical Continuous Aggregates (2.9+)

Build CAggs on top of CAggs for multi-resolution queries:

```sql
-- Hourly aggregate (from raw data):
CREATE MATERIALIZED VIEW metrics_hourly
WITH (timescaledb.continuous) AS
SELECT time_bucket('1 hour', time) AS bucket, device_id, avg(value) AS avg_val
FROM metrics
GROUP BY bucket, device_id;

-- Daily aggregate (from hourly, NOT from raw):
CREATE MATERIALIZED VIEW metrics_daily
WITH (timescaledb.continuous) AS
SELECT time_bucket('1 day', bucket) AS bucket, device_id, avg(avg_val) AS avg_val
FROM metrics_hourly
GROUP BY bucket, device_id;
```

**Inside baseball:** The daily CAgg refreshes from the hourly CAgg, not from raw data. This is dramatically faster and doesn't touch compressed raw chunks. But: mathematical correctness requires care — `avg(avg(value))` is NOT the same as `avg(value)` unless all groups have equal counts. Use weighted averages or keep `count(*)` and `sum(value)` for proper reaggregation.

---

## 5. Advanced Continuous Aggregates and Materialization Internals

### Invalidation Tracking Internals

TimescaleDB tracks which time ranges in a continuous aggregate are stale using an **invalidation log**. Every DML operation (INSERT, UPDATE, DELETE) on the raw hypertable writes an entry to `_timescaledb_catalog.continuous_aggs_hypertable_invalidation_log`, recording the time range of the affected rows. During CAgg refresh, the scheduler consults this log plus the **invalidation threshold** stored in `_timescaledb_catalog.continuous_aggs_invalidation_threshold` to determine which buckets need re-aggregation.

```sql
-- Check the current invalidation threshold for a CAgg:
SELECT h.table_name AS hypertable,
       it.watermark
FROM _timescaledb_catalog.continuous_aggs_invalidation_threshold it
JOIN _timescaledb_catalog.hypertable h ON h.id = it.hypertable_id;

-- Monitor pending invalidations (entries not yet processed by refresh):
SELECT hypertable_id,
       lowest_modified_value,
       greatest_modified_value
FROM _timescaledb_catalog.continuous_aggs_hypertable_invalidation_log
ORDER BY lowest_modified_value DESC
LIMIT 20;
-- A large backlog here means refreshes aren't keeping up with writes.
```

**The invalidation hysteresis:** Refreshing the same time window twice does NOT re-aggregate data that hasn't changed. On the first refresh, TimescaleDB processes invalidation entries and moves them from the hypertable invalidation log to a per-CAgg materialization invalidation log (`_timescaledb_catalog.continuous_aggs_materialization_invalidation_log`). A second refresh of the same window finds no new invalidation entries and skips the work. This means over-scheduling refreshes is cheap — you pay only for the metadata check, not the aggregation.

**How DML creates invalidation entries:**

| Operation | Invalidation Behavior |
|-----------|----------------------|
| `INSERT` | Adds an entry for the time range of the inserted row(s) |
| `UPDATE` (time column unchanged) | Adds an entry for the time range of the affected row(s) |
| `UPDATE` (time column changed) | Adds entries for BOTH the old and new time ranges |
| `DELETE` | Adds an entry for the time range of the deleted row(s) |
| `COPY` | Same as batched INSERT — one invalidation entry spanning the min/max time of the batch |
| `DROP CHUNKS` | Invalidates the entire time range of the dropped chunk |

**Forced refresh after manual chunk manipulation:**

When you manually decompress, recompress, or move chunks, the invalidation log may not reflect the changes. Use the experimental force refresh to re-aggregate regardless of invalidation state:

```sql
-- Force refresh a specific window (useful after manual chunk surgery):
CALL refresh_continuous_aggregate('metrics_hourly',
  '2024-01-01'::timestamptz,
  '2024-01-08'::timestamptz
);
-- Note: the standard CALL syntax always refreshes the specified window.
-- The "force" behavior is implicit when you specify an explicit window —
-- it re-aggregates all buckets in the range, not just invalidated ones.

-- To refresh ONLY invalidated ranges (what the policy does):
-- Simply let the policy run. Manual CALL with explicit bounds always
-- re-aggregates the full window.
```

### Compressing Continuous Aggregates

CAggs are hypertables under the hood — they have chunks, indexes, and full hypertable capabilities. **You can and should compress them.**

```sql
-- Enable compression on a CAgg:
ALTER MATERIALIZED VIEW metrics_hourly SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'device_id',   -- Typically your GROUP BY dimension
  timescaledb.compress_orderby = 'bucket DESC'     -- The time bucket column
);

-- Add a compression policy:
SELECT add_compression_policy('metrics_hourly', compress_after => INTERVAL '30 days');
```

**segmentby/orderby for CAggs:**

| CAgg GROUP BY clause | Recommended segmentby | Recommended orderby | Rationale |
|---------------------|----------------------|--------------------:|-----------|
| `bucket, device_id` | `device_id` | `bucket DESC` | Query pattern filters by device, scans time ranges |
| `bucket, region, metric_name` | `region, metric_name` | `bucket DESC` | Multiple GROUP BY dimensions → all go in segmentby |
| `bucket` only (global aggregation) | *(omit segmentby)* | `bucket DESC` | No dimension to segment on; one segment per chunk |

**Compression ratio on pre-aggregated data:** Since CAgg rows are already aggregated (fewer rows, more uniform structure), compression ratios on CAggs are typically **5-15x** on top of the already-reduced data. Combined with the aggregation reduction, the total storage savings from raw data to compressed CAgg can be 100-1000x.

**Real-time mode + compressed CAgg chunks:**

When real-time mode is enabled and a query hits a time range that spans both compressed and uncompressed CAgg chunks, TimescaleDB transparently decompresses the compressed CAgg chunks on the fly. This is significantly cheaper than decompressing raw data because the CAgg has far fewer rows. In practice, the overhead is negligible for typical dashboard queries.

**Retention policies on CAggs:**

CAggs are hypertables, so you can add independent retention policies:

```sql
-- Keep raw data for 90 days, hourly CAgg for 1 year, daily CAgg for 5 years:
SELECT add_retention_policy('metrics', drop_after => INTERVAL '90 days');
SELECT add_retention_policy('metrics_hourly', drop_after => INTERVAL '1 year');
SELECT add_retention_policy('metrics_daily', drop_after => INTERVAL '5 years');

-- The CAgg retention policy drops CAgg chunks, NOT raw data.
-- Raw data retention is controlled by the policy on the raw hypertable.
```

**Worked example: multi-tier aggregation with compression and retention:**

```sql
-- === Tier 1: Raw data (90 days, compressed after 7 days) ===
ALTER TABLE metrics SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'device_id',
  timescaledb.compress_orderby = 'time DESC'
);
SELECT add_compression_policy('metrics', compress_after => INTERVAL '7 days');
SELECT add_retention_policy('metrics', drop_after => INTERVAL '90 days');

-- === Tier 2: Hourly CAgg (1 year, compressed after 30 days) ===
CREATE MATERIALIZED VIEW metrics_hourly
WITH (timescaledb.continuous) AS
SELECT time_bucket('1 hour', time) AS bucket, device_id,
       avg(value) AS avg_val, min(value) AS min_val, max(value) AS max_val,
       count(*) AS sample_count, sum(value) AS sum_val
FROM metrics
GROUP BY bucket, device_id;

SELECT add_continuous_aggregate_policy('metrics_hourly',
  start_offset => INTERVAL '3 days',
  end_offset   => INTERVAL '1 hour',
  schedule_interval => INTERVAL '1 hour'
);

ALTER MATERIALIZED VIEW metrics_hourly SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'device_id',
  timescaledb.compress_orderby = 'bucket DESC'
);
SELECT add_compression_policy('metrics_hourly', compress_after => INTERVAL '30 days');
SELECT add_retention_policy('metrics_hourly', drop_after => INTERVAL '1 year');

-- === Tier 3: Daily CAgg (5 years, compressed after 90 days) ===
-- Built from hourly CAgg, NOT raw data (hierarchical CAgg, 2.9+)
CREATE MATERIALIZED VIEW metrics_daily
WITH (timescaledb.continuous) AS
SELECT time_bucket('1 day', bucket) AS bucket, device_id,
       sum(sum_val) / sum(sample_count) AS avg_val,  -- Weighted average, mathematically correct
       min(min_val) AS min_val, max(max_val) AS max_val,
       sum(sample_count) AS sample_count
FROM metrics_hourly
GROUP BY 1, device_id;

SELECT add_continuous_aggregate_policy('metrics_daily',
  start_offset => INTERVAL '7 days',
  end_offset   => INTERVAL '1 day',
  schedule_interval => INTERVAL '1 day'
);

ALTER MATERIALIZED VIEW metrics_daily SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'device_id',
  timescaledb.compress_orderby = 'bucket DESC'
);
SELECT add_compression_policy('metrics_daily', compress_after => INTERVAL '90 days');
SELECT add_retention_policy('metrics_daily', drop_after => INTERVAL '5 years');

-- Storage footprint (example: 100 devices, 1 row/sec/device):
-- Raw:     ~864M rows/day → 90 days uncompressed ~= 200 GB, compressed ~= 15 GB
-- Hourly:  ~2,400 rows/day → 1 year ~= 50 MB compressed
-- Daily:   ~100 rows/day  → 5 years ~= 1 MB compressed
```

### CAgg on Compressed Source Hypertables

When a continuous aggregate refresh needs to re-aggregate data from a time range whose chunks are already compressed, TimescaleDB must **decompress → aggregate → store result**. This is the decompress-aggregate cycle, and it has real I/O cost.

```sql
-- What happens during refresh when source chunks are compressed:
-- 1. TimescaleDB identifies which source chunks overlap the refresh window
-- 2. For compressed chunks: reads compressed data, decompresses in memory
-- 3. Runs the aggregation query on the decompressed data
-- 4. Writes results to the CAgg's materialization hypertable
-- Note: the source chunks are NOT recompressed — they were read, not modified
```

**The I/O cost scales with refresh window size:**

| Refresh window | Source data state | I/O Cost | Duration (100 devices, 1 row/sec/device) |
|---------------|-------------------|----------|------------------------------------------|
| 1 hour | Uncompressed (recent) | Low | <1 second |
| 1 day | Mostly uncompressed | Low-Medium | 1-5 seconds |
| 7 days | Mix of compressed + uncompressed | Medium | 10-30 seconds |
| 30 days | Mostly compressed | High | 1-5 minutes |
| 90 days | All compressed | Very High | 5-20 minutes |

**Best practice:** Keep the refresh `start_offset` small enough that most of the refreshed data resides in **uncompressed recent chunks**. A good heuristic:

```
start_offset ≈ 2× the compression policy interval
```

For example, if you compress after 7 days, set `start_offset` to 14 days at most. This means the refresh window overlaps at most ~7 days of compressed data and ~7 days of uncompressed data.

```sql
-- GOOD: refresh window mostly hits uncompressed data
SELECT add_continuous_aggregate_policy('metrics_hourly',
  start_offset => INTERVAL '3 days',   -- compression_after = 7 days → all uncompressed
  end_offset   => INTERVAL '1 hour',
  schedule_interval => INTERVAL '1 hour'
);

-- BAD: refresh window hits mostly compressed data
SELECT add_continuous_aggregate_policy('metrics_hourly',
  start_offset => INTERVAL '90 days',  -- 83 of those days are compressed
  end_offset   => INTERVAL '1 hour',
  schedule_interval => INTERVAL '1 day'
);
-- This decompresses 83 days of data on every refresh — even if only 1 day changed.
-- Use manual CALL refresh_continuous_aggregate() for historical backfills instead.
```

### Indexing Continuous Aggregates

CAggs are hypertables, so they have per-chunk indexes — the same rules from the index strategy section apply.

**Default indexes created by TimescaleDB on CAggs:**

TimescaleDB automatically creates a composite index on the GROUP BY columns of the CAgg. For `GROUP BY bucket, device_id`, you get an index on `(device_id, bucket DESC)` per chunk (the exact index depends on the TimescaleDB version, but it's always based on the GROUP BY dimensions).

**When to add custom indexes on CAggs:**

```sql
-- If your CAgg queries filter by a dimension NOT in the default index:
-- e.g., you added 'region' to the CAgg but the default index is (device_id, bucket)
CREATE INDEX ON metrics_hourly (region, bucket DESC);

-- For queries that look up a specific device across a wide time range:
CREATE INDEX ON metrics_hourly (device_id, bucket DESC);
-- This may already exist as the default. Check with:
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'metrics_hourly';

-- For queries that aggregate across all devices in a time range:
-- No additional index needed — chunk exclusion handles the time dimension.

-- Same composite index rules as raw hypertables:
-- Entity/dimension columns FIRST, time bucket column LAST.
CREATE INDEX ON metrics_hourly (device_id, bucket DESC);  -- GOOD
CREATE INDEX ON metrics_hourly (bucket DESC, device_id);  -- BAD (low selectivity on bucket within chunk)
```

### PG Native Materialized Views vs TimescaleDB CAggs — Decision Guide

| Factor | PG Materialized View | TimescaleDB CAgg |
|--------|---------------------|-----------------|
| Refresh | Full recomputation (`REFRESH MATERIALIZED VIEW`) | Incremental (only changed time ranges) |
| Concurrency during refresh | `CONCURRENTLY` requires a unique index; blocks briefly | Non-blocking (separate materialization hypertable) |
| Real-time mode | No — stale until refreshed | Yes — combines materialized + live data |
| Compression | No | Yes (CAgg is a hypertable) |
| Hierarchical | No (can't build MV on MV efficiently) | Yes (CAgg on CAgg, 2.9+) |
| Retention | Manual (`DROP` + recreate, or delete rows) | `add_retention_policy()` — automatic chunk drops |
| Indexing | Standard PG indexes on the whole view | Per-chunk indexes (smaller, faster to build/vacuum) |
| Storage scaling | Single table — VACUUM pain at scale | Chunked — VACUUM per chunk, DROP CHUNKS for instant cleanup |
| Use case | Small, infrequently-changing aggregations; non-time-series | Time-series aggregations at any scale |
| When PG MV is better | Non-time-series data; complex JOINs that CAggs don't support; PG without TimescaleDB installed | — |

### `REFRESH MATERIALIZED VIEW CONCURRENTLY` — The PG Native Option

PostgreSQL's `REFRESH MATERIALIZED VIEW CONCURRENTLY` provides non-blocking refresh for native materialized views, but it comes with significant caveats:

```sql
-- Requires a UNIQUE index on the materialized view:
CREATE UNIQUE INDEX ON my_summary (id);

-- Then you can refresh without blocking readers:
REFRESH MATERIALIZED VIEW CONCURRENTLY my_summary;
```

**How it works internally:**

1. Executes the view's query into a temporary result set
2. Computes a **full diff** between the existing materialized data and the new result set (using the unique index)
3. Applies INSERTs, UPDATEs, and DELETEs to reconcile the difference
4. Briefly locks the view during the final swap (readers are blocked for milliseconds)

**Cost implications:**

| View size | `REFRESH` (non-concurrent) | `REFRESH CONCURRENTLY` |
|-----------|---------------------------|----------------------|
| 100K rows | Fast (full replace) | Moderate (diff is cheap) |
| 1M rows | Moderate | Slow (diff requires full scan + index lookup per row) |
| 10M rows | Slow but predictable | Very slow (the diff itself can take minutes) |
| 100M rows | Minutes | Prohibitive — use TimescaleDB CAggs instead |

**When `REFRESH CONCURRENTLY` is good enough:**
- Views under ~10M rows that change slowly (daily refresh)
- Non-time-series aggregations (e.g., user stats, product summaries)
- When you need complex JOINs that CAggs don't support
- Environments without TimescaleDB installed

**When to switch to TimescaleDB CAggs:**
- Time-series data at any meaningful scale (>1M rows in the source table)
- You need near-real-time freshness (real-time mode)
- You need compression on the aggregated data
- You need hierarchical aggregation (daily from hourly from raw)
- The CONCURRENTLY diff becomes the bottleneck (usually >10M rows)

---

## 6. Index Strategy for Hypertables

### Per-Chunk Indexes

Every index defined on a hypertable is automatically created on every chunk. This means:

- A hypertable with 5 indexes and 500 chunks has 2500 actual PostgreSQL indexes
- Each chunk's indexes are independent (separate B-trees, separate vacuuming)
- Adding an index to a hypertable creates it on ALL existing chunks (potentially slow)

```sql
-- This creates an index on every chunk:
CREATE INDEX idx_metrics_device ON metrics (device_id, time DESC);

-- To index only future chunks:
CREATE INDEX idx_metrics_device ON metrics (device_id, time DESC)
  WITH (timescaledb.transaction_per_chunk);
-- Actually, there's no built-in way to skip existing chunks.
-- Workaround: create the index, then drop it on old chunks individually if needed.
```

### Index Recommendations for Time-Series

| Query Pattern | Recommended Index | Notes |
|---------------|-------------------|-------|
| Point query on entity + time range | `(device_id, time DESC)` | Most common pattern. The time column is already the chunk boundary, but within a chunk, this index narrows to the device. |
| Latest value per entity | `(device_id, time DESC)` + `LIMIT 1` | Same index. The `DESC` ordering means the latest value is at the start. |
| Range scan on time only | **No additional index needed** | Chunk exclusion handles the time range. Within a chunk, a seq scan is often optimal (chunks are small). |
| Filter on tag/label + time | `(tag_column, time DESC)` | Same pattern as device_id. One index per frequently-filtered dimension. |
| Full-text search on metadata | GIN index on `tsvector` or JSONB | Same as vanilla PostgreSQL. Per-chunk GIN indexes are fine. |

### Indexes You Don't Need

```sql
-- DON'T create a standalone index on the time column:
CREATE INDEX idx_metrics_time ON metrics (time DESC);  -- WASTE
-- Chunk exclusion already handles time filtering.
-- Within a chunk, the time range is narrow enough that a seq scan is fine.

-- DON'T create too many indexes:
-- 5 indexes × 1000 chunks = 5000 indexes.
-- Each index slows down INSERTs and increases VACUUM work.
-- Start with 1-2 indexes and add only when EXPLAIN shows a need.
```

### Composite Index Column Order

**Time goes LAST (or second) in composite indexes**, not first:

```sql
-- GOOD: entity first, time second
CREATE INDEX ON metrics (device_id, time DESC);
-- Chunk exclusion handles the time dimension.
-- Within the chunk, the index narrows by device_id first.

-- BAD: time first
CREATE INDEX ON metrics (time DESC, device_id);
-- Within a chunk, time has very low selectivity (all rows are in the chunk's time range).
-- This index is nearly useless for filtering.
```

---

## 7. PostgreSQL Tuning Overrides for Time-Series

TimescaleDB workloads are different from generic OLTP. These PostgreSQL settings need adjustment:

### Memory

```ini
# shared_buffers: same 25% rule, but ensure 2-3 active chunks fit
shared_buffers = 8GB          # Standard recommendation

# work_mem: higher than OLTP because time-series queries do more sorting/aggregation
work_mem = 64MB               # vs typical OLTP 16-32MB

# maintenance_work_mem: higher because VACUUM/REINDEX runs per-chunk (many small operations)
maintenance_work_mem = 2GB

# effective_cache_size: same as vanilla PG (50-75% of RAM)
effective_cache_size = 24GB
```

### Autovacuum

**Chunks change the autovacuum calculus.** Each chunk is a separate table. With 500 chunks:

```ini
# Increase workers — each chunk needs its own vacuum pass
autovacuum_max_workers = 6    # vs default 3

# Lower naptime — more tables to check
autovacuum_naptime = 15s      # vs default 60s

# For the most recent (actively written) chunk, vacuum needs to be aggressive:
# Set per-table on the hypertable (applies to future chunks):
ALTER TABLE metrics SET (
  autovacuum_vacuum_scale_factor = 0.02,    # 2% dead tuples, not 20%
  autovacuum_analyze_scale_factor = 0.01
);
```

**The old-chunk optimization:** Chunks that are no longer receiving writes (e.g., yesterday's chunk) accumulate zero dead tuples. Autovacuum will check them but do nothing — wasting cycles. You can raise the threshold on old chunks, but in practice the naptime check is cheap and not worth optimizing.

### WAL and Checkpoints

```ini
# Time-series writes are append-heavy. Increase WAL capacity.
max_wal_size = 8GB            # vs default 1GB
min_wal_size = 2GB
checkpoint_timeout = 15min

# WAL compression saves significant space on high-ingest workloads:
wal_compression = lz4
```

### Planner

```ini
# SSD settings (same as vanilla PG):
random_page_cost = 1.1
effective_io_concurrency = 200

# Parallel query is very useful for time-series aggregations:
max_parallel_workers_per_gather = 4
max_parallel_workers = 8

# IMPORTANT: don't set these too high or planning time explodes with many chunks:
# The planner considers parallel plans per-chunk, so:
# 1000 chunks × 4 workers = 4000 parallel workers considered = slow planning
```

---

## 8. Chunk Exclusion — How Queries Skip Chunks

### How It Works

When you query a hypertable with a time predicate, TimescaleDB's planner extension checks the chunk metadata table to determine which chunks overlap with the query's time range. Chunks outside the range are excluded from the plan entirely.

```sql
-- This query only scans chunks covering the last 24 hours:
EXPLAIN SELECT * FROM metrics WHERE time > now() - INTERVAL '1 day';
-- Plan shows: Append with only 1-2 chunk scans, not 500

-- This is equivalent to PostgreSQL's partition pruning but faster:
-- PG partition pruning checks constraint exclusion per partition.
-- TimescaleDB uses a metadata lookup (O(log n) on chunk ranges).
```

### What Breaks Chunk Exclusion

| Anti-Pattern | Why It Breaks | Fix |
|-------------|---------------|-----|
| `WHERE time::date = '2024-06-15'` | Cast prevents direct range comparison | `WHERE time >= '2024-06-15' AND time < '2024-06-16'` |
| `WHERE EXTRACT(HOUR FROM time) = 14` | Function on time column | Can't fix — this inherently scans all chunks. Redesign query. |
| `WHERE time > $1` (prepared statement, PG < 12) | Parameter unknown at plan time | PG 12+ handles this with runtime pruning. Upgrade. |
| JOINs without time predicate on the hypertable side | Planner can't infer time range from the join | Add explicit `AND metrics.time > ...` to the WHERE clause |
| `OR` conditions mixing time and non-time | `WHERE time > X OR device_id = Y` | Rewrite as `UNION ALL` of two queries |

### Verifying Chunk Exclusion

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT avg(value) FROM metrics
WHERE time > now() - INTERVAL '1 hour' AND device_id = 'sensor-42';

-- Look for: "Chunks excluded: 498" or similar
-- If you see all chunks being scanned, chunk exclusion failed.
```

---

## 9. Data Lifecycle: Retention, Tiering, and Drop Policies

### Retention Policies

```sql
-- Drop chunks older than 90 days (instant — drops the chunk table):
SELECT add_retention_policy('metrics', drop_after => INTERVAL '90 days');

-- Check scheduled policies:
SELECT * FROM timescaledb_information.jobs WHERE proc_name = 'policy_retention';
```

### The Tiered Storage Pattern (Self-Managed)

For data you want to keep but query rarely:

```
0-7 days:    Raw data, uncompressed, fast queries
7-90 days:   Compressed data, slower queries but much smaller
90+ days:    Archive to S3/GCS via pg_dump or COPY, then drop chunks
```

```sql
-- Compression policy: compress chunks older than 7 days
SELECT add_compression_policy('metrics', compress_after => INTERVAL '7 days');

-- Retention policy: drop chunks older than 90 days
SELECT add_retention_policy('metrics', drop_after => INTERVAL '90 days');

-- For archival before dropping:
-- Use pg_dump per-chunk or COPY TO with a time filter before the retention policy runs
```

### TimescaleDB Cloud Tiered Storage (Managed)

If using TimescaleDB Cloud, tiered storage moves old chunks to object storage (S3) while keeping them queryable:

```sql
SELECT add_tiering_policy('metrics', move_after => INTERVAL '30 days');
-- Chunks older than 30 days are moved to S3 but remain queryable via foreign data wrappers
```

---

## 10. Background Workers and Job Scheduling

TimescaleDB runs background workers for:
- Compression policies
- Retention policies
- Continuous aggregate refresh
- Chunk management

```sql
-- View all scheduled jobs:
SELECT * FROM timescaledb_information.jobs;

-- View job execution history:
SELECT * FROM timescaledb_information.job_stats;

-- Tune the number of background workers:
-- In postgresql.conf:
timescaledb.max_background_workers = 8     # Default varies by version
-- This caps how many policies can run in parallel.
-- If you have many hypertables with policies, increase this.
```

### When Background Workers Cause Problems

1. **Too many concurrent compression jobs**: Compression is CPU+I/O intensive. If 5 hypertables all try to compress simultaneously, they can saturate I/O.

```sql
-- Stagger job schedules:
SELECT alter_job(job_id, schedule_interval => INTERVAL '2 hours', next_start => '2024-01-01 01:00')
FROM timescaledb_information.jobs
WHERE proc_name = 'policy_compression' AND hypertable_name = 'metrics';
```

2. **CAgg refresh blocking ingest**: Continuous aggregate refresh reads from the raw hypertable. On a write-heavy table, this can cause lock contention.

```sql
-- Minimize contention by refreshing smaller windows more frequently:
SELECT add_continuous_aggregate_policy('metrics_hourly',
  start_offset => INTERVAL '2 hours',   -- Small window
  end_offset   => INTERVAL '5 minutes', -- Near-real-time
  schedule_interval => INTERVAL '5 minutes'
);
```

3. **Retention policy running during peak hours**: `drop_chunks` is fast but acquires locks briefly.

```sql
-- Schedule retention during off-peak:
SELECT alter_job(
  (SELECT job_id FROM timescaledb_information.jobs WHERE proc_name = 'policy_retention' AND hypertable_name = 'metrics'),
  schedule_interval => INTERVAL '1 day',
  next_start => '2024-01-01 03:00'  -- 3 AM
);
```

---

## 11. Multi-Node (Distributed Hypertables) — When NOT to Use

### The State of Multi-Node

TimescaleDB multi-node (distributed hypertables) was deprecated in 2.13. The recommended path forward is:

- **Single-node TimescaleDB** for most workloads (scales to billions of rows on modern hardware)
- **PostgreSQL logical replication** for read scaling
- **Citus** (now part of Azure) for true distributed PostgreSQL

### Why Single-Node Is Usually Enough

A single modern server (32 cores, 128 GB RAM, NVMe) with TimescaleDB can handle:
- **Ingest**: 500k-2M rows/sec (with COPY and batching)
- **Storage**: Petabyte-scale with compression (10-20x ratio)
- **Queries**: Sub-second on recent data, seconds on compressed historical data with good indexes and CAggs

Most teams that think they need multi-node actually need:
1. Better compression settings (reduce storage 10-20x)
2. Continuous aggregates (reduce query scope 100-1000x)
3. Proper retention policies (don't keep what you don't need)
4. Better indexes (stop scanning all chunks)

---

## 12. Monitoring TimescaleDB

### Essential Views

```sql
-- Chunk information (sizes, compression status):
SELECT
  hypertable_name,
  chunk_name,
  range_start, range_end,
  is_compressed,
  pg_size_pretty(before_compression_total_bytes) AS raw_size,
  pg_size_pretty(after_compression_total_bytes) AS compressed_size,
  CASE WHEN before_compression_total_bytes > 0
    THEN round(before_compression_total_bytes::numeric / after_compression_total_bytes, 1)
    ELSE NULL END AS ratio
FROM timescaledb_information.chunks
WHERE hypertable_name = 'metrics'
ORDER BY range_start DESC
LIMIT 20;

-- Hypertable size summary:
SELECT
  hypertable_name,
  pg_size_pretty(hypertable_size(format('%I.%I', hypertable_schema, hypertable_name)::regclass)) AS total_size,
  pg_size_pretty(
    hypertable_size(format('%I.%I', hypertable_schema, hypertable_name)::regclass) -
    pg_indexes_size(format('%I.%I', hypertable_schema, hypertable_name)::regclass)
  ) AS data_size,
  num_chunks
FROM timescaledb_information.hypertables;

-- Compression stats:
SELECT * FROM hypertable_compression_stats('metrics');

-- Job health:
SELECT
  j.hypertable_name,
  j.proc_name,
  js.last_run_started_at,
  js.last_successful_finish,
  js.last_run_status,
  js.total_runs,
  js.total_failures
FROM timescaledb_information.jobs j
JOIN timescaledb_information.job_stats js USING (job_id)
ORDER BY js.last_run_started_at DESC;
```

### Red Flags

| Signal | Meaning | Action |
|--------|---------|--------|
| Chunk count > 2000 | Planner overhead; slow query planning | Increase chunk interval or enable retention |
| Compression ratio < 3x | Wrong segmentby/orderby or highly random data | Review compression settings |
| CAgg refresh taking >10min | Refresh window too large or source data not indexed | Shrink refresh window, add index on time + segmentby columns |
| `last_run_status = 'Failed'` on any job | Policy failed (disk full, lock timeout, etc.) | Check `timescaledb_information.job_errors` for details |
| Buffer pool hit ratio <95% on recent chunks | Chunks too large for memory | Decrease chunk interval or increase `shared_buffers` |

---

## 13. Configuration Template

For a **32 GB RAM, NVMe SSD, IoT metrics workload** (100k rows/sec, 50 devices):

```ini
# === PostgreSQL base settings ===
shared_buffers = 8GB
work_mem = 64MB
maintenance_work_mem = 2GB
effective_cache_size = 24GB
wal_buffers = 64MB
huge_pages = try

max_wal_size = 8GB
min_wal_size = 2GB
checkpoint_timeout = 15min
checkpoint_completion_target = 0.9
wal_compression = lz4

random_page_cost = 1.1
effective_io_concurrency = 200
default_statistics_target = 200

max_parallel_workers_per_gather = 4
max_parallel_workers = 8
max_worker_processes = 24       # PG workers + TimescaleDB background workers

autovacuum_max_workers = 6
autovacuum_naptime = 15s
autovacuum_vacuum_cost_delay = 2ms
autovacuum_vacuum_cost_limit = 800

log_min_duration_statement = 250
log_checkpoints = on

shared_preload_libraries = 'timescaledb'

# === TimescaleDB settings ===
timescaledb.max_background_workers = 8
timescaledb.last_tuned = '2024-01-01T00:00:00Z'
timescaledb.last_tuned_version = '0.1.0'
```

```sql
-- Hypertable setup:
SELECT create_hypertable('metrics', by_range('time', INTERVAL '1 day'));

-- Compression:
ALTER TABLE metrics SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'device_id',
  timescaledb.compress_orderby = 'time DESC'
);
SELECT add_compression_policy('metrics', compress_after => INTERVAL '7 days');

-- Retention:
SELECT add_retention_policy('metrics', drop_after => INTERVAL '90 days');

-- Continuous aggregate:
CREATE MATERIALIZED VIEW metrics_hourly
WITH (timescaledb.continuous) AS
SELECT time_bucket('1 hour', time) AS bucket, device_id,
       avg(value), min(value), max(value), count(*)
FROM metrics GROUP BY bucket, device_id;

SELECT add_continuous_aggregate_policy('metrics_hourly',
  start_offset => INTERVAL '3 days',
  end_offset => INTERVAL '5 minutes',
  schedule_interval => INTERVAL '5 minutes'
);
```
