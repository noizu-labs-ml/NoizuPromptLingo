# MySQL / MariaDB Performance Tuning Reference

> Target audience: senior developers and DBAs running MySQL 8.0+ or MariaDB 10.6+ in production.
> Philosophy: understand the engine internals, then tune with purpose. Cargo-culting my.cnf snippets from Stack Overflow is how you get 3 AM pages.

---

## 1. InnoDB Architecture: What You Must Know

### The Clustered Index — MySQL's Defining Characteristic

InnoDB stores the **entire row** in the leaf nodes of the primary key B+tree. This is the clustered index. There is no separate heap file like PostgreSQL. Every secondary index leaf stores the primary key value, not a pointer to a physical row location.

**Consequences nobody warns you about:**

1. **PK choice affects every single query.** A wide PK (UUID, composite) bloats every secondary index because every secondary index leaf copies the PK value. A 16-byte UUID PK on a table with 5 secondary indexes means 80 extra bytes per row across all indexes — on a 100M row table, that's ~8 GB of wasted index space.

2. **Random UUID PKs destroy write performance.** The clustered index is physically ordered by PK. Random UUIDs cause random page splits across the B+tree. `uuid_to_bin(uuid, 1)` (swap the time bits) or `UUID_v7` (time-ordered) fix this. Or use `BIGINT AUTO_INCREMENT` and expose UUIDs as a separate column.

3. **Secondary index lookups are always two-step.** A query using a secondary index first traverses that index to get the PK, then traverses the clustered index to get the row. This "bookmark lookup" is why covering indexes matter even more in MySQL than PostgreSQL.

4. **DELETE doesn't reclaim space immediately.** InnoDB marks rows as deleted in the clustered index; the purge thread reclaims space asynchronously. `OPTIMIZE TABLE` or `ALTER TABLE ... ENGINE=InnoDB` forces a table rebuild (online in 8.0+, but still expensive on large tables).

### Buffer Pool Internals

The buffer pool is InnoDB's page cache. Every data page and index page goes through it.

```ini
# The classic advice: set to 70-80% of RAM on a dedicated DB server
innodb_buffer_pool_size = 24G   # on a 32 GB server

# But the real tuning is in the details:
innodb_buffer_pool_instances = 8  # Reduces mutex contention. Set to 8 for pools >= 8 GB.
                                   # Each instance gets pool_size / instances.
                                   # Max useful: 64. Beyond that, diminishing returns.

innodb_buffer_pool_chunk_size = 128M  # Resize granularity (default).
                                       # pool_size must be a multiple of chunk_size * instances.
                                       # InnoDB silently rounds up if it's not.
```

**The 37.5% Rule is Wrong.** Many guides say "set buffer pool to 50-80% of RAM." The right answer depends on what else runs on the box:

| Scenario | Buffer Pool | Why |
|----------|-------------|-----|
| Dedicated MySQL, 64GB RAM | 48-52 GB (75-80%) | Leave headroom for OS cache, per-connection buffers, temp tables |
| Shared with app, 32GB RAM | 10-12 GB (30-37%) | App needs memory; contention with OS cache helps nobody |
| Read-heavy, dataset fits in RAM | Increase until cache hit ratio stops improving | Monitor `Innodb_buffer_pool_read_requests` vs `Innodb_buffer_pool_reads` |
| Write-heavy, large dataset | Don't exceed 75% even on dedicated server | Write-heavy workloads need OS cache for redo log, doublewrite, binlog |

**Buffer Pool LRU: The Young/Old Split**

InnoDB doesn't use a simple LRU. The buffer pool is split into "young" (hot) and "old" (cold) sublists. New pages enter at the head of the old sublist. Only if they're accessed again within `innodb_old_blocks_time` (default 1000ms) do they move to the young sublist.

This prevents a single full-table scan from evicting your entire working set. But it means:

- Large analytical queries that touch pages twice within 1 second WILL pollute the buffer pool
- For mixed OLTP+analytics: increase `innodb_old_blocks_time` to 5000-10000ms, or better yet, route analytics to a replica

```sql
-- Monitor buffer pool state:
SELECT
  POOL_ID, POOL_SIZE, FREE_BUFFERS, DATABASE_PAGES,
  OLD_DATABASE_PAGES, MODIFIED_DB_PAGES,
  PENDING_READS, PENDING_WRITES_LRU
FROM INFORMATION_SCHEMA.INNODB_BUFFER_POOL_STATS;

-- Cache hit ratio (should be > 99.5% for OLTP):
SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool_read%';
-- Hit ratio = 1 - (Innodb_buffer_pool_reads / Innodb_buffer_pool_read_requests)
```

### The Adaptive Hash Index — A Hidden Landmine

InnoDB automatically builds in-memory hash indexes on frequently-accessed B+tree pages. Sounds great. Here's when it's not:

- **High contention on the AHI latch under heavy concurrent reads.** MySQL 8.0 shards the AHI across `innodb_adaptive_hash_index_parts` (default 8), but on 64+ core machines with uniform access patterns, AHI latch waits can dominate.
- **Wastes buffer pool memory.** The AHI consumes buffer pool space. On servers where buffer pool is tight, that's memory not caching data pages.
- **Unpredictable.** The AHI decides what to cache based on access patterns. It can evict its own entries at the worst time.

```ini
# Test disabling it and measure:
innodb_adaptive_hash_index = OFF

# Check current AHI state:
# SHOW ENGINE INNODB STATUS\G  -- look for "ADAPTIVE HASH INDEX" section
# SHOW GLOBAL STATUS LIKE 'Innodb_adaptive_hash%';
```

**When to disable AHI:**
- Servers with 64+ cores and uniform access patterns (AHI latch contention)
- Write-heavy workloads where reads are mostly sequential/range
- When `Innodb_adaptive_hash_searches` is low relative to `Innodb_adaptive_hash_searches_btree`

**When to keep it:**
- Point-select-heavy OLTP (session lookups, user profiles)
- Low-to-moderate core counts (<32 cores)
- When disabling it measurably regresses latency

---

## 2. Transaction Isolation and Locking — Where MySQL Bites

### REPEATABLE READ: MySQL's Default and Your Enemy

MySQL's default isolation level is `REPEATABLE READ`, not `READ COMMITTED` like PostgreSQL. This has profound performance implications:

**Gap Locks and Next-Key Locks:**

In REPEATABLE READ, InnoDB uses **next-key locking** — it locks not just the rows matching your WHERE clause but the *gaps* between them. This prevents phantom reads but causes deadlocks and contention that don't exist in READ COMMITTED.

```sql
-- Table: orders (id INT PRIMARY KEY, status VARCHAR(20), INDEX(status))
-- Rows: id=1 status='pending', id=5 status='shipped', id=10 status='shipped'

-- Transaction 1:
SELECT * FROM orders WHERE status = 'shipped' FOR UPDATE;
-- Locks: rows id=5 and id=10 PLUS the gaps (5..10) and (10..supremum)
-- This means NO OTHER TRANSACTION can insert id=7, status='shipped'

-- Transaction 2 (blocks!):
INSERT INTO orders VALUES (7, 'shipped');
-- Waits on the gap lock held by T1, even though row 7 doesn't exist
```

**The Fix for Most Applications:**

```sql
SET GLOBAL transaction_isolation = 'READ-COMMITTED';
-- Or per-session: SET SESSION transaction_isolation = 'READ-COMMITTED';
```

READ COMMITTED eliminates gap locks for most operations. **Caveat:** requires `binlog_format = ROW` (which you should be using anyway post-MySQL 5.7).

**When to keep REPEATABLE READ:**
- Banking/financial applications that absolutely need serializable-like guarantees
- Applications that rely on consistent snapshot reads within a transaction
- When the application explicitly uses `SELECT ... FOR UPDATE` with gap-lock semantics

### InnoDB Deadlock Detection

```ini
# Default: ON. InnoDB actively checks for deadlocks on every lock wait.
innodb_deadlock_detect = ON

# On high-contention workloads (thousands of concurrent transactions hitting
# the same rows), deadlock detection becomes the bottleneck itself — O(n²)
# in the worst case on the lock wait graph.
#
# Alternative: disable detection, set a lock wait timeout instead:
innodb_deadlock_detect = OFF
innodb_lock_wait_timeout = 5   # seconds. Transaction errors out, app retries.
```

**When to disable deadlock detection:**
- High-contention workloads (>100 concurrent transactions competing for the same rows)
- When you have proper retry logic in the application
- Benchmark: if `SHOW ENGINE INNODB STATUS` shows "DEADLOCK DETECTION" taking >1ms, test disabling

**When to keep it ON:**
- Low-to-moderate contention
- Applications without retry logic (deadlock detection at least tells you which transaction to abort)

---

## 3. Flush Strategy — The `innodb_flush_log_at_trx_commit` Decision

This is the single most impactful durability/performance trade-off in MySQL.

| Value | Behavior | Durability | Performance |
|-------|----------|------------|-------------|
| **1** (default) | Flush + fsync redo log on every commit | **Full ACID** — survives power failure | Baseline (slowest) |
| **2** | Write to OS buffer on every commit, fsync once per second | Lose up to 1 second of commits on power failure; survives MySQL crash | 2-5x faster commits |
| **0** | Write + flush once per second; commits don't trigger any I/O | Lose up to 1 second on MySQL crash or power failure | 5-10x faster commits |

**The real decision matrix:**

| Scenario | Setting | Rationale |
|----------|---------|-----------|
| Financial transactions, e-commerce orders | `1` | Cannot lose a committed transaction, period |
| Session storage, analytics, logging | `2` | Losing 1 second of sessions/logs is acceptable; crash recovery works |
| Batch import, ETL pipeline | `0` during load, `1` after | Speed matters; you can rerun the batch |
| Replica servers | `2` | Data is recoverable from the primary; full durability is redundant |

```ini
# Combine with:
innodb_flush_method = O_DIRECT  # Bypass OS double-caching (Linux). Always set this.
                                 # Alternatives: O_DSYNC (rarely better), fsync (default, usually wrong)
```

### The Doublewrite Buffer — Do You Still Need It?

InnoDB writes pages twice: first to a sequential doublewrite area, then to the actual data file. This protects against torn pages (partial writes due to crash mid-write).

```ini
# Default: ON. Since MySQL 8.0.20, this is file-based (not in system tablespace).
innodb_doublewrite = ON

# On storage that guarantees atomic writes (ZFS, FusionIO, some NVMe with capacitor-backed cache):
innodb_doublewrite = OFF
# Saves ~10-15% write I/O
```

**Never disable doublewrite on ext4/xfs without hardware write atomicity guarantees.** A torn page = silent data corruption that you may not discover for months.

---

## 4. InnoDB I/O Tuning

### I/O Capacity

```ini
# Tell InnoDB how fast your storage is (IOPS):
innodb_io_capacity = 2000        # Background flushing target (dirty pages, merge inserts)
innodb_io_capacity_max = 4000    # Burst limit during aggressive flushing (checkpoint urgency)

# Guidelines:
# HDD (single):     200 (default)
# SAS RAID:         2000-5000
# SSD (SATA):       5000-10000
# NVMe:             10000-40000
# Cloud (gp3/io2):  Check your provisioned IOPS and set to 75%
```

**The trap:** Setting `innodb_io_capacity` too high makes InnoDB flush dirty pages aggressively, wearing out SSDs and stealing I/O from queries. Too low, and dirty pages pile up, causing checkpoint stalls. Start at 50-75% of your measured IOPS and tune from there.

### Redo Log Sizing (The Post-8.0.30 World)

MySQL 8.0.30 replaced `innodb_log_file_size` × `innodb_log_files_in_group` with a single `innodb_redo_log_capacity` parameter.

```ini
# Pre-8.0.30:
innodb_log_file_size = 2G
innodb_log_files_in_group = 2
# Total redo space = 4 GB

# Post-8.0.30:
innodb_redo_log_capacity = 4G
# Same total, single parameter. InnoDB manages the number of files internally.
```

**Sizing guidance:**

The redo log should be large enough to hold ~1-2 hours of write activity without forcing aggressive checkpointing. Undersized redo logs cause "furious flushing" — InnoDB must urgently flush dirty pages to make room, creating I/O spikes.

```sql
-- Measure your write rate:
SHOW GLOBAL STATUS LIKE 'Innodb_os_log_written';
-- Note the value, wait 60 seconds, check again. The delta = bytes/minute.
-- redo_log_capacity should be >= delta * 60 (1 hour of writes)
```

Typical production values: 2-8 GB for OLTP, 8-16 GB for write-heavy workloads.

### The Change Buffer — When to Turn It Off

InnoDB's change buffer defers writes to secondary index pages that aren't in the buffer pool. Instead of reading the page, modifying it, and writing it back, InnoDB buffers the change and merges it later when the page is read for a query.

```ini
innodb_change_buffering = all      # Default: buffer inserts, deletes, purges
innodb_change_buffer_max_size = 25 # Percentage of buffer pool (default)
```

**When to disable:**
- SSD storage where random I/O is cheap (the change buffer saves random reads; on SSD, reads are fast)
- Workloads where secondary indexes are always in the buffer pool (dataset fits in memory)
- When you observe `Innodb_ibuf_merges` being very high, causing latency spikes on random reads

```ini
# For SSD with dataset in memory:
innodb_change_buffering = none
innodb_change_buffer_max_size = 0   # Reclaim buffer pool space
```

---

## 5. Online DDL — What's Actually Online and What Lies

MySQL 8.0 "Online DDL" doesn't mean "zero impact." It means "doesn't hold an exclusive lock for the full duration." Every DDL operation has three phases:

1. **Preparation** — brief exclusive lock to set up
2. **Execution** — may be fully online, may block DML, may copy the table
3. **Commit** — brief exclusive lock to swap

### The Truth Table

| Operation | Algorithm | Concurrent DML? | Rebuilds Table? | Inside Baseball |
|-----------|-----------|-----------------|-----------------|-----------------|
| `ADD INDEX` | INPLACE | Yes (reads + writes) | No | Builds index in background. The brief MDL lock at start/end can still cause stalls if there's a pending DDL queue. |
| `ADD COLUMN` (nullable, at end) | INSTANT (8.0.12+) | Yes | **No** | Only modifies metadata. Truly instant. The column doesn't physically exist in existing rows until they're updated. |
| `ADD COLUMN` (with DEFAULT, not at end) | INPLACE | Yes | **Yes** — full table rebuild | Despite being "online," it rewrites every row. On a 500GB table, this takes hours and doubles your disk usage temporarily. |
| `DROP COLUMN` | INPLACE | Yes | **Yes** | Table rebuild. Not instant despite sounding simple. PG 17 can mark columns as dropped in metadata; MySQL cannot. |
| `CHANGE COLUMN TYPE` | COPY | **No — blocks writes** | Yes | The most dangerous DDL. Falls back to the old COPY algorithm. Use `pt-online-schema-change` or `gh-ost` instead. |
| `ADD FOREIGN KEY` | INPLACE | Yes (reads only, writes blocked during validation) | No | Validation phase scans the entire child table. If the child is large, this is slow and blocks writes for the duration. |
| `RENAME COLUMN` | INSTANT (8.0) | Yes | No | Metadata-only change. Safe. |
| `RENAME INDEX` | INSTANT | Yes | No | Safe. |
| `OPTIMIZE TABLE` | INPLACE (8.0) | Yes | Yes | Full table rebuild. Use sparingly on large tables. |

### pt-online-schema-change vs gh-ost

When MySQL's built-in online DDL isn't safe enough (especially `CHANGE COLUMN TYPE`):

| Tool | Mechanism | Pros | Cons |
|------|-----------|------|------|
| **pt-online-schema-change** (Percona) | Creates shadow table + triggers | Battle-tested, handles FK constraints, supports throttling | Trigger overhead on write-heavy tables; trigger-based DDL can cause replication lag |
| **gh-ost** (GitHub) | Creates shadow table + binlog tailing | No triggers, less write overhead, pausable, testable with `--test-on-replica` | Requires binlog access, more complex setup, struggles with FK constraints |

**The inside-baseball take:** For most teams, `gh-ost` is better. Trigger-based approaches (pt-osc) create write amplification — every INSERT/UPDATE/DELETE fires a trigger that writes to the shadow table. On a table with 10k writes/sec, that's 10k extra writes. `gh-ost` reads the binlog stream instead, which is already being written. The trade-off is operational complexity.

---

## 6. MySQL Optimizer Secrets

### Optimizer Trace — The Secret Weapon

`EXPLAIN` tells you what the optimizer chose. Optimizer trace tells you **why**.

```sql
SET optimizer_trace = 'enabled=on';
SELECT * FROM orders WHERE status = 'pending' AND created_at > '2024-01-01';
SELECT * FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE\G
SET optimizer_trace = 'enabled=off';
```

The trace JSON shows:
- Every index considered and why each was accepted/rejected
- Cost estimates for each access path
- Why the optimizer chose table scan over index scan
- Join order evaluation and costs
- Subquery transformation decisions

This is the MySQL equivalent of PostgreSQL's `auto_explain` with verbose logging, but more detailed.

### Invisible Indexes (8.0+) — MySQL's Best-Kept Secret

You can make an index invisible to the optimizer without dropping it. This is the **safe way to test index removal**.

```sql
-- Make invisible (optimizer ignores it, but it's still maintained)
ALTER TABLE orders ALTER INDEX idx_status INVISIBLE;

-- Monitor for performance regression for a week

-- If no regression: drop it
DROP INDEX idx_status ON orders;

-- If regression detected: make visible again (instant, no rebuild)
ALTER TABLE orders ALTER INDEX idx_status VISIBLE;
```

PostgreSQL has no equivalent. In PG, you must drop the index (and recreate it if you were wrong — which takes time on large tables).

### Descending Indexes (8.0+)

MySQL 8.0 supports true descending indexes. Before 8.0, `DESC` in index definitions was parsed but ignored.

```sql
-- Pre-8.0: this was silently stored as ASC
CREATE INDEX idx_date ON orders (created_at DESC);  -- actually stored ASC

-- Post-8.0: real descending index
CREATE INDEX idx_date ON orders (created_at DESC);  -- truly descending

-- Mixed-direction composite (now actually works):
CREATE INDEX idx_mixed ON orders (status ASC, created_at DESC);
```

### Histograms (8.0+)

MySQL 8.0 added histogram statistics for non-indexed columns. Unlike PostgreSQL (which collects histograms automatically via ANALYZE), MySQL requires explicit creation:

```sql
ANALYZE TABLE orders UPDATE HISTOGRAM ON status, region WITH 256 BUCKETS;

-- View histogram:
SELECT HISTOGRAM FROM INFORMATION_SCHEMA.COLUMN_STATISTICS
WHERE TABLE_NAME = 'orders' AND COLUMN_NAME = 'status'\G

-- Drop:
ANALYZE TABLE orders DROP HISTOGRAM ON status;
```

**The catch:** Histograms are not automatically refreshed. After significant data changes, you must re-run the ANALYZE command. Many MySQL installations forget this and run on stale histograms, which is worse than no histograms.

### Index Condition Pushdown (ICP)

ICP pushes WHERE conditions that can be evaluated using index columns down to the storage engine, filtering rows before they're read from the clustered index.

```sql
-- Without ICP (pre-5.6 behavior):
-- 1. Storage engine reads matching rows from secondary index
-- 2. Returns full rows to SQL layer
-- 3. SQL layer applies remaining WHERE conditions

-- With ICP (5.6+):
-- 1. Storage engine reads matching index entries
-- 2. Applies remaining WHERE conditions using index columns AT THE INDEX LEVEL
-- 3. Only fetches full rows for entries that pass

-- Example: index on (status, created_at)
SELECT * FROM orders WHERE status = 'pending' AND total > 100;
-- ICP checks status='pending' at the index level
-- But total>100 requires the base row, so ICP can't help there

-- Better example: index on (status, region, created_at)
SELECT * FROM orders WHERE status = 'pending' AND region LIKE 'US%' AND created_at > '2024-01-01';
-- ICP can evaluate all three conditions from the index, only fetching base rows for matches
```

```sql
-- Check if ICP is being used:
EXPLAIN SELECT ...;
-- Extra column shows: "Using index condition"
```

---

## 7. Replication Internals

### Binary Log Format — The Choice That Haunts You

| Format | Behavior | When It Breaks |
|--------|----------|----------------|
| `STATEMENT` | Logs the SQL statement | Non-deterministic functions (`NOW()`, `RAND()`, `UUID()`), `LIMIT` without `ORDER BY`, UDFs, `INSERT ... SELECT` with concurrent modifications |
| `ROW` | Logs the actual row changes (before/after images) | Large DELETE/UPDATE generates enormous binlogs; `DELETE FROM big_table WHERE ...` on 10M rows = 10M row events |
| `MIXED` | Statement by default, switches to ROW when the statement is non-deterministic | Unpredictable which format will be used; debugging replication issues becomes harder |

**The correct answer for 2024+: `ROW`.** Always. The binlog size overhead is the cost of correctness. Use `binlog_row_image = MINIMAL` to reduce size if you don't need the before-image.

```ini
binlog_format = ROW
binlog_row_image = MINIMAL   # Only log changed columns (default: FULL logs all columns)
                              # MINIMAL saves 30-70% binlog space
                              # Caveat: some CDC tools (Debezium) need FULL for before-image
```

### GTIDs — The Replication Topology Enabler

Global Transaction IDs (GTIDs) are UUIDs attached to every transaction, enabling topology changes without manual binlog position tracking.

```ini
gtid_mode = ON
enforce_gtid_consistency = ON
```

**Inside-baseball GTID gotchas:**

1. **`CREATE TABLE ... SELECT` is banned.** GTID consistency enforcement prohibits this because it's two operations (DDL + DML) in one statement. Rewrite as `CREATE TABLE ... LIKE` + `INSERT ... SELECT`.

2. **`CREATE TEMPORARY TABLE` inside transactions is banned.** Same reason. Workaround: use derived tables or CTEs.

3. **Errant transactions kill replication.** If a replica gets a transaction that doesn't exist on the primary (from a direct write, maintenance, or failover), replication breaks. Use `gtid_purged` carefully and never write to replicas unless you know exactly what you're doing.

### Semi-Synchronous Replication

```ini
# Primary:
rpl_semi_sync_source_enabled = ON
rpl_semi_sync_source_timeout = 1000   # ms. Fallback to async if replica doesn't ACK in time.

# Replica:
rpl_semi_sync_replica_enabled = ON
```

**The timeout trap:** If the replica is slow, semi-sync falls back to async. The primary logs a warning, but your application doesn't know. You think you have durable replication, but you don't. Monitor `Rpl_semi_sync_source_no_tx` (transactions that fell back to async).

---

## 8. Performance Schema — MySQL's `pg_stat_statements` on Steroids

Performance Schema is MySQL's introspection framework. It's more powerful than `pg_stat_statements` but more complex.

### Essential Queries

```sql
-- Top 10 slowest query digests (like pg_stat_statements):
SELECT
  DIGEST_TEXT,
  COUNT_STAR AS calls,
  ROUND(SUM_TIMER_WAIT / 1e12, 2) AS total_sec,
  ROUND(AVG_TIMER_WAIT / 1e12, 4) AS avg_sec,
  SUM_ROWS_EXAMINED,
  SUM_ROWS_SENT
FROM performance_schema.events_statements_summary_by_digest
ORDER BY SUM_TIMER_WAIT DESC
LIMIT 10;

-- Find full table scans:
SELECT
  OBJECT_SCHEMA, OBJECT_NAME,
  COUNT_READ AS reads,
  COUNT_FETCH AS fetches
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE INDEX_NAME IS NULL
  AND COUNT_READ > 0
ORDER BY COUNT_READ DESC
LIMIT 20;

-- Wait analysis (what is MySQL waiting on?):
SELECT
  EVENT_NAME,
  COUNT_STAR AS waits,
  ROUND(SUM_TIMER_WAIT / 1e12, 2) AS total_wait_sec,
  ROUND(AVG_TIMER_WAIT / 1e9, 2) AS avg_wait_ms
FROM performance_schema.events_waits_summary_global_by_event_name
WHERE COUNT_STAR > 0 AND EVENT_NAME NOT LIKE 'idle%'
ORDER BY SUM_TIMER_WAIT DESC
LIMIT 20;

-- Lock contention:
SELECT
  OBJECT_SCHEMA, OBJECT_NAME,
  LOCK_TYPE, LOCK_MODE, LOCK_STATUS, LOCK_DATA,
  OWNER_THREAD_ID
FROM performance_schema.data_locks
WHERE LOCK_STATUS = 'WAITING';

-- Memory usage by component (8.0+):
SELECT
  EVENT_NAME,
  CURRENT_NUMBER_OF_BYTES_USED / 1024 / 1024 AS mb_used,
  HIGH_NUMBER_OF_BYTES_USED / 1024 / 1024 AS mb_peak
FROM performance_schema.memory_summary_global_by_event_name
WHERE CURRENT_NUMBER_OF_BYTES_USED > 1024 * 1024
ORDER BY CURRENT_NUMBER_OF_BYTES_USED DESC
LIMIT 20;
```

### `sys` Schema — Performance Schema Made Readable

The `sys` schema (bundled since 5.7) provides views that format Performance Schema data for humans:

```sql
-- Top queries by latency:
SELECT * FROM sys.statements_with_runtimes_in_95th_percentile LIMIT 10;

-- Tables with full scans:
SELECT * FROM sys.schema_tables_with_full_table_scans LIMIT 10;

-- Unused indexes:
SELECT * FROM sys.schema_unused_indexes;

-- Redundant indexes:
SELECT * FROM sys.schema_redundant_indexes;

-- Wait analysis (readable):
SELECT * FROM sys.wait_classes_global_by_avg_latency;

-- IO by file:
SELECT * FROM sys.io_global_by_file_by_bytes LIMIT 10;

-- Buffer pool contents:
SELECT * FROM sys.innodb_buffer_stats_by_table ORDER BY pages DESC LIMIT 10;
```

---

## 9. Connection Management — Thread Pool vs Connection Pool

### MySQL's Thread Model

Each MySQL connection gets its own OS thread (not a process like PostgreSQL). This is lighter than PG's process-per-connection model but still has limits:

- ~5-10 MB per thread (stack, buffers, sort/join buffers)
- Context switching overhead scales with thread count
- `max_connections` default is 151; many production servers run 500-1000

### Thread Pool (Enterprise / MariaDB / Percona)

MySQL Community Edition uses one-thread-per-connection. MySQL Enterprise, Percona Server, and MariaDB offer a thread pool that multiplexes connections onto a fixed number of worker threads.

```ini
# Percona Server / MariaDB:
thread_handling = pool-of-threads
thread_pool_size = 16               # Worker thread groups (set to CPU core count)
thread_pool_max_threads = 200       # Absolute cap
thread_pool_stall_limit = 60        # ms before a stalled thread is considered stuck

# MariaDB:
thread_pool_size = 8                # Thread groups
thread_pool_max_threads = 500
```

**When thread pool helps:** 1000+ connections, most idle. The pool handles the connections with ~16-32 actual threads.

**When it doesn't help:** If all connections are active and compute-bound, a thread pool adds overhead without benefit.

### ProxySQL — The PgBouncer of MySQL

ProxySQL is the standard connection pooler for MySQL (equivalent to PgBouncer).

```ini
# /etc/proxysql.cnf key settings:
mysql_variables = {
    max_connections = 2048         # ProxySQL client-facing connections
    multiplexing = true            # Reuse backend connections across clients
    connection_pool_size = 100     # Backend connections to MySQL
}
```

**ProxySQL advantages over application-level pooling:**
- Query routing (read/write split, sharding)
- Query caching
- Query firewall
- Connection multiplexing across application instances

---

## 10. Configuration Template

Production-ready `my.cnf` for a **32 GB RAM, SSD, OLTP workload** server (MySQL 8.0.30+):

```ini
[mysqld]
# ============================================================
# MySQL 8.0 Production Configuration
# Target: 32 GB RAM, NVMe SSD, OLTP workload
# ============================================================

# --- InnoDB Memory ---
innodb_buffer_pool_size = 24G
innodb_buffer_pool_instances = 8
innodb_log_buffer_size = 64M

# --- InnoDB I/O ---
innodb_flush_method = O_DIRECT
innodb_flush_log_at_trx_commit = 1    # Full durability. Set to 2 for replicas.
innodb_doublewrite = ON               # OFF only on ZFS or capacitor-backed NVMe.
innodb_io_capacity = 10000            # NVMe. Reduce for SATA SSD (2000) or HDD (200).
innodb_io_capacity_max = 20000
innodb_read_io_threads = 8
innodb_write_io_threads = 8

# --- InnoDB Redo Log ---
innodb_redo_log_capacity = 4G         # 8.0.30+. Set to hold 1-2 hours of writes.

# --- InnoDB Behavioral ---
innodb_change_buffering = none        # SSD: random reads are cheap. Save buffer pool.
innodb_adaptive_hash_index = ON       # Test OFF on 64+ core machines.
innodb_print_all_deadlocks = ON       # Log all deadlocks to error log.

# --- Transaction Isolation ---
transaction_isolation = READ-COMMITTED  # Eliminates gap locks. Requires ROW binlog.

# --- Connections ---
max_connections = 500                 # Use ProxySQL in front for higher counts.
thread_cache_size = 64                # Cache threads for reuse (reduce thread creation).
wait_timeout = 600                    # Kill idle connections after 10 minutes.
interactive_timeout = 600

# --- Per-Session Memory ---
sort_buffer_size = 4M                 # Per-sort allocation. Don't set globally >8M.
join_buffer_size = 4M                 # Per-join for BNL joins. Don't set globally >8M.
read_rnd_buffer_size = 4M             # Multi-range read buffer.
tmp_table_size = 64M                  # Max in-memory temp table before spilling to disk.
max_heap_table_size = 64M             # Must match tmp_table_size.

# --- Binary Log ---
binlog_format = ROW
binlog_row_image = MINIMAL            # Reduce binlog size by ~50%.
binlog_expire_logs_seconds = 604800   # 7 days retention.
sync_binlog = 1                       # Flush binlog on every commit. Set to 0 for replicas.
log_bin = mysql-bin
server_id = 1                         # Unique per server. Required for replication.

# --- GTIDs ---
gtid_mode = ON
enforce_gtid_consistency = ON

# --- Query Optimizer ---
optimizer_switch = 'index_merge_intersection=off'  # Often produces slower plans than
                                                    # using a single best index.

# --- Logging ---
slow_query_log = ON
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 0.25                # Log queries slower than 250ms.
log_queries_not_using_indexes = ON    # Log queries doing full table scans.
log_slow_extra = ON                   # 8.0.14+: adds Rows_examined, Handler_* to slow log.

# --- Performance Schema ---
performance_schema = ON
performance_schema_max_digest_length = 4096
```

### Scaling This Template

| Scenario | Key Changes |
|----------|-------------|
| **64 GB RAM** | `innodb_buffer_pool_size = 48G`, `innodb_buffer_pool_instances = 16` |
| **128+ GB RAM** | Cap buffer pool at 80%, `innodb_buffer_pool_instances = 32-64` |
| **Read-heavy replica** | `innodb_flush_log_at_trx_commit = 2`, `sync_binlog = 0`, increase `innodb_read_io_threads` |
| **Write-heavy** | `innodb_redo_log_capacity = 8-16G`, increase `innodb_io_capacity`, lower `innodb_flush_log_at_trx_commit` to 2 |
| **HDD storage** | `innodb_io_capacity = 200`, `innodb_io_capacity_max = 400`, keep `innodb_change_buffering = all` |
| **1000+ connections** | Deploy ProxySQL, keep `max_connections = 200` on MySQL side |

---

## 11. MariaDB Divergences

MariaDB forked from MySQL 5.5 and has diverged significantly. Key differences for tuning:

| Feature | MySQL 8.0 | MariaDB 10.11+ |
|---------|-----------|----------------|
| Thread pool | Enterprise only | Built-in (free) |
| `INSTANT ADD COLUMN` | End of table only (8.0.12); any position (8.0.29) | Any position (10.3+), well before MySQL |
| Optimizer | Cost-based with histograms (8.0) | Cost-based with engine-independent table statistics (persistent stats since 10.0) |
| JSON | Native JSON type (binary storage) | JSON is an alias for LONGTEXT (text storage, slower for path queries) |
| Window functions | Full support (8.0) | Full support (10.2+) |
| CTEs | Recursive + non-recursive (8.0) | Same (10.2+) |
| System-versioned tables | Not supported | Built-in temporal tables (`WITH SYSTEM VERSIONING`) |
| Encryption at rest | Per-tablespace (Enterprise), keyring plugins | Per-tablespace + redo/undo/binlog encryption (free) |
| `EXPLAIN ANALYZE` | 8.0.18+ | 10.1+ (different output format) |
| Invisible columns | Not supported | 10.3+ (`ALTER TABLE t ADD COLUMN c INT INVISIBLE`) |
| Thread pool stall detection | Enterprise | Built-in with `thread_pool_stall_limit` |
| Query cache | **Removed** in 8.0 | Still available (but disabled by default in 10.1.7+) |

### MariaDB-Specific Tuning

```ini
# MariaDB thread pool (free, unlike MySQL Enterprise):
thread_handling = pool-of-threads
thread_pool_size = 8                # CPU core count
thread_pool_idle_timeout = 60

# MariaDB system-versioned tables:
# Built-in temporal table support — no need for application-level history tables
ALTER TABLE orders ADD SYSTEM VERSIONING;
-- Now: SELECT * FROM orders FOR SYSTEM_TIME AS OF '2024-01-01';
```

---

## 12. Quick Diagnostic Checklist

When something is slow, check in this order:

1. **Slow query log** — What's actually slow? `long_query_time = 0` briefly to capture everything.
2. **`EXPLAIN ANALYZE`** (8.0.18+) — What's the plan and actual execution? (Before 8.0.18: `EXPLAIN` only shows estimates.)
3. **`SHOW ENGINE INNODB STATUS\G`** — Deadlocks, semaphore waits, buffer pool stats, transaction list.
4. **`SHOW PROCESSLIST`** or `SELECT * FROM performance_schema.threads WHERE TYPE = 'FOREGROUND'` — What's running right now?
5. **Buffer pool hit ratio** — Is data cached? `Innodb_buffer_pool_reads / Innodb_buffer_pool_read_requests` should be < 0.005.
6. **InnoDB row operations** — `SHOW GLOBAL STATUS LIKE 'Innodb_rows_%'` — what kind of work is the engine doing?
7. **Disk I/O** — `iostat -x 1` at the OS level. If `%util` > 80%, you have an I/O bottleneck.
8. **Redo log checkpoint age** — In `SHOW ENGINE INNODB STATUS`, if checkpoint age approaches max checkpoint age, increase `innodb_redo_log_capacity`.
