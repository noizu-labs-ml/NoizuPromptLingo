# Schema Review Checklist

## Review Metadata
- **Database**: {name, version}
- **Application**: {project name}
- **Reviewer**: {name}
- **Date**: {YYYY-MM-DD}
- **Schema Version**: {migration ID or timestamp}
- **Verdict**: Pass / Pass with Notes / Fail -- Revisions Required

---

## Naming Conventions

- [ ] **Table names follow a consistent singular/plural convention** -- Mixed conventions cause confusion across teams and ORMs; pick one and enforce it project-wide.
- [ ] **Column names use snake_case and are descriptive** -- Abbreviations like `usr_nm` rot; `user_name` is searchable, readable, and self-documenting.
- [ ] **Foreign key columns follow `{referenced_table}_id` pattern** -- Consistent FK naming makes joins predictable and schema diagrams readable without cross-referencing.
- [ ] **Index names follow `idx_{table}_{columns}` pattern** -- Named indexes are findable in `pg_stat_user_indexes` and debuggable in EXPLAIN output; auto-generated names are not.
- [ ] **Constraint names follow `{table}_{type}_{columns}` pattern** -- When a constraint violation fires, the error message includes the name; `chk_orders_amount_positive` tells you the problem, `orders_check` does not.

## Data Types

- [ ] **Columns use the most specific applicable type** -- `INTEGER` where a number is needed, `BOOLEAN` where true/false, `DATE` where date-only; avoids implicit cast costs and invalid data.
- [ ] **TEXT is not used as a catch-all when a constrained type fits** -- Unbounded TEXT columns bypass validation; use `VARCHAR(n)`, enum types, or CHECK constraints to enforce domain rules at the DB level.
- [ ] **All timestamps include timezone (`TIMESTAMPTZ`)** -- `TIMESTAMP` without timezone silently drops tz info on insert, causing subtle bugs when servers or clients span zones.
- [ ] **Primary key type choice (UUID vs SERIAL/BIGSERIAL) is intentional and documented** -- UUIDs add 2x storage overhead and worse index locality; SERIALs leak row counts and don't merge across databases. The tradeoff must be explicit.
- [ ] **Enum vs lookup table decision is justified for each enumerated column** -- PG enums are fast but painful to alter (no value removal before PG 14, requires migration); lookup tables are flexible but add joins.
- [ ] **JSONB columns have documented schemas and are justified over relational columns** -- JSONB bypasses constraint enforcement, makes indexing expensive, and hides structure; use it for truly semi-structured data, not to avoid migrations.

## Constraints

- [ ] **Every table has a primary key** -- Tables without PKs cannot be efficiently updated, deleted, or replicated; logical replication explicitly requires them.
- [ ] **All relationships have foreign key constraints** -- Without FKs, the database cannot prevent orphan rows; application-level enforcement is insufficient because not all writes go through the app.
- [ ] **NOT NULL is applied to every column that should always have a value** -- NULL semantics are tricky (NULL != NULL, NULL in aggregates); defaulting to NOT NULL and opting in to nullability prevents accidental data gaps.
- [ ] **CHECK constraints enforce domain rules for bounded values** -- `CHECK (amount >= 0)`, `CHECK (status IN ('active','inactive'))` catches bad data at write time, not in a post-mortem.
- [ ] **Unique constraints exist for all natural keys and business identifiers** -- Without them, duplicate emails, duplicate order numbers, or duplicate slugs silently enter the system and corrupt downstream logic.
- [ ] **ON DELETE behavior prevents orphaned records** -- `ON DELETE CASCADE` vs `RESTRICT` vs `SET NULL` must be an explicit choice; the default (`NO ACTION`) silently defers the check to end-of-transaction, which surprises most developers.

## Indexes

- [ ] **All foreign key columns are indexed** -- PG does not auto-index FKs; unindexed FKs cause sequential scans on the child table during parent deletes and JOIN operations.
- [ ] **Indexes exist for common query patterns (WHERE, ORDER BY, JOIN)** -- Missing indexes force sequential scans; each high-frequency query path should have a supporting index identified during design.
- [ ] **No redundant indexes exist** -- An index on `(a, b)` already covers queries on `(a)`; a separate index on `(a)` wastes write I/O, storage, and vacuum time.
- [ ] **Partial indexes are considered for filtered queries** -- `CREATE INDEX idx_orders_pending ON orders(created_at) WHERE status = 'pending'` is smaller, faster, and cheaper to maintain than a full index when most rows don't match.
- [ ] **Covering indexes (INCLUDE) are used where beneficial** -- `CREATE INDEX idx_users_email ON users(email) INCLUDE (name)` satisfies index-only scans without hitting the heap, eliminating a table lookup per row.

## Normalization

- [ ] **Schema meets 3NF as a baseline** -- Normalization prevents update anomalies (changing a value in one place but not another); 3NF is the minimum bar for OLTP schemas.
- [ ] **Any denormalization is explicitly justified and documented** -- Denormalized columns drift out of sync; if you denormalize for performance, document the source of truth and the sync mechanism.
- [ ] **No repeated groups (arrays of columns like `phone1`, `phone2`, `phone3`)** -- Repeated groups cap cardinality, waste space on sparse rows, and make queries painful; use a child table.
- [ ] **No transitive dependencies (non-key column depending on another non-key column)** -- If `zip_code` determines `city`, storing both in the same table means updating a zip requires updating the city too; extract to a reference table.

## Security

- [ ] **Row-Level Security (RLS) is enabled if the schema serves multiple tenants** -- Without RLS, a single missing WHERE clause in any query leaks data across tenants; RLS enforces isolation at the database level regardless of application bugs.
- [ ] **Sensitive data columns are identified and access-controlled** -- PII, credentials, health data, and financial data should be inventoried; column-level privileges or view-based access restricts exposure.
- [ ] **No secrets, API keys, or credentials are stored as plain-text columns** -- Secrets in the database leak through backups, replicas, and query logs; use a secrets manager or at minimum encrypt at rest with application-level keys.
- [ ] **Audit columns (`created_at`, `updated_at`, `created_by`) are present on mutable tables** -- Without audit columns, you cannot answer "who changed this and when," which is the first question in every incident investigation.

## Performance

- [ ] **Table partitioning is considered for tables expected to exceed 10M rows** -- Partition pruning eliminates scanning irrelevant data; large unpartitioned tables cause slow sequential scans, painful vacuums, and index bloat.
- [ ] **No "god tables" with 30+ columns mixing concerns** -- Wide tables increase I/O per row fetch (even for queries needing 2 columns), complicate indexing, and signal a modeling problem; split by access pattern.
- [ ] **JSONB is not used as a substitute for relational modeling** -- JSONB queries require GIN indexes (expensive to maintain) and cannot enforce NOT NULL, FK, or CHECK constraints; overuse turns the database into a document store without document store ergonomics.
- [ ] **ON DELETE behavior is appropriate for table sizes** -- `CASCADE` on a parent with millions of children causes long-running deletes and lock contention; consider soft deletes or batch cleanup for large tables.
- [ ] **Connection pooling is configured (PgBouncer / application pool)** -- Each PG connection costs ~10MB of RAM; without pooling, connection storms cause OOM kills and max_connections exhaustion, taking down the entire database.

---

## Summary

| Category | Pass | Fail | N/A | Notes |
|----------|------|------|-----|-------|
| Naming Conventions | /5 | /5 | /5 | |
| Data Types | /6 | /6 | /6 | |
| Constraints | /6 | /6 | /6 | |
| Indexes | /5 | /5 | /5 | |
| Normalization | /4 | /4 | /4 | |
| Security | /4 | /4 | /4 | |
| Performance | /5 | /5 | /5 | |
| **Total** | **/35** | **/35** | **/35** | |

## Action Items

| # | Category | Item | Priority | Owner | Due |
|---|----------|------|----------|-------|-----|
| 1 | -- | -- | Critical / High / Medium / Low | -- | -- |
