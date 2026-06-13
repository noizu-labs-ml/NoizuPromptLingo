# Engine Internals Compared: PostgreSQL vs MySQL vs TimescaleDB

> Target audience: senior developers who work across multiple database engines and need to understand why tuning advice differs so dramatically between them.
> This document explains the architectural reasons behind the tuning differences, not just the tuning parameters themselves.

---

## 1. MVCC: The Fundamental Divergence

PostgreSQL and MySQL (InnoDB) both use Multi-Version Concurrency Control (MVCC), but their implementations are architecturally opposite, and this single difference drives most of the tuning divergence.

### PostgreSQL: Heap-Based MVCC (Write-Optimized)

PostgreSQL stores all row versions directly in the heap (table) file. When you UPDATE a row:

1. The old version stays in place (marked with the updating transaction's `xmax`)
2. A new version is written to the heap (possibly a different page)
3. All indexes that reference the row get new entries pointing to the new version
4. The old version is invisible to new transactions but still physically present

**Consequence: Bloat.** Dead row versions accumulate until VACUUM reclaims them. A table with 10M rows that gets fully updated twice has 30M physical rows (10M live + 20M dead).

**Why PostgreSQL chose this:**
- Writes are fast: no undo log overhead, no read of undo data on rollback
- Rollback is instant: just mark the transaction as aborted
- No rollback segment sizing headaches
- Consistent read snapshots are trivial: just check `xmin`/`xmax` visibility

### MySQL (InnoDB): Undo Log MVCC (Read-Optimized)

InnoDB stores only the latest row version in the clustered index (the "current" row). When you UPDATE:

1. The old version is copied to the undo log (undo tablespace)
2. The current row in the clustered index is updated in-place
3. Secondary indexes **are not updated** if the indexed columns didn't change (only the clustered index is updated)
4. Readers needing an older snapshot reconstruct the old version from the undo log chain

**Consequence: No table bloat.** The table always contains only the latest versions. Space from updated/deleted rows is reused immediately by the purge thread.

**Why InnoDB chose this:**
- Tables stay compact (no bloat, no VACUUM needed)
- Secondary indexes are cheaper to maintain (only updated when indexed columns change)
- Read performance on the latest version is optimal (single B+tree traversal)

### The Trade-Off Matrix

| Characteristic | PostgreSQL | MySQL (InnoDB) |
|----------------|-----------|----------------|
| **Table size over time** | Grows with dead tuples (bloat) | Stays compact |
| **VACUUM/Purge** | Explicit, expensive, critical | Automatic, lightweight purge thread |
| **Rollback cost** | Instant (just mark xact aborted) | Must replay undo log (can be slow for large transactions) |
| **Long transaction impact** | Blocks VACUUM → bloat accumulates | Blocks purge → undo log grows → disk usage |
| **Index maintenance on UPDATE** | ALL indexes updated (new version pointer) | Only indexes with changed columns |
| **Write amplification on UPDATE** | High (new heap tuple + all index entries) | Lower (in-place update + undo log entry) |
| **Read old snapshot** | Direct heap access (old version is right there) | Reconstruct from undo chain (slower for very old snapshots) |
| **HOT updates** | If no indexed columns change, can avoid index updates (Heap-Only Tuple) | N/A (always in-place) |
| **Fillfactor tuning** | Important (leave room for HOT updates) | N/A (in-place updates don't need free space) |

### TimescaleDB Implications

TimescaleDB inherits PostgreSQL's heap-based MVCC. But chunks change the dynamics:

- **Old chunks are append-only** — no updates, no dead tuples, no vacuum needed
- **Only the most recent chunk has significant write activity** — vacuum pressure is concentrated
- **DROP CHUNKS bypasses VACUUM entirely** — dead data is removed by dropping the chunk table, not by reclaiming individual dead tuples
- **Compression replaces the heap** — compressed chunks use a columnar format, eliminating MVCC overhead entirely

This is why TimescaleDB's time-series data model sidesteps PostgreSQL's biggest weakness (bloat from MVCC) while retaining its strengths (snapshot isolation, transactional DDL).

---

## 2. Write Amplification

Write amplification is the ratio of actual bytes written to storage vs. the logical bytes the application wrote. Higher write amplification = more I/O, more SSD wear.

### PostgreSQL Write Path

A single UPDATE of a 100-byte row causes:

1. **New heap tuple**: 100 bytes + tuple header (~24 bytes) = ~124 bytes
2. **WAL record for the new tuple**: ~150 bytes (includes full page image on first modify after checkpoint)
3. **Index entries**: one per index, each ~30-100 bytes in WAL
4. **Full-page writes (FPW)**: first modification to any page after a checkpoint writes the entire 8KB page to WAL

**Total for one 100-byte UPDATE with 3 indexes and FPW:**
- Heap: 8KB (FPW) + 124 bytes
- Index 1: 8KB (FPW) + ~50 bytes
- Index 2: 8KB (FPW) + ~50 bytes
- Index 3: 8KB (FPW) + ~50 bytes
- **Total WAL: ~32KB** for a 100-byte logical write = **320x amplification**

After the first modify (FPW is done), subsequent updates on the same pages are cheaper: ~400 bytes per update.

**Mitigations:**
```ini
wal_compression = lz4         # Compresses FPW images (30-60% reduction)
full_page_writes = on         # Never turn this off (data corruption risk)
# Increase checkpoint_timeout to reduce FPW frequency:
checkpoint_timeout = 15min    # Default 5min triggers FPW too often
```

### MySQL (InnoDB) Write Path

A single UPDATE of the same 100-byte row:

1. **In-place update in clustered index page**: modifies the existing row (no new tuple)
2. **Undo log entry**: ~100 bytes (the old version for MVCC)
3. **Redo log entry**: ~50-100 bytes (the change vector)
4. **Doublewrite buffer**: 16KB (if the page was dirty, written to doublewrite area before the data file)
5. **Secondary indexes**: only if indexed columns changed

**Total for the same UPDATE (3 indexes, indexed column unchanged):**
- Redo: ~100 bytes
- Undo: ~100 bytes
- Doublewrite: 16KB (amortized across many page writes)
- **Total: ~200 bytes + amortized doublewrite** = much lower amplification

**The in-place update advantage is massive.** This is why InnoDB handles high-write OLTP workloads with less I/O than PostgreSQL, all else being equal.

**Mitigations on MySQL:**
```ini
innodb_doublewrite = OFF      # ONLY on storage with atomic writes (ZFS, FusionIO)
                               # Saves 16KB per dirty page flush
innodb_redo_log_capacity = 4G # Larger redo log → fewer checkpoints → less doublewrite
```

### TimescaleDB Write Amplification

For append-only time-series (INSERT-only, no UPDATE/DELETE):

- No dead tuples → no MVCC overhead
- Each INSERT writes to the end of the heap → good page locality
- FPW happens on the first INSERT into each new 8KB page → amortized over many rows
- Compression eliminates post-compression write amplification entirely

**Net effect:** TimescaleDB's append-only workload has ~3-5x write amplification (vs. PostgreSQL OLTP's 10-300x). This is why TimescaleDB can sustain 500k+ rows/sec on a single NVMe drive.

---

## 3. Connection Architecture

### PostgreSQL: Process-Per-Connection

Each PostgreSQL connection spawns a separate OS process via `fork()`. This provides:

- **Strong isolation**: one runaway query can't corrupt another connection's memory
- **Simplicity**: each backend has its own memory space, no thread-safety issues in the codebase
- **Cost**: ~5-10 MB per connection (process memory, catalog cache, work_mem allocations)

At 200 connections: ~1-2 GB just for connection overhead.
At 1000 connections: ~5-10 GB + severe lock contention in shared memory structures.

**The scalability limit is ~200-300 active connections.** Beyond that, use PgBouncer.

### MySQL: Thread-Per-Connection (Community) or Thread Pool

Each MySQL connection gets an OS thread. Threads are lighter than processes:

- **Lower memory overhead**: ~2-5 MB per thread (vs ~5-10 MB per process)
- **Faster creation**: thread creation < process fork
- **But**: thread safety bugs can corrupt shared memory (rare in modern MySQL, but possible)

MySQL Community can handle 500-1000 connections without a pooler. With Percona/MariaDB thread pool, 5000+ client connections can be multiplexed onto ~32 worker threads.

### Impact on Tuning

| Parameter | PostgreSQL Approach | MySQL Approach |
|-----------|--------------------|--------------------|
| Connection limits | Keep low (100-200), use PgBouncer | Higher (500-1000), or use ProxySQL/thread pool |
| Per-connection memory (`work_mem` / `sort_buffer_size`) | Budget carefully: 200 connections × 32MB = 6.4 GB worst case | Similar concern, but thread overhead is lower |
| Connection pooling | **Mandatory** for production | Recommended but not always mandatory |
| Idle connection cost | ~10 MB each (process memory) | ~2-5 MB each (thread stack + TLS buffers) |

---

## 4. Checkpoint Mechanics

Both PostgreSQL and MySQL face the same fundamental problem: dirty pages in memory must eventually be flushed to disk, and this flush (checkpoint) can cause I/O spikes.

### PostgreSQL Checkpoints

The checkpointer process periodically flushes all dirty pages from `shared_buffers` to disk:

1. Marks all currently dirty pages
2. Writes them to their data files, spread over `checkpoint_completion_target × checkpoint_timeout`
3. Writes a checkpoint record to WAL
4. Recycles WAL files before the checkpoint

**The I/O spike problem:** If `max_wal_size` is too small, checkpoints are forced by WAL volume (not timeout), causing sudden I/O storms. The `checkpoints_req` counter (in `pg_stat_bgwriter`) tells you how often this happens.

```sql
-- Diagnostic:
SELECT checkpoints_timed, checkpoints_req FROM pg_stat_bgwriter;
-- checkpoints_req >> checkpoints_timed = increase max_wal_size
```

### MySQL (InnoDB) Checkpoint/Flushing

InnoDB uses a **fuzzy checkpoint** model with multiple flushing mechanisms:

1. **Page cleaner threads** continuously flush dirty pages (background)
2. **Adaptive flushing** adjusts flush rate based on redo log fill level
3. **Checkpoint** occurs when redo log space needs to be reclaimed

The key difference: MySQL's flushing is continuous and adaptive, while PostgreSQL's is periodic and burst-oriented.

```ini
# MySQL adaptive flushing:
innodb_adaptive_flushing = ON            # Adjusts flush rate to redo log fill
innodb_adaptive_flushing_lwm = 10        # Start adaptive flushing at 10% redo capacity
innodb_flushing_avg_loops = 30           # Smoothing factor for adaptive rate

# PostgreSQL's nearest equivalent:
bgwriter_lru_maxpages = 200              # Background writer pages per round
bgwriter_lru_multiplier = 2.0            # Multiplier for recent need estimate
# But PG's bgwriter is much less sophisticated than InnoDB's page cleaners
```

### TimescaleDB Checkpoint Behavior

TimescaleDB amplifies PostgreSQL's checkpoint cost because:
- More tables (chunks) = more dirty pages across more files
- Ingest-heavy workloads dirty many pages quickly
- Compression policies create write bursts (rewriting chunk data)

**Mitigation:** Increase `max_wal_size` and `checkpoint_timeout` more aggressively than for vanilla PostgreSQL OLTP.

---

## 5. Replication Architecture

### PostgreSQL: Physical (WAL) + Logical

**Physical replication (streaming):** Ships WAL bytes from primary to replica. Replica replays the WAL to maintain an exact byte-for-byte copy.

- Pros: Simple, reliable, low overhead, supports PITR
- Cons: Replica must have identical PostgreSQL version and architecture; can't filter tables; can't do cross-version replication

**Logical replication (PG 10+):** Decodes WAL into logical change events (INSERT/UPDATE/DELETE), ships row-level changes.

- Pros: Cross-version, selective table replication, can replicate to different schemas
- Cons: Higher overhead (WAL decoding), doesn't replicate DDL, can drift if not monitored

### MySQL: Binary Log Replication

MySQL replication is always logical — it ships binlog events (row images or SQL statements) from primary to replica.

- **Row-based binlog**: Ships before/after row images. Correct but verbose.
- **Statement-based binlog**: Ships SQL statements. Compact but non-deterministic (breaks on `NOW()`, `RAND()`, etc.).

MySQL has no equivalent to PostgreSQL's physical (WAL-shipping) replication. The closest analog is Group Replication (MySQL's Paxos-based consensus protocol), which provides synchronous replication but with significant overhead.

### Impact on Performance

| Factor | PostgreSQL Physical | MySQL Row Binlog |
|--------|--------------------|--------------------|
| Primary overhead | Minimal (WAL is written anyway) | Moderate (binlog is additional I/O) |
| Replica lag | Typically <1 second | Typically <1 second, but can spike on large transactions |
| Large transaction impact | WAL is streamed in real-time | Binlog event is written atomically at commit; large transactions cause replica burst |
| DDL replication | Automatic (part of WAL) | Automatic (part of binlog) |
| Filtering | Not possible (physical) | Possible with `binlog-do-db` and row filters |

### TimescaleDB Replication

TimescaleDB supports PostgreSQL physical replication out of the box. Logical replication has caveats:
- Chunks are regular tables — logical replication replicates them normally
- But chunk creation/deletion is DDL — **not replicated by logical replication**
- The recommended approach: physical replication for TimescaleDB replicas

---

## 6. When to Use Which Engine

### PostgreSQL Strengths (Where It Wins)

| Workload | Why PostgreSQL Wins |
|----------|--------------------| 
| Complex queries with CTEs, window functions, LATERAL | Mature optimizer, excellent CTE inlining (12+), full SQL standard support |
| JSONB semi-structured data | Native JSONB type with GIN indexing, containment operators, path queries |
| Geospatial (PostGIS) | PostGIS is the gold standard; nothing in MySQL comes close |
| Extension ecosystem | pg_stat_statements, pg_trgm, pgvector, PostGIS, TimescaleDB, Citus |
| Transactional DDL | All DDL is transactional — `ALTER TABLE` inside a transaction can be rolled back |
| Correctness guarantees | Strictest SQL compliance, no silent data truncation, no implicit type coercion surprises |

### MySQL Strengths (Where It Wins)

| Workload | Why MySQL/InnoDB Wins |
|----------|----------------------|
| High-write OLTP (social media, session stores) | In-place updates, no VACUUM, lower write amplification |
| Very high connection counts | Thread model handles 500-1000+ connections better than PG's process model |
| Simple read-heavy workloads | Clustered index gives excellent point-lookup performance; no MVCC bloat on readers |
| Operational simplicity | No VACUUM to tune, no autovacuum falling behind, no XID wraparound risk |
| Ecosystem breadth | WordPress, Drupal, Magento, most PHP CMSes expect MySQL; tooling is mature |
| Online DDL for most operations | INSTANT column addition, INPLACE index creation (PG's CREATE INDEX CONCURRENTLY is comparable but less featureful) |

### TimescaleDB Strengths (Where It Wins)

| Workload | Why TimescaleDB Wins |
|----------|---------------------|
| Time-series ingest + query | Chunk exclusion, automatic partitioning, 500k+ rows/sec ingest |
| IoT metrics and sensor data | Compression (10-20x), continuous aggregates, built-in retention |
| Observability data (logs, traces, metrics) | Handles high cardinality better than specialized TSDBs; full SQL |
| Replacing InfluxDB/Prometheus for long-term storage | SQL query language, JOIN with relational data, better tooling |

### Anti-Patterns (Where Each Engine Struggles)

| Engine | Don't Use For | Why |
|--------|--------------|-----|
| PostgreSQL | High-write, long-lived tables with frequent UPDATEs and no maintenance windows | VACUUM can't keep up; bloat spirals; XID wraparound risk |
| MySQL | Complex analytical queries (10+ table joins, recursive CTEs, window functions) | Optimizer is weaker; missing features (lateral joins added in 8.0.14 but limited); no transactional DDL |
| TimescaleDB | Traditional OLTP (shopping carts, user accounts, CMS content) | It's PostgreSQL underneath — use plain PostgreSQL. TimescaleDB adds overhead for non-time-series tables. |

---

## 7. Cross-Engine Tuning Cheat Sheet

When switching between engines, these are the parameter mappings:

| Concept | PostgreSQL | MySQL (InnoDB) | TimescaleDB |
|---------|-----------|----------------|-------------|
| Main page cache | `shared_buffers` (25% RAM) | `innodb_buffer_pool_size` (70-80% RAM) | `shared_buffers` (same as PG) |
| OS cache hint | `effective_cache_size` | N/A (InnoDB manages its own) | `effective_cache_size` |
| Per-query sort memory | `work_mem` | `sort_buffer_size` + `join_buffer_size` | `work_mem` (set higher for aggregations) |
| Maintenance memory | `maintenance_work_mem` | `innodb_log_buffer_size` (closest analog) | `maintenance_work_mem` |
| WAL / redo log size | `max_wal_size` | `innodb_redo_log_capacity` | `max_wal_size` (set higher) |
| Checkpoint interval | `checkpoint_timeout` | N/A (adaptive flushing) | `checkpoint_timeout` (set higher) |
| Random I/O cost hint | `random_page_cost` (1.1 for SSD) | N/A (InnoDB has its own cost model) | `random_page_cost` |
| Connection limit | `max_connections` + PgBouncer | `max_connections` + ProxySQL | `max_connections` + PgBouncer |
| Slow query log | `log_min_duration_statement` | `long_query_time` + `slow_query_log` | `log_min_duration_statement` |
| Query stats extension | `pg_stat_statements` | Performance Schema + `sys` schema | `pg_stat_statements` |
| Dead tuple cleanup | autovacuum | purge thread (automatic) | autovacuum (per-chunk) |
| Default isolation | READ COMMITTED | REPEATABLE READ | READ COMMITTED |
| Parallel query | `max_parallel_workers_per_gather` | N/A (MySQL has no parallel query) | `max_parallel_workers_per_gather` |
| Table partitioning | Declarative partitioning (10+) | Declarative partitioning (8.0+) | Automatic via chunks |
