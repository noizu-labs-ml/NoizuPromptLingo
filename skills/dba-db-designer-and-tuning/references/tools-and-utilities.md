# PostgreSQL Tools & Utilities Catalog

A curated catalog of database tools and utilities for PostgreSQL-first development. Organized by workflow stage: design, analyze, monitor, migrate, maintain, test, and daily CLI work.

---

## Table of Contents

1. [Schema Visualization & ERD](#1-schema-visualization--erd)
2. [Query Analysis](#2-query-analysis)
3. [Performance Monitoring](#3-performance-monitoring)
4. [Migration Tools](#4-migration-tools)
5. [Maintenance & Operations](#5-maintenance--operations)
6. [Data Generation & Testing](#6-data-generation--testing)
7. [CLI Essentials](#7-cli-essentials)

---

## 1. Schema Visualization & ERD

Tools for understanding, documenting, and communicating database structure.

| Tool | What It Does | Install | Key Usage | When to Reach For It |
|------|-------------|---------|-----------|---------------------|
| **pgModeler** | Desktop ERD editor that reverse-engineers live databases and generates DDL | `brew install pgmodeler` or [pgmodeler.io](https://pgmodeler.io) | Import via connection string, drag-and-drop design, export SQL | Designing new schemas visually or producing presentation-quality diagrams |
| **DBeaver** | Universal database GUI with built-in ERD generation from any connection | `brew install --cask dbeaver-community` | Right-click schema > View Diagram; supports editing, export to PNG/SVG | Quick visual exploration of an unfamiliar database |
| **dbdiagram.io** | Web-based ERD tool using DBML syntax; shareable links, export to SQL | Browser: [dbdiagram.io](https://dbdiagram.io) | Write DBML in-browser, click Export > PostgreSQL | Collaborating on schema design with a team, embedding in docs |
| **SchemaSpy** | Generates browsable HTML documentation from a live database | `java -jar schemaspy.jar` ([schemaspy.org](https://schemaspy.org)) | `java -jar schemaspy.jar -t pgsql11 -db mydb -host localhost -u user -o output/` | Producing self-contained schema docs for onboarding or audits |
| **pg_dump + graphviz** | Quick-and-dirty ERD from DDL: dump schema, parse FK relationships, render | Built-in (`pg_dump`) + `brew install graphviz` | `pg_dump --schema-only mydb \| postgresql_autodoc \| dot -Tpng -o erd.png` | One-off ERD when you don't want to install a GUI |

### Tips

- **dbdiagram.io** can import raw SQL DDL — paste your `pg_dump --schema-only` output directly.
- **pgModeler** is the most complete open-source option but has a learning curve; DBeaver is faster for "just show me the tables."
- For CI-generated docs, SchemaSpy runs headless and produces static HTML you can host anywhere.

---

## 2. Query Analysis

Tools for understanding why queries are slow and what the planner is doing.

| Tool | What It Does | Install | Key Usage | When to Reach For It |
|------|-------------|---------|-----------|---------------------|
| **pg_stat_statements** | Tracks execution stats (calls, total time, rows) for all normalized queries | Built-in extension: `CREATE EXTENSION pg_stat_statements;` | `SELECT query, calls, mean_exec_time, rows FROM pg_stat_statements ORDER BY total_exec_time DESC LIMIT 20;` | First stop for identifying your slowest queries — always enable this |
| **auto_explain** | Automatically logs EXPLAIN plans for queries exceeding a time threshold | Built-in: add to `shared_preload_libraries` | `SET auto_explain.log_min_duration = '100ms'; SET auto_explain.log_analyze = true;` | Finding slow query plans in production without manual EXPLAIN |
| **pgBadger** | Parses PostgreSQL log files and generates detailed HTML reports with query stats | `brew install pgbadger` or [pgbadger.darold.net](https://pgbadger.darold.net) | `pgbadger /var/log/postgresql/postgresql.log -o report.html` | Post-incident analysis, weekly performance reviews |
| **explain.dalibo.com** | Web-based EXPLAIN plan visualizer with node-by-node cost breakdown | Browser: [explain.dalibo.com](https://explain.dalibo.com) | Paste `EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)` output | Sharing plan analysis with teammates, visual plan exploration |
| **explain.depesz.com** | Web-based EXPLAIN visualizer focused on highlighting the slowest nodes | Browser: [explain.depesz.com](https://explain.depesz.com) | Paste `EXPLAIN ANALYZE` text output | Quick identification of the most expensive plan node |
| **Flame graphs** | Visualize nested plan nodes as flame graphs for complex queries | [pg_flame](https://github.com/mgartner/pg_flame): `go install github.com/mgartner/pg_flame@latest` | `psql -c "EXPLAIN (ANALYZE, FORMAT JSON) SELECT ..." \| pg_flame \| flamegraph.pl > out.svg` | Complex queries with deeply nested joins/subqueries |

### Tips

- **pg_stat_statements** is non-negotiable — enable it in every environment including staging.
- Set `pg_stat_statements.track = all` to capture queries inside functions and procedures.
- **auto_explain** has overhead; use `log_min_duration` to limit to genuinely slow queries (100ms+ in production).
- For **pgBadger**, ensure `log_line_prefix` includes `%t [%p]: [%l-1]` and `log_min_duration_statement` is set.

---

## 3. Performance Monitoring

Tools for ongoing visibility into database health and resource usage.

| Tool | What It Does | Install | Key Usage | When to Reach For It |
|------|-------------|---------|-----------|---------------------|
| **pg_stat_activity** | Shows currently running queries, wait events, and connection state | Built-in view | `SELECT pid, state, wait_event_type, query, now() - query_start AS duration FROM pg_stat_activity WHERE state != 'idle';` | Diagnosing "the database feels slow right now" |
| **pg_stat_user_tables** | Per-table stats: sequential scans, index scans, live/dead tuples, last vacuum | Built-in view | `SELECT relname, seq_scan, idx_scan, n_dead_tup, last_autovacuum FROM pg_stat_user_tables ORDER BY n_dead_tup DESC;` | Finding tables that need indexes or are overdue for vacuum |
| **pg_stat_user_indexes** | Per-index usage stats: scans, reads, fetches | Built-in view | `SELECT indexrelname, idx_scan, idx_tup_read FROM pg_stat_user_indexes WHERE idx_scan = 0 ORDER BY pg_relation_size(indexrelid) DESC;` | Finding unused indexes that waste space and slow writes |
| **pgHero** | Web dashboard showing slow queries, missing indexes, space usage, connections | Docker: `docker run -e DATABASE_URL=... ankane/pghero` | Browse `http://localhost:8080` | Quick health overview without setting up a full monitoring stack |
| **pgwatch2** | Monitoring agent with pre-built Grafana dashboards for PostgreSQL metrics | Docker Compose: [github.com/cybertec-postgresql/pgwatch2](https://github.com/cybertec-postgresql/pgwatch2) | `docker-compose up` with connection config | Production monitoring with historical trends and alerting |
| **postgres_exporter** | Prometheus exporter for PostgreSQL metrics | Docker: `quay.io/prometheuscommunity/postgres-exporter` | Configure `DATA_SOURCE_NAME`, scrape with Prometheus, visualize in Grafana | When you already run Prometheus/Grafana and want PG metrics in the same stack |
| **pgbench** | Built-in benchmarking tool for measuring throughput and latency | Built-in | `pgbench -i -s 10 mydb && pgbench -c 10 -j 2 -T 60 mydb` | Baseline performance testing, validating config changes, load testing |

### Key Built-in Views Cheat Sheet

```sql
-- Connections by state
SELECT state, count(*) FROM pg_stat_activity GROUP BY state;

-- Cache hit ratio (should be > 99%)
SELECT
  sum(heap_blks_hit) / nullif(sum(heap_blks_hit) + sum(heap_blks_read), 0) AS ratio
FROM pg_statio_user_tables;

-- Index hit ratio (should be > 95%)
SELECT
  sum(idx_blks_hit) / nullif(sum(idx_blks_hit) + sum(idx_blks_read), 0) AS ratio
FROM pg_statio_user_indexes;

-- Tables with most dead tuples (vacuum candidates)
SELECT schemaname, relname, n_dead_tup, last_autovacuum
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC LIMIT 10;
```

---

## 4. Migration Tools

Tools for evolving schemas safely across environments.

| Tool | What It Does | Install | Key Usage | When to Reach For It |
|------|-------------|---------|-----------|---------------------|
| **migra** | Diffs two PostgreSQL schemas and generates the ALTER statements to reconcile them | `pip install migra[pg]` | `migra postgresql:///db_old postgresql:///db_new` | Verifying migration completeness — "did my migration script produce the expected schema?" |
| **Flyway** | Version-controlled SQL migrations with a numbered file convention | `brew install flyway` or Docker | `flyway -url=jdbc:postgresql://localhost/mydb migrate` | Java/JVM projects, teams that want numbered migration files (V1__, V2__) |
| **Liquibase** | Changelog-based migrations in XML/YAML/SQL with rollback support | `brew install liquibase` or Docker | `liquibase --changelog-file=changelog.xml update` | When you need declarative rollback plans or cross-database portability |
| **pgdiff** | Compares two database schemas and outputs DDL differences | `go install github.com/joncrlsn/pgdiff@latest` | `pgdiff -U user1 db1 -U user2 db2` | Lightweight alternative to migra for quick schema diffs |
| **pg_dump --schema-only** | Dumps DDL for diffing with standard tools | Built-in | `pg_dump --schema-only mydb > schema.sql && diff old.sql schema.sql` | Low-tech schema comparison when you don't want to install anything |

### Tips

- **migra** is the standout tool here — it understands PostgreSQL-specific features (views, functions, triggers, policies) and generates clean output.
- Use `pg_dump --schema-only` snapshots before and after migrations as a safety check.
- Most ORMs (Django, Ecto, ActiveRecord, Prisma, Drizzle) have built-in migration systems — reach for these tools when validating ORM output or doing framework-free work.
- See `migration-planning.md` for the full migration planning framework.

---

## 5. Maintenance & Operations

Tools for keeping PostgreSQL healthy in production.

| Tool | What It Does | Install | Key Usage | When to Reach For It |
|------|-------------|---------|-----------|---------------------|
| **pgbouncer** | Lightweight connection pooler that sits between app and PostgreSQL | `brew install pgbouncer` or Docker | Configure `pgbouncer.ini` with `pool_mode = transaction`, point app at pgbouncer port | Always — connection pooling is essential for any app with more than a handful of connections |
| **pg_repack** | Reorganizes tables and indexes online without exclusive locks | `apt install postgresql-16-repack` or build from source | `pg_repack -d mydb -t bloated_table` | Reclaiming space from bloated tables without downtime |
| **pgBackRest** | Enterprise-grade backup with incremental, parallel, and encrypted backups | `apt install pgbackrest` ([pgbackrest.org](https://pgbackrest.org)) | `pgbackrest --stanza=main backup --type=incr` | Production backup strategy; take a backup before risky migrations |
| **pgstattuple** | Reports tuple-level statistics including dead tuple ratio and free space | Built-in extension: `CREATE EXTENSION pgstattuple;` | `SELECT * FROM pgstattuple('my_table');` | Diagnosing table bloat — dead tuple ratio above 20% means vacuum isn't keeping up |
| **pg_stat_kcache** | Tracks OS-level cache and disk I/O per query (pairs with pg_stat_statements) | Extension: [github.com/powa-team/pg_stat_kcache](https://github.com/powa-team/pg_stat_kcache) | `SELECT query, reads, writes, user_time FROM pg_stat_kcache_detail;` | Distinguishing CPU-bound from I/O-bound queries |
| **vacuumdb** | CLI wrapper for VACUUM with parallel and per-table options | Built-in | `vacuumdb --analyze --jobs=4 mydb` | Scheduled maintenance or manual vacuum after bulk operations |

### Bloat Detection Quick Check

```sql
-- Using pgstattuple to check a specific table
SELECT
  table_len,
  tuple_count,
  dead_tuple_count,
  dead_tuple_percent,
  free_space,
  free_percent
FROM pgstattuple('my_table');

-- Estimate bloat across all tables (no extension needed)
SELECT
  schemaname, tablename,
  pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename)) AS total_size,
  n_dead_tup,
  n_live_tup,
  round(n_dead_tup::numeric / nullif(n_live_tup + n_dead_tup, 0) * 100, 1) AS dead_pct
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000
ORDER BY n_dead_tup DESC;
```

---

## 6. Data Generation & Testing

Tools for creating realistic test data and benchmarking.

| Tool | What It Does | Install | Key Usage | When to Reach For It |
|------|-------------|---------|-----------|---------------------|
| **pgbench** (custom scripts) | Built-in load generator with support for custom SQL scripts | Built-in | Write a custom script file, run `pgbench -f custom.sql -c 10 -T 30 mydb` | Testing specific query patterns under load |
| **Faker** (Python) | Generates realistic fake data (names, emails, addresses, dates) | `pip install faker` | `from faker import Faker; f = Faker(); f.name()` | Seeding development databases with plausible data |
| **Faker.js** (Node) | JavaScript equivalent of Python Faker | `npm install @faker-js/faker` | `import { faker } from '@faker-js/faker'; faker.person.fullName()` | Node/TypeScript projects needing seed data |
| **pg_sample** | Extracts a referentially-intact sample from a production database | `pip install pg_sample` | `pg_sample --limit="small_table=100%,*=1%" postgres:///prod > sample.sql` | Creating small dev databases that preserve FK relationships |
| **generate_series** | Built-in PostgreSQL function for generating sequences of data | Built-in | `INSERT INTO events SELECT generate_series(1,1000000), now() - (random() * interval '365 days');` | Quick bulk data generation without external tools |

### Custom pgbench Script Example

```sql
-- custom_bench.sql
\set customer_id random(1, 100000)
\set order_date random_timestamp('2020-01-01', '2024-12-31')

BEGIN;
SELECT * FROM orders WHERE customer_id = :customer_id AND created_at > :order_date;
UPDATE customers SET last_seen = now() WHERE id = :customer_id;
COMMIT;
```

```bash
# Initialize, then run with 10 clients for 60 seconds
pgbench -i -s 50 mydb
pgbench -f custom_bench.sql -c 10 -j 4 -T 60 -P 5 mydb
```

---

## 7. CLI Essentials

Daily-driver tools and techniques for working with PostgreSQL from the terminal.

### psql Power Tips

```bash
# Launch with useful defaults
psql -h localhost -d mydb -U user

# Inside psql:
\timing on              -- Show query execution time
\x auto                 -- Auto-switch to expanded display for wide rows
\pset pager off         -- Disable pager (useful in scripts)
\pset null '[NULL]'     -- Make NULLs visible
\set HISTSIZE 10000     -- Keep more history
```

#### Useful psql Shortcuts

| Command | What It Does |
|---------|-------------|
| `\dt+` | List tables with sizes |
| `\di+` | List indexes with sizes |
| `\d+ table_name` | Describe table with storage info |
| `\df+ function_name` | Describe function with source |
| `\sf function_name` | Show function source code |
| `\e` | Open last query in `$EDITOR` |
| `\watch 5` | Re-run last query every 5 seconds |
| `\copy table TO 'file.csv' CSV HEADER` | Export to CSV (client-side) |
| `\g \| less` | Pipe output through pager |

#### .psqlrc for Comfortable Defaults

```sql
-- ~/.psqlrc
\set QUIET 1
\set HISTSIZE 10000
\set HISTCONTROL ignoredups
\pset null '[NULL]'
\pset linestyle unicode
\pset border 2
\timing on
\x auto
\set QUIET 0

-- Handy shortcuts
\set slow 'SELECT pid, now() - query_start AS duration, state, query FROM pg_stat_activity WHERE state != \'idle\' ORDER BY duration DESC;'
\set locks 'SELECT pid, locktype, relation::regclass, mode, granted FROM pg_locks WHERE NOT granted;'
\set bloat 'SELECT schemaname, tablename, n_dead_tup, pg_size_pretty(pg_total_relation_size(schemaname || \'.\' || tablename)) FROM pg_stat_user_tables ORDER BY n_dead_tup DESC LIMIT 10;'
```

Usage: `:slow` runs the slow-query finder, `:locks` shows blocked locks, `:bloat` shows bloated tables.

### pgcli — Enhanced psql

| Feature | psql | pgcli |
|---------|------|-------|
| Autocomplete | Basic | Context-aware (tables, columns, keywords) |
| Syntax highlighting | No | Yes |
| Multi-line editing | Limited | Full |
| Output formatting | Basic | Auto-formatted with colors |

```bash
# Install
brew install pgcli
# or
pip install pgcli

# Use exactly like psql
pgcli -h localhost -d mydb -U user
```

**When to use pgcli vs psql**: Use pgcli for interactive exploration (the autocomplete is transformative). Use psql for scripting, `\copy`, and environments where you can't install extras.

---

## Tool Selection Quick Reference

| I need to... | Reach for |
|:-------------|:----------|
| See my schema visually | DBeaver (quick), pgModeler (thorough), dbdiagram.io (shareable) |
| Find the slowest queries | pg_stat_statements (always), pgBadger (from logs) |
| Understand a query plan | `EXPLAIN (ANALYZE, BUFFERS)` + explain.dalibo.com |
| Monitor production health | pgHero (simple), pgwatch2 (full Grafana stack), postgres_exporter (existing Prometheus) |
| Diff two schemas | migra (best), pgdiff (lightweight) |
| Pool connections | pgbouncer (always) |
| Fix table bloat | pgstattuple (diagnose), pg_repack (fix without downtime) |
| Generate test data | Faker (realistic), generate_series (bulk), pg_sample (production subset) |
| Work faster in the terminal | pgcli (interactive), .psqlrc shortcuts (scripted) |
