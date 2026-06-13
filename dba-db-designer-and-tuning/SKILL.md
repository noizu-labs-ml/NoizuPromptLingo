---
name: trl-dba-db-designer-and-tuning
description: >
  Design database schemas, optimize queries, plan migrations, and tune
  PostgreSQL, MySQL/MariaDB, and TimescaleDB performance for production
  workloads. Use this skill when the user wants to design a new database
  schema, normalize or denormalize tables, choose index strategies, analyze
  slow queries with EXPLAIN, plan a database migration across ORMs, tune
  database configuration for their workload, compare database engines, or
  optimize time-series data storage — even if they don't say "DBA" or
  "database design." Also trigger when users mention schema review, query
  performance, N+1 queries, missing indexes, migration rollback strategy,
  connection pooling, vacuum tuning, partitioning, JSONB schema design, ORM
  query optimization, InnoDB buffer pool, innodb_flush_log_at_trx_commit,
  gap locks, MySQL replication, binary log format, TimescaleDB chunks,
  hypertables, continuous aggregates, compression, time-series database
  tuning, chunk sizing, or database engine comparison.
---

# DBA — Database Designer and Tuning

Database design, schema architecture, query optimization, index strategy, migration planning, and multi-engine performance tuning (PostgreSQL, MySQL/MariaDB, TimescaleDB) for developers who wear the DBA hat.

## Overview

This skill covers the full lifecycle of database work that falls on application developers — from initial schema design through production query tuning across PostgreSQL, MySQL/MariaDB, and TimescaleDB. It provides:

- **Schema design methodology** — Phased process from requirements gathering through physical schema with validation gates at each stage
- **Indexing decision framework** — Query-pattern-driven index selection with cost/benefit analysis and maintenance impact
- **Query optimization workflow** — Systematic EXPLAIN analysis, anti-pattern detection, and rewrite strategies
- **ORM and migration guide** — Polyglot coverage of 15+ ORM/migration frameworks with real gotchas per framework
- **PostgreSQL tuning reference** — Production-tested configuration parameters, vacuum strategy, statistics tuning, and connection pooling
- **MySQL/MariaDB tuning reference** — InnoDB internals, buffer pool architecture, gap locks, flush strategies, online DDL, Performance Schema, replication
- **TimescaleDB tuning reference** — Chunk sizing, compression strategies, continuous aggregates, data lifecycle, time-series-specific PostgreSQL tuning
- **Cross-engine internals** — MVCC implementation differences, write amplification, replication models, when to use which engine
- **Worked examples** — Complete design walkthroughs demonstrating principles in realistic scenarios

## Core Philosophy

**Five Principles:**

1. **Data model first, queries second** — Get the logical model right and most query problems solve themselves; optimize only after the model is sound
2. **Normalize until it hurts, denormalize until it works** — Start in 3NF, measure actual query patterns, then selectively denormalize with documentation of why
3. **Indexes are not free** — Every index is a write-time cost, a storage cost, and a vacuum cost; justify each one against measured query patterns
4. **Migrations are contracts** — A migration is a promise to every environment that will run it; make them idempotent, reversible, and tested
5. **Measure, don't guess** — Use EXPLAIN ANALYZE, pg_stat_statements, and real workload data; intuition about database performance is wrong more often than it's right

## When to Use This Skill

- **Designing a new database schema** — Greenfield project needs a data model: requirements gathering, entity identification, normalization, physical schema generation
- **Optimizing slow queries** — Production queries are slow: EXPLAIN analysis, index recommendations, query rewrites, configuration tuning
- **Reviewing an existing schema** — Inherited codebase needs a schema audit: normalization issues, missing constraints, index coverage gaps, naming inconsistencies
- **Planning a database migration** — Changing ORMs, splitting databases, adding columns to large tables, or restructuring schemas with zero-downtime requirements
- **Choosing indexing strategy** — Need to decide between B-tree, GIN, GiST, BRIN, or partial indexes for specific query patterns
- **Tuning PostgreSQL for production** — Adjusting shared_buffers, work_mem, vacuum settings, connection pooling, or autovacuum for a specific workload profile
- **Designing JSONB schemas** — Semi-structured data in PostgreSQL: when to use JSONB vs relational, indexing strategies, query patterns
- **Debugging ORM-generated queries** — ORM producing N+1 queries, inefficient joins, or unnecessary subqueries

> For building MCP tools that interact with databases, see **trl-skill-engineer** (`references/mcp-catalog/data-and-databases.md`).
> For SEO optimization of database-related technical documentation, see **trl-seo-guru** (`kb/01-ai-seo-complete-guide.md`).
> For publishing database design tutorials and articles, see **trl-content-publishing** (`SKILL.md`).

## Database Design Process

### Phase 1: Requirements Gathering

Understand the domain, access patterns, and constraints before modeling anything.

| Activity | Output | Key Questions |
|----------|--------|---------------|
| Domain analysis | Entity list, relationship map | What are the core business objects? How do they relate? |
| Access pattern inventory | Read/write ratio, query shapes | What queries will run most? What's the read:write ratio? |
| Volume estimation | Row counts, growth projections | How many rows per table at launch? At 12 months? At 5 years? |
| Constraint identification | SLAs, compliance, consistency needs | What consistency model? Any regulatory constraints (GDPR, HIPAA)? |
| Technology constraints | DB engine, hosting, ORM | PostgreSQL version? Managed vs self-hosted? Which ORM? |

### Phase 2: Conceptual Model

Entity-relationship modeling without implementation details.

| Activity | Output | Validation |
|----------|--------|------------|
| Entity identification | Entity list with attributes | Each entity has a clear business identity and natural key candidate |
| Relationship mapping | ER diagram (1:1, 1:N, M:N) | Every relationship has cardinality and optionality documented |
| Attribute classification | Required vs optional, type hints | No attribute belongs to more than one entity |
| Aggregate boundary definition | Aggregate roots, consistency boundaries | Clear transaction boundaries identified |

### Phase 3: Logical Model

Normalize the conceptual model into relational structure.

| Activity | Output | Validation |
|----------|--------|------------|
| Normalize to 3NF | Table definitions with columns | Every non-key column depends on the key, the whole key, and nothing but the key |
| Define primary keys | PK strategy (natural, surrogate, composite) | Consistent PK strategy documented with rationale |
| Define foreign keys | FK constraints with cascade rules | Every relationship has an FK; cascade behavior explicitly chosen |
| Add check constraints | Domain constraints in DDL | Business rules encoded as constraints, not just application logic |
| Document intentional denormalization | Denormalization log | Every deviation from 3NF has a measured justification |

### Phase 4: Physical Model

PostgreSQL-specific implementation decisions.

| Activity | Output | Validation |
|----------|--------|------------|
| Data type selection | Column types (use domain types where appropriate) | No `varchar` without length rationale; timestamps are `timestamptz` |
| Index design | Initial index set | Indexes justified by Phase 1 access patterns, not speculation |
| Partitioning decisions | Partition strategy (if applicable) | Only partition tables projected to exceed 100M+ rows or with clear time-series patterns |
| Storage parameters | TOAST, fillfactor, tablespace | Defaults unless measured workload justifies otherwise |
| Naming conventions | Style guide | Consistent: `snake_case` tables, `snake_case` columns, `idx_table_columns` indexes |

### Phase 5: Validation

Verify the design against requirements before implementation.

| Check | Method | Pass Criteria |
|-------|--------|---------------|
| Query coverage | Write SQL for every access pattern from Phase 1 | Every query is expressible without full table scans on large tables |
| Constraint coverage | Map every business rule to a DB constraint | No business rule enforced only in application code that could be a constraint |
| Migration feasibility | Draft migration script | Migration is reversible and can run in under 5 minutes on projected data volume |
| Growth simulation | Project table sizes at 1yr, 3yr, 5yr | No table hits partition/index pain points within 3 years without a documented plan |
| ORM compatibility | Map schema to ORM models | Schema works with chosen ORM without fight-the-framework workarounds |

## Schema Design Patterns

| Pattern | When to Use | PostgreSQL Implementation |
|---------|-------------|--------------------------|
| **Surrogate key (UUID)** | Distributed systems, API-exposed IDs, multi-tenant | `id UUID DEFAULT gen_random_uuid() PRIMARY KEY` |
| **Surrogate key (BIGSERIAL)** | Single-database, internal IDs, high insert volume | `id BIGSERIAL PRIMARY KEY` |
| **Natural key** | Immutable domain identifiers (ISO codes, SSN where legal) | `country_code CHAR(2) PRIMARY KEY` |
| **Polymorphic association (≤5 types)** | Multiple parent types share a child table, small fixed set | Exclusive belongs-to: separate FK columns with `CHECK (num_nonnulls(post_id, ticket_id) = 1)` + partial indexes |
| **Polymorphic association (extensible)** | Memberships, notes, tags, policies attachable to any entity type; growing type set | Enum-typed dual-key poly join: `(resource_type_enum, resource_id)` with PG enums, composite indexes, stored procedures, conditional LEFT JOINs. See `schema-design-patterns.md` Option 4 |
| **EAV (Entity-Attribute-Value)** | User-defined fields, plugin systems, truly dynamic schemas | Use JSONB column instead: `attributes JSONB DEFAULT '{}'::jsonb` with GIN index |
| **Soft delete** | Audit trail, undo support, regulatory retention | `deleted_at TIMESTAMPTZ DEFAULT NULL` + partial index `WHERE deleted_at IS NULL` |
| **Temporal / history table** | Full audit trail of changes, point-in-time queries | Range-based: `valid_during TSTZRANGE` with `EXCLUDE USING gist (entity_id WITH =, valid_during WITH &&)` |
| **Multi-tenant (schema)** | Strong tenant isolation, per-tenant migrations | `CREATE SCHEMA tenant_xxx;` + `search_path` per connection |
| **Multi-tenant (row-level)** | Shared tables, simpler operations, moderate isolation | `tenant_id` FK on every table + RLS policies: `CREATE POLICY tenant_isolation ON orders USING (tenant_id = current_setting('app.tenant_id')::int)` |
| **JSONB document** | Semi-structured data, varying attributes, API payloads | `data JSONB NOT NULL` + `CREATE INDEX idx_data_gin ON t USING gin (data jsonb_path_ops)` |
| **Materialized view** | Expensive aggregations, dashboard queries, read-heavy denormalization | `CREATE MATERIALIZED VIEW mv AS SELECT ... WITH DATA;` + `REFRESH MATERIALIZED VIEW CONCURRENTLY mv;` |
| **Partitioning (range)** | Time-series data, tables >100M rows, archival requirements | `CREATE TABLE events (...) PARTITION BY RANGE (created_at);` + monthly/quarterly child tables |
| **Partitioning (list)** | Multi-tenant with partition-per-tenant, categorical splits | `PARTITION BY LIST (region)` with explicit child tables per value |
| **Enum type** | Fixed, rarely-changing value sets (status, role) | `CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'shipped', 'delivered');` — add values with `ALTER TYPE ... ADD VALUE` (non-reversible in a transaction before PG 12) |

## Indexing Strategy

### Index Type Decision Table

| Query Pattern | Recommended Index | Example | When to Avoid |
|---------------|-------------------|---------|---------------|
| Exact equality lookup (`WHERE email = ?`) | B-tree (default) | `CREATE INDEX idx_users_email ON users (email);` | Column has <100 distinct values (full scan may be faster) |
| Range scan (`WHERE created_at > ?`) | B-tree | `CREATE INDEX idx_orders_created ON orders (created_at);` | Table under 10K rows (seq scan wins) |
| Multi-column equality + range (`WHERE status = ? AND created_at > ?`) | Composite B-tree (equality columns first) | `CREATE INDEX idx_orders_status_created ON orders (status, created_at);` | If only the range column is used alone (index won't help) |
| Full-text search (`WHERE body @@ to_tsquery(?)`) | GIN on tsvector | `CREATE INDEX idx_posts_search ON posts USING gin (to_tsvector('english', body));` | Frequently updated columns (GIN rebuild is expensive) |
| JSONB containment (`WHERE data @> '{"type": "premium"}'`) | GIN with jsonb_path_ops | `CREATE INDEX idx_data ON t USING gin (data jsonb_path_ops);` | If you only query specific top-level keys (use B-tree on expression instead) |
| JSONB specific key (`WHERE data->>'status' = ?`) | B-tree on expression | `CREATE INDEX idx_data_status ON t ((data->>'status'));` | If query patterns are varied across many keys (use GIN) |
| Array containment (`WHERE tags @> ARRAY['postgres']`) | GIN | `CREATE INDEX idx_tags ON posts USING gin (tags);` | Small arrays on small tables |
| Geospatial proximity (`WHERE ST_DWithin(geom, ?, 1000)`) | GiST (with PostGIS) | `CREATE INDEX idx_geom ON locations USING gist (geom);` | Non-spatial queries on the same column |
| Large table sequential scan with high selectivity on sortable column | BRIN | `CREATE INDEX idx_events_created ON events USING brin (created_at);` | Randomly ordered data (BRIN needs physical correlation) |
| Queries that only match a subset (`WHERE status = 'active'`) | Partial index | `CREATE INDEX idx_active_orders ON orders (created_at) WHERE status = 'active';` | If the filtered subset is >50% of the table |
| Queries that need only indexed columns | Covering index (INCLUDE) | `CREATE INDEX idx_orders_cover ON orders (user_id) INCLUDE (total, status);` | Wide INCLUDE lists (bloats index, slows writes) |
| Uniqueness constraint on subset | Unique partial index | `CREATE UNIQUE INDEX idx_one_active ON subscriptions (user_id) WHERE active = true;` | If the constraint applies to all rows (use regular UNIQUE) |

### Index Maintenance Rules

| Rule | Rationale |
|------|-----------|
| Audit unused indexes quarterly | `pg_stat_user_indexes.idx_scan = 0` means the index costs writes but serves no reads |
| Avoid indexing boolean columns alone | Two distinct values = no selectivity; combine with other columns or use partial index |
| Rebuild bloated indexes | `pg_stat_user_tables.n_dead_tup` rising + `REINDEX CONCURRENTLY` in PG 12+ |
| Limit indexes per table to 8-10 max | Each index slows INSERT/UPDATE/DELETE; more than 10 suggests schema or query redesign |
| Use `CREATE INDEX CONCURRENTLY` in production | Non-concurrent index creation locks the table for writes |

## Query Optimization Workflow

### Step 1: Capture the Problem

```sql
-- Enable pg_stat_statements (must be in shared_preload_libraries)
SELECT query, calls, mean_exec_time, stddev_exec_time, rows
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 20;
```

### Step 2: Analyze with EXPLAIN

```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) SELECT ...;
```

**What to look for:**

| EXPLAIN Signal | Problem | Fix |
|----------------|---------|-----|
| `Seq Scan` on large table with filter | Missing index | Add index matching the WHERE clause |
| `Nested Loop` with high `loops` count | N+1 join pattern | Rewrite as single query with proper JOIN or use `IN (SELECT ...)` |
| `Sort` with `external merge` | `work_mem` too low for this query | Increase `work_mem` (per-session) or add index supporting the ORDER BY |
| `Hash Join` with `Batches > 1` | `work_mem` too low for hash table | Increase `work_mem` or reduce result set before join |
| `Rows Removed by Filter` >> `Rows` returned | Index not selective enough | More specific index, composite index, or partial index |
| `Index Scan` vs `Index Only Scan` | Table access required | Add INCLUDE columns to make it index-only; run VACUUM for visibility map |
| Estimated rows wildly off from actual | Stale statistics | `ANALYZE table_name;` or increase `default_statistics_target` |
| `CTE Scan` (PG < 12) | CTE materialization barrier | Rewrite as subquery or upgrade to PG 12+ (CTEs are inlined by default) |

### Step 3: Common Anti-Patterns and Rewrites

| Anti-Pattern | Problem | Rewrite |
|--------------|---------|---------|
| `SELECT *` | Fetches unused columns, prevents index-only scans | Select only needed columns |
| `WHERE UPPER(email) = UPPER(?)` | Function on column prevents index use | Create expression index: `CREATE INDEX ON t (UPPER(email));` or use `citext` type |
| `WHERE date_col BETWEEN ? AND ?` on `TIMESTAMP` | Implicit casting, wrong results with timezones | Use `timestamptz` and explicit range: `WHERE date_col >= ? AND date_col < ?` |
| `ORDER BY random() LIMIT 1` | Full table scan + sort | Use `TABLESAMPLE SYSTEM(1)` or `OFFSET floor(random() * count) LIMIT 1` |
| `COUNT(*)` on large table for existence check | Counts all rows | Use `SELECT EXISTS (SELECT 1 FROM t WHERE ...)` |
| `NOT IN (SELECT ...)` with NULLs | NULL semantics cause wrong results + poor performance | Use `NOT EXISTS (SELECT 1 FROM t2 WHERE ...)` |
| Correlated subquery in SELECT | Executes once per outer row | Rewrite as JOIN or lateral join |
| `LIKE '%term%'` | Leading wildcard prevents B-tree index use | Use `pg_trgm` GIN index: `CREATE INDEX ON t USING gin (col gin_trgm_ops);` |

## ORM & Migration Framework Guide

| Language | ORM / Migration Tool | Key Patterns | Gotchas |
|----------|---------------------|--------------|---------|
| **Elixir** | Ecto + Ecto.Migration | Changesets for validation; `Repo.preload` for associations; explicit `join` in queries | Preloads are separate queries (not JOINs) — use `join` + `select` for performance; `Ecto.Multi` for transactions; schema-less queries (`from p in "posts"`) bypass model validation |
| **Python** | SQLAlchemy + Alembic | Session unit-of-work; `relationship()` with `lazy` options; `joinedload` / `subqueryload` | Default `lazy="select"` causes N+1; `expire_on_commit=True` (default) re-fetches after commit; Alembic autogenerate misses CHECK constraints and partial indexes |
| **Python** | Django ORM + built-in migrations | `select_related` (JOIN) / `prefetch_related` (separate query); `F()` for atomic updates | `QuerySet` is lazy — chaining doesn't execute; `select_related` follows FK chains (can explode); migrations are ordered per-app — cross-app dependencies need `RunSQL` |
| **Java** | Hibernate / JPA + Flyway or Liquibase | `@Entity` mapping; JPQL; `@OneToMany(fetch = LAZY)` | `FetchType.EAGER` is the default for `@ManyToOne` — causes N+1; `LazyInitializationException` outside session; `@GeneratedValue(IDENTITY)` disables batch inserts; Flyway checksums break if you edit applied migrations |
| **PHP** | Eloquent (Laravel) + built-in migrations | `with()` for eager loading; `$casts` for type mapping; query scopes | Eloquent uses separate queries for `with()` (not JOINs); `$guarded = []` is mass-assignment vulnerability; `->get()` loads entire result set into memory; timestamps default to `TIMESTAMP` not `TIMESTAMPTZ` |
| **Node.js** | Prisma + Prisma Migrate | Declarative schema in `.prisma`; `include` / `select` for relations; `$transaction` | No raw composite types; Prisma Migrate generates non-idempotent SQL — can't re-run; implicit many-to-many creates opaque join table you can't customize; connection pool default is 5 (too low for production) |
| **Node.js** | Drizzle + drizzle-kit | SQL-like query builder; schema as TypeScript; push vs migrate modes | `push` mutates DB directly (dangerous in prod); no automatic down migrations; relations API is read-only sugar — JOINs need explicit `leftJoin` |
| **Node.js** | Sequelize + sequelize-cli | `define()` models; `belongsTo`/`hasMany` associations; `include` for eager load | `sync()` drops tables in production if misused; `include` generates LEFT JOINs that multiply rows; `paranoid: true` for soft delete doesn't scope unique constraints |
| **Node.js** | TypeORM + built-in migrations | Decorators (`@Entity`, `@Column`); QueryBuilder; `relations` in find options | `synchronize: true` in production drops columns; `eager: true` on relations causes N+1; migration generation compares entity state vs DB — drift causes spurious migrations |
| **Node.js** | Knex.js (query builder + migrations) | Fluent query builder; manual migration files; schema builder | No model layer — you manage types yourself; `knex.raw` escaping is manual; no down migration by default (you must write both `up` and `down`) |
| **Rust** | Diesel + diesel_cli migrations | Type-safe query DSL; compile-time query validation; `schema.rs` auto-generated | `schema.rs` must match DB — `diesel migration run` + `diesel print-schema`; no async (use `tokio::task::spawn_blocking`); adding nullable column requires `Option<T>` in struct |
| **Rust** | SQLx + manual migrations | Compile-time checked raw SQL; async native; `sqlx migrate run` | Compile-time checking needs a live DB connection (`DATABASE_URL`); no query builder — raw SQL only; migration files are plain SQL (you manage idempotency) |
| **Go** | GORM + AutoMigrate or goose | Struct tags for mapping; `Preload` for associations; hooks | `AutoMigrate` only adds columns, never removes or renames — use goose for real migrations; `Preload` generates separate queries; soft delete (`gorm.Model`) adds `deleted_at` index silently |
| **Go** | sqlc (code generation) | Write SQL, generate Go code; type-safe; zero runtime overhead | SQL must be PostgreSQL-dialect specific; no migration management — pair with goose or golang-migrate; no dynamic queries (all SQL is static) |
| **Go** | ent (Meta) | Graph-based schema; code generation; privacy layer | Schema is Go code, not SQL — learning curve; generated code is verbose; migration diffing can be brittle with complex edges |
| **Cross-platform** | Liquibase | XML/YAML/JSON changelogs; DB-agnostic; changelog checksums | Changelog order is immutable once applied; preconditions needed for idempotency; community edition lacks rollback generation for many change types |

## PostgreSQL Tuning Quick Reference

### Memory Configuration

| Parameter | Default | Tuning Guidance | Impact |
|-----------|---------|-----------------|--------|
| `shared_buffers` | 128MB | 25% of RAM (max ~8GB on most workloads) | Main page cache; too high steals from OS cache |
| `effective_cache_size` | 4GB | 50-75% of RAM | Planner hint only — does not allocate memory |
| `work_mem` | 4MB | 16-64MB for OLTP; higher for analytical queries | Per-sort/hash operation — multiply by `max_connections` for worst case |
| `maintenance_work_mem` | 64MB | 256MB-1GB | Used by VACUUM, CREATE INDEX, ALTER TABLE |
| `huge_pages` | try | `on` if OS supports it (Linux: `vm.nr_hugepages`) | Reduces TLB misses; significant for large `shared_buffers` |

### Autovacuum Tuning

| Parameter | Default | When to Change |
|-----------|---------|----------------|
| `autovacuum_vacuum_scale_factor` | 0.2 | Lower (0.01-0.05) for large tables — default waits until 20% dead tuples |
| `autovacuum_vacuum_threshold` | 50 | Raise for tiny tables that churn (avoid constant vacuuming) |
| `autovacuum_max_workers` | 3 | Increase to 5-6 if autovacuum can't keep up (check `pg_stat_user_tables.n_dead_tup`) |
| `autovacuum_vacuum_cost_delay` | 2ms | Lower (0-1ms) if vacuum is falling behind and I/O headroom exists |
| `autovacuum_naptime` | 1min | Lower if tables need more frequent vacuum checks |

Per-table override for hot tables:

```sql
ALTER TABLE hot_table SET (
    autovacuum_vacuum_scale_factor = 0.01,
    autovacuum_analyze_scale_factor = 0.005
);
```

### Statistics and Planner

| Parameter | Default | Tuning Guidance |
|-----------|---------|-----------------|
| `default_statistics_target` | 100 | Increase to 500-1000 for columns with skewed distributions |
| `random_page_cost` | 4.0 | Lower to 1.1-1.5 for SSD storage (matches sequential cost) |
| `effective_io_concurrency` | 1 | Set to 200 for SSD; adjusts bitmap heap scan prefetch |
| `jit` | on (PG 12+) | Disable (`off`) if short OLTP queries dominate — JIT overhead exceeds benefit |
| `plan_cache_mode` | auto | Set to `force_custom_plan` if prepared statement plan caching produces bad plans |

### Connection Pooling

| Tool | Use Case | Key Config |
|------|----------|------------|
| **PgBouncer** | Connection pooling for high-concurrency apps | `pool_mode = transaction` for most apps; `pool_size` = 2-4x CPU cores |
| **pgpool-II** | Pooling + read replicas + load balancing | More complex; use PgBouncer if you only need pooling |
| **Application pool** | ORM built-in pool (Ecto, SQLAlchemy, HikariCP) | Set `pool_size` based on: `connections = (2 * CPU cores) + disk spindles` |

**Rule of thumb:** PostgreSQL handles ~200-300 active connections well. Beyond that, use PgBouncer in transaction mode.

### Essential Monitoring Queries

```sql
-- Active queries running longer than 5 seconds
SELECT pid, now() - pg_stat_activity.query_start AS duration, query, state
FROM pg_stat_activity
WHERE state != 'idle' AND now() - pg_stat_activity.query_start > interval '5 seconds'
ORDER BY duration DESC;

-- Table bloat candidates
SELECT schemaname, relname, n_dead_tup, n_live_tup,
       round(n_dead_tup::numeric / greatest(n_live_tup, 1) * 100, 1) AS dead_pct,
       last_autovacuum
FROM pg_stat_user_tables
WHERE n_dead_tup > 10000
ORDER BY n_dead_tup DESC;

-- Unused indexes (candidates for removal)
SELECT schemaname, relname, indexrelname, idx_scan, pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes
WHERE idx_scan = 0 AND schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_relation_size(indexrelid) DESC;

-- Cache hit ratio (should be >99% for OLTP)
SELECT sum(heap_blks_hit) / greatest(sum(heap_blks_hit) + sum(heap_blks_read), 1) AS ratio
FROM pg_statio_user_tables;
```

## Quick Start Guides

### Design a New Schema

1. Inventory access patterns: list every query the application will run (read [requirements gathering](#phase-1-requirements-gathering))
2. Identify entities and relationships: draw an ER diagram (read [schema-design-patterns.md](references/schema-design-patterns.md))
3. Normalize to 3NF, then selectively denormalize (read [schema-design-patterns.md](references/schema-design-patterns.md))
4. Choose PK strategy, FK cascades, and constraints (read [worked-example-ecommerce-schema.md](references/worked-example-ecommerce-schema.md))
5. Design initial indexes based on access patterns (read [indexing-strategy.md](references/indexing-strategy.md))
6. Validate by writing SQL for every access pattern from step 1
7. Draft migration using your ORM (read [orm-framework-guide.md](references/orm-framework-guide.md))
8. Run the [schema-review-checklist.md](assets/schema-review-checklist.md) before merging

### Optimize Slow Queries

1. Identify the slow queries via `pg_stat_statements` or application logs
2. Run `EXPLAIN (ANALYZE, BUFFERS)` on each (read [query-optimization.md](references/query-optimization.md))
3. Check for anti-patterns in the Query Optimization Workflow above
4. Check index coverage against [indexing-strategy.md](references/indexing-strategy.md)
5. Check PostgreSQL config against [postgresql-tuning.md](references/postgresql-tuning.md)
6. Apply fixes and re-measure with `EXPLAIN ANALYZE`
7. Document findings in [query-audit-template.md](assets/query-audit-template.md)

### Review an Existing Schema

1. Export the schema: `pg_dump --schema-only dbname > schema.sql`
2. Run through [schema-review-checklist.md](assets/schema-review-checklist.md)
3. Check naming conventions, constraint coverage, index usage
4. Cross-reference with [schema-design-patterns.md](references/schema-design-patterns.md)
5. Identify unused indexes via `pg_stat_user_indexes`
6. Document findings and prioritize fixes

### Plan a Migration

1. Document current state and target state
2. Identify breaking changes (column renames, type changes, dropped columns)
3. Plan for zero-downtime: additive changes first, then backfill, then remove old (read [migration-planning.md](references/migration-planning.md))
4. Check ORM-specific gotchas in [orm-framework-guide.md](references/orm-framework-guide.md)
5. Write and test rollback scripts
6. Estimate migration duration on production data volume
7. Track progress in [project-tracker.md](assets/project-tracker.md)

## Reference Guide

### When to Read Each Reference

| Task | Read These |
|------|-----------|
| **Starting a new schema** | `schema-design-patterns.md`, `worked-example-ecommerce-schema.md` |
| **Choosing indexes** | `indexing-strategy.md` |
| **Fixing slow queries (PostgreSQL)** | `query-optimization.md`, `postgresql-tuning.md` |
| **Fixing slow queries (MySQL)** | `mysql-query-optimization.md`, `mysql-tuning.md` |
| **Choosing indexes (MySQL)** | `mysql-indexing-strategy.md` |
| **Tuning PostgreSQL** | `postgresql-tuning.md`, `tools-and-utilities.md` |
| **Tuning MySQL / MariaDB** | `mysql-tuning.md` |
| **Tuning TimescaleDB** | `timescaledb-tuning.md`, `postgresql-tuning.md` (base PG settings) |
| **Choosing between engines** | `engine-internals-compared.md` |
| **Understanding MVCC / write amplification** | `engine-internals-compared.md` |
| **Planning a migration** | `migration-planning.md`, `orm-framework-guide.md` |
| **Migrating to TimescaleDB** | `worked-example-timescale-migration.md`, `timescaledb-tuning.md` |
| **Choosing/configuring an ORM** | `orm-framework-guide.md` |
| **Connection pooling** | `connection-pooling.md` |
| **MySQL tools and diagnostics** | `mysql-tools-and-utilities.md` |
| **Running a schema audit** | `schema-design-patterns.md` + `assets/schema-review-checklist.md` |
| **Full design walkthrough** | `worked-example-ecommerce-schema.md` |
| **Agent integration** | `agent-playbook.claude-code.md` |

All reference paths are relative to `references/` unless prefixed with `assets/`.

## Related Skills

- **trl-skill-engineer** — Meta-skill for designing, building, and validating new skills; includes the MCP/tool catalog with database tooling
- **trl-content-publishing** — Write database design tutorials, migration guides, and PostgreSQL optimization articles
- **trl-seo-guru** — Optimize technical database documentation for search engines and AI answer engines
- **trl-mcp-builder** — Build MCP tools that interact with databases for schema introspection or query analysis
- **trl-user-experience-engineer** — Design admin dashboards and database management UIs

## Bundled Resources

### References

**Core Design** (read first for schema work):
- [schema-design-patterns.md](references/schema-design-patterns.md) — Normalization, denormalization, PK strategies, JSONB schemas, multi-tenancy, temporal tables, and PostgreSQL-specific patterns
- [indexing-strategy.md](references/indexing-strategy.md) — Index type selection, composite index design, partial indexes, covering indexes, maintenance and monitoring

**Optimization** (read for performance work):
- [query-optimization.md](references/query-optimization.md) — EXPLAIN analysis methodology, anti-pattern catalog with rewrites, join strategies, subquery optimization, CTE vs subquery decisions
- [postgresql-tuning.md](references/postgresql-tuning.md) — Memory, vacuum, statistics, planner, WAL, connection pooling configuration with workload-specific recommendations
- [mysql-tuning.md](references/mysql-tuning.md) — InnoDB architecture (clustered index, buffer pool, adaptive hash index), transaction isolation and gap locks, flush strategies, I/O tuning, online DDL truth table, optimizer secrets (invisible indexes, histograms, optimizer trace), replication internals (binlog format, GTIDs, semi-sync), Performance Schema and sys schema, MariaDB divergences
- [mysql-indexing-strategy.md](references/mysql-indexing-strategy.md) — Clustered index implications on secondary indexes, PK choice impact, index type comparison (B+tree, FULLTEXT, SPATIAL), composite index design with key_len analysis, missing features and workarounds (no partial indexes, no INCLUDE, no GIN/GiST/BRIN), invisible indexes for safe auditing, prefix indexes, multi-valued indexes for JSON arrays, optimizer hints for index selection, index maintenance and fragmentation, design patterns (soft delete, job queue, multi-tenant, covering index)
- [mysql-query-optimization.md](references/mysql-query-optimization.md) — EXPLAIN three formats (tabular, TREE, ANALYZE), access type hierarchy, Extra column decoded, MySQL-specific anti-patterns (implicit type conversion, subquery materialization vs merging, GROUP BY implicit sorting removal in 8.0), join optimization (hash join 8.0.18+, no merge join), optimizer trace deep debugging, Performance Schema diagnostic queries, common tuning scenarios, MySQL vs PostgreSQL capability comparison
- [timescaledb-tuning.md](references/timescaledb-tuning.md) — Chunk sizing internals, INSERT routing path, compression (segmentby/orderby decisions, ratio expectations), continuous aggregates (real-time mode, hierarchical CAggs, refresh/retention interaction), per-chunk index strategy, PostgreSQL tuning overrides for time-series, chunk exclusion mechanics, data lifecycle policies, background worker tuning
- [engine-internals-compared.md](references/engine-internals-compared.md) — MVCC implementation differences (PG heap+vacuum vs InnoDB undo logs), write amplification analysis, connection architecture (process vs thread), checkpoint mechanics, replication models, engine selection decision matrix

**Migration & ORM**:
- [migration-planning.md](references/migration-planning.md) — Zero-downtime migration strategies, large table alterations, data backfill patterns, rollback planning, environment coordination
- [orm-framework-guide.md](references/orm-framework-guide.md) — Deep dive into 15+ ORM/migration frameworks: Ecto, SQLAlchemy, Django, Hibernate, Eloquent, Prisma, Drizzle, Sequelize, TypeORM, Knex, Diesel, SQLx, GORM, sqlc, ent, Liquibase

**Connection Pooling** (cross-engine):
- [connection-pooling.md](references/connection-pooling.md) — PgBouncer deep dive (transaction/session/statement modes, pool sizing formula, auth, monitoring), ProxySQL deep dive (multiplexing, read/write split, query caching/firewall, health checks), application-level pooling (HikariCP, SQLAlchemy, Ecto, Prisma), pool sizing with Little's Law, decision matrix for 14 common scenarios

**Tools & Examples**:
- [tools-and-utilities.md](references/tools-and-utilities.md) — pgcli, pg_stat_statements, pgBadger, pg_repack, pgbench, and other essential PostgreSQL tools
- [mysql-tools-and-utilities.md](references/mysql-tools-and-utilities.md) — pt-query-digest, mysqltuner, sys schema views, Performance Schema, gh-ost, pt-online-schema-change, pt-archiver, orchestrator, ProxySQL, MySQL Shell, mysqlbinlog, PMM, innotop, pt-stalk, pt-kill, sysbench, mysqlslap — 18 tools with PG equivalent comparisons
- [worked-example-ecommerce-schema.md](references/worked-example-ecommerce-schema.md) — End-to-end schema design walkthrough: requirements through physical model for an e-commerce domain
- [worked-example-timescale-migration.md](references/worked-example-timescale-migration.md) — End-to-end 500M-row PostgreSQL to TimescaleDB migration: assessment, side-by-side migration (avoiding the exclusive lock trap), compression setup, continuous aggregates, retention policies, rollback at every stage, 6 war stories

**Agent Integration**:
- [agent-playbook.claude-code.md](references/agent-playbook.claude-code.md) — Agent role definition, execution workflows and decision trees for PostgreSQL schema review/query optimization/migration planning, MySQL slow query diagnosis, TimescaleDB performance diagnosis, and database engine selection

### Assets

- [project-tracker.md](assets/project-tracker.md) — Database project tracker for monitoring schema design and migration progress
- [schema-review-checklist.md](assets/schema-review-checklist.md) — Pre-merge schema audit checklist: naming, constraints, indexes, types, documentation
- [query-audit-template.md](assets/query-audit-template.md) — Template for documenting slow query analysis: EXPLAIN output, root cause, fix, before/after metrics
