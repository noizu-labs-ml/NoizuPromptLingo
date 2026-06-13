# MySQL Tools & Utilities Catalog

> Target audience: senior developers and DBAs running MySQL 8.0+ in production. Not a feature-list rehash — this is the "what I actually reach for at 3 AM" guide, with the gotchas that documentation doesn't mention.

---

## Table of Contents

1. [Query Analysis & Profiling](#1-query-analysis--profiling)
2. [Schema & Data Management](#2-schema--data-management)
3. [Replication & HA](#3-replication--ha)
4. [Monitoring & Diagnostics](#4-monitoring--diagnostics)
5. [Benchmarking](#5-benchmarking)
6. [CLI Essentials](#6-cli-essentials)
7. [Tool Selection Quick Reference](#tool-selection-quick-reference)

---

## 1. Query Analysis & Profiling

Tools for understanding why queries are slow, what the optimizer chose, and where time is actually spent.

### pt-query-digest (Percona Toolkit)

**What it does:** Parses slow query logs (or tcpdump captures, or Performance Schema output) and produces ranked reports showing which query fingerprints are consuming the most time.

**When you need it:** This is your first move when someone says "the database is slow." You don't guess which queries to optimize — you let pt-query-digest tell you where the time is going. It fingerprints queries (normalizes literals), ranks by total execution time, and shows you the 80/20: the handful of query patterns responsible for most of your load.

**Install:**

```bash
# Percona Toolkit (includes pt-query-digest and 30+ other tools)
brew install percona-toolkit
# or
apt-get install percona-toolkit
# or grab the single script
wget https://www.percona.com/get/pt-query-digest
chmod +x pt-query-digest
```

**Key usage:**

```bash
# Parse the slow query log (most common)
pt-query-digest /var/log/mysql/mysql-slow.log

# Parse only queries from the last hour
pt-query-digest --since '1h' /var/log/mysql/mysql-slow.log

# Parse and filter to a specific database
pt-query-digest --filter '$event->{db} eq "production"' /var/log/mysql/mysql-slow.log

# Parse from tcpdump (captures ALL queries, not just slow ones)
tcpdump -s 65535 -x -nn -q -tttt -i any -c 10000 port 3306 > mysql.tcpdump
pt-query-digest --type tcpdump mysql.tcpdump

# Parse from Performance Schema
pt-query-digest --type perfschema --host localhost --user root --ask-pass

# Output as JSON for further processing
pt-query-digest --output json /var/log/mysql/mysql-slow.log > report.json

# Review history over time (store digests in a table)
pt-query-digest --review h=localhost,D=percona,t=query_review \
                --history h=localhost,D=percona,t=query_history \
                /var/log/mysql/mysql-slow.log
```

**Reading the report:**

The report ranks query fingerprints by total execution time. For each fingerprint you get:

- **Response time** — total and percentage of all query time
- **Calls** — how many times this fingerprint executed
- **R/Call** — average response time per execution
- **V/M** — variance-to-mean ratio. High V/M means inconsistent performance (sometimes fast, sometimes slow). This is often more actionable than average time — it points to lock contention, cold cache misses, or plan instability.
- **EXPLAIN** — the tool can even run EXPLAIN on representative samples

**The three input sources and when to use each:**

| Source | What It Captures | Overhead | When to Use |
|--------|-----------------|----------|-------------|
| Slow query log | Queries above `long_query_time` | Near zero | Default choice. Set `long_query_time = 0` briefly for full capture |
| tcpdump | All queries, all connections | Moderate (disk I/O) | When you can't modify MySQL config, or need to see queries from specific clients |
| Performance Schema | All queries with stats | Memory (depends on digest sizing) | When you want ongoing monitoring without log rotation |

**Gotchas:**

- The slow query log must have `log_slow_verbosity = full` (Percona Server) or at minimum `log_slow_extra = ON` (MySQL 8.0.14+) to include bytes_sent, tmp tables, etc.
- Setting `long_query_time = 0` captures everything but generates enormous logs. Do it for 5-10 minutes, not hours.
- tcpdump parsing is CPU-intensive. Capture to file, analyze offline.
- The `--review` and `--history` tables are massively useful for tracking query performance over time across deployments, but nobody sets them up until after the third incident.

**PG equivalent:** pgBadger (log-based) + pg_stat_statements (in-process). MySQL's pg_stat_statements equivalent is Performance Schema `events_statements_summary_by_digest`, but pt-query-digest's reports are significantly more readable.

---

### mysqltuner.pl

**What it does:** Analyzes a running MySQL instance and produces recommendations for configuration tuning based on current status variables, uptime, and resource usage.

**When you need it:** After initial deployment to catch obvious misconfigurations. After a workload change. When you inherit a MySQL instance and want a fast "what's obviously wrong" check.

**Install:**

```bash
wget https://raw.githubusercontent.com/major/MySQLTuner-perl/master/mysqltuner.pl
chmod +x mysqltuner.pl

# or
brew install mysqltuner
```

**Key usage:**

```bash
# Basic run
perl mysqltuner.pl --host localhost --user root --pass secret

# With CVE checks and engine stats
perl mysqltuner.pl --host localhost --user root --pass secret --cvefile vulnerabilities.csv --buffers --dbstat --tbstat --idxstat

# JSON output for automation
perl mysqltuner.pl --host localhost --user root --pass secret --json --outputfile tuner-report.json
```

**What it gets right:**

- Buffer pool sizing relative to data size
- Table cache misses
- Temporary table spill to disk ratios
- InnoDB log file size vs checkpoint age
- Open file limits
- Thread cache efficiency
- Join operations without indexes (`Select_full_join` counter)

**What it gets wrong (or at least oversimplifies):**

1. **"Key buffer too small"** — It reports this for MyISAM key buffer even when you have zero MyISAM tables. Ignore it.
2. **"Sort buffer too large"** — It may suggest increasing `sort_buffer_size` when the real fix is a better index or query rewrite. Per-connection buffers should almost never be set above 256KB-1MB.
3. **Uptime-dependent advice** — If the server was restarted recently, all ratios are skewed. Wait at least 48 hours (ideally a week covering your full workload cycle) before trusting its recommendations.
4. **It can't see query patterns** — It sees symptoms (temp tables, filesorts) but not causes. "Too many temp tables" might mean one terrible query running 10,000 times, not a systemic config issue.
5. **Thread pool advice** — Its recommendations for `thread_cache_size` are usually fine, but it doesn't understand connection pooling. If you use ProxySQL, thread cache is largely irrelevant.

**Bottom line:** Run it, read it critically, but don't blindly apply its suggestions. It's a starting point, not an oracle.

**PG equivalent:** No direct equivalent. pgtune.leopard.in.ua does config recommendations, pgHero does some runtime analysis. Neither is as comprehensive as mysqltuner for a single-script health check.

---

### sys Schema Views

**What it does:** The `sys` schema (bundled with MySQL 5.7+ and 8.0+) wraps Performance Schema data in human-readable views. Performance Schema is incredibly powerful but its raw tables are a nightmare to query. The sys schema is the translation layer that makes it usable.

**Essential views every DBA should bookmark:**

```sql
-- Top queries by total latency (your "what's slow" starting point)
SELECT * FROM sys.statements_with_runtimes_in_95th_percentile;

-- Top queries by full table scans
SELECT * FROM sys.statements_with_full_table_scans ORDER BY no_index_used_count DESC;

-- Top queries generating temp tables on disk
SELECT * FROM sys.statements_with_temp_tables ORDER BY disk_tmp_tables DESC;

-- Currently running queries with wait analysis
SELECT * FROM sys.session;

-- Redundant indexes (indexes that are a prefix of another index)
SELECT * FROM sys.schema_redundant_indexes;

-- Unused indexes (secondary indexes with zero reads)
SELECT * FROM sys.schema_unused_indexes;

-- Table I/O by table (which tables are hottest)
SELECT * FROM sys.schema_table_statistics_with_buffer ORDER BY rows_fetched DESC;

-- InnoDB buffer pool contents (what's in memory right now)
SELECT * FROM sys.innodb_buffer_stats_by_table ORDER BY allocated DESC;

-- User resource consumption (who's using the most)
SELECT * FROM sys.user_summary;

-- Wait event analysis (where time is being spent)
SELECT * FROM sys.wait_classes_global_by_avg_latency;

-- Host summary (connections and resource usage by source host)
SELECT * FROM sys.host_summary;

-- IO by file (which files generate the most I/O)
SELECT * FROM sys.io_global_by_file_by_bytes ORDER BY total DESC LIMIT 20;

-- Memory usage by component
SELECT * FROM sys.memory_global_by_current_bytes ORDER BY current_alloc DESC;
```

**The killer diagnostic routine:**

```sql
-- Step 1: What's running right now?
SELECT thd_id, conn_id, user, db, command, time, state,
       current_statement, last_statement,
       trx_latency, trx_state, lock_latency
FROM sys.session
WHERE command != 'Sleep'
ORDER BY time DESC;

-- Step 2: What's blocked?
SELECT * FROM sys.innodb_lock_waits;

-- Step 3: What's been the heaviest since last restart?
SELECT query, exec_count, avg_latency, max_latency, rows_examined_avg,
       full_scans, tmp_disk_tables
FROM sys.statement_analysis
ORDER BY total_latency DESC
LIMIT 20;
```

**Gotchas:**

- `sys.schema_unused_indexes` only reflects usage since the last server restart (or since Performance Schema counters were reset). An index might be "unused" because the monthly report job hasn't run yet.
- These views query Performance Schema, which itself has overhead. On extremely busy instances (50,000+ QPS), even reading sys views can cause momentary slowdowns. Don't put them in a 1-second monitoring loop.
- MariaDB does NOT include the sys schema by default. You need to install it manually from the `mysql-sys` GitHub repo.

**PG equivalent:** pg_stat_user_tables, pg_stat_user_indexes, pg_stat_activity. PostgreSQL's built-in stats views are simpler but also less structured than the sys schema. pg_stat_statements fills the "statement analysis" gap.

---

### Performance Schema Consumers and Instruments

**What it does:** Performance Schema is MySQL's low-level instrumentation framework. "Instruments" are the probes (what to measure), "consumers" are the destinations (where to store the measurements). By default, MySQL enables a useful subset but not everything.

**What to enable and what it costs:**

| Instrument / Consumer | Default | Enable? | Memory Cost | Why |
|----------------------|---------|---------|-------------|-----|
| `events_statements_*` consumers | ON | Keep ON | Moderate (sized by `performance_schema_max_digest_length`) | Required for sys schema statement views |
| `events_waits_*` consumers | OFF | Enable selectively | Low-Moderate | Shows lock waits, I/O waits, mutex contention |
| `events_stages_*` consumers | OFF | Enable for debugging | Low | Shows query execution stages (sorting, tmp table, etc.) |
| `events_transactions_*` consumers | OFF | Enable if using XA or tracking TX latency | Low | Transaction-level timing |
| `memory/%` instruments | Partially ON | Enable for memory debugging | Moderate | Per-component memory allocation tracking |
| `wait/io/file/%` instruments | ON | Keep ON | Low | File I/O latency tracking |
| `wait/lock/table/%` instruments | ON | Keep ON | Low | Table lock tracking |
| `wait/synch/mutex/%` instruments | OFF | Enable for mutex debugging only | HIGH | Mutex-level instrumentation. Significant overhead. |

**How to enable at runtime:**

```sql
-- Enable wait event consumers (persists until restart)
UPDATE performance_schema.setup_consumers
SET ENABLED = 'YES'
WHERE NAME LIKE 'events_waits%';

-- Enable memory instruments
UPDATE performance_schema.setup_instruments
SET ENABLED = 'YES', TIMED = 'YES'
WHERE NAME LIKE 'memory/%';

-- To persist across restarts, add to my.cnf:
-- performance-schema-consumer-events-waits-current=ON
-- performance-schema-consumer-events-waits-history=ON
-- performance-schema-instrument='memory/%=ON'
```

**Gotchas:**

- `performance_schema_max_digest_length` (default 1024) controls how much of each query is stored. For applications with long queries (ORMs love these), increase to 4096-8192 or you'll get truncated fingerprints that look like different queries.
- `performance_schema_max_digest_sample_size` (default 1024, 8.0.19+) controls the sample query stored. Same issue — increase if your queries are long.
- Enabling `wait/synch/mutex/%` instruments on a busy server can cause 5-15% throughput degradation. Enable briefly for debugging, disable after.
- Performance Schema memory is allocated at startup and not returned. The `-max-` sizing variables determine the ceiling. Over-sizing wastes memory permanently.
- Unlike pg_stat_statements, Performance Schema counters reset on server restart. If you need historical data, you must export it (PMM does this automatically).

**PG equivalent:** No direct equivalent. PostgreSQL uses a combination of pg_stat_statements, pg_stat_activity, pg_stat_bgwriter, and extension-based instrumentation (pg_stat_kcache, pg_wait_sampling). MySQL's Performance Schema is more unified but also more complex to configure.

---

## 2. Schema & Data Management

Tools for making schema changes on live production databases without downtime.

### gh-ost (GitHub Online Schema Change)

**What it does:** Performs online ALTER TABLE operations by creating a ghost table, copying data in chunks via row-based binary log events, then performing an atomic cut-over. Unlike trigger-based tools, gh-ost tails the binary log to capture ongoing changes, meaning it adds zero triggers to the original table.

**When you need it:** Any ALTER TABLE on a table larger than ~1GB in production. Smaller tables can usually handle a direct ALTER (InnoDB Online DDL handles many operations without blocking), but once you're past a few million rows, the risk of locking, replication lag, or running out of space makes a controlled migration tool essential.

**Install:**

```bash
# Binary releases
wget https://github.com/github/gh-ost/releases/latest/download/gh-ost-binary-linux-amd64.tar.gz
tar xf gh-ost-binary-linux-amd64.tar.gz

# or build from source
go install github.com/github/gh-ost@latest

# Homebrew
brew install gh-ost
```

**Key usage:**

```bash
# Add a column (the classic use case)
gh-ost \
  --host=replica.db.internal \
  --allow-on-master \
  --database=production \
  --table=orders \
  --alter="ADD COLUMN tracking_number VARCHAR(100) DEFAULT NULL" \
  --chunk-size=1000 \
  --max-load="Threads_running=30" \
  --critical-load="Threads_running=50" \
  --throttle-control-replicas="replica1.db.internal,replica2.db.internal" \
  --max-lag-millis=1500 \
  --execute

# Dry run first (always)
# Same command but remove --execute to see what it would do

# Interactive throttle control (create this file to pause migration)
# touch /tmp/gh-ost.throttle  → pauses
# rm /tmp/gh-ost.throttle     → resumes

# Monitor progress via Unix socket
echo "status" | nc -U /tmp/gh-ost.orders.sock
```

**How it works internally:**

1. Creates a ghost table (`_orders_gho`) with the new schema
2. Creates a changelog table (`_orders_ghc`) for internal tracking
3. Starts tailing the binary log on a replica (or master) to capture DML on the original table
4. Copies existing rows in chunks from the original to the ghost table
5. Applies ongoing DML changes captured from the binlog to the ghost table
6. When copy is complete, performs an atomic cut-over: renames original to `_orders_del`, renames ghost to `orders`

**The cut-over phase — where things get interesting:**

gh-ost uses a lock-based cut-over by default. It briefly acquires a lock to perform the rename atomically. This lock typically lasts milliseconds, but if your server has long-running queries that hold metadata locks, the cut-over can stall. Use `--cut-over-lock-timeout-seconds=3` and let it retry rather than waiting indefinitely.

**gh-ost vs pt-online-schema-change:**

| Aspect | gh-ost | pt-online-schema-change |
|--------|--------|------------------------|
| Change capture | Binary log tailing | Triggers on original table |
| Write overhead on original table | None (no triggers) | 3 triggers per DML (INSERT, UPDATE, DELETE) |
| Replication lag sensitivity | Built-in replica monitoring | Manual or `--max-lag` |
| Foreign key support | No FK support | Limited FK support (drop-swap or rebuild) |
| Cut-over | Atomic rename with brief lock | Atomic rename with brief lock |
| Requires binlog access | Yes (ROW format) | No |
| Battle-tested at | GitHub (tens of thousands of migrations) | Percona (decades of production use) |

**When gh-ost is the right choice:** Most of the time. No trigger overhead, better throttling, built-in replica lag monitoring.

**When to use pt-osc instead:** When you have foreign keys (gh-ost doesn't support them at all), when you can't access the binary log, or when you're on very old MySQL versions.

**Gotchas:**

- Requires `binlog_format=ROW`. If you're still on MIXED or STATEMENT, gh-ost won't work.
- The ghost table consumes as much disk space as the original table during migration. Ensure you have headroom.
- On tables with no PRIMARY KEY or UNIQUE KEY, gh-ost cannot operate. Fix your schema first.
- The `--allow-on-master` flag is required when not running against a replica. In production, prefer pointing at a replica for binlog tailing to reduce master load.
- `--max-load` and `--critical-load` use MySQL status variables. `Threads_running` is the most common, but you can use any status variable. `--critical-load` aborts the migration; `--max-load` just throttles.
- Foreign keys: gh-ost will refuse to run. Period. No workaround.

**PG equivalent:** No direct equivalent needed — PostgreSQL's ALTER TABLE for adding nullable columns is instantaneous (metadata-only change). For operations that do require a full rewrite in PG, pg_repack handles online table rebuilds. The MySQL ecosystem needs gh-ost because InnoDB's ALTER TABLE is more disruptive than PostgreSQL's for many DDL operations.

---

### pt-online-schema-change (Percona Toolkit)

**What it does:** Performs online ALTER TABLE using triggers. Creates a new table with the desired schema, adds INSERT/UPDATE/DELETE triggers to the original table to capture ongoing changes, copies data in chunks, then atomically swaps the tables.

**When you need it:** When gh-ost won't work — specifically: tables with foreign keys, environments where you can't access the binary log, or when you need the "tried-and-true" tool that's been running in production since 2011.

**Install:**

```bash
# Part of Percona Toolkit
brew install percona-toolkit
# or
apt-get install percona-toolkit
```

**Key usage:**

```bash
# Add an index
pt-online-schema-change \
  --alter "ADD INDEX idx_created_at (created_at)" \
  --host=db.internal \
  --user=admin \
  --ask-pass \
  --chunk-size=1000 \
  --max-lag=1s \
  --check-replication-filters \
  --execute \
  D=production,t=events

# With FK handling (this is pt-osc's killer feature over gh-ost)
pt-online-schema-change \
  --alter "ADD COLUMN notes TEXT" \
  --alter-foreign-keys-method=rebuild_constraints \
  --execute \
  D=production,t=orders

# Dry run
pt-online-schema-change \
  --alter "ADD COLUMN notes TEXT" \
  --dry-run \
  D=production,t=orders
```

**Foreign key handling strategies:**

- `rebuild_constraints` — After swap, ALTERs child tables to point FKs at the new table. Brief metadata lock on child tables.
- `drop_swap` — Drops FKs, swaps tables, re-adds FKs. Brief window with no FK enforcement. Faster but riskier.
- `none` — Refuses to run if FKs exist. The safe default.

**Gotchas:**

- Three triggers on a hot table add measurable write overhead: every INSERT/UPDATE/DELETE on the original table now fires an additional trigger. On write-heavy tables (>5,000 writes/sec), this can increase replication lag.
- Triggers interact with other triggers. If the original table already has triggers, pt-osc will refuse to run (MySQL allows only one trigger per event per table in older versions; 8.0 allows multiple but pt-osc still refuses to avoid complexity).
- `--chunk-size` is in rows, not bytes. Rows vary in size. Monitor disk I/O during the migration.
- The `--check-slave-lag` option requires the tool to connect to replicas. Ensure the user has PROCESS and REPLICATION CLIENT privileges on replicas.

**PG equivalent:** Again, most PG ALTER TABLE operations don't need this. For heavy operations, tools like pg_repack or pg_squeeze serve a similar role.

---

### pt-archiver

**What it does:** Safely deletes or archives rows from large tables in small, controlled batches. Instead of `DELETE FROM huge_table WHERE created_at < '2020-01-01'` (which locks the table, generates a massive undo log, and causes replication lag), pt-archiver does it in configurable chunks with sleep intervals between batches.

**When you need it:** Purging old data, archiving to a secondary table or file, any batch DELETE on a table with more than a few hundred thousand rows.

**Key usage:**

```bash
# Delete old rows in batches of 1000, sleeping 500ms between batches
pt-archiver \
  --source h=db.internal,D=production,t=events \
  --where "created_at < '2023-01-01'" \
  --limit 1000 \
  --sleep 0.5 \
  --bulk-delete \
  --purge

# Archive to a file (TSV) before deleting
pt-archiver \
  --source h=db.internal,D=production,t=events \
  --where "created_at < '2023-01-01'" \
  --file '/archive/events_%Y-%m-%d.tsv' \
  --limit 1000 \
  --purge

# Archive to another table (same server or different server)
pt-archiver \
  --source h=db.internal,D=production,t=events \
  --dest h=archive.internal,D=archive,t=events_archive \
  --where "created_at < '2023-01-01'" \
  --limit 1000

# Dry run: see what it would do
pt-archiver \
  --source h=db.internal,D=production,t=events \
  --where "created_at < '2023-01-01'" \
  --limit 1000 \
  --dry-run
```

**Gotchas:**

- `--bulk-delete` uses multi-row DELETE statements (faster) instead of single-row DELETE. Use it unless you have triggers that must fire per row.
- The `--where` clause MUST use an indexed column, or pt-archiver will do a full table scan to find matching rows. It optimizes by using the PRIMARY KEY for nibbling, but the WHERE must be sargable.
- Monitor replication lag during archival. Use `--check-slave-lag` to auto-pause if a replica falls behind.
- On tables with foreign keys and CASCADE deletes, batch deletion can be much slower than expected because each parent row delete cascades to child tables.

**PG equivalent:** No direct equivalent tool. In PostgreSQL you'd typically use `DELETE ... USING` with a CTE and `LIMIT` in a loop, or use pg_partman with partition dropping for time-series data.

---

### pt-table-checksum + pt-table-sync

**What it does:** `pt-table-checksum` verifies that replica data matches the master by computing checksums of table chunks and comparing. `pt-table-sync` fixes any detected differences by generating corrective DML.

**When you need it:** After a failover, after restoring a replica from backup, or as a routine weekly check on critical tables. Replication drift happens more often than people think — non-deterministic functions, unsafe statements in mixed-mode binlog, direct writes to replicas, bugs in older replication code.

**Key usage:**

```bash
# Check all tables for replication consistency
pt-table-checksum \
  --host=master.db.internal \
  --user=admin \
  --ask-pass \
  --databases=production \
  --check-replication-filters \
  --replicate=percona.checksums

# Check results (run on each replica)
pt-table-checksum \
  --host=master.db.internal \
  --replicate-check-only

# Sync detected differences (dry run first!)
pt-table-sync \
  --print \
  --replicate=percona.checksums \
  h=master.db.internal

# Apply the fixes
pt-table-sync \
  --execute \
  --replicate=percona.checksums \
  h=master.db.internal
```

**Gotchas:**

- pt-table-checksum works by executing checksum queries on the master that replicate to replicas. This means the checksum work happens on replicas too. On already-lagging replicas, this adds load.
- `--replicate=percona.checksums` creates a table on the master that stores chunk checksums. Each replica receives this via replication and compares locally.
- For GTID-based replication: use `--no-check-binlog-format` if your binlog format is ROW (pt-table-checksum prefers STATEMENT for its checksum queries but can work with ROW).
- `pt-table-sync --execute` modifies data. Always `--print` first and review.

**PG equivalent:** No direct equivalent. PostgreSQL doesn't have a replication consistency checking tool. For logical replication, you'd compare counts and checksums manually with SQL.

---

## 3. Replication & HA

### Orchestrator (VTOrc)

**What it does:** Manages MySQL replication topology: discovers all replicas, monitors health, performs automated failover when the master dies, and provides a web UI showing the topology graph. Originally an independent project by Shlomi Noach, now integrated into Vitess as VTOrc.

**When you need it:** Any MySQL setup with replication. Without orchestrator, failover is manual: SSH into a replica, run `STOP SLAVE`, check positions, `CHANGE MASTER TO`, hope you got it right. Orchestrator makes this automatic, deterministic, and auditable.

**Install:**

```bash
# Standalone orchestrator
wget https://github.com/openark/orchestrator/releases/latest/download/orchestrator-linux-amd64.tar.gz

# As part of Vitess (VTOrc)
# See vitess.io for deployment docs

# Docker
docker run -d --name orchestrator -p 3000:3000 openark/orchestrator:latest
```

**Key concepts:**

- **Discovery**: Orchestrator connects to one instance and recursively discovers the entire topology by following replication relationships
- **Polling**: Checks each instance every `InstancePollSeconds` (default 5s)
- **Failover**: On master failure, promotes the best replica based on configureable rules (prefer GTID, prefer same datacenter, etc.)
- **Topology refactoring**: You can drag-and-drop replicas between masters in the web UI. It handles the replication reconfiguration.

**GTID vs position-based failover:**

With GTID (which you should be using in 8.0+), failover is dramatically simpler. Orchestrator can promote any replica regardless of its binary log position. Without GTID, orchestrator has to find a replica whose binary log position is compatible with others — a much more fragile process.

```bash
# Tell orchestrator to use GTID
{
  "AutoGTIDMode": "AUTO_OR_MANUAL",
  "UseMySQLGTID": true
}
```

**Gotchas:**

- Orchestrator needs its own metadata database (MySQL or SQLite). Use MySQL for production — SQLite is fine for testing but can't be shared across orchestrator instances.
- The anti-flapping mechanism (`RecoveryPeriodBlockSeconds`) prevents cascading failovers. Default 3600s means after a failover, orchestrator won't do another for an hour. Tune this based on your SLA.
- Orchestrator only handles replication topology. It does NOT update your application's connection string. You need ProxySQL, DNS failover, or a VIP manager for that.
- If you use semi-synchronous replication, orchestrator can factor that into promotion decisions — preferring replicas that are semi-sync acknowledged.

**PG equivalent:** Patroni (etcd/Consul-based HA), repmgr (simpler alternative). PostgreSQL's HA ecosystem is arguably more mature for single-primary setups thanks to Patroni.

---

### ProxySQL

**What it does:** A high-performance MySQL protocol proxy that provides connection pooling, read/write splitting, query routing, query caching, query firewalling, and backend health checking. It sits between your application and MySQL, and your app connects to ProxySQL instead of directly to MySQL.

**When you need it:** Multiple applications connecting to MySQL, read/write splitting across master and replicas, connection count management, or when you want query-level routing rules. See `connection-pooling.md` for the full deep dive.

**Install:**

```bash
# Package
apt-get install proxysql2
# or
yum install proxysql2

# Docker
docker run -d --name proxysql -p 6033:6033 -p 6032:6032 proxysql/proxysql:latest
```

**Key usage:**

```bash
# Connect to admin interface
mysql -u admin -padmin -h 127.0.0.1 -P 6032 --prompt='ProxySQL> '

# Add backend servers
INSERT INTO mysql_servers (hostgroup_id, hostname, port, weight)
VALUES (10, 'master.db.internal', 3306, 1000);
INSERT INTO mysql_servers (hostgroup_id, hostname, port, weight)
VALUES (20, 'replica1.db.internal', 3306, 1000);
INSERT INTO mysql_servers (hostgroup_id, hostname, port, weight)
VALUES (20, 'replica2.db.internal', 3306, 500);
LOAD MYSQL SERVERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;

# Set up read/write splitting
INSERT INTO mysql_query_rules (rule_id, active, match_digest, destination_hostgroup, apply)
VALUES (1, 1, '^SELECT.*FOR UPDATE', 10, 1);  -- FOR UPDATE goes to writer
INSERT INTO mysql_query_rules (rule_id, active, match_digest, destination_hostgroup, apply)
VALUES (2, 1, '^SELECT', 20, 1);               -- Other SELECTs go to readers
LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;

# Add application users
INSERT INTO mysql_users (username, password, default_hostgroup)
VALUES ('app_user', 'password', 10);
LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL USERS TO DISK;
```

**The three-layer config model:**

ProxySQL has three configuration layers: RUNTIME (active), MEMORY (staging), and DISK (persistent). All admin changes go to MEMORY first. You `LOAD ... TO RUNTIME` to activate and `SAVE ... TO DISK` to persist. This lets you test changes before committing them — and roll back by `LOAD ... FROM DISK` if things go wrong.

**Monitoring:**

```sql
-- Connection pool status
SELECT hostgroup, srv_host, status, ConnUsed, ConnFree, ConnOK, ConnERR, Queries
FROM stats_mysql_connection_pool;

-- Query digest stats (your poor man's pt-query-digest)
SELECT hostgroup, digest_text, count_star, sum_time, min_time, max_time
FROM stats_mysql_query_digest
ORDER BY sum_time DESC
LIMIT 20;

-- Global stats
SELECT * FROM stats_mysql_global;
```

**Gotchas:**

- ProxySQL speaks the MySQL wire protocol. This means it doesn't support `LOAD DATA LOCAL INFILE` by default (security risk), and some client libraries have edge-case incompatibilities.
- The admin interface listens on port 6032 with default credentials (`admin/admin`). Change these immediately in production.
- Query rules use POSIX regex, not MySQL regex. `.*` is greedy. Test your rules with `SELECT match_digest, destination_hostgroup FROM mysql_query_rules;` before activating.
- Connection multiplexing breaks with session-level state: `SET` variables, temporary tables, `GET_LOCK()`, prepared statements (unless you configure `multiplexing=0` for that user). ProxySQL detects some of these automatically and disables multiplexing for the session.
- Under Kubernetes, run ProxySQL as a sidecar or DaemonSet, not as a centralized pool, to avoid a single point of failure.

**PG equivalent:** PgBouncer (connection pooling only) or Pgpool-II (pooling + read/write splitting + load balancing). ProxySQL is significantly more feature-rich than either — it's closer to a full SQL-aware proxy.

---

### MySQL Shell

**What it does:** The modern replacement for the `mysql` command-line client. Supports SQL, JavaScript, and Python modes, X Protocol (the new document-store protocol), and InnoDB Cluster management (Group Replication setup, router configuration, cluster status).

**When you need it:** Managing InnoDB Cluster or Group Replication setups, working with the document store, or when you want a richer CLI experience than the classic `mysql` client.

**Install:**

```bash
# Package
apt-get install mysql-shell
# or
brew install mysql-shell
```

**Key usage:**

```bash
# Connect (SQL mode by default)
mysqlsh root@localhost:3306 --sql

# Switch modes inside the shell
\sql
\js
\py

# InnoDB Cluster: bootstrap a cluster
mysqlsh root@db1:3306 --js
# > dba.configureInstance()
# > var cluster = dba.createCluster('production')
# > cluster.addInstance('root@db2:3306')
# > cluster.addInstance('root@db3:3306')
# > cluster.status()

# Check instance readiness for Group Replication
mysqlsh root@db1:3306 -- dba check-instance-configuration

# Dump and load (massively parallel)
mysqlsh root@localhost -- util dump-instance /backups/full --threads=8
mysqlsh root@localhost -- util load-dump /backups/full --threads=8
```

**The dump/load utilities deserve special mention:**

MySQL Shell's `util.dumpInstance()` and `util.loadDump()` are dramatically faster than `mysqldump` for large databases. They work in parallel, support compression, and can resume interrupted loads. For databases over 10GB, they're the only sane choice.

```bash
# Parallel dump with compression (10x faster than mysqldump on large DBs)
mysqlsh root@localhost -- util dump-instance /backups/full \
  --threads=8 \
  --compression=zstd \
  --excludeSchemas=information_schema,performance_schema,sys

# Load to a different server
mysqlsh root@newserver -- util load-dump /backups/full \
  --threads=8 \
  --ignoreExistingObjects=true
```

**Gotchas:**

- MySQL Shell requires the X Plugin (port 33060 by default). If you only have the classic protocol (3306), use `--mysql` flag instead of `--mysqlx`.
- InnoDB Cluster management commands only work in JS or Python mode, not SQL mode. This trips people up.
- `util.dumpInstance()` uses `FLUSH TABLES WITH READ LOCK` by default for consistency. On busy servers, this can hang. Use `--consistent=false` if you can tolerate a fuzzy snapshot, or `--consistent=true --lock-tables=false` with GTID to get consistency without global locks.

**PG equivalent:** psql (CLI), but psql doesn't have the cluster management capabilities. For backup, pg_dump/pg_restore with `--jobs` provides parallel dump/restore.

---

### mysqlbinlog

**What it does:** Reads and decodes MySQL binary log files. Essential for point-in-time recovery (PITR), debugging replication issues, and understanding what happened to your data.

**When you need it:** Point-in-time recovery after accidental data deletion, diagnosing replication divergence, auditing what queries ran and when, or extracting specific transactions from the binlog.

**Key usage:**

```bash
# View binlog contents (human-readable)
mysqlbinlog --verbose /var/lib/mysql/binlog.000042

# View with decoded ROW events (essential for ROW format binlogs)
mysqlbinlog --verbose --verbose /var/lib/mysql/binlog.000042
# (yes, --verbose twice: first decodes events, second adds column names as comments)

# Filter by time range
mysqlbinlog --start-datetime='2024-01-15 14:00:00' \
            --stop-datetime='2024-01-15 14:30:00' \
            /var/lib/mysql/binlog.000042

# Filter by position
mysqlbinlog --start-position=12345 --stop-position=67890 \
            /var/lib/mysql/binlog.000042

# Point-in-time recovery: replay binlogs up to the bad statement
mysqlbinlog --stop-datetime='2024-01-15 14:25:30' \
            binlog.000040 binlog.000041 binlog.000042 | mysql -u root -p

# Remote binlog reading (from a replica or backup server)
mysqlbinlog --read-from-remote-server \
            --host=master.db.internal \
            --user=repl_user \
            --password \
            binlog.000042

# Find the DROP TABLE that someone ran at lunch
mysqlbinlog --verbose /var/lib/mysql/binlog.000042 | grep -B5 "DROP TABLE"
```

**PITR workflow:**

1. Restore the most recent full backup
2. Identify the timestamp or position of the bad event (the `DROP TABLE`, the `DELETE` without a WHERE)
3. Replay binlogs from the backup's position up to just before the bad event
4. Verify data integrity
5. Resume replication or re-point applications

```bash
# Full PITR sequence
# 1. Restore backup (e.g., from mysqlsh dump or xtrabackup)
# 2. Find the bad event:
mysqlbinlog --verbose binlog.000042 | grep -n "DROP TABLE\|DELETE FROM important"
# 3. Replay up to just before it:
mysqlbinlog --stop-position=98765 binlog.000040 binlog.000041 binlog.000042 | mysql -u root -p
```

**Gotchas:**

- With `binlog_format=ROW` (which you should be using), the raw binlog is unreadable. You MUST use `--verbose` to decode it. With `--verbose --verbose` you get column names as comments.
- `mysqlbinlog` output for ROW events includes base64-encoded data. The `--verbose` flag decodes this into pseudo-SQL (`### UPDATE table SET ...`), but these pseudo-SQL statements are comments — they cannot be replayed directly. Replay uses the binary events, not the decoded comments.
- Binary log files can be enormous. Use `--start-datetime`/`--stop-datetime` or `--start-position`/`--stop-position` to limit output.
- GTID-based binlog filtering: use `--include-gtids` and `--exclude-gtids` for surgical extraction of specific transactions.

**PG equivalent:** pg_waldump (WAL inspection) and PITR using continuous archiving with pg_basebackup + WAL replay. PostgreSQL's WAL-based recovery is architecturally similar but uses a different mechanism (recovery.conf / restore_command).

---

## 4. Monitoring & Diagnostics

### Percona Monitoring and Management (PMM)

**What it does:** Full-stack database monitoring platform with dashboards for MySQL, PostgreSQL, MongoDB, and ProxySQL. The MySQL-specific features include Query Analytics (QAN), which captures every query and provides drill-down into execution stats, EXPLAIN plans, and examples.

**When you need it:** Production monitoring. PMM is what you deploy when you want a single pane of glass across your database fleet, with the depth to diagnose performance issues without SSH-ing into servers.

**Install:**

```bash
# PMM Server (Docker)
docker run -d --name pmm-server -p 443:8443 percona/pmm-server:2

# PMM Client (on each DB host)
apt-get install pmm2-client
pmm-admin config --server-url=https://admin:admin@pmm-server:443 --server-insecure-tls
pmm-admin add mysql --username=pmm --password=secret --query-source=perfschema
```

**What it monitors:**

- **QAN (Query Analytics)**: Every query fingerprint with latency distributions, row counts, temp table usage, sort operations. This is pt-query-digest but continuous and with a web UI.
- **Node-level metrics**: CPU, memory, disk, network via node_exporter
- **MySQL metrics**: InnoDB buffer pool, connections, replication lag, handler stats, tmp tables, slow queries via mysqld_exporter
- **Dashboard catalog**: 30+ pre-built Grafana dashboards covering InnoDB, replication, user stats, table stats, query response time

**QAN vs pt-query-digest:**

| Aspect | QAN | pt-query-digest |
|--------|-----|-----------------|
| Data source | Performance Schema or slow log | Slow log or tcpdump or Performance Schema |
| Continuous | Yes (always running) | One-shot (run on demand) |
| Historical data | Retained (configurable) | Must re-parse logs |
| Drill-down | Web UI with filters | Text report |
| Resource overhead | Moderate (PMM client + server) | None (runs on demand) |

**Gotchas:**

- PMM Server needs decent resources: 2+ CPU cores, 4+ GB RAM, and fast storage for ClickHouse (which stores QAN data). Don't try to run it on a t3.micro.
- QAN from Performance Schema is lower overhead than from slow log, but captures less detail (no query samples with `performance_schema_max_sql_text_length` at default).
- The default retention is 30 days. For compliance or long-term trending, increase ClickHouse retention but plan for disk.
- PMM 2 uses VictoriaMetrics (not Prometheus) under the hood. If you already have a Prometheus stack, you'll be running parallel time-series databases. Consider using just the PMM exporters and pointing your existing Prometheus at them.

**PG equivalent:** pgwatch2 + pgHero, or the full Prometheus + Grafana stack with postgres_exporter. PMM actually supports PostgreSQL monitoring too.

---

### innotop

**What it does:** Real-time, terminal-based InnoDB status monitor. Think `top` or `htop` but for MySQL internals: current queries, InnoDB buffer pool, row operations, locks, deadlocks, replication status.

**When you need it:** Active incident response. When the database is slow right now and you need to see what's happening in real time. It's faster than running `SHOW PROCESSLIST` and `SHOW ENGINE INNODB STATUS` in a loop.

**Install:**

```bash
# cpan
cpan Term::ReadKey
cpan DBI
cpan DBD::mysql
cpan innotop

# or from source
git clone https://github.com/innotop/innotop.git
cd innotop && perl Makefile.PL && make install

# Homebrew (if available)
brew install innotop
```

**Key usage:**

```bash
# Connect and start monitoring
innotop -h db.internal -u admin -p

# Inside innotop:
# Q — Query List (like SHOW PROCESSLIST but sortable)
# I — InnoDB I/O Info
# B — InnoDB Buffer Pool
# L — Lock Waits
# D — InnoDB Deadlocks
# R — InnoDB Row Operations
# C — Command Counters (Com_select, Com_insert, etc.)
# S — Replica Status

# Show only queries running > 2 seconds
# Press 'Q' then 'f' to add filters
```

**Gotchas:**

- innotop hasn't seen active development in a while. Some MySQL 8.0 features aren't reflected.
- Requires the Perl `DBI` and `DBD::mysql` modules. On modern systems with Perl version mismatches, installation can be painful. Docker helps.
- For persistent monitoring, use PMM or Grafana dashboards. innotop is for interactive troubleshooting, not dashboarding.

**PG equivalent:** pg_activity (interactive process viewer), pg_top. PostgreSQL's equivalent tools are more actively maintained.

---

### pt-stalk

**What it does:** Watches MySQL status variables and automatically collects diagnostic data when a threshold is breached. It's like setting a trap: "when Threads_running exceeds 30, grab everything." Collects: SHOW PROCESSLIST, SHOW ENGINE INNODB STATUS, disk I/O stats, OS-level diagnostics.

**When you need it:** Intermittent performance problems that you can't reproduce manually. The database was slow at 3 AM but by the time you check at 9 AM, everything looks fine. pt-stalk captures the evidence automatically.

**Key usage:**

```bash
# Watch for high thread activity
pt-stalk \
  --function=status \
  --variable=Threads_running \
  --threshold=25 \
  --cycles=5 \
  --collect-tcpdump \
  --dest=/var/lib/pt-stalk \
  --log=/var/log/pt-stalk.log \
  --daemonize

# Custom trigger: high InnoDB row lock wait time
pt-stalk \
  --function=status \
  --variable=Innodb_row_lock_time_avg \
  --threshold=1000 \
  --dest=/var/lib/pt-stalk

# After an incident, analyze the collected data
ls /var/lib/pt-stalk/
# 2024-01-15_03-15-00-processlist
# 2024-01-15_03-15-00-innodb-status
# 2024-01-15_03-15-00-iostat
# 2024-01-15_03-15-00-vmstat
# 2024-01-15_03-15-00-tcpdump
```

**What it collects per trigger:**

- `SHOW FULL PROCESSLIST`
- `SHOW ENGINE INNODB STATUS`
- `SHOW GLOBAL STATUS`
- `SHOW GLOBAL VARIABLES`
- `iostat`, `vmstat`, `mpstat` output
- `top` snapshot
- Optionally: `tcpdump` capture (for pt-query-digest)
- Optionally: GDB stack traces of mysqld

**Gotchas:**

- `--cycles=5` means the condition must be true for 5 consecutive checks before triggering. This prevents false alarms from momentary spikes.
- `--collect-tcpdump` captures network traffic. This can use significant disk space on busy servers. Set `--collect-tcpdump-timeout=30` to limit capture duration.
- pt-stalk runs as root (for tcpdump and some OS stats). Use `--user` and `--password` for the MySQL connection separately.
- The collected files are raw text. pt-stalk collects; you analyze. Feed the tcpdump to pt-query-digest, read the INNODB STATUS manually.

**PG equivalent:** No direct equivalent. You could build something with pg_stat_activity snapshots and cron, but there's no packaged tool like pt-stalk for PostgreSQL. auto_explain with log_min_duration serves a similar purpose for query-level diagnostics.

---

### pt-kill

**What it does:** Automatically kills MySQL queries or connections matching specified criteria. Watches SHOW PROCESSLIST and kills queries that exceed a time threshold, match a pattern, or come from specific users/hosts.

**When you need it:** Runaway queries. A developer runs a full table scan that locks the entire table, or an ORM generates a cartesian join. pt-kill catches these before they cascade into a full outage.

**Key usage:**

```bash
# Kill queries running longer than 60 seconds
pt-kill \
  --host=db.internal \
  --user=admin \
  --ask-pass \
  --busy-time=60 \
  --kill \
  --print \
  --daemonize \
  --log=/var/log/pt-kill.log

# Kill only SELECT queries running > 30 seconds (don't kill writes)
pt-kill \
  --busy-time=30 \
  --match-command='Query' \
  --match-info='(?i)^SELECT' \
  --kill-query \
  --print

# Kill idle connections older than 1 hour (connection leak cleanup)
pt-kill \
  --idle-time=3600 \
  --match-command='Sleep' \
  --kill \
  --print

# Just log what would be killed (dry run)
pt-kill \
  --busy-time=60 \
  --print \
  --no-kill
```

**`--kill` vs `--kill-query`:**

- `--kill` kills the connection (the client gets disconnected)
- `--kill-query` kills just the running query (the connection stays open, the client gets an error on that query)

Use `--kill-query` in production. Killing connections can cause application connection pool churn.

**Gotchas:**

- `--match-info` uses Perl regex. Test your patterns carefully.
- pt-kill polls SHOW PROCESSLIST at intervals (`--interval`, default 1 second). A query could start and finish between polls and never be caught.
- Be very careful with `--match-info` patterns. `'^SELECT'` is fine; `'.*'` kills everything. Always use `--print --no-kill` first.
- Consider using ProxySQL's `mysql_query_rules` with `max_latency_ms` instead — it's more precise and doesn't require a separate daemon.

**PG equivalent:** `pg_terminate_backend()` / `pg_cancel_backend()` wrapped in a monitoring script. `statement_timeout` at the role or database level is the PG-native approach.

---

## 5. Benchmarking

### sysbench

**What it does:** Multi-threaded benchmarking tool primarily used for MySQL OLTP workload testing. Tests CPU, memory, disk I/O, and database performance with configurable workloads.

**When you need it:** Baseline performance testing of a new server, comparing configurations, validating that a hardware or config change actually improved performance, load testing before a launch.

**Install:**

```bash
brew install sysbench
# or
apt-get install sysbench
```

**Key usage:**

```bash
# Prepare the test database (creates sbtest tables)
sysbench oltp_read_write \
  --db-driver=mysql \
  --mysql-host=localhost \
  --mysql-user=root \
  --mysql-password=secret \
  --mysql-db=sbtest \
  --tables=10 \
  --table-size=1000000 \
  prepare

# Run read-write OLTP benchmark
sysbench oltp_read_write \
  --db-driver=mysql \
  --mysql-host=localhost \
  --mysql-user=root \
  --mysql-password=secret \
  --mysql-db=sbtest \
  --tables=10 \
  --table-size=1000000 \
  --threads=16 \
  --time=300 \
  --report-interval=10 \
  run

# Read-only workload (testing replica performance)
sysbench oltp_read_only \
  --db-driver=mysql \
  --mysql-host=localhost \
  --mysql-user=root \
  --mysql-password=secret \
  --mysql-db=sbtest \
  --tables=10 \
  --table-size=1000000 \
  --threads=32 \
  --time=300 \
  run

# Write-heavy workload
sysbench oltp_write_only \
  --db-driver=mysql \
  --threads=16 \
  --time=300 \
  run

# Cleanup
sysbench oltp_read_write \
  --db-driver=mysql \
  --mysql-db=sbtest \
  cleanup
```

**Interpreting results:**

```
SQL statistics:
    queries performed:
        read:    2345678
        write:   670194
        other:   335097
        total:   3350969
    transactions:        167548 (558.49 per sec.)     ← TPS: the number to watch
    queries:             3350969 (11170.00 per sec.)   ← QPS
    ignored errors:      0 (0.00 per sec.)
    reconnects:          0 (0.00 per sec.)

Latency (ms):
         min:    3.45
         avg:    28.65
         max:    345.78
         95th:   48.34    ← p95 latency: the number your users feel
```

**Key metrics to compare:**
- **TPS** (transactions per second): Higher is better. This is your throughput.
- **95th percentile latency**: Lower is better. This is your user experience.
- **Max latency**: Outlier indicator. High max with low avg suggests contention or GC pauses.

**Configuring for realistic workloads:**

The default sysbench tables use AUTO_INCREMENT BIGINT primary keys, which is optimistic. For a more realistic test:

```bash
# More tables with smaller row counts (simulates microservices)
--tables=50 --table-size=100000

# More threads to simulate connection pressure
--threads=64 --rate=1000  # rate-limited to 1000 TPS

# Range queries (common in dashboards, reports)
sysbench oltp_read_only --range-size=100 --threads=32 run
```

**Gotchas:**

- sysbench workloads are artificial. A real application has specific query patterns, hot spots, and access distributions that sysbench doesn't replicate. Use it for A/B testing configurations, not for absolute capacity planning.
- The `prepare` step creates tables with AUTO_INCREMENT PKs and a few secondary indexes. This is a best-case scenario for InnoDB. Real tables with UUID PKs, JSON columns, and 10 secondary indexes will perform differently.
- Running sysbench from the same host as MySQL skews results (sysbench uses CPU and memory too). Run it from a separate client machine.
- `--threads` beyond 2-4x your CPU core count typically shows diminishing returns and increasing latency. The optimal thread count varies by workload.

**PG equivalent:** pgbench (built into PostgreSQL). pgbench is simpler and more integrated, but sysbench is more configurable and supports custom Lua scripts for complex workloads.

---

### mysqlslap

**What it does:** Built-in MySQL load testing tool. Generates a schema, populates it with data, and runs queries under concurrent connections.

**When you need it:** Quick-and-dirty load testing when you don't want to install sysbench. Useful for testing specific queries under concurrency rather than generic OLTP workloads.

**Key usage:**

```bash
# Auto-generate queries (create a test schema, run concurrent selects/inserts)
mysqlslap \
  --host=localhost \
  --user=root \
  --password=secret \
  --auto-generate-sql \
  --auto-generate-sql-load-type=mixed \
  --concurrency=10,25,50 \
  --iterations=3 \
  --number-of-queries=1000

# Test a specific query under load
mysqlslap \
  --host=localhost \
  --user=root \
  --password=secret \
  --query="SELECT * FROM orders WHERE customer_id = FLOOR(RAND() * 100000)" \
  --create-schema=production \
  --concurrency=50 \
  --iterations=5 \
  --number-of-queries=10000

# Test from a file of queries
mysqlslap \
  --host=localhost \
  --user=root \
  --password=secret \
  --query=/path/to/test-queries.sql \
  --delimiter=";" \
  --concurrency=20 \
  --iterations=3
```

**Gotchas:**

- mysqlslap's auto-generated schema is trivial. It doesn't test realistic scenarios.
- It doesn't report percentile latencies — only average, min, max. For serious benchmarking, use sysbench.
- Each "iteration" drops and recreates the test schema. This means it tests cold-cache performance unless you pre-warm.
- `--concurrency=10,25,50` runs three separate tests sequentially with increasing concurrency. Useful for finding the concurrency sweet spot.

**When to use mysqlslap vs sysbench:**

- mysqlslap: Quick tests, specific query testing, no extra installation needed
- sysbench: Serious benchmarking, reproducible results, custom Lua workloads, better reporting

**PG equivalent:** pgbench with custom scripts. pgbench is more capable than mysqlslap but less capable than sysbench.

---

## 6. CLI Essentials

### mysql Client Power Tips

```bash
# Connect with useful defaults
mysql -h localhost -u root -p --auto-rehash --safe-updates

# --safe-updates (aka --i-am-a-dummy): prevents UPDATE/DELETE without WHERE
# Saves careers. Enable it in your .my.cnf for production connections.
```

**Essential commands inside mysql:**

```sql
-- Show databases with sizes
SELECT table_schema AS 'Database',
       ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables
GROUP BY table_schema
ORDER BY SUM(data_length + index_length) DESC;

-- Show tables with sizes and row counts
SELECT table_name,
       ROUND(data_length / 1024 / 1024, 2) AS 'Data (MB)',
       ROUND(index_length / 1024 / 1024, 2) AS 'Index (MB)',
       table_rows AS 'Approx Rows'
FROM information_schema.tables
WHERE table_schema = DATABASE()
ORDER BY data_length + index_length DESC;

-- Show running queries (better than SHOW PROCESSLIST)
SELECT id, user, host, db, command, time, state,
       LEFT(info, 100) AS query
FROM information_schema.processlist
WHERE command != 'Sleep'
ORDER BY time DESC;

-- Show InnoDB engine status (locks, deadlocks, buffer pool)
SHOW ENGINE INNODB STATUS\G

-- Show binary log position (for backup/PITR reference)
SHOW MASTER STATUS;

-- Show replica status
SHOW REPLICA STATUS\G
```

#### .my.cnf for Comfortable Defaults

```ini
# ~/.my.cnf
[mysql]
auto-rehash
safe-updates
prompt=\\u@\\h [\\d]>\\_
pager=less -SFX
show-warnings

[client]
default-character-set=utf8mb4
```

**The prompt string explained:**
- `\u` — current user
- `\h` — hostname
- `\d` — current database
- Result: `root@production [mydb]> ` — you always know where you are

### mycli — Enhanced mysql Client

```bash
# Install
brew install mycli
# or
pip install mycli

# Use exactly like mysql
mycli -h localhost -u root -p production
```

| Feature | mysql | mycli |
|---------|-------|-------|
| Autocomplete | Basic (with --auto-rehash, slow on large schemas) | Fast, context-aware (tables, columns, functions) |
| Syntax highlighting | No | Yes |
| Multi-line editing | Awkward | Full readline with vi/emacs bindings |
| Output formatting | Fixed | Multiple formats (table, csv, tsv, vertical) |
| Pager | Configurable | Built-in with auto-detection |
| Favorites | No | Save and recall queries with `\fs` and `\f` |

**When to use mycli vs mysql:** mycli for interactive work (the autocomplete alone is worth it). mysql for scripting, batch operations, and in environments where you can't install extras.

---

## Tool Selection Quick Reference

| I need to... | Reach for |
|:-------------|:----------|
| Find the slowest queries | pt-query-digest (one-shot), PMM QAN (continuous), sys.statement_analysis (quick) |
| Understand a query plan | `EXPLAIN ANALYZE` (MySQL 8.0.18+), `EXPLAIN FORMAT=TREE` (8.0.16+) |
| ALTER TABLE without downtime | gh-ost (no triggers, preferred), pt-online-schema-change (has FK support) |
| Delete millions of old rows safely | pt-archiver (batched, throttled, replication-aware) |
| Check replication consistency | pt-table-checksum (detect), pt-table-sync (fix) |
| Manage replication topology | Orchestrator (standalone), VTOrc (Vitess), MySQL Shell (InnoDB Cluster) |
| Pool and route connections | ProxySQL (feature-rich), app-level pool (simple setups) |
| Monitor production | PMM (full stack), Grafana + mysqld_exporter (existing Prometheus) |
| Watch InnoDB in real-time | innotop (interactive terminal), sys.session (quick SQL) |
| Catch intermittent problems | pt-stalk (automated evidence collection) |
| Kill runaway queries | pt-kill (daemon), ProxySQL query rules (inline) |
| Benchmark a server | sysbench (serious), mysqlslap (quick) |
| Inspect binary logs | mysqlbinlog --verbose --verbose |
| Point-in-time recovery | mysqlbinlog + full backup restore |
| Get a fast config health check | mysqltuner.pl (read critically, don't blindly apply) |
| Work faster in the terminal | mycli (interactive), .my.cnf with safe-updates (scripted) |
| Dump/restore large databases | MySQL Shell util.dumpInstance/loadDump (parallel, 10x faster than mysqldump) |
