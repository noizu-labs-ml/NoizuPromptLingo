# PostgreSQL Tuning Reference

> Target audience: mid-to-senior developers running PostgreSQL 14--17 in production.
> Philosophy: tune what matters, measure before and after, avoid cargo-culting.

---

## 1. Memory Configuration

| Parameter | Default | Recommendation | When to Change |
|-----------|---------|---------------|----------------|
| `shared_buffers` | 128 MB | **25% of total RAM** (cap at ~8-16 GB) | Always. The default is absurdly low for any production workload. Beyond 16 GB you hit diminishing returns because the OS page cache handles the rest. On Windows, keep it lower (~512 MB-1 GB) due to NTFS/buffer manager differences. |
| `work_mem` | 4 MB | **Total RAM / (max_connections * 4)** as a starting point; 16-64 MB is typical for OLTP | When you see `Sort Method: external merge` in `EXPLAIN ANALYZE`. Be careful: this is allocated **per-sort-per-query**, so a complex query with 5 sort/hash nodes uses 5x this value. Setting it to 1 GB globally is a fast path to OOM. Use `SET work_mem = '256MB'` at the session level for known-heavy reports. |
| `maintenance_work_mem` | 64 MB | **1-2 GB** (or up to 5% of RAM) | Always for production. Speeds up `CREATE INDEX`, `VACUUM`, `ALTER TABLE ADD FOREIGN KEY`. Unlike `work_mem`, only a few maintenance operations run concurrently, so being generous is safe. |
| `effective_cache_size` | 4 GB | **50-75% of total RAM** | Always. This is a *hint* to the planner, not an allocation. It tells PostgreSQL how much data it can expect to find in the OS page cache + shared_buffers combined. Setting it too low makes the planner avoid index scans when they would be faster. |
| `wal_buffers` | -1 (auto: 1/32 of `shared_buffers`) | **64 MB** (auto-tuning usually gets this right) | Only when `shared_buffers` is very small or you see WAL write bottlenecks. The auto-tuned value (1/32 of shared_buffers, capped at ~16 MB by default in older versions) works for most workloads. 64 MB is a safe explicit ceiling. |
| `huge_pages` | `try` | **`try`** (Linux), **`off`** (non-Linux) | When `shared_buffers` >= 8 GB on Linux. Huge pages reduce TLB misses. Set to `on` only after confirming `vm.nr_hugepages` is configured in sysctl -- otherwise PostgreSQL will refuse to start. Check: `grep HugePages /proc/meminfo`. |

### When the Rules of Thumb Break

- **Dedicated database server with 256+ GB RAM**: `shared_buffers` at 25% = 64 GB. That is too high. Cap at 16-32 GB and let the OS cache handle the rest. PostgreSQL's buffer management has lock contention issues above ~16 GB.
- **Shared servers (app + DB on same box)**: Drop `shared_buffers` to 15% of RAM. You are competing with the application for memory.
- **High-connection-count environments (500+)**: `work_mem` must be low (4-8 MB) or you will OOM. This is a strong signal you need connection pooling, not more memory per connection.
- **Data warehouse / analytics workloads**: `work_mem` can be much higher (256 MB-1 GB) because you have fewer concurrent queries doing heavy sorts and hash joins.

---

## 2. WAL and Checkpoint Tuning

### Parameters

| Parameter | Default | Recommendation | Notes |
|-----------|---------|---------------|-------|
| `wal_level` | `replica` | **`replica`** for most; `logical` if you need logical replication or CDC | `minimal` disables replication and PITR -- never use in production. `logical` adds overhead to WAL generation (~5-10% more WAL volume). |
| `max_wal_size` | 1 GB | **4-16 GB** | Controls how much WAL accumulates before a checkpoint is forced. The default triggers checkpoints too frequently on write-heavy workloads, causing I/O spikes. |
| `min_wal_size` | 80 MB | **1-2 GB** | Prevents WAL files from being recycled too aggressively. Keeps pre-allocated WAL files around to avoid file creation overhead during write bursts. |
| `checkpoint_completion_target` | 0.9 (PG 14+) | **0.9** | Spreads checkpoint I/O over 90% of the checkpoint interval. The old default was 0.5, which caused I/O spikes. If you are on PG 13 or earlier, set this explicitly. |
| `checkpoint_timeout` | 5 min | **15-30 min** | Longer intervals mean fewer checkpoints but more WAL to replay on crash recovery. 15 min is a good balance for OLTP. 30 min for write-heavy workloads with fast storage. |

### Diagnosing Checkpoint I/O Spikes

```sql
SELECT checkpoints_timed,
       checkpoints_req,
       buffers_checkpoint,
       buffers_backend,
       maxwritten_clean
FROM pg_stat_bgwriter;
```

What to look for:

- **`checkpoints_req` >> `checkpoints_timed`**: Checkpoints are being forced by WAL volume hitting `max_wal_size` before `checkpoint_timeout` fires. Increase `max_wal_size`.
- **`buffers_backend` is high**: The background writer and checkpointer are not keeping up. Backends are writing dirty pages themselves. Increase `bgwriter_lru_maxpages` and `bgwriter_lru_multiplier`.
- **`maxwritten_clean` is high**: The background writer hit its per-round limit and stopped. Increase `bgwriter_lru_maxpages`.

### WAL Compression

```
wal_compression = lz4   # PG 15+; use 'on' (pglz) for PG 14
```

Reduces WAL volume by 30-60% on typical workloads. The CPU cost is negligible with LZ4. Especially valuable for replicas over slow links.

---

## 3. Autovacuum Tuning

Autovacuum is the **single most misunderstood PostgreSQL feature**. Undertune it and you get table bloat, slow queries, and eventually transaction ID wraparound. Overtune it and you waste I/O. Most production problems come from undertuning.

### How Autovacuum Works

A table becomes a vacuum candidate when:

```
dead_tuples > autovacuum_vacuum_threshold + (autovacuum_vacuum_scale_factor * n_live_tup)
```

Defaults: `threshold = 50`, `scale_factor = 0.2`

This means a table with 10M rows needs **2,000,050 dead tuples** (20%) before autovacuum kicks in. For a large, heavily-updated table, that is far too late.

### Per-Table Tuning

For large, write-heavy tables, override the scale factor:

```sql
-- Vacuum when 1% of rows are dead instead of 20%
ALTER TABLE orders SET (
    autovacuum_vacuum_scale_factor = 0.01,
    autovacuum_analyze_scale_factor = 0.005
);

-- For very large tables (100M+ rows), use a fixed threshold instead
ALTER TABLE events SET (
    autovacuum_vacuum_scale_factor = 0,
    autovacuum_vacuum_threshold = 50000,
    autovacuum_analyze_scale_factor = 0,
    autovacuum_analyze_threshold = 50000
);
```

### When to Increase `autovacuum_max_workers`

Default is 3. Increase to **5-8** when:

- You have more than 20 tables with heavy write activity
- Autovacuum is consistently falling behind (check `last_autovacuum` timestamps)
- You have many partitions (each partition is a separate table for vacuum purposes)

Each worker consumes up to `autovacuum_work_mem` (or `maintenance_work_mem` if not set), so budget memory accordingly.

Also consider:

```
autovacuum_vacuum_cost_delay = 2ms   # Default 2ms (PG 12+), was 20ms before
autovacuum_vacuum_cost_limit = 800   # Default 200. Increase to let vacuum work faster.
```

Reducing the cost delay and increasing the cost limit lets autovacuum complete faster at the expense of more I/O. On SSDs, this trade-off is almost always worth it.

### Tables That Never Get Vacuumed

Common causes:

1. **Long-running transactions**: Any transaction open longer than your vacuum cycle holds back the `xmin` horizon. Vacuum cannot remove tuples visible to that transaction. Fix: kill idle-in-transaction sessions (`idle_in_transaction_session_timeout`).

2. **Prepared transactions that were never committed or rolled back**: Check `pg_prepared_xacts`. These hold back `xmin` indefinitely.

3. **Replication slots with lagging replicas**: An inactive or slow replication slot holds back `xmin` cluster-wide. Monitor `pg_replication_slots` and drop abandoned slots.

4. **Transaction ID wraparound approaching**: When a table gets within 10M transactions of wraparound, PostgreSQL forces an aggressive anti-wraparound vacuum that may lock the table. Monitor with:

```sql
SELECT relname,
       age(relfrozenxid) AS xid_age,
       pg_size_pretty(pg_total_relation_size(oid)) AS size
FROM pg_class
WHERE relkind = 'r'
ORDER BY age(relfrozenxid) DESC
LIMIT 20;
```

If `xid_age` approaches `autovacuum_freeze_max_age` (default 200M), you have a problem brewing.

### Monitoring Autovacuum

```sql
SELECT schemaname, relname,
       last_vacuum, last_autovacuum,
       last_analyze, last_autoanalyze,
       n_dead_tup, n_live_tup,
       CASE WHEN n_live_tup > 0
            THEN round(n_dead_tup::numeric / n_live_tup, 4)
            ELSE 0 END AS dead_ratio
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC
LIMIT 20;
```

Red flags:

- `last_autovacuum` is NULL or days old on an active table
- `dead_ratio` > 0.1 (10% dead tuples)
- `n_dead_tup` is in the millions

### Emergency: Manual VACUUM FULL

`VACUUM FULL` rewrites the entire table and reclaims disk space. It requires an **ACCESS EXCLUSIVE** lock (blocks all reads and writes) for the duration.

**When it is justified:**

- Table bloat exceeds 50% and is not recovering with regular vacuum
- You have a maintenance window and can tolerate downtime
- The table is small enough to rewrite quickly (<10 GB)

**When it is wrong (use alternatives instead):**

- On a large table during business hours (use `pg_repack` instead -- online rewrite, no exclusive lock)
- As a routine maintenance task (fix your autovacuum settings instead)
- On a table with active traffic (it will block everything for the entire rewrite duration)

```bash
# Preferred alternative: pg_repack (online, no exclusive lock)
pg_repack --table orders --no-superuser-check -d mydb
```

---

## 4. Connection Management

### max_connections: Keep It Low

**Default**: 100. **Recommendation**: 100-200, backed by connection pooling.

Each PostgreSQL connection consumes:
- ~5-10 MB of RAM (process memory, work_mem allocations, catalog caches)
- One OS process (context switching overhead scales with connection count)
- Lock table entries, snapshot overhead

The formula:

```
max_connections < (total_RAM - shared_buffers - OS_needs) / per_connection_mem
```

Example for 32 GB RAM:

```
(32768 - 8192 - 4096) MB / 10 MB = ~2048 max theoretical
```

But you would never run 2048 connections. Beyond ~300 connections, lock contention in PostgreSQL's shared memory structures degrades throughput. **If you need more than 200 application connections, you need a connection pooler, not more connections.**

### Connection Pooling with PgBouncer

PgBouncer sits between your application and PostgreSQL, multiplexing many client connections onto fewer database connections.

| Mode | How It Works | Best For |
|------|-------------|----------|
| **session** | Client gets a dedicated server connection for its entire session | Legacy apps that use session-level features (temp tables, prepared statements, SET commands) |
| **transaction** | Client gets a server connection only for the duration of a transaction; returned to pool between transactions | **Most applications.** This is the default recommendation. |
| **statement** | Client gets a server connection per statement | Only for simple, stateless query workloads. Cannot use multi-statement transactions. |

**Transaction mode caveats** (things that break):

- `LISTEN/NOTIFY` (connection-bound)
- Prepared statements (use `prepared_statement_mode = server` in PgBouncer 1.21+)
- `SET` commands (use `SET LOCAL` inside transactions instead)
- Temporary tables (scoped to session, not transaction)
- Advisory locks (session-level ones will behave unexpectedly)

### Why Pooling Is Mandatory in Production

Without pooling, a typical web application with 20 app servers, each opening 10 connections = 200 database connections. Add background workers, cron jobs, admin tools: you are at 300+.

With PgBouncer in transaction mode: those 300 client connections map to ~30-50 actual database connections (because most connections are idle between transactions). PostgreSQL performs dramatically better at 50 connections than at 300.

```ini
# pgbouncer.ini
[databases]
mydb = host=127.0.0.1 port=5432 dbname=mydb

[pgbouncer]
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 50
reserve_pool_size = 10
reserve_pool_timeout = 3
server_idle_timeout = 300
```

---

## 5. Planner Configuration

| Parameter | Default | SSD Recommendation | HDD Recommendation | Notes |
|-----------|---------|-------------------|-------------------|-------|
| `random_page_cost` | 4.0 | **1.1** | **4.0** (keep default) | The planner uses this to estimate the cost of a random I/O read relative to sequential. On SSDs, random reads are nearly as fast as sequential, so 1.1 tells the planner to prefer index scans. This is the single most impactful planner parameter for SSD-backed databases. |
| `seq_page_cost` | 1.0 | **1.0** | **1.0** | Baseline cost. Leave at 1.0 -- everything else is relative to this. |
| `effective_io_concurrency` | 1 | **200** | **2-4** | How many concurrent I/O requests the OS can handle. SSDs handle hundreds. This affects bitmap heap scans and prefetching. |
| `cpu_tuple_cost` | 0.01 | **0.01** | **0.01** | Rarely needs changing. Increase if you have very fast I/O but slow CPUs (uncommon). |
| `cpu_index_tuple_cost` | 0.005 | **0.005** | **0.005** | Rarely needs changing. |

### How to Test Planner Changes

Never change planner parameters globally without testing. Use a session-level override:

```sql
-- Test with the new setting
SET random_page_cost = 1.1;
EXPLAIN ANALYZE SELECT * FROM orders WHERE customer_id = 12345;

-- Compare with the old setting
SET random_page_cost = 4.0;
EXPLAIN ANALYZE SELECT * FROM orders WHERE customer_id = 12345;
```

Compare actual execution times, not just estimated costs. The planner might choose a different plan with different cost settings -- that is the point. Verify the new plan is actually faster.

### Statistics Targets

If the planner consistently makes bad estimates for a specific column:

```sql
-- Increase statistics granularity for a column (default 100, max 10000)
ALTER TABLE orders ALTER COLUMN status SET STATISTICS 500;
ANALYZE orders;
```

This is useful for columns with skewed distributions (e.g., status columns where 90% of rows are 'completed').

---

## 6. Parallel Query

| Parameter | Default | Recommendation | Notes |
|-----------|---------|---------------|-------|
| `max_parallel_workers_per_gather` | 2 | **2-4** | Maximum workers per parallel query node. The planner decides how many to actually use based on table size and cost estimates. |
| `max_parallel_workers` | 8 | **Number of CPU cores / 2** | Global cap on parallel workers across all queries. |
| `max_worker_processes` | 8 | **Number of CPU cores** | Global cap on all background workers (includes parallel query, autovacuum, logical replication). |
| `min_parallel_table_scan_size` | 8 MB | **8 MB** (default is fine) | Minimum table size before the planner considers a parallel sequential scan. |
| `min_parallel_index_scan_size` | 512 KB | **512 KB** (default is fine) | Minimum index size for parallel index scan. |
| `parallel_setup_cost` | 1000 | **1000** (default is fine) | Estimated cost of launching a parallel worker. Increase if parallel queries are chosen for small tasks where the overhead is not worth it. |
| `parallel_tuple_cost` | 0.1 | **0.1** (default is fine) | Cost of passing a tuple from worker to leader. |

### When Parallel Queries Help

- Large sequential scans (>100 MB tables)
- Aggregations over large datasets (`COUNT(*)`, `SUM()`, `AVG()`)
- Hash joins on large tables
- Parallel index scans (B-tree only, PG 12+)

### When Parallel Queries Hurt

- **OLTP with many concurrent short queries**: The overhead of launching workers exceeds the benefit. Each parallel worker is a full process with memory overhead.
- **When you are already CPU-saturated**: Parallel workers compete with other queries. If you have 16 cores and 50 active queries, adding parallel workers makes contention worse.
- **Complex queries with many nodes**: Only certain plan nodes support parallelism. If the bottleneck is a non-parallel node, adding workers to the parallel portion does not help.

### Forcing/Disabling for Testing

```sql
-- Disable parallel query for a session (to test single-threaded perf)
SET max_parallel_workers_per_gather = 0;

-- Force parallel query even on small tables (for testing only)
SET parallel_setup_cost = 0;
SET parallel_tuple_cost = 0;
SET min_parallel_table_scan_size = 0;
SET min_parallel_index_scan_size = 0;
```

---

## 7. Monitoring Queries

### Table Bloat Estimation

```sql
SELECT schemaname, tablename,
       pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename)) AS total_size,
       pg_size_pretty(
         pg_total_relation_size(schemaname || '.' || tablename) -
         pg_relation_size(schemaname || '.' || tablename)
       ) AS bloat_estimate,
       CASE WHEN pg_relation_size(schemaname || '.' || tablename) > 0
            THEN round(100.0 * (
              pg_total_relation_size(schemaname || '.' || tablename) -
              pg_relation_size(schemaname || '.' || tablename)
            )::numeric / pg_total_relation_size(schemaname || '.' || tablename), 1)
            ELSE 0 END AS bloat_pct
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(schemaname || '.' || tablename) DESC
LIMIT 20;
```

> Note: True bloat estimation requires the `pgstattuple` extension. The above is a rough heuristic. For accurate numbers:

```sql
CREATE EXTENSION IF NOT EXISTS pgstattuple;
SELECT * FROM pgstattuple('orders');
-- Look at dead_tuple_percent and free_space
```

### Index Bloat Estimation

```sql
SELECT schemaname, indexrelname,
       pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
       idx_scan AS scans,
       idx_tup_read AS tuples_read,
       idx_tup_fetch AS tuples_fetched
FROM pg_stat_user_indexes
WHERE pg_relation_size(indexrelid) > 10 * 1024 * 1024  -- indexes > 10 MB
ORDER BY pg_relation_size(indexrelid) DESC
LIMIT 20;
```

For true index bloat, use `pgstatindex` from the `pgstattuple` extension:

```sql
SELECT * FROM pgstatindex('orders_pkey');
-- Look at avg_leaf_density (below 50% = significant bloat)
```

### Unused Indexes

```sql
SELECT schemaname, relname, indexrelname,
       pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
       idx_scan,
       idx_tup_read
FROM pg_stat_user_indexes
WHERE idx_scan = 0
  AND pg_relation_size(indexrelid) > 1024 * 1024  -- skip tiny indexes
ORDER BY pg_relation_size(indexrelid) DESC;
```

> Warning: reset `pg_stat_user_indexes` stats after a major release to avoid dropping indexes only used during migrations. Check that `pg_stat_reset()` has not been called recently. Also check for indexes used by replicas (query the replica's `pg_stat_user_indexes`).

### Most Time-Consuming Queries (pg_stat_statements)

```sql
-- Requires: CREATE EXTENSION pg_stat_statements;
-- And: shared_preload_libraries = 'pg_stat_statements' (requires restart)

SELECT queryid,
       calls,
       round(total_exec_time::numeric / 1000, 2) AS total_time_sec,
       round(mean_exec_time::numeric, 2) AS mean_time_ms,
       round((100.0 * total_exec_time / sum(total_exec_time) OVER ())::numeric, 2) AS pct_total,
       rows,
       query
FROM pg_stat_statements
WHERE userid = (SELECT usesysid FROM pg_user WHERE usename = current_user)
ORDER BY total_exec_time DESC
LIMIT 20;
```

### Lock Contention

```sql
SELECT blocked_locks.pid AS blocked_pid,
       blocked_activity.usename AS blocked_user,
       blocking_locks.pid AS blocking_pid,
       blocking_activity.usename AS blocking_user,
       blocked_activity.query AS blocked_query,
       blocking_activity.query AS blocking_query,
       blocked_activity.wait_event_type,
       now() - blocked_activity.query_start AS blocked_duration
FROM pg_catalog.pg_locks blocked_locks
JOIN pg_catalog.pg_stat_activity blocked_activity
  ON blocked_activity.pid = blocked_locks.pid
JOIN pg_catalog.pg_locks blocking_locks
  ON blocking_locks.locktype = blocked_locks.locktype
  AND blocking_locks.database IS NOT DISTINCT FROM blocked_locks.database
  AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
  AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
  AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
  AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
  AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
  AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
  AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
  AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
  AND blocking_locks.pid != blocked_locks.pid
JOIN pg_catalog.pg_stat_activity blocking_activity
  ON blocking_activity.pid = blocking_locks.pid
WHERE NOT blocked_locks.granted
ORDER BY blocked_duration DESC;
```

### Replication Lag

```sql
-- On the primary
SELECT client_addr,
       state,
       sent_lsn,
       write_lsn,
       flush_lsn,
       replay_lsn,
       pg_wal_lsn_diff(sent_lsn, replay_lsn) AS replay_lag_bytes,
       pg_size_pretty(pg_wal_lsn_diff(sent_lsn, replay_lsn)) AS replay_lag_pretty,
       write_lag,
       flush_lag,
       replay_lag
FROM pg_stat_replication;
```

### Cache Hit Ratio

```sql
SELECT
  sum(heap_blks_read) AS heap_read,
  sum(heap_blks_hit) AS heap_hit,
  CASE WHEN sum(heap_blks_hit) + sum(heap_blks_read) > 0
       THEN round(100.0 * sum(heap_blks_hit) /
                  (sum(heap_blks_hit) + sum(heap_blks_read)), 2)
       ELSE 0 END AS cache_hit_ratio
FROM pg_statio_user_tables;
```

> Target: **>99%** for OLTP. If below 95%, you likely need more RAM or `shared_buffers` is too small.

### Active Connections by State

```sql
SELECT state, usename, datname, count(*)
FROM pg_stat_activity
WHERE pid != pg_backend_pid()
GROUP BY state, usename, datname
ORDER BY count DESC;
```

### Long-Running Queries

```sql
SELECT pid,
       now() - query_start AS duration,
       state,
       wait_event_type,
       wait_event,
       left(query, 100) AS query_preview
FROM pg_stat_activity
WHERE state != 'idle'
  AND query_start < now() - interval '5 minutes'
  AND pid != pg_backend_pid()
ORDER BY duration DESC;
```

### Dead Tuple Ratio by Table

```sql
SELECT schemaname, relname,
       n_live_tup,
       n_dead_tup,
       CASE WHEN n_live_tup > 0
            THEN round(100.0 * n_dead_tup / n_live_tup, 2)
            ELSE 0 END AS dead_pct,
       last_vacuum,
       last_autovacuum
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000
ORDER BY n_dead_tup DESC
LIMIT 20;
```

---

## 8. Partitioning

### When to Partition

Partition when:

- **Table exceeds ~100M rows** and queries consistently filter on a single column (date, tenant_id, region)
- **Time-series data** where old data is archived or dropped (partition drop is instant; `DELETE` is not)
- **Maintenance operations** (VACUUM, reindex) are taking too long on a single large table

Do NOT partition when:

- The table is under 10M rows (partitioning adds overhead with no benefit)
- Queries do not filter on the partition key (every query hits every partition)
- You are partitioning to "be ready for scale" that may never come

### Declarative Partitioning (PG 10+)

```sql
-- Range partitioning by date (most common)
CREATE TABLE events (
    id          bigint GENERATED ALWAYS AS IDENTITY,
    created_at  timestamptz NOT NULL,
    event_type  text NOT NULL,
    payload     jsonb
) PARTITION BY RANGE (created_at);

-- Create partitions
CREATE TABLE events_2025_q1 PARTITION OF events
    FOR VALUES FROM ('2025-01-01') TO ('2025-04-01');
CREATE TABLE events_2025_q2 PARTITION OF events
    FOR VALUES FROM ('2025-04-01') TO ('2025-07-01');

-- List partitioning (by category)
CREATE TABLE orders (
    id          bigint GENERATED ALWAYS AS IDENTITY,
    region      text NOT NULL,
    total       numeric
) PARTITION BY LIST (region);

CREATE TABLE orders_us PARTITION OF orders FOR VALUES IN ('us-east', 'us-west');
CREATE TABLE orders_eu PARTITION OF orders FOR VALUES IN ('eu-west', 'eu-central');

-- Hash partitioning (for even distribution when no natural key exists)
CREATE TABLE sessions (
    id          uuid PRIMARY KEY,
    user_id     bigint,
    data        jsonb
) PARTITION BY HASH (id);

CREATE TABLE sessions_0 PARTITION OF sessions FOR VALUES WITH (MODULUS 4, REMAINDER 0);
CREATE TABLE sessions_1 PARTITION OF sessions FOR VALUES WITH (MODULUS 4, REMAINDER 1);
CREATE TABLE sessions_2 PARTITION OF sessions FOR VALUES WITH (MODULUS 4, REMAINDER 2);
CREATE TABLE sessions_3 PARTITION OF sessions FOR VALUES WITH (MODULUS 4, REMAINDER 3);
```

### Partition Pruning

PostgreSQL automatically skips partitions that cannot contain matching rows. Verify with `EXPLAIN`:

```sql
EXPLAIN SELECT * FROM events WHERE created_at = '2025-03-15';
-- Should show: "Append" with only events_2025_q1 scanned
```

Ensure `enable_partition_pruning = on` (default). Pruning works at plan time for constants and at execution time for parameterized queries (PG 11+).

### Index Inheritance

**Indexes on the parent table are automatically created on new partitions (PG 11+).** But you must create them on the parent first:

```sql
-- This creates an index on every existing and future partition
CREATE INDEX idx_events_type ON events (event_type);
```

For unique constraints, the partition key must be part of the constraint:

```sql
-- This works:
ALTER TABLE events ADD CONSTRAINT events_pkey PRIMARY KEY (id, created_at);

-- This does NOT work:
ALTER TABLE events ADD CONSTRAINT events_pkey PRIMARY KEY (id);
-- ERROR: unique constraint must include all partition key columns
```

### Common Mistakes

1. **Too many partitions**: 1000+ partitions causes planning overhead. Aim for tens to low hundreds. If daily partitions on multi-year data, consider monthly instead.

2. **Forgetting the default partition**: Rows that do not match any partition cause an error. Add a default unless you are certain about coverage:

   ```sql
   CREATE TABLE events_default PARTITION OF events DEFAULT;
   ```

3. **Not automating partition creation**: Partitions do not create themselves. Use `pg_partman` or a cron job to pre-create future partitions.

4. **Querying without the partition key**: `SELECT * FROM events WHERE event_type = 'login'` scans ALL partitions. If most queries do not include the partition key, partitioning is making things worse.

5. **Foreign keys referencing partitioned tables**: Only supported in PG 12+, and only for the partitioned table referencing another table (not the other direction until PG 15, which added foreign keys pointing TO partitioned tables).

---

## 9. PostgreSQL Version-Specific Features

| Version | Key Feature | Tuning Impact |
|---------|-------------|---------------|
| **12** (2019) | CTE inlining; generated columns; pluggable storage | CTEs are no longer optimization fences. Rewrite `WITH` queries if you were using them to force plan order -- the planner now inlines them. |
| **13** (2020) | Parallel vacuum; incremental sort; de-duplication in B-tree indexes | `VACUUM` runs in parallel across indexes (`max_parallel_maintenance_workers`). B-tree indexes on low-cardinality columns shrink significantly. |
| **14** (2021) | Extended statistics improvements; connection slot reserved for superuser; `idle_session_timeout` | Extended stats on expressions (not just columns). Set `idle_session_timeout` to kill abandoned sessions. Fewer manual `CREATE STATISTICS` needed. |
| **15** (2022) | `MERGE` statement; `pg_stat_statements` tracks JIT/WAL stats; `pg_walinspect`; row-level security perf improvements | `MERGE` replaces complex upsert logic. `pg_stat_statements` now shows WAL bytes per query -- find your heaviest WAL writers. |
| **16** (2023) | `pg_stat_io` view; logical replication from standby; parallel full-text search; `COPY ... WHERE` | `pg_stat_io` replaces guesswork about I/O patterns -- shows reads, writes, extends, fsyncs per backend type. Game-changer for I/O tuning. |
| **17** (2024) | Incremental backup; `COPY` batch inserts; identity columns in partitions; JSON_TABLE; `MERGE ... RETURNING` | Incremental backup (`pg_basebackup --incremental`) massively reduces backup storage and time. `COPY` improvements speed up bulk loads. |

---

## 10. Configuration Template

Production-ready `postgresql.conf` for a **32 GB RAM, SSD, OLTP workload** server.

```ini
# ============================================================
# PostgreSQL Production Configuration
# Target: 32 GB RAM, SSD storage, OLTP workload
# Generated: 2025
# ============================================================

# --- Memory ---
shared_buffers = 8GB                   # 25% of RAM. Sweet spot for most workloads.
work_mem = 32MB                        # 32GB / (200 conns * 4). Generous for OLTP;
                                       # reduce if connection count is high.
maintenance_work_mem = 2GB             # Speeds up VACUUM, CREATE INDEX, ALTER TABLE.
effective_cache_size = 24GB            # 75% of RAM. Planner hint for expected OS cache.
wal_buffers = 64MB                     # Explicit ceiling. Auto-tuning would pick ~256MB
                                       # from 8GB shared_buffers, which is wasteful.
huge_pages = try                       # Use if OS is configured (vm.nr_hugepages).
                                       # Falls back gracefully.

# --- WAL & Checkpoints ---
wal_level = replica                    # Required for replication and PITR.
max_wal_size = 8GB                     # Avoid frequent forced checkpoints on write-heavy
                                       # workloads.
min_wal_size = 1GB                     # Keep pre-allocated WAL files around.
checkpoint_completion_target = 0.9     # Spread checkpoint I/O over 90% of interval.
checkpoint_timeout = 15min             # Balance between recovery time and I/O smoothness.
wal_compression = lz4                  # 30-60% WAL volume reduction. Negligible CPU cost.

# --- Autovacuum ---
autovacuum_max_workers = 5             # Default 3 is too few for 20+ active tables.
autovacuum_vacuum_cost_delay = 2ms     # Aggressive on SSD. Default was 20ms pre-PG12.
autovacuum_vacuum_cost_limit = 800     # Let vacuum work harder per cycle.
autovacuum_naptime = 30s               # Check for work every 30s instead of 60s.

# --- Connections ---
max_connections = 150                  # Use PgBouncer in front. Do not increase this
                                       # without connection pooling.
idle_in_transaction_session_timeout = 300000  # 5 min. Kill sessions that hold locks
                                              # by sitting idle in a transaction.

# --- Planner ---
random_page_cost = 1.1                 # SSD: random I/O ~ sequential I/O.
effective_io_concurrency = 200         # SSD can handle many concurrent I/O requests.
default_statistics_target = 200        # More granular stats than default 100.
                                       # Better plans for skewed distributions.

# --- Parallel Query ---
max_parallel_workers_per_gather = 4    # Up to 4 workers per parallel query node.
max_parallel_workers = 8               # Global cap. Half of a 16-core machine.
max_worker_processes = 16              # Total background workers including autovacuum,
                                       # logical replication, parallel query.
max_parallel_maintenance_workers = 2   # Parallel CREATE INDEX, VACUUM.

# --- Logging ---
log_min_duration_statement = 250       # Log queries slower than 250ms.
log_checkpoints = on                   # Log every checkpoint for diagnostics.
log_lock_waits = on                    # Log when a query waits >1s for a lock.
log_temp_files = 1MB                   # Log when queries spill to disk.
log_autovacuum_min_duration = 500      # Log autovacuum runs taking >500ms.

# --- pg_stat_statements ---
shared_preload_libraries = 'pg_stat_statements'
pg_stat_statements.max = 10000
pg_stat_statements.track = all
```

### Scaling This Template

| Scenario | Changes |
|----------|---------|
| **64 GB RAM** | `shared_buffers = 16GB`, `effective_cache_size = 48GB`, `maintenance_work_mem = 4GB` |
| **128+ GB RAM** | Cap `shared_buffers` at 16-32 GB, scale `effective_cache_size` to 75%, `work_mem` can increase |
| **Fewer cores (4)** | `max_parallel_workers = 4`, `max_parallel_workers_per_gather = 2`, `max_worker_processes = 8` |
| **Data warehouse** | `work_mem = 256MB-1GB`, `max_parallel_workers_per_gather = 8`, lower `max_connections` to 50 |
| **High connections (500+)** | Add PgBouncer, keep `max_connections = 100`, drop `work_mem` to 8-16 MB |
| **HDD storage** | `random_page_cost = 4.0`, `effective_io_concurrency = 2`, be generous with `shared_buffers` |
