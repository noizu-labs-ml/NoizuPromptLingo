# Connection Pooling: The Definitive Cross-Engine Reference

> Target audience: senior developers and DBAs who need to decide whether they need a connection pooler, which one, and how to configure it. Covers PostgreSQL (PgBouncer), MySQL (ProxySQL), and application-level pooling with production-tested configurations.

---

## Table of Contents

1. [Why Connection Pooling Exists](#1-why-connection-pooling-exists)
2. [PgBouncer Deep Dive](#2-pgbouncer-deep-dive)
3. [ProxySQL Deep Dive](#3-proxysql-deep-dive)
4. [Application-Level Pooling](#4-application-level-pooling)
5. [Pool Sizing Deep Dive](#5-pool-sizing-deep-dive)
6. [Decision Matrix](#6-decision-matrix)

---

## 1. Why Connection Pooling Exists

### The Resource Cost Per Connection

**PostgreSQL** forks a new OS process for every client connection. Each backend process costs:
- ~5-10 MB of resident memory (before query execution)
- A slot in the process table
- Shared memory for locks, buffers, catalog cache
- OS scheduling overhead as process count grows

At 500 connections, you're looking at 2.5-5 GB of memory just for connection overhead, and the OS scheduler is context-switching between 500 processes. At 1,000 connections, the system is spending more time managing processes than executing queries.

**MySQL** uses threads instead of processes. Each connection thread costs:
- ~256 KB - 1 MB base memory (thread stack + per-connection buffers)
- Additional memory per-query: `sort_buffer_size`, `join_buffer_size`, `read_buffer_size` — allocated on demand
- Mutex contention on internal structures as thread count grows

MySQL handles more connections than PostgreSQL before degrading, but the cliff still exists. At 1,000-2,000 threads, mutex contention (especially on the InnoDB adaptive hash index and the buffer pool) starts to dominate. At 5,000+ threads, you're burning CPU on thread scheduling rather than useful work.

### The Scalability Cliff

Both engines exhibit a characteristic pattern:

```
Throughput
    │
    │         ╭──────────────── ← optimal concurrency
    │        ╱
    │       ╱
    │      ╱          ╲
    │     ╱              ╲        ← throughput collapse
    │    ╱                  ╲
    │   ╱                      ╲────────
    │  ╱
    │ ╱
    └──────────────────────────────────── Connections
         50    100   200   500  1000
```

Throughput increases with concurrency up to a point (typically 2-4x CPU cores), then plateaus, then actively degrades. The degradation is caused by:

1. **Lock contention**: More threads competing for the same internal mutexes
2. **Context switching**: OS spends more time switching between threads/processes than running them
3. **Cache thrashing**: CPU L1/L2/L3 caches become useless as more threads rotate through cores
4. **Memory pressure**: Per-connection memory adds up, pushing working data out of the buffer pool/shared buffers

### Why "Just Increase max_connections" Is Wrong

The failure mode is insidious. A developer notices connection errors, bumps `max_connections` from 200 to 1,000, and things work — until they don't. The system now has headroom to accept connections that it cannot efficiently serve. Instead of a clean "too many connections" error at 200 connections, the server accepts 800 connections and serves all of them slowly, eventually causing application timeouts across the board.

**The correct mental model**: Your database has an optimal active query count (usually 2-4x CPU cores). Everything beyond that should be **waiting in a queue**, not consuming database resources. A connection pooler IS that queue.

```
Without pooler:
[500 app connections] ──→ [500 database connections] → CPU thrashing, everyone slow

With pooler:
[500 app connections] ──→ [pooler: queue] ──→ [20 database connections] → fast for active queries
```

---

## 2. PgBouncer Deep Dive

### What It Is

PgBouncer is a lightweight connection pooler for PostgreSQL. It sits between your application and PostgreSQL, maintains a pool of actual database connections, and multiplexes client connections onto them. Written in C, it uses libevent for async I/O and runs in a single process with minimal memory footprint (~2 KB per connection).

### Install

```bash
# Package managers
apt-get install pgbouncer
brew install pgbouncer

# Docker
docker run --name pgbouncer -e DATABASE_URL="postgres://user:pass@pghost:5432/mydb" \
  -p 6432:6432 edoburu/pgbouncer:latest
```

### Pool Modes

PgBouncer offers three pool modes. The mode determines when a server connection is returned to the pool.

#### Transaction Mode (`pool_mode = transaction`)

Server connection is assigned when a transaction begins and returned when it commits/rolls back. Between transactions, the connection is available for other clients.

**This is what you want 90% of the time.** It gives the best multiplexing ratio — a pool of 20 server connections can serve 500 application connections because most of those connections are idle between transactions.

**What breaks in transaction mode:**

| Feature | Why It Breaks | Workaround |
|---------|--------------|------------|
| `SET` commands (`SET search_path`, `SET timezone`) | Session state doesn't carry across transactions — next TX may get a different server connection | Use `SET LOCAL` (transaction-scoped) or configure defaults in postgresql.conf |
| `LISTEN`/`NOTIFY` | Requires a persistent connection to receive notifications | Use a dedicated non-pooled connection for LISTEN |
| Prepared statements (protocol-level) | Named prepared statements are session-scoped; different connection = different prepared statement namespace | Use `server_reset_query_always = 1` with `DEALLOCATE ALL`, or disable prepared statements in your driver |
| Temporary tables | Exist only for the session; next transaction may get a different connection | Create and use temp tables within a single transaction |
| Advisory locks | Session-level advisory locks (`pg_advisory_lock`) are tied to a connection | Use transaction-level advisory locks (`pg_advisory_xact_lock`) instead |
| `DECLARE CURSOR` (without HOLD) | Cursors are transaction-scoped by default, but some ORMs expect session-scoped cursors | Use `WITH HOLD` cursors or refactor to fetch within a single transaction |
| Connection-level `SET` for role/search_path | Lost between transactions | Use `ALTER ROLE ... SET` or `ALTER DATABASE ... SET` for defaults |

**The prepared statement problem deserves emphasis.** Many database drivers (libpq, JDBC, Go's database/sql) use protocol-level prepared statements transparently. In transaction mode, the driver prepares a statement on connection A, but the next transaction runs on connection B — where that prepared statement doesn't exist. This causes mysterious "prepared statement does not exist" errors under load.

Solutions:
- **Disable prepared statements in the driver** (most common fix). In Go: `sslmode=disable&default_query_exec_mode=simple_protocol`. In JDBC: `prepareThreshold=0`.
- **PgBouncer 1.21+**: Supports `prepared_statement_cache_size` which tracks prepared statements across connections. This is the clean fix.
- **server_reset_query**: Set to `DISCARD ALL` (expensive) or `DEALLOCATE ALL; RESET ALL;` to clean up after each transaction. Adds latency.

#### Session Mode (`pool_mode = session`)

Server connection is assigned when the client connects and returned when the client disconnects. This is essentially just connection limiting — it caps the number of simultaneous connections to PostgreSQL but doesn't multiplex.

**When to use it:** When your application relies on session-state features (SET, LISTEN/NOTIFY, prepared statements) and you can't refactor, but you still need connection limiting to protect PostgreSQL from connection storms.

**Multiplexing benefit:** None. If you have 20 server connections and 500 clients, 480 clients wait for a connection to become available (when another client disconnects). This is a queue, not a multiplexer.

#### Statement Mode (`pool_mode = statement`)

Server connection is returned after every single statement. No multi-statement transactions allowed.

**When to use it:** Almost never. Autocommit read-only workloads against read replicas. Analytics queries. Any multi-statement transaction will break because each statement may go to a different connection.

### Pool Sizing Formula

The foundational formula, originally from the PostgreSQL wiki and validated extensively in production:

```
optimal_pool_size = (2 × CPU_cores) + effective_spindle_count
```

Where:
- **CPU_cores** = physical cores (not hyperthreads) on the database server
- **effective_spindle_count** = number of independent I/O channels. For SSDs, use 1 (the parallelism is internal). For spinning disks in RAID, use the number of spindles.

**Why this works:** It's derived from queueing theory. At any given moment, you can have at most `CPU_cores` threads doing CPU work and `spindle_count` threads blocked on I/O without contention. More connections than this means threads are competing rather than working.

**Practical examples:**

| Server | Cores | Storage | Pool Size |
|--------|-------|---------|-----------|
| 4-core VPS, SSD | 4 | SSD (1) | (2 × 4) + 1 = **9** |
| 8-core dedicated, NVMe | 8 | NVMe (1) | (2 × 8) + 1 = **17** |
| 16-core, RAID-10 (8 spindles) | 16 | 8 spindles | (2 × 16) + 8 = **40** |
| 32-core, NVMe | 32 | NVMe (1) | (2 × 32) + 1 = **65** |

**"But I have 500 application instances!"** — Doesn't matter. The database has 8 cores. It can efficiently serve ~17 concurrent queries. Those 500 app instances should share a pool of 17 server connections. The 483 "extra" connections wait in PgBouncer's queue (microseconds to low milliseconds at most — far faster than the database degrading under 500 concurrent queries).

### Configuration Walkthrough

```ini
;; pgbouncer.ini — production configuration

[databases]
; Map application database names to real PostgreSQL connections
; Format: logical_name = host=<host> port=<port> dbname=<db> [auth_user=<user>]
production = host=pg-primary.internal port=5432 dbname=myapp
production_readonly = host=pg-replica.internal port=5432 dbname=myapp

[pgbouncer]
; === Listening ===
listen_addr = 0.0.0.0
listen_port = 6432

; === Authentication ===
auth_type = md5
; auth_file contains username:password pairs
; For auth passthrough (avoid maintaining userlist.txt):
;   auth_type = hba
;   auth_hba_file = /etc/pgbouncer/pg_hba.conf
;   auth_query = SELECT usename, passwd FROM pg_shadow WHERE usename=$1
;   auth_user = pgbouncer  ; a PG role with SELECT on pg_shadow
auth_file = /etc/pgbouncer/userlist.txt

; === Pool Mode ===
pool_mode = transaction

; === Pool Sizing ===
; max_client_conn: maximum client connections PgBouncer will accept
; This is your "queue capacity" — set high
max_client_conn = 1000

; default_pool_size: server connections per user/database pair
; This is your actual concurrency limit — set to formula result
default_pool_size = 20

; min_pool_size: keep this many connections warm (avoid cold-start latency)
min_pool_size = 5

; reserve_pool_size: extra connections available when pool is exhausted
; These activate only when reserve_pool_timeout is reached
reserve_pool_size = 5
reserve_pool_timeout = 3

; === Timeouts ===
; How long a client waits for a server connection before error
query_wait_timeout = 120

; Kill server connections idle longer than this (reclaim resources)
server_idle_timeout = 600

; Maximum lifetime of a server connection (catches leaked connections, stale state)
server_lifetime = 3600

; Kill client connections idle longer than this
client_idle_timeout = 0  ; 0 = disabled (let the app manage its own idle connections)

; === Query Handling ===
; Run this on server connection before returning to pool
; DISCARD ALL is thorough but adds ~0.5ms overhead per transaction
; DEALLOCATE ALL is lighter if you only worry about prepared statements
server_reset_query = DISCARD ALL

; For transaction mode: reset on every server release (not just session end)
server_reset_query_always = 1

; === Resource Limits ===
; Maximum server connections PgBouncer will open (across all pools)
max_db_connections = 100

; Per-user limit
max_user_connections = 50

; === Logging ===
log_connections = 0        ; noisy in production
log_disconnections = 0     ; noisy in production
log_pooler_errors = 1
stats_period = 60          ; log stats every 60 seconds

; === TLS (if needed) ===
; client_tls_sslmode = require
; client_tls_cert_file = /etc/pgbouncer/server.crt
; client_tls_key_file = /etc/pgbouncer/server.key
; server_tls_sslmode = require
```

### Auth Passthrough vs userlist.txt

**userlist.txt** (simple but painful):

```
; /etc/pgbouncer/userlist.txt
"app_user" "md5abc123def456..."
"readonly_user" "md5789..."
```

Every time you change a database password, you must update this file and reload PgBouncer. This is a maintenance nightmare with multiple users.

**Auth passthrough** (preferred):

```ini
auth_type = md5
auth_user = pgbouncer_auth
auth_query = SELECT usename, passwd FROM pg_shadow WHERE usename=$1
```

PgBouncer uses a dedicated PostgreSQL role (`pgbouncer_auth`) to look up credentials in `pg_shadow` at connection time. Password changes in PostgreSQL are automatically reflected. The `pgbouncer_auth` role needs only `SELECT` on `pg_shadow`.

**For SCRAM-SHA-256** (PostgreSQL 10+, the default since 14):

```ini
auth_type = scram-sha-256
auth_user = pgbouncer_auth
auth_query = SELECT usename, passwd FROM pg_shadow WHERE usename=$1
```

PgBouncer 1.14+ supports SCRAM. If you're running an older version, upgrade — MD5 auth is deprecated.

### Monitoring

Connect to PgBouncer's admin console:

```bash
psql -h localhost -p 6432 -U pgbouncer pgbouncer
```

**Essential monitoring queries:**

```sql
-- Pool status: the most important view
SHOW POOLS;
-- Key columns:
--   cl_active:  client connections actively in a transaction
--   cl_waiting: client connections waiting for a server connection ← ALERT IF > 0 FOR EXTENDED PERIODS
--   sv_active:  server connections executing a query
--   sv_idle:    server connections idle in pool (available)
--   sv_used:    server connections idle but recently used (reset query pending)
--   pool_mode:  should match your configuration

-- Connection stats
SHOW STATS;
-- Key metrics:
--   total_xact_count:  transactions processed
--   total_query_count: queries processed
--   total_xact_time:   total transaction duration (microseconds)
--   avg_xact_time:     average transaction duration
--   avg_query_time:    average query duration
--   avg_wait_time:     average time spent waiting for a connection ← ALERT IF > 50ms

-- Current connections
SHOW CLIENTS;
SHOW SERVERS;

-- Configuration
SHOW CONFIG;

-- Reload config without restart
RELOAD;
```

**Key alerts to set:**

| Metric | Threshold | Why |
|--------|-----------|-----|
| `cl_waiting > 0` sustained > 30s | Warning | Clients waiting means pool is exhausted |
| `cl_waiting > 10` | Critical | Significant connection queueing |
| `avg_wait_time > 100ms` | Warning | Pool contention adding user-visible latency |
| `sv_active = default_pool_size` sustained | Warning | Pool at capacity — consider increasing or investigate slow queries |
| `total_xact_count` flat | Critical | PgBouncer stopped processing — check server connections |

### PgBouncer vs Pgpool-II

| Aspect | PgBouncer | Pgpool-II |
|--------|-----------|-----------|
| Primary purpose | Connection pooling | Connection pooling + load balancing + replication management |
| Resource usage | ~2 KB per connection, single process | ~6-30 KB per connection, multi-process |
| Pooling efficiency | Excellent (transaction mode) | Good (session mode only for complex queries) |
| Read/write splitting | No (single backend) | Yes (built-in with query parsing) |
| Replication management | No | Yes (streaming replication, failover) |
| Query caching | No | Yes (in-memory) |
| Complexity | Simple (one config file) | Complex (multiple config files, mode-dependent behavior) |
| Statement-level parsing | No (transparent proxy) | Yes (parses SQL for routing) |
| Watchdog/failover | No | Yes (with external consensus) |

**When to use PgBouncer:** Connection pooling is your primary need. You handle read/write routing at the application level or via DNS.

**When to use Pgpool-II:** You need read/write splitting at the proxy layer AND don't want to handle it in the application. But be aware: Pgpool-II's SQL parser doesn't understand every PostgreSQL query form. Complex CTEs, custom operators, and extension-specific syntax can be misrouted.

**In practice:** Most teams use PgBouncer for pooling and handle read/write splitting in the application (separate connection strings for primary and replica). Pgpool-II's additional features come with significant operational complexity.

### Multi-Database vs Single-Database Deployment

**Single-database** (one PgBouncer per database):

```ini
[databases]
myapp = host=pg.internal port=5432 dbname=myapp
```

Simpler. Each PgBouncer instance manages one pool. Good when you have one application and one database.

**Multi-database** (one PgBouncer for many databases):

```ini
[databases]
app1 = host=pg.internal port=5432 dbname=app1
app2 = host=pg.internal port=5432 dbname=app2
analytics = host=pg-replica.internal port=5432 dbname=app1
```

More operationally efficient. But `default_pool_size` applies per database/user combination, so if you have 10 databases and `default_pool_size=20`, PgBouncer could open up to 200 server connections (10 × 20). Use `max_db_connections` to cap the total.

**Wildcard mode** (auto-map any database name):

```ini
[databases]
* = host=pg.internal port=5432
```

PgBouncer will proxy connections to any database on the target host. Convenient but dangerous — no allowlisting of database names.

---

## 3. ProxySQL Deep Dive

### What It Is

ProxySQL is a high-performance MySQL protocol proxy that provides connection multiplexing, read/write splitting, query routing, query caching, query firewalling, and backend health monitoring. It speaks the MySQL wire protocol on both sides — applications connect to ProxySQL as if it were MySQL, and ProxySQL connects to actual MySQL backends.

### Install

```bash
# Packages
apt-get install proxysql2
yum install proxysql2

# Docker
docker run -d --name proxysql \
  -p 6033:6033 \
  -p 6032:6032 \
  proxysql/proxysql:latest

# Port 6033: MySQL traffic (application connects here)
# Port 6032: Admin interface
```

### Connection Multiplexing Architecture

ProxySQL maintains two connection pools:

1. **Frontend pool**: Connections from applications to ProxySQL
2. **Backend pool**: Connections from ProxySQL to MySQL servers

The key insight: ProxySQL **multiplexes** frontend connections onto a smaller set of backend connections. When an application connection is idle (between queries), the backend connection is returned to the pool and can serve other frontend connections.

```
[App: 500 connections] ──→ [ProxySQL frontend pool: 500]
                                        │
                              [multiplexing layer]
                                        │
                           [ProxySQL backend pool: 50]
                                        │
                              [MySQL: 50 connections]
```

This multiplexing is more aggressive than PgBouncer's transaction mode. ProxySQL can return backend connections to the pool after every query (not just after every transaction), unless the session has state that prevents it.

**When multiplexing is disabled for a session:**

ProxySQL automatically disables multiplexing (pins a backend connection to a frontend connection) when it detects session-level state:
- Active transaction (`BEGIN` without `COMMIT`)
- User-defined variables (`@variable`)
- `SET` commands that change session state
- `GET_LOCK()` / `RELEASE_LOCK()`
- Temporary tables
- `PREPARE` / `EXECUTE` / `DEALLOCATE PREPARE`
- `FOUND_ROWS()` (depends on previous query's connection)

This is tracked per-connection. Once the state is cleared (transaction committed, lock released), multiplexing resumes.

### Read/Write Splitting with Query Rules

ProxySQL routes queries based on regex matching against hostgroups:

```sql
-- Connect to admin interface
-- mysql -u admin -padmin -h 127.0.0.1 -P 6032

-- Define hostgroups
-- Hostgroup 10 = writers (master)
-- Hostgroup 20 = readers (replicas)

-- Add backend servers
INSERT INTO mysql_servers (hostgroup_id, hostname, port, weight, max_connections)
VALUES
  (10, 'mysql-master.internal', 3306, 1000, 100),
  (20, 'mysql-replica1.internal', 3306, 1000, 200),
  (20, 'mysql-replica2.internal', 3306, 500, 200);

-- Configure replication hostgroups (enables automatic failover detection)
INSERT INTO mysql_replication_hostgroups (writer_hostgroup, reader_hostgroup, comment)
VALUES (10, 20, 'production cluster');

-- Query routing rules (processed in rule_id order, first match wins)

-- Rule 1: SELECT ... FOR UPDATE → writer
INSERT INTO mysql_query_rules (rule_id, active, match_digest, destination_hostgroup, apply)
VALUES (100, 1, '^SELECT.*FOR UPDATE$', 10, 1);

-- Rule 2: SELECT → readers
INSERT INTO mysql_query_rules (rule_id, active, match_digest, destination_hostgroup, apply)
VALUES (200, 1, '^SELECT', 20, 1);

-- Rule 3: Everything else (INSERT, UPDATE, DELETE, DDL) → writer (default hostgroup)
-- No rule needed — default_hostgroup from mysql_users handles this

-- Activate
LOAD MYSQL SERVERS TO RUNTIME;
LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;
SAVE MYSQL QUERY RULES TO DISK;
```

**Important:** `match_digest` matches against the query digest (normalized form), not the raw query. This means `SELECT * FROM users WHERE id=1` and `SELECT * FROM users WHERE id=2` match the same rule. Use `match_pattern` for raw query matching.

### Query Caching

ProxySQL can cache query results in memory, serving repeated identical queries without hitting the backend:

```sql
-- Cache SELECT results for 5 seconds
INSERT INTO mysql_query_rules
  (rule_id, active, match_digest, cache_ttl, destination_hostgroup, apply)
VALUES
  (150, 1, '^SELECT.*FROM config_settings', 60000, 20, 1);  -- 60s cache for config
  -- cache_ttl is in milliseconds

-- Cache anything from the reader hostgroup for 1 second (aggressive)
INSERT INTO mysql_query_rules
  (rule_id, active, match_digest, cache_ttl, destination_hostgroup, apply)
VALUES
  (300, 1, '^SELECT', 1000, 20, 1);

LOAD MYSQL QUERY RULES TO RUNTIME;
```

**When caching helps:** Read-heavy workloads with frequently repeated identical queries (dashboards, config lookups, catalog pages). ProxySQL's cache is keyed on the full query text — even a different whitespace pattern is a cache miss.

**When caching hurts:** Write-after-read patterns where stale data causes incorrect behavior. ProxySQL has no cache invalidation mechanism beyond TTL expiration.

### Query Firewall

Block dangerous queries before they reach the backend:

```sql
-- Block queries without a WHERE clause on specific tables
INSERT INTO mysql_query_rules
  (rule_id, active, match_digest, error_msg, apply)
VALUES
  (50, 1, '^DELETE FROM orders$', 'DELETE without WHERE on orders table is blocked', 1);

INSERT INTO mysql_query_rules
  (rule_id, active, match_digest, error_msg, apply)
VALUES
  (51, 1, '^UPDATE orders SET', 'UPDATE without WHERE on orders table is blocked — use a more specific query', 1);

-- Block TRUNCATE entirely
INSERT INTO mysql_query_rules
  (rule_id, active, match_digest, error_msg, apply)
VALUES
  (52, 1, '^TRUNCATE', 'TRUNCATE is blocked by ProxySQL. Contact DBA.', 1);

-- Rate-limit expensive queries (max 10 per second)
INSERT INTO mysql_query_rules
  (rule_id, active, match_digest, destination_hostgroup, max_latency_ms, apply)
VALUES
  (60, 1, '^SELECT.*JOIN.*JOIN.*JOIN', 20, 30000, 1);
  -- max_latency_ms=30000 kills queries taking >30s

LOAD MYSQL QUERY RULES TO RUNTIME;
```

### Backend Health Checks and Failover

ProxySQL continuously monitors backend health:

```sql
-- Configure monitoring user (must exist on all MySQL backends)
UPDATE global_variables SET variable_value='monitor_user' WHERE variable_name='mysql-monitor_username';
UPDATE global_variables SET variable_value='monitor_pass' WHERE variable_name='mysql-monitor_password';

-- Health check intervals
UPDATE global_variables SET variable_value='2000' WHERE variable_name='mysql-monitor_ping_interval';      -- ping every 2s
UPDATE global_variables SET variable_value='1000' WHERE variable_name='mysql-monitor_ping_timeout';       -- 1s timeout
UPDATE global_variables SET variable_value='60000' WHERE variable_name='mysql-monitor_replication_lag_interval'; -- check lag every 60s
UPDATE global_variables SET variable_value='10' WHERE variable_name='mysql-monitor_replication_lag_timeout';    -- 10s max lag

LOAD MYSQL VARIABLES TO RUNTIME;
SAVE MYSQL VARIABLES TO DISK;
```

When a backend fails health checks, ProxySQL marks it as `SHUNNED` and stops routing traffic to it. When it recovers, traffic resumes automatically.

For replication-aware routing, ProxySQL checks `Seconds_Behind_Master` and removes lagging replicas from the reader hostgroup:

```sql
-- Set max acceptable replication lag (seconds)
UPDATE mysql_servers SET max_replication_lag=10 WHERE hostgroup_id=20;
LOAD MYSQL SERVERS TO RUNTIME;
```

### Admin Interface and Runtime Reconfiguration

The three-layer configuration model is ProxySQL's killer feature for operations:

```
DISK ←→ MEMORY ←→ RUNTIME

SAVE ... TO DISK     ←  persist to SQLite (survives restart)
LOAD ... TO RUNTIME  ←  activate changes (live, immediate)
LOAD ... FROM DISK   ←  rollback to saved config
LOAD ... FROM CONFIG ←  reload from proxysql.cnf
```

**Live reconfiguration workflow:**

```sql
-- 1. Make change in MEMORY
INSERT INTO mysql_servers (hostgroup_id, hostname, port) VALUES (20, 'new-replica.internal', 3306);

-- 2. Verify (still in MEMORY, not active)
SELECT * FROM mysql_servers;

-- 3. Activate
LOAD MYSQL SERVERS TO RUNTIME;

-- 4. Verify it's working
SELECT * FROM stats_mysql_connection_pool WHERE srv_host='new-replica.internal';

-- 5. Persist (only after confirming it works)
SAVE MYSQL SERVERS TO DISK;

-- If something went wrong at step 4:
LOAD MYSQL SERVERS FROM DISK;  -- rollback to previous persisted state
LOAD MYSQL SERVERS TO RUNTIME;
```

This means you can add/remove backends, change routing rules, and modify users on a running ProxySQL instance with zero downtime and instant rollback.

### Configuration Walkthrough

```ini
# /etc/proxysql.cnf — initial bootstrap configuration
# After first start, ProxySQL uses its internal SQLite DB.
# All runtime changes are via the admin interface.

datadir="/var/lib/proxysql"

admin_variables=
{
    admin_credentials="admin:your-secure-admin-password"
    mysql_ifaces="0.0.0.0:6032"
    # Restrict admin access
    # admin_credentials="admin:pass;radminuser:radminpass"
    # refresh_interval=2000
}

mysql_variables=
{
    # Application-facing interface
    interfaces="0.0.0.0:6033"

    # Connection limits
    max_connections=2048

    # Timeouts
    connect_timeout_server=3000        # 3s to connect to backend
    connect_timeout_server_max=10000   # 10s max including retries
    connection_max_age_ms=0            # 0 = no max age (let server_lifetime handle it)

    # Default settings for new connections
    default_charset="utf8mb4"
    default_collation_connection="utf8mb4_general_ci"

    # Multiplexing
    multiplexing=true
    connection_warming=false           # Don't pre-warm connections

    # Monitoring
    monitor_username="proxysql_monitor"
    monitor_password="monitor_password"
    monitor_ping_interval=2000
    monitor_ping_timeout=1000
    monitor_replication_lag_interval=10000
    monitor_replication_lag_timeout=3000

    # Connection pool
    free_connections_pct=10            # Keep 10% of connections idle for burst
    session_idle_ms=1000               # Release backend after 1s idle

    # Query handling
    long_query_time=10000              # Log queries > 10s
    query_retries_on_failure=1         # Retry failed queries once on different backend

    # Thread pool
    threads=4                          # Match CPU cores
    stacksize=1048576
}

# Initial server and user configuration (loaded once on first start)
mysql_servers=
(
    { hostgroup_id=10, hostname="mysql-master.internal", port=3306, weight=1000, max_connections=200 },
    { hostgroup_id=20, hostname="mysql-replica1.internal", port=3306, weight=1000, max_connections=200 },
    { hostgroup_id=20, hostname="mysql-replica2.internal", port=3306, weight=500, max_connections=200 }
)

mysql_users=
(
    { username="app_user", password="app_password", default_hostgroup=10, max_connections=500 }
)

mysql_query_rules=
(
    { rule_id=100, active=1, match_digest="^SELECT.*FOR UPDATE$", destination_hostgroup=10, apply=1 },
    { rule_id=200, active=1, match_digest="^SELECT", destination_hostgroup=20, apply=1 }
)

mysql_replication_hostgroups=
(
    { writer_hostgroup=10, reader_hostgroup=20, comment="production" }
)
```

### Monitoring

```sql
-- Connection pool health (primary monitoring view)
SELECT hostgroup, srv_host, srv_port, status,
       ConnUsed, ConnFree, ConnOK, ConnERR,
       Queries, Bytes_data_sent, Bytes_data_recv,
       Latency_us
FROM stats_mysql_connection_pool;
-- Key: ConnUsed near max_connections = pool exhaustion
-- Key: ConnERR increasing = backend health issue
-- Key: Latency_us increasing = backend slowdown

-- Query digest stats (which queries are heaviest)
SELECT hostgroup, schemaname,
       digest_text,
       count_star,
       sum_time,                        -- total execution time (microseconds)
       ROUND(sum_time/count_star) AS avg_time_us,
       min_time,
       max_time,
       rows_sent,
       rows_affected
FROM stats_mysql_query_digest
ORDER BY sum_time DESC
LIMIT 20;

-- Command counters (DML breakdown)
SELECT Command, Total_Time_us, Total_cnt,
       ROUND(Total_Time_us/Total_cnt) AS avg_us
FROM stats_mysql_commands_counters
WHERE Total_cnt > 0
ORDER BY Total_Time_us DESC;

-- Global stats
SELECT * FROM stats_mysql_global
WHERE Variable_Name IN (
    'Client_Connections_connected',
    'Client_Connections_created',
    'Server_Connections_connected',
    'Server_Connections_created',
    'Questions',
    'Slow_queries',
    'Com_frontend',
    'Com_backend',
    'Query_Cache_Entries',
    'Query_Cache_Memory_bytes',
    'Query_Cache_count_GET',
    'Query_Cache_count_GET_OK',       -- cache hits
    'Query_Cache_Purged',
    'ConnPool_get_conn_success',
    'ConnPool_get_conn_failure'       -- ALERT if increasing
);

-- Monitor ping log (backend health history)
SELECT * FROM monitor.mysql_server_ping_log
ORDER BY time_start_us DESC LIMIT 20;

-- Monitor replication lag log
SELECT * FROM monitor.mysql_server_replication_lag_log
ORDER BY time_start_us DESC LIMIT 20;
```

**Key alerts to set:**

| Metric | Threshold | Why |
|--------|-----------|-----|
| `ConnPool_get_conn_failure` increasing | Any increase | Clients failing to get backend connections |
| `ConnERR` increasing on a backend | > 5/minute | Backend health degrading |
| `Latency_us` on backends | > 500,000 (500ms) | Backend slowdown |
| `Client_Connections_connected` | > 80% of max_connections | Approaching connection limit |
| `Slow_queries` count | Trend increase | Query performance regression |
| Replication lag on readers | > `max_replication_lag` setting | Reads may return stale data |

---

## 4. Application-Level Pooling

Every database driver/ORM maintains its own connection pool. These are the first layer of pooling and sometimes the only layer you need.

### HikariCP (Java / JVM)

The gold standard for JVM connection pooling. Fast, correct, well-documented.

```java
HikariConfig config = new HikariConfig();
config.setJdbcUrl("jdbc:mysql://localhost:3306/mydb");
config.setUsername("app_user");
config.setPassword("password");

// === Pool sizing ===
config.setMaximumPoolSize(10);    // Max connections in the pool
config.setMinimumIdle(5);         // See warning below
config.setConnectionTimeout(30000); // 30s to get a connection before error
config.setIdleTimeout(600000);    // 10 min idle before connection is retired
config.setMaxLifetime(1800000);   // 30 min max connection lifetime
                                  // Must be less than MySQL's wait_timeout

// === Leak detection ===
config.setLeakDetectionThreshold(60000); // Log if connection not returned within 60s

// === Validation ===
config.setConnectionTestQuery("SELECT 1"); // Only needed for JDBC3 drivers
// JDBC4+ drivers use Connection.isValid() — no test query needed

HikariDataSource ds = new HikariDataSource(config);
```

**The `minimumIdle` trap:**

HikariCP's author (Brett Wooldridge) explicitly recommends setting `minimumIdle` equal to `maximumPoolSize`. The reasoning: if your pool needs 10 connections, it should maintain 10 connections. Having an idle connection in the pool costs ~1 MB. Having to create a new connection under load costs 5-50ms of latency that a user feels.

The only reason to set `minimumIdle < maximumPoolSize` is if you have many application instances and want to reduce total connection count during low-traffic periods. In that case, use a dedicated pooler (PgBouncer/ProxySQL) instead.

```java
// RECOMMENDED: fixed-size pool
config.setMaximumPoolSize(10);
config.setMinimumIdle(10);  // same as max — pool is always fully stocked

// ANTI-PATTERN: dynamic sizing (seems clever, wastes latency under load)
config.setMaximumPoolSize(20);
config.setMinimumIdle(2);   // pool shrinks to 2, then scrambles to grow under load
```

**maxLifetime coordination:**

`maxLifetime` must be LESS than MySQL's `wait_timeout` (default 28800s = 8 hours) and PostgreSQL's equivalent. If a connection sits idle longer than `wait_timeout`, MySQL closes it silently. HikariCP tries to use it and gets a "connection closed" error. Set `maxLifetime` to 25-30 minutes — short enough to cycle connections regularly, long enough to avoid churn.

**Gotchas:**

- HikariCP logs connection pool metrics via JMX by default. Export these to your monitoring system. The `hikaricp_connections_active` and `hikaricp_connections_pending` metrics are gold.
- For PostgreSQL with PgBouncer in transaction mode: disable prepared statements (`prepareThreshold=0` in the JDBC URL) or you'll get "prepared statement does not exist" errors.

### SQLAlchemy Pool (Python)

```python
from sqlalchemy import create_engine

engine = create_engine(
    "mysql+pymysql://user:pass@localhost:3306/mydb",

    # Pool class (QueuePool is default and correct for most cases)
    pool_size=5,            # Maintained connections
    max_overflow=10,        # Extra connections allowed under load (total max = 5 + 10 = 15)
    pool_timeout=30,        # Seconds to wait for a connection
    pool_recycle=1800,      # Recycle connections after 30 min (CRITICAL for MySQL)
    pool_pre_ping=True,     # Verify connection is alive before using it

    # For read-only or serverless patterns:
    # pool_class=NullPool   # No pooling — new connection per request
)
```

**`pool_recycle` is non-optional for MySQL.** MySQL's `wait_timeout` (default 8 hours) silently closes idle connections. Without `pool_recycle`, SQLAlchemy will try to use a dead connection and error. `pool_pre_ping=True` adds a `SELECT 1` before each use, which catches dead connections but adds a round-trip. Use both: `pool_recycle=1800` to proactively cycle connections, and `pool_pre_ping=True` as a safety net.

**QueuePool vs NullPool:**

| Pool | Behavior | When to Use |
|------|----------|-------------|
| `QueuePool` | Maintains a pool of connections, reuses them | Default. Standard web applications, long-running services |
| `NullPool` | Creates a new connection per use, closes it immediately | Behind PgBouncer/ProxySQL (let the external pooler manage connections), or serverless functions where processes are short-lived |
| `StaticPool` | One connection shared across all threads | Testing only |

**For serverless (AWS Lambda, Cloud Functions):** Use `NullPool`. These environments spin up and tear down processes rapidly. A connection pool inside a short-lived process wastes resources and causes connection leaks as frozen containers accumulate.

**Gotchas:**

- `pool_size + max_overflow` is your actual maximum. Many people set `pool_size=20, max_overflow=10` thinking they have 20 connections, but under load they have 30.
- SQLAlchemy's pool is per-engine. If you create multiple engines (primary + replica), each has its own pool. Total connections = sum of all engines.
- In async mode (`create_async_engine`), the pool uses `AsyncAdaptedQueuePool`. Same semantics, but compatible with asyncio.

### Ecto Pool (Elixir)

Ecto uses `DBConnection` under the hood, which implements its own connection pool.

```elixir
# config/prod.exs
config :my_app, MyApp.Repo,
  hostname: "localhost",
  database: "myapp",
  username: "app_user",
  password: "secret",
  pool_size: 10,           # Number of connections in the pool
  queue_target: 50,        # Target queue wait time in ms
  queue_interval: 1000,    # How often to check queue health (ms)
  timeout: 15_000,         # Query timeout (ms)
  connect_timeout: 5_000,  # Connection establishment timeout (ms)
  idle_interval: 10_000    # Ping interval for idle connections (ms)

# For multiple databases:
config :my_app, MyApp.ReadRepo,
  hostname: "replica.internal",
  pool_size: 15             # Larger pool for read-heavy workloads
```

**Queue target tuning:**

Ecto's pool uses an adaptive algorithm. `queue_target` (default 50ms) is the acceptable wait time for a connection. If waits exceed this for longer than `queue_interval`, the pool starts dropping connections to force new ones (on the assumption that existing connections are stale or stuck). This is aggressive — in most cases, you want to increase `queue_target` to 200-500ms in production to avoid unnecessary connection churn during brief load spikes.

```elixir
# More tolerant of brief spikes
pool_size: 10,
queue_target: 200,     # Accept up to 200ms wait before triggering adaptive behavior
queue_interval: 5000   # Check every 5 seconds instead of every 1 second
```

**Gotchas:**

- Ecto's pool does NOT support overflow like SQLAlchemy. `pool_size` is a hard limit. If all connections are in use, callers queue until `timeout`.
- In umbrella apps, each app with its own Repo has its own pool. Total connections = sum of all Repo pool_sizes. This catches people off guard when they have 5 umbrella apps each with `pool_size: 10` and wonder why they have 50 connections.
- For PgBouncer in transaction mode: add `prepare: :unnamed` to your Repo config to avoid named prepared statement issues. For Ecto 3.10+, this is `prepare: :named` by default but can be set to `:unnamed` for PgBouncer compatibility.

### Prisma Pool (Node.js / TypeScript)

```prisma
// schema.prisma
datasource db {
  provider = "mysql"
  url      = env("DATABASE_URL")
}

// Connection URL with pool params:
// mysql://user:pass@localhost:3306/mydb?connection_limit=20&pool_timeout=10
```

```typescript
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL
    }
  },
  // Log slow queries
  log: [
    { level: 'query', emit: 'event' },
    { level: 'warn', emit: 'stdout' },
    { level: 'error', emit: 'stdout' }
  ]
})

// Log queries taking > 1 second
prisma.$on('query', (e) => {
  if (e.duration > 1000) {
    console.warn(`Slow query (${e.duration}ms): ${e.query}`)
  }
})
```

**The default pool size is too low for production.**

Prisma defaults to `connection_limit=5` when the `connection_limit` parameter is not specified. For a single Node.js process, this might be fine. But in production with multiple worker processes (pm2, cluster mode), each process gets its own pool. 4 workers × 5 connections = 20 connections. Add serverless scale-up and you quickly exhaust MySQL's connection limit.

```
# Production connection string
DATABASE_URL="mysql://user:pass@localhost:3306/mydb?connection_limit=20&pool_timeout=10&connect_timeout=10"
```

**The Prisma Data Proxy / Accelerate:**

For serverless deployments (Vercel, AWS Lambda), Prisma offers a managed connection pooler (Prisma Accelerate, formerly Data Proxy). It sits between your serverless functions and the database, providing connection pooling that persists across cold starts. This solves the serverless connection explosion problem that PgBouncer/ProxySQL solve for traditional deployments.

**Gotchas:**

- Prisma's pool is per-PrismaClient instance. If you instantiate multiple clients (e.g., in serverless where each invocation creates a new client), you get pool multiplication. Use a singleton pattern.
- `pool_timeout` (default 10s) is how long Prisma waits for a free connection before erroring. In high-concurrency serverless, increase this or increase `connection_limit`.
- Prisma uses prepared statements internally. Behind PgBouncer in transaction mode, you need PgBouncer 1.21+ with prepared statement tracking, or `pgbouncer=true` in the connection string (Prisma-specific flag that disables prepared statements).

### When App-Level Pooling Is Enough vs When You Need a Dedicated Pooler

| Scenario | App-Level Pool Sufficient? | Why |
|----------|---------------------------|-----|
| Single monolith, moderate traffic | Yes | One pool, one application, easy to right-size |
| Single app, high traffic (>1000 QPS) | Maybe | If pool size stays under optimal formula, fine |
| Multiple apps sharing one database | No — use a pooler | Each app maintains its own pool; combined connections exceed optimal |
| Microservices (10+ services) | No — use a pooler | Connection explosion: 10 services × 10 instances × 10 pool = 1,000 connections |
| Serverless (Lambda, Cloud Functions) | No — use a pooler | Each invocation may create connections; no shared pool across invocations |
| Read/write splitting needed | Depends | App-level works (separate connection strings). ProxySQL adds transparent routing. |
| Connection storms (deploy spikes, retry cascades) | No — use a pooler | The pooler queues excess connections; the database sees a steady connection count |

**Rule of thumb:** If `(number_of_app_instances) × (pool_size_per_instance)` exceeds 2-3x the optimal pool size formula, you need a dedicated pooler.

---

## 5. Pool Sizing Deep Dive

### The Formula and Why It Works

```
optimal_pool_size = (2 × CPU_cores) + effective_IO_channels
```

This isn't cargo-cult wisdom — it's applied queueing theory (Little's Law). At any instant:

- Up to `CPU_cores` queries can be actively computing
- Up to `CPU_cores` additional queries can be ready-to-run (context-switching overhead is acceptable at 2x)
- Up to `effective_IO_channels` queries can be blocked on I/O without wasting CPU

More connections than this creates a situation where queries compete for resources rather than use them. The competition itself (lock contention, context switching, cache invalidation) consumes resources that could serve actual queries.

### Worked Examples

#### Example 1: SaaS Application (Mixed OLTP)

- **Server**: 8 cores, NVMe SSD, 32 GB RAM
- **Formula**: (2 × 8) + 1 = **17 connections**
- **Application**: 4 web servers, each with pool_size=10

Without pooler: 4 × 10 = 40 connections. 2.3x optimal. Database works but with unnecessary contention.

With pooler: PgBouncer with `default_pool_size=17`. App servers connect to PgBouncer. Database sees at most 17 concurrent queries. App servers' idle connections consume only PgBouncer memory (~2 KB each).

#### Example 2: Microservices Backend

- **Server**: 16 cores, NVMe SSD, 64 GB RAM
- **Formula**: (2 × 16) + 1 = **33 connections**
- **Application**: 12 microservices, 3 instances each, pool_size=5

Without pooler: 12 × 3 × 5 = 180 connections. 5.5x optimal. Significant throughput degradation.

With pooler: ProxySQL with 33 writer connections + 33 reader connections. Each microservice connects to ProxySQL. Combined 180 application connections are multiplexed onto 33 backend connections.

#### Example 3: E-commerce with Burst Traffic

- **Server**: 4 cores, SSD, 16 GB RAM
- **Formula**: (2 × 4) + 1 = **9 connections**
- **Application**: Single Rails app, 8 Puma workers, pool_size=5

Without pooler: 8 × 5 = 40 connections. 4.4x optimal. During flash sales, all 40 connections are active simultaneously. Database throughput drops to 60% of optimal.

With pooler: PgBouncer with `default_pool_size=9`. Under burst traffic, 31 connections queue in PgBouncer (sub-millisecond wait) while 9 connections serve queries at maximum throughput. Total request latency may actually decrease because queries finish faster without contention.

### The "Too Many Connections" Death Spiral

This is the failure mode that kills production systems:

```
1. Load increases → response times increase
2. Clients timeout → clients retry → MORE connections open
3. More connections → more contention → response times increase MORE
4. More timeouts → more retries → MORE connections
5. max_connections reached → new connections rejected → cascading failure
6. Upstream services timeout → their clients retry → amplification
```

The death spiral is self-reinforcing. The "fix" (increasing max_connections) makes the problem worse by allowing more connections to compete, making each connection slower, causing more retries.

**The correct response:**

1. **Connection pooler** prevents the spiral by queuing excess connections instead of passing them to the database
2. **Circuit breakers** in the application stop retry amplification
3. **Connection timeouts** (both `connect_timeout` and `statement_timeout`) prevent connections from accumulating indefinitely
4. **Backpressure** — return 503s early rather than accepting requests you can't serve

### Monitoring Pool Health

Regardless of pooling layer, monitor these four metrics:

| Metric | Healthy Range | Problem Indicator |
|--------|--------------|-------------------|
| **Active connections** | < pool_size × 0.8 | Sustained at pool_size = saturated; response times degrading |
| **Idle connections** | > pool_size × 0.1 | Zero idle = no headroom for burst; too many idle = pool oversized |
| **Wait time** (queue time) | < 10ms avg | > 50ms avg = pool too small; > 100ms = imminent user impact |
| **Wait count** (requests queued) | Near zero | Sustained > 0 = demand exceeds pool capacity |

**PgBouncer monitoring:**

```sql
-- cl_waiting > 0 for extended periods = pool too small
SHOW POOLS;
-- avg_wait_time > 50ms = users feeling the queue
SHOW STATS;
```

**ProxySQL monitoring:**

```sql
-- ConnFree = 0 and ConnUsed = max = saturated
SELECT hostgroup, srv_host, ConnUsed, ConnFree, ConnERR
FROM stats_mysql_connection_pool;
```

**HikariCP monitoring (JMX/Prometheus):**

```
hikaricp_connections_active     -- should be < pool_size
hikaricp_connections_idle       -- should be > 0
hikaricp_connections_pending    -- should be near 0; > 0 = waiting for connection
hikaricp_connections_timeout    -- should be 0; any > 0 = pool exhaustion
```

---

## 6. Decision Matrix

### Quick Decision Guide

| Your Situation | Recommended Approach |
|:---------------|:--------------------|
| Single app + PostgreSQL | PgBouncer in transaction mode |
| Single app + MySQL (moderate traffic) | App-level pool (HikariCP, SQLAlchemy, Ecto) |
| Single app + MySQL (high traffic) | ProxySQL or app-level pool with careful sizing |
| Multiple apps + PostgreSQL | PgBouncer (centralized or per-app) |
| Multiple apps + MySQL | ProxySQL |
| Microservices + PostgreSQL | PgBouncer (mandatory — connection explosion otherwise) |
| Microservices + MySQL | ProxySQL (mandatory — same reason) |
| Read/write split + PostgreSQL | PgBouncer (2 instances: one for primary, one for replica) + app routing |
| Read/write split + MySQL | ProxySQL (built-in query-based routing) |
| Kubernetes + PostgreSQL | PgBouncer as sidecar per pod, or centralized PgBouncer deployment |
| Kubernetes + MySQL | ProxySQL as sidecar or centralized deployment |
| Serverless + PostgreSQL | PgBouncer (centralized, long-lived) or RDS Proxy |
| Serverless + MySQL | ProxySQL (centralized) or RDS Proxy or Prisma Accelerate |
| Need query caching at proxy layer | ProxySQL (MySQL) or application-level cache (Redis) |
| Need query firewalling | ProxySQL (MySQL) — PgBouncer doesn't inspect queries |

### Detailed Scenarios

#### Single App + PostgreSQL

```
[App] ──→ [PgBouncer (transaction mode)] ──→ [PostgreSQL]
           pool_size = (2 × cores) + 1
           max_client_conn = 500
```

PgBouncer is essentially mandatory for PostgreSQL in production. Even a single application benefits from the connection queuing behavior. Without PgBouncer, a deploy that restarts 10 app instances simultaneously creates a connection storm.

#### Multiple Apps + PostgreSQL

**Option A: Centralized PgBouncer**

```
[App A] ──→ [PgBouncer] ──→ [PostgreSQL]
[App B] ──↗  pool per user/db pair
[App C] ──↗  max_db_connections = global cap
```

Simpler to operate. One PgBouncer instance to monitor. But: single point of failure (run multiple with keepalived or behind a load balancer).

**Option B: Per-app PgBouncer**

```
[App A] ──→ [PgBouncer A] ──→ [PostgreSQL]
[App B] ──→ [PgBouncer B] ──↗
[App C] ──→ [PgBouncer C] ──↗
```

Each app manages its own pool. More resilient (App B's PgBouncer failure doesn't affect App A). But: harder to enforce a global connection limit. Set `max_db_connections` on each PgBouncer such that the sum doesn't exceed the database's `max_connections`.

#### Single App + MySQL (When You Don't Need ProxySQL)

```
[App with HikariCP/SQLAlchemy/Ecto pool] ──→ [MySQL]
        pool_size = 10-20
```

For a single application with one MySQL backend, app-level pooling is often sufficient. The app pool maintains a fixed set of connections to MySQL. No additional infrastructure. No additional failure points.

**When this breaks down:** Deploys. If you have 10 app instances and each maintains 10 connections, a rolling deploy briefly doubles the connection count (old instances draining + new instances connecting). If your optimal pool size is 20, this spike to 200 connections causes contention. At this point, add ProxySQL.

#### Microservices Architecture

```
[Service A (×5)] ──→ [ProxySQL/PgBouncer] ──→ [Database]
[Service B (×3)] ──↗   pool = (2 × cores) + 1
[Service C (×8)] ──↗   queue = ∞ (limited by client timeout)
[Service D (×2)] ──↗
[Service E (×4)] ──↗
```

In a microservices architecture, a dedicated pooler is non-negotiable. Without it:
- 5 services × 4 instances × 10 pool_size = 200 connections per service = 1,000 total
- Database optimal is 33 connections (16-core server)
- You're 30x over optimal

With a pooler:
- All 1,000 application connections multiplex through 33 backend connections
- Database operates at peak efficiency
- Services are decoupled from database connection management

#### Kubernetes Sidecar Pattern

```yaml
# Deployment with PgBouncer sidecar
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      containers:
      - name: app
        image: myapp:latest
        env:
        - name: DATABASE_URL
          value: "postgres://user:pass@localhost:6432/mydb"  # connects to sidecar
      - name: pgbouncer
        image: edoburu/pgbouncer:latest
        ports:
        - containerPort: 6432
        env:
        - name: DATABASE_URL
          value: "postgres://user:pass@pg-primary.internal:5432/mydb"
        - name: POOL_MODE
          value: "transaction"
        - name: DEFAULT_POOL_SIZE
          value: "5"   # per-pod pool — keep small
        - name: MAX_DB_CONNECTIONS
          value: "5"
```

**Sidecar vs centralized in K8s:**

| Aspect | Sidecar | Centralized |
|--------|---------|-------------|
| Failure domain | Per-pod (isolated) | Shared (pooler failure = global outage) |
| Connection count | Each pod has its own pool (5 × N pods) | Single pool (controlled) |
| Latency | Localhost (sub-ms) | Network hop (~1ms) |
| Resource usage | One PgBouncer per pod (trivial but adds up) | One PgBouncer deployment |
| Total connection control | Hard (must coordinate across pods) | Easy (one config) |

**Recommendation:** Use sidecars when you have < 20 pods and can control total connections via `MAX_DB_CONNECTIONS`. Use centralized when you have many pods or need strict global connection limits. Some teams use both: centralized for connection limiting, sidecars for local multiplexing.

#### Serverless Functions

Serverless is the worst-case scenario for database connections. Each function invocation may:
- Cold start → create new connection → connection overhead
- Run for 100ms → hold connection for 100ms → 99% idle
- Scale to 1,000 concurrent invocations → 1,000 connections

```
[Lambda ×1000] ──→ [External Pooler] ──→ [Database]
                    (must be long-lived,
                     outside serverless)
```

Options:
- **RDS Proxy** (AWS): Managed connection pooler for RDS. Supports PostgreSQL and MySQL. Zero config. Higher cost. Limited customization.
- **PgBouncer on EC2/ECS** (PostgreSQL): Self-managed but fully customizable. Run on a small always-on instance.
- **ProxySQL on EC2/ECS** (MySQL): Same pattern.
- **Prisma Accelerate** (any): Managed pooler with caching. Easiest for Prisma users. Adds latency (external service).
- **Supabase Supavisor** (PostgreSQL): Built into Supabase. If you're on Supabase, it's automatic.

The critical requirement: **the pooler must be long-lived and outside the serverless execution environment.** A pooler inside a Lambda function is useless — it has the same lifecycle as the function.
