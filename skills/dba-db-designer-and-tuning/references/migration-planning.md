# Migration Planning and Execution

> A PostgreSQL-first reference for planning, executing, and rolling back database migrations without breaking production. Covers raw SQL migrations, ORM tooling, zero-downtime patterns, and the hard-won knowledge that "it worked on staging" is not a deployment strategy.

---

## Table of Contents

1. [Migration Risk Assessment](#migration-risk-assessment)
2. [Safe DDL Operations in PostgreSQL](#safe-ddl-operations-in-postgresql)
3. [Migration Strategies](#migration-strategies)
   - [Direct DDL](#direct-ddl)
   - [Expand-Contract](#expand-contract)
   - [Shadow Table](#shadow-table)
   - [Online Schema Migration](#online-schema-migration)
   - [Blue-Green Database](#blue-green-database)
4. [Data Backfill Patterns](#data-backfill-patterns)
5. [Zero-Downtime Migration Checklist](#zero-downtime-migration-checklist)
6. [Rollback Planning](#rollback-planning)
7. [ORM Migration Tooling](#orm-migration-tooling)
8. [Migration Testing](#migration-testing)

---

## Migration Risk Assessment

Every migration has a risk profile. The mistake is treating a 500M-row table rewrite the same as adding a nullable column. Assess before you execute.

### Risk Factor Matrix

| Factor | Low Risk | Medium Risk | High Risk |
|--------|----------|-------------|-----------|
| **Table size** | < 100K rows | 100K - 10M rows | > 10M rows |
| **Lock duration** | No lock or `ACCESS SHARE` | Brief `ROW EXCLUSIVE` | `ACCESS EXCLUSIVE` for > 1s on a hot table |
| **Data transformation** | None (structural DDL only) | Type coercion or default backfill | Complex data reshaping, cross-table joins |
| **Rollback difficulty** | Trivially reversible (`DROP COLUMN`) | Reversible with data preservation effort | Irreversible without backup (destructive type change, column drop with data loss) |
| **Application coupling** | No app code change needed | App tolerates old + new schema (deploy order flexible) | App and schema must change atomically (deploy coordination required) |
| **Downtime tolerance** | Maintenance window available | Minutes acceptable, not hours | Zero downtime required (SLA, revenue loss) |
| **Replication lag sensitivity** | No replicas, or replicas tolerate lag | Read replicas may serve stale schema briefly | Synchronous replication or logical replication that must stay in sync |
| **Concurrent write volume** | Low-traffic table or off-peak | Moderate steady writes | High-throughput OLTP table under constant load |

### Scoring

Assign each factor a score: Low = 1, Medium = 2, High = 3. Sum the scores.

| Total Score | Risk Level | Approach |
|-------------|------------|----------|
| 8-11 | **Low** | Direct DDL in a migration file. Standard deploy. |
| 12-16 | **Medium** | Expand-contract or batched backfill. Test on staging with production-sized data. |
| 17-24 | **High** | Shadow table, online schema migration, or blue-green. Dedicated migration plan with rollback script. Stakeholder sign-off. |

### Pre-Migration Checklist

Before writing a single line of DDL:

1. **What is the table size?** `SELECT pg_size_pretty(pg_total_relation_size('my_table'));`
2. **What is the row count?** `SELECT reltuples::bigint FROM pg_class WHERE relname = 'my_table';` (fast estimate, not `COUNT(*)`)
3. **What locks will this acquire?** Check the [DDL operations table](#safe-ddl-operations-in-postgresql) below.
4. **Are there dependent views, triggers, or foreign keys?** They may block or break.
5. **What is the current write rate?** `SELECT * FROM pg_stat_user_tables WHERE relname = 'my_table';` — check `n_tup_ins`, `n_tup_upd`, `n_tup_del`.
6. **Is there a rollback plan?** If the answer is "restore from backup," your plan is incomplete.

---

## Safe DDL Operations in PostgreSQL

Not all `ALTER TABLE` is created equal. Some operations are metadata-only (instant). Some acquire heavy locks. Some rewrite the entire table to disk. Knowing which is which is the difference between a 5ms migration and a 45-minute outage.

### Operation Reference

| Operation | Lock Type | Duration | Rewrites Table? | Notes |
|-----------|-----------|----------|-----------------|-------|
| `ADD COLUMN` (nullable, no default) | `ACCESS EXCLUSIVE` | **Instant** (metadata only) | No | Safe on any table size. Lock is brief. |
| `ADD COLUMN ... DEFAULT x` (PG 11+) | `ACCESS EXCLUSIVE` | **Instant** (metadata only) | No | PG 11+ stores default in catalog, backfills on read. The big win. |
| `ADD COLUMN ... DEFAULT x` (PG < 11) | `ACCESS EXCLUSIVE` | **Proportional to table size** | **Yes** | Rewrites every row. Avoid on large tables. |
| `ADD COLUMN ... NOT NULL DEFAULT x` (PG 11+) | `ACCESS EXCLUSIVE` | **Instant** | No | Combines fast default + catalog-level NOT NULL. Safe. |
| `DROP COLUMN` | `ACCESS EXCLUSIVE` | **Instant** (metadata only) | No | Marks column as dropped. Space reclaimed on next VACUUM FULL or rewrite. |
| `ALTER COLUMN SET NOT NULL` | `ACCESS EXCLUSIVE` | **Full table scan** | No | Scans every row to verify no NULLs exist. On 100M rows, this is minutes. |
| `ALTER COLUMN DROP NOT NULL` | `ACCESS EXCLUSIVE` | **Instant** | No | Metadata-only. |
| `ALTER COLUMN SET DEFAULT` | `ACCESS EXCLUSIVE` | **Instant** | No | Changes default for future inserts only. Does not backfill. |
| `ALTER COLUMN TYPE` (same physical storage) | `ACCESS EXCLUSIVE` | **Instant** | No | E.g., `varchar(50)` → `varchar(100)`, `varchar(n)` → `text`. |
| `ALTER COLUMN TYPE` (different storage) | `ACCESS EXCLUSIVE` | **Proportional to table size** | **Yes** | E.g., `integer` → `bigint`, `text` → `integer`. Full table rewrite. |
| `ADD CONSTRAINT ... CHECK` | `ACCESS EXCLUSIVE` | **Full table scan** | No | Validates all existing rows. |
| `ADD CONSTRAINT ... CHECK NOT VALID` | `ACCESS EXCLUSIVE` | **Instant** | No | Skips validation. Enforced on new writes only. |
| `VALIDATE CONSTRAINT` | `SHARE UPDATE EXCLUSIVE` | **Full table scan** | No | Validates existing rows without blocking writes. The safe two-step pattern. |
| `ADD CONSTRAINT ... FOREIGN KEY` | `SHARE ROW EXCLUSIVE` (both tables) | **Full scan of referencing table** | No | Locks both tables. Use `NOT VALID` + `VALIDATE` for large tables. |
| `DROP CONSTRAINT` | `ACCESS EXCLUSIVE` | **Instant** | No | |
| `RENAME COLUMN` | `ACCESS EXCLUSIVE` | **Instant** | No | But breaks any application code using the old name. |
| `RENAME TABLE` | `ACCESS EXCLUSIVE` | **Instant** | No | Breaks all queries referencing the old name. |
| `CREATE INDEX` | `SHARE` | **Proportional to table size** | No | **Blocks writes** for the entire build duration. |
| `CREATE INDEX CONCURRENTLY` | None (effectively) | **Proportional to table size** | No | Does not block writes. Takes ~2-3x longer. Can fail and leave an invalid index. |
| `DROP INDEX` | `ACCESS EXCLUSIVE` | **Instant** | No | |
| `DROP INDEX CONCURRENTLY` | None (effectively) | **Instant** | No | Does not block reads/writes during drop. |
| `ATTACH PARTITION` (PG 11+) | `SHARE UPDATE EXCLUSIVE` | Constraint validation scan | No | If the partition has a matching CHECK constraint, scan is skipped (PG 11+). |

### Lock Compatibility Quick Reference

| Lock | Blocks Reads? | Blocks Writes? | Blocks DDL? |
|------|:-------------:|:--------------:|:-----------:|
| `ACCESS SHARE` | No | No | No |
| `ROW SHARE` | No | No | Some |
| `ROW EXCLUSIVE` | No | No | Some |
| `SHARE UPDATE EXCLUSIVE` | No | No | Yes |
| `SHARE` | No | **Yes** | Yes |
| `SHARE ROW EXCLUSIVE` | No | **Yes** | Yes |
| `EXCLUSIVE` | No | **Yes** | Yes |
| `ACCESS EXCLUSIVE` | **Yes** | **Yes** | **Yes** |

**Key insight**: `ACCESS EXCLUSIVE` blocks everything, but if the operation is metadata-only, the lock is held for microseconds. The danger is when `ACCESS EXCLUSIVE` is held during a table rewrite or full scan — that's when queries queue up and your application stalls.

### The Lock Queue Problem

PostgreSQL locks are queued. If your `ALTER TABLE` is waiting for an `ACCESS EXCLUSIVE` lock behind a long-running query, **every subsequent query also waits**. This cascading queue is how a "quick" migration takes down production.

**Mitigation:**

```sql
-- Set a lock timeout so you fail fast instead of queueing
SET lock_timeout = '5s';

-- Your DDL here
ALTER TABLE orders ADD COLUMN tracking_number text;

-- Reset
RESET lock_timeout;
```

If it times out, retry during lower traffic or kill the blocking query (after confirming it's safe to do so).

```sql
-- Find blocking queries
SELECT pid, now() - pg_stat_activity.query_start AS duration, query, state
FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > interval '30 seconds'
  AND state != 'idle'
ORDER BY duration DESC;
```

---

## Migration Strategies

### Direct DDL

The simplest approach. Run `ALTER TABLE` directly in a migration file. Use when the [risk assessment](#migration-risk-assessment) scores Low.

**When safe:**
- Adding a nullable column (any table size)
- Adding a column with a default (PG 11+, any table size)
- Dropping a column (after confirming no application code references it)
- Creating an index concurrently
- Adding a `NOT VALID` constraint

**When unsafe:**
- Any operation that rewrites the table on a table with > 1M rows
- Any operation acquiring `ACCESS EXCLUSIVE` for more than a few seconds on a table with active traffic
- Any operation that requires coordinated application changes

```sql
-- Safe: adding a nullable column with default (PG 11+)
ALTER TABLE orders ADD COLUMN fulfillment_status text DEFAULT 'pending';

-- Safe: concurrent index
CREATE INDEX CONCURRENTLY idx_orders_fulfillment ON orders (fulfillment_status);

-- Safe: two-step constraint
ALTER TABLE orders ADD CONSTRAINT chk_fulfillment_status
  CHECK (fulfillment_status IN ('pending', 'processing', 'shipped', 'delivered'))
  NOT VALID;

VALIDATE CONSTRAINT chk_fulfillment_status;
```

---

### Expand-Contract

The workhorse pattern for zero-downtime schema changes. You expand the schema (add new), migrate data, switch the application, then contract (remove old).

**Use when:** You need to rename a column, change a column type, split/merge columns, or restructure data — and you can't tolerate downtime.

#### Step-by-Step: Renaming a Column

Scenario: Rename `orders.shipping_address` → `orders.delivery_address` on a table with 20M rows, zero downtime required.

**Phase 1: Expand** (Migration 1 — deploy independently of app changes)

```sql
-- Add the new column
ALTER TABLE orders ADD COLUMN delivery_address text;

-- Create a trigger to dual-write during the transition
CREATE OR REPLACE FUNCTION sync_delivery_address()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    IF NEW.delivery_address IS NULL AND NEW.shipping_address IS NOT NULL THEN
      NEW.delivery_address := NEW.shipping_address;
    END IF;
    IF NEW.shipping_address IS NULL AND NEW.delivery_address IS NOT NULL THEN
      NEW.shipping_address := NEW.delivery_address;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sync_delivery_address
  BEFORE INSERT OR UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION sync_delivery_address();
```

**Phase 2: Backfill** (Run as a batched job — see [Data Backfill Patterns](#data-backfill-patterns))

```sql
-- Backfill in batches
UPDATE orders
SET delivery_address = shipping_address
WHERE delivery_address IS NULL
  AND id BETWEEN $start AND $end;
```

**Phase 3: Switch reads** (Application deploy — read from new column, write to both)

Deploy application code that reads from `delivery_address`. The trigger keeps both columns in sync, so this deploy is safe regardless of timing.

**Phase 4: Contract** (Migration 2 — after confirming all reads use the new column)

```sql
-- Drop the sync trigger
DROP TRIGGER trg_sync_delivery_address ON orders;
DROP FUNCTION sync_delivery_address();

-- Drop the old column
ALTER TABLE orders DROP COLUMN shipping_address;
```

**Timeline:**
- Phase 1: Deploy anytime
- Phase 2: Run immediately after, takes minutes to hours depending on table size
- Phase 3: Deploy when backfill is complete
- Phase 4: Deploy after Phase 3 has been stable for a comfort period (hours to days)

---

### Shadow Table

Create a new table with the desired schema, dual-write to both, backfill the new table, then swap.

**Use when:**
- Major schema restructuring (normalizing a denormalized table, changing primary key structure)
- The change is too complex for expand-contract
- You need to change column types that require a full rewrite anyway
- You want to rebuild indexes and reclaim space simultaneously

#### Step-by-Step: Changing a Primary Key from `integer` to `bigint`

```sql
-- 1. Create the shadow table with desired schema
CREATE TABLE orders_new (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id bigint NOT NULL,
  total numeric(12,2),
  created_at timestamptz DEFAULT now()
  -- ... all columns with new types
);

-- 2. Create indexes on the shadow table (while it's empty, this is fast)
CREATE INDEX idx_orders_new_customer ON orders_new (customer_id);
CREATE INDEX idx_orders_new_created ON orders_new (created_at);

-- 3. Set up dual-write trigger on the original table
CREATE OR REPLACE FUNCTION replicate_to_orders_new()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO orders_new (id, customer_id, total, created_at)
    OVERRIDING SYSTEM VALUE
    VALUES (NEW.id, NEW.customer_id, NEW.total, NEW.created_at);
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE orders_new SET
      customer_id = NEW.customer_id,
      total = NEW.total,
      created_at = NEW.created_at
    WHERE id = NEW.id;
  ELSIF TG_OP = 'DELETE' THEN
    DELETE FROM orders_new WHERE id = OLD.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_replicate_orders
  AFTER INSERT OR UPDATE OR DELETE ON orders
  FOR EACH ROW EXECUTE FUNCTION replicate_to_orders_new();

-- 4. Backfill historical data (see Data Backfill Patterns)
-- This runs concurrently with the trigger catching new writes.
-- Use INSERT ... ON CONFLICT to handle overlaps.

INSERT INTO orders_new (id, customer_id, total, created_at)
OVERRIDING SYSTEM VALUE
SELECT id, customer_id, total, created_at FROM orders
WHERE id BETWEEN $start AND $end
ON CONFLICT (id) DO NOTHING;

-- 5. Validate row counts and spot-check data
SELECT count(*) FROM orders;
SELECT count(*) FROM orders_new;

-- 6. Swap (in a transaction, briefly locks both tables)
BEGIN;
  ALTER TABLE orders RENAME TO orders_old;
  ALTER TABLE orders_new RENAME TO orders;

  -- Update sequence to continue from the right value
  SELECT setval(pg_get_serial_sequence('orders', 'id'),
    (SELECT max(id) FROM orders));

  -- Update foreign keys pointing to orders (if any)
  -- ALTER TABLE order_items DROP CONSTRAINT fk_order_id;
  -- ALTER TABLE order_items ADD CONSTRAINT fk_order_id
  --   FOREIGN KEY (order_id) REFERENCES orders(id);
COMMIT;

-- 7. Drop the old table after a comfort period
-- DROP TABLE orders_old;
```

**Risks:**
- The swap transaction acquires `ACCESS EXCLUSIVE` on both tables — keep it minimal
- Foreign keys referencing the original table must be updated in the swap transaction
- Triggers, views, and functions referencing the old table need updating
- Sequence ownership must be transferred

---

### Online Schema Migration

Tools that automate the shadow table pattern, handling dual-write, backfill, and swap transparently.

#### pg_repack (PostgreSQL)

Repacks a table online without `ACCESS EXCLUSIVE` lock (except briefly during the final swap). Useful for:
- Rebuilding a table to reclaim bloat
- Changing table storage parameters
- Reordering rows by an index (cluster without lock)

```bash
# Repack a single table (rebuilds table + indexes, reclaims dead space)
pg_repack --table orders --no-superuser-check -d mydb

# Repack and reorder by index
pg_repack --table orders --order-by created_at -d mydb

# Dry run
pg_repack --table orders --dry-run -d mydb
```

**Limitations:** pg_repack doesn't change the schema — it repacks existing structure. For schema changes, you need the manual shadow table approach or a tool like pgroll.

#### pgroll (PostgreSQL)

A newer tool from Xata that automates expand-contract migrations with versioned schema access:

```bash
# Start a migration (expand phase)
pgroll start migration.json

# Complete a migration (contract phase, drops old schema)
pgroll complete migration.json

# Rollback an in-progress migration
pgroll rollback
```

pgroll creates versioned views so old and new application versions can coexist during migration.

#### gh-ost (MySQL — mentioned for comparison)

GitHub's online schema migration for MySQL. Creates a shadow table, uses binlog to replicate changes, then performs an atomic swap. PostgreSQL doesn't have an exact equivalent because PostgreSQL's DDL is transactional and its MVCC handles many cases that MySQL cannot.

---

### Blue-Green Database

Maintain two complete database instances. Migrate the "green" instance, switch traffic, keep "blue" as rollback.

**When to use:**
- Major version upgrades (PG 14 → PG 16)
- Schema changes so radical that expand-contract is impractical
- When you need instant rollback (switch back to blue)

**How it works:**

```
                    ┌─────────────────┐
                    │   Application   │
                    │   (via proxy)   │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  Connection     │
                    │  Router/Proxy   │
                    │  (PgBouncer)    │
                    └───┬─────────┬───┘
                        │         │
               ┌────────▼──┐  ┌──▼────────┐
               │   Blue    │  │   Green   │
               │  (active) │  │ (standby) │
               └───────────┘  └───────────┘
```

**Steps:**

1. **Set up replication**: Blue → Green via logical replication
2. **Apply migrations** to Green while replication keeps data flowing
3. **Test** Green with read-only traffic or shadow traffic
4. **Switch** the connection router from Blue to Green
5. **Monitor** for issues — if problems, switch back to Blue
6. **Decommission** Blue after a comfort period

**Costs:**
- Double the infrastructure during migration
- Logical replication has limitations (DDL not replicated, sequence handling, large object support)
- Application connection strings must be managed via a proxy or DNS, not hardcoded

**When NOT to use:**
- For routine schema changes (massive overkill)
- When you can't afford double the database infrastructure
- When logical replication can't handle your schema (partitioned tables, custom types with no replication support)

---

## Data Backfill Patterns

The most common source of migration incidents isn't the DDL — it's the backfill. A naive `UPDATE ... SET new_col = old_col` on 100M rows will bloat your table, saturate I/O, and potentially wrap your transaction ID counter.

### Batched UPDATE with Progress Tracking

```sql
-- Create a tracking table (optional but invaluable for long backfills)
CREATE TABLE IF NOT EXISTS _migration_progress (
  migration_name text PRIMARY KEY,
  last_processed_id bigint NOT NULL DEFAULT 0,
  rows_updated bigint NOT NULL DEFAULT 0,
  started_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

INSERT INTO _migration_progress (migration_name)
VALUES ('backfill_delivery_address')
ON CONFLICT DO NOTHING;
```

### Backfill Script (Shell + psql)

```bash
#!/usr/bin/env bash
set -euo pipefail

DB_URL="${DATABASE_URL:?Set DATABASE_URL}"
BATCH_SIZE=5000
SLEEP_BETWEEN_BATCHES=0.1  # seconds — tune based on load

MIGRATION="backfill_delivery_address"

while true; do
  RESULT=$(psql "$DB_URL" -t -A <<SQL
    WITH batch AS (
      SELECT id
      FROM orders
      WHERE delivery_address IS NULL
        AND id > (SELECT last_processed_id FROM _migration_progress
                  WHERE migration_name = '$MIGRATION')
      ORDER BY id
      LIMIT $BATCH_SIZE
    ),
    updated AS (
      UPDATE orders
      SET delivery_address = shipping_address
      WHERE id IN (SELECT id FROM batch)
        AND delivery_address IS NULL
      RETURNING id
    )
    UPDATE _migration_progress
    SET last_processed_id = COALESCE((SELECT max(id) FROM batch), last_processed_id),
        rows_updated = rows_updated + (SELECT count(*) FROM updated),
        updated_at = now()
    WHERE migration_name = '$MIGRATION'
    RETURNING rows_updated, last_processed_id;
SQL
  )

  ROWS_UPDATED=$(echo "$RESULT" | cut -d'|' -f1)
  LAST_ID=$(echo "$RESULT" | cut -d'|' -f2)

  echo "[$(date -Iseconds)] Progress: $ROWS_UPDATED total rows, last_id=$LAST_ID"

  # Check if we're done (batch returned no new rows)
  REMAINING=$(psql "$DB_URL" -t -A -c \
    "SELECT count(*) FROM orders WHERE delivery_address IS NULL AND id > $LAST_ID LIMIT 1")

  if [[ "$REMAINING" == "0" ]]; then
    echo "Backfill complete. Total rows: $ROWS_UPDATED"
    break
  fi

  sleep "$SLEEP_BETWEEN_BATCHES"
done
```

### Advisory Locks for Preventing Concurrent Runs

If multiple workers or cron jobs might trigger the same backfill:

```sql
-- At the start of your backfill script/function
SELECT pg_try_advisory_lock(hashtext('backfill_delivery_address'));
-- Returns true if lock acquired, false if another process holds it

-- At the end
SELECT pg_advisory_unlock(hashtext('backfill_delivery_address'));
```

### Avoiding Transaction ID Wraparound

For very large backfills (100M+ rows), each batch should be its own transaction. Never wrap the entire backfill in a single `BEGIN ... COMMIT`. Signs you're in trouble:

```sql
-- Check transaction ID age
SELECT age(datfrozenxid) FROM pg_database WHERE datname = current_database();

-- If this approaches 2 billion, you're in autovacuum emergency territory
-- Each batch in its own transaction lets autovacuum clean up between batches
```

### Throttling Based on Replication Lag

If you have read replicas, aggressive backfills can cause replication lag:

```bash
# Check replication lag before each batch
LAG=$(psql "$DB_URL" -t -A -c \
  "SELECT COALESCE(max(replay_lag), '0s')::interval FROM pg_stat_replication;")

# Parse and wait if lag exceeds threshold
# (implementation depends on your monitoring stack)
```

### Backfill Performance Tips

| Tip | Why |
|-----|-----|
| Use `WHERE id BETWEEN x AND y` not `OFFSET/LIMIT` | OFFSET scans and discards rows — O(n) per batch |
| Batch size 1,000-10,000 rows | Smaller = more overhead, larger = longer locks and more WAL |
| Add `sleep` between batches | Let autovacuum and replication catch up |
| Disable triggers temporarily if safe | Triggers fire per-row during UPDATE, potentially doubling work |
| Run during off-peak hours | Less contention, more I/O headroom |
| Monitor `pg_stat_progress_vacuum` | Ensure autovacuum keeps up with dead tuple generation |
| Use `RETURNING` count for progress | Avoid separate COUNT queries |

---

## Zero-Downtime Migration Checklist

**Scenario:** Add a `NOT NULL` column with a default value to a 50M-row table, zero downtime.

This is the single most common "how do I do this safely?" question. Here's the step-by-step.

### PostgreSQL 11+ (Fast Default Path)

PostgreSQL 11 introduced "fast defaults" — adding a column with a DEFAULT no longer rewrites the table. The default is stored in the catalog and applied on read for existing rows. This makes the operation metadata-only regardless of table size.

```sql
-- Step 1: Set lock timeout to fail fast if there's a long-running query
SET lock_timeout = '5s';

-- Step 2: Add the column with NOT NULL and DEFAULT in one statement
-- This is instant on PG 11+ — no table rewrite, no full scan
ALTER TABLE orders
  ADD COLUMN priority integer NOT NULL DEFAULT 0;

-- Step 3: Reset lock timeout
RESET lock_timeout;

-- Step 4: Create any needed indexes (concurrently!)
CREATE INDEX CONCURRENTLY idx_orders_priority ON orders (priority);
```

**That's it.** On PG 11+, this is a Low-risk migration regardless of table size.

The `ACCESS EXCLUSIVE` lock is held only for the brief catalog update. Existing rows read the default from the catalog until they're naturally updated, at which point the default is materialized in the row.

### PostgreSQL < 11 (The Hard Way)

If you're on PG 10 or earlier (and you should really upgrade), the same operation requires the expand-contract pattern:

```sql
-- Step 1: Add nullable column (instant, metadata-only)
SET lock_timeout = '5s';
ALTER TABLE orders ADD COLUMN priority integer;
RESET lock_timeout;

-- Step 2: Set default for new rows
ALTER TABLE orders ALTER COLUMN priority SET DEFAULT 0;

-- Step 3: Backfill existing rows in batches (see Data Backfill Patterns)
-- DO NOT: UPDATE orders SET priority = 0;
-- DO:     Batched updates with progress tracking

-- Step 4: After backfill is complete, add the NOT NULL constraint
-- Option A: Direct (scans entire table, holds ACCESS EXCLUSIVE)
-- Only viable if you can tolerate a brief lock while it scans
ALTER TABLE orders ALTER COLUMN priority SET NOT NULL;

-- Option B: Safe two-step with CHECK constraint (PG 9.2+)
ALTER TABLE orders ADD CONSTRAINT chk_priority_not_null
  CHECK (priority IS NOT NULL) NOT VALID;

-- This validates without blocking writes (SHARE UPDATE EXCLUSIVE lock)
VALIDATE CONSTRAINT chk_priority_not_null;

-- PG 12+: PostgreSQL recognizes validated CHECK (col IS NOT NULL)
-- as equivalent to NOT NULL, so you can then:
ALTER TABLE orders ALTER COLUMN priority SET NOT NULL;
ALTER TABLE orders DROP CONSTRAINT chk_priority_not_null;
```

### Full Checklist

- [ ] Identify PostgreSQL version (`SELECT version();`)
- [ ] Assess table size (`pg_total_relation_size`)
- [ ] Check for long-running transactions (`pg_stat_activity`)
- [ ] Set `lock_timeout` in migration
- [ ] Use PG 11+ fast default path if available
- [ ] If PG < 11: expand → backfill → constrain
- [ ] Create indexes with `CONCURRENTLY`
- [ ] Test on staging with production-sized data
- [ ] Prepare rollback SQL
- [ ] Monitor during execution: locks, replication lag, table bloat
- [ ] Clean up: drop old columns, remove temporary triggers, drop tracking tables

---

## Rollback Planning

Every migration needs a rollback. "Restore from backup" is a disaster recovery plan, not a rollback plan. A rollback should take seconds to minutes, not hours.

### Pattern 1: Reversible DDL

The simplest case — the reverse operation is trivial and safe.

| Forward | Rollback |
|---------|----------|
| `ADD COLUMN x` | `DROP COLUMN x` |
| `CREATE INDEX CONCURRENTLY idx` | `DROP INDEX CONCURRENTLY idx` |
| `ADD CONSTRAINT ... NOT VALID` | `DROP CONSTRAINT` |
| `CREATE TABLE` | `DROP TABLE` |
| `ALTER COLUMN DROP NOT NULL` | `ALTER COLUMN SET NOT NULL` (only if no NULLs were inserted) |

**Write both forward and rollback SQL at the same time.** Store them together:

```sql
-- migrations/20240115_add_priority.up.sql
ALTER TABLE orders ADD COLUMN priority integer NOT NULL DEFAULT 0;

-- migrations/20240115_add_priority.down.sql
ALTER TABLE orders DROP COLUMN priority;
```

### Pattern 2: Data-Preserving Rollback

When the migration transforms data, preserve the original so rollback doesn't lose information.

#### Example: Changing column type from `text` to `integer`

```sql
-- Forward migration
-- 1. Add backup column
ALTER TABLE products ADD COLUMN price_text_backup text;

-- 2. Copy original data
UPDATE products SET price_text_backup = price_text;

-- 3. Add new column
ALTER TABLE products ADD COLUMN price_numeric numeric(10,2);

-- 4. Backfill (with error handling for non-numeric values)
UPDATE products SET price_numeric = price_text::numeric
WHERE price_text ~ '^\d+\.?\d*$';

-- 5. Switch application to use price_numeric
-- 6. Eventually drop price_text (but keep price_text_backup for a while)

-- Rollback
-- Restore from backup column
UPDATE products SET price_text = price_text_backup;
ALTER TABLE products DROP COLUMN price_numeric;
ALTER TABLE products DROP COLUMN price_text_backup;
```

### Pattern 3: Point-of-No-Return Migrations

Some migrations cannot be rolled back without data loss. Acknowledge this explicitly.

**Examples:**
- Dropping a column that contained data (without backup)
- Truncating a table
- Lossy type conversions (`text` → `integer` where some values weren't numeric)
- Merging two tables into one (original row identity lost)

**For point-of-no-return migrations:**

1. **Document that rollback = forward-fix** in the migration file
2. **Take a logical backup** before running: `pg_dump -t affected_table > pre_migration_backup.sql`
3. **Set a rollback time budget** — "if this isn't working within 30 minutes, restore the table from the backup file"
4. **Have the forward-fix ready** — if the migration succeeds but the new schema causes application errors, what's the quickest fix that doesn't require reverting the schema?

### Rollback Time Budgets

Establish before you start: "If we need to rollback, how long will it take and is that acceptable?"

| Rollback Method | Time | When Acceptable |
|----------------|------|-----------------|
| Reverse DDL (`DROP COLUMN`) | Seconds | Always — this is the gold standard |
| Restore backup column | Minutes (proportional to table size) | When table is < 10M rows |
| `pg_dump` restore of single table | Minutes to hours | Maintenance window only |
| Point-in-time recovery (PITR) | 30 min - hours | Catastrophic failure only, affects ALL tables |
| Full backup restore | Hours | Nuclear option — last resort |

### Rollback Decision Framework

```
Migration failed or causing issues
         │
         ├─ Can reverse DDL fix it? ──────── Yes ──► Reverse DDL (seconds)
         │
         ├─ Is data backed up in a          Yes ──► Restore from backup
         │   backup column?                          column (minutes)
         │
         ├─ Is forward-fix faster than       Yes ──► Forward-fix: deploy
         │   rollback?                                app change or corrective
         │                                            migration
         │
         ├─ Do you have a table-level        Yes ──► pg_dump restore (minutes
         │   dump from before migration?              to hours, single table)
         │
         └─ None of the above ──────────────────── PITR or full restore
                                                     (hours, affects everything)
```

---

## ORM Migration Tooling

Every ORM has a migration system. They all generate DDL. Some generate good DDL. Most generate DDL you should review before running on production.

### Overview

| Tool | Language | Generate | Run | Rollback | Status | Key Gotcha |
|------|----------|----------|-----|----------|--------|------------|
| **Ecto** | Elixir | `mix ecto.gen.migration` | `mix ecto.migrate` | `mix ecto.rollback` | `mix ecto.migrations` | No `CONCURRENTLY` — use `execute/1` for raw SQL |
| **Alembic** | Python | `alembic revision --autogenerate` | `alembic upgrade head` | `alembic downgrade -1` | `alembic current` | Autogenerate misses custom types, partial indexes |
| **Django** | Python | `python manage.py makemigrations` | `python manage.py migrate` | `python manage.py migrate app 0003` | `python manage.py showmigrations` | `RunSQL` needed for concurrent indexes; squash migrations regularly |
| **Flyway** | Java/JVM | Manual SQL files | `flyway migrate` | `flyway undo` (Teams only) | `flyway info` | No built-in rollback in Community edition |
| **Liquibase** | Java/JVM | `liquibase diff` | `liquibase update` | `liquibase rollback` | `liquibase status` | XML/YAML changesets verbose; raw SQL changesets cleaner |
| **Laravel** | PHP | `php artisan make:migration` | `php artisan migrate` | `php artisan migrate:rollback` | `php artisan migrate:status` | `Schema::table` generates suboptimal DDL for large tables |
| **Prisma** | Node.js | `npx prisma migrate dev` | `npx prisma migrate deploy` | Manual | `npx prisma migrate status` | No native concurrent index; shadow database required for dev |
| **Diesel** | Rust | `diesel migration generate` | `diesel migration run` | `diesel migration revert` | `diesel migration list` | Generates `up.sql`/`down.sql` — you write raw SQL |
| **goose** | Go | `goose create name sql` | `goose up` | `goose down` | `goose status` | Simple and predictable; no autogenerate (feature, not bug) |
| **golang-migrate** | Go | Manual SQL files | `migrate up` | `migrate down` | `migrate version` | `{version}_{name}.up.sql` / `.down.sql` naming convention |

### The "ORM Generates Bad DDL" Escape Hatch

Every ORM has a way to run raw SQL when the generated DDL is wrong for your use case. Use it for:
- `CREATE INDEX CONCURRENTLY` (most ORMs generate blocking `CREATE INDEX`)
- Complex constraint creation with `NOT VALID` + `VALIDATE`
- Batched data migrations
- Any operation on tables > 1M rows where the default DDL would lock too long

#### Ecto (Elixir)

```elixir
defmodule MyApp.Repo.Migrations.AddPriorityIndex do
  use Ecto.Migration

  # Disable DDL transaction — required for CONCURRENTLY
  @disable_ddl_transaction true
  @disable_migration_lock true

  def change do
    execute(
      "CREATE INDEX CONCURRENTLY idx_orders_priority ON orders (priority)",
      "DROP INDEX CONCURRENTLY idx_orders_priority"
    )
  end
end
```

#### Alembic (Python / SQLAlchemy)

```python
from alembic import op
import sqlalchemy as sa

def upgrade():
    # Disable transaction for concurrent index
    op.execute("COMMIT")
    op.execute(
        "CREATE INDEX CONCURRENTLY idx_orders_priority ON orders (priority)"
    )

def downgrade():
    op.execute("COMMIT")
    op.execute("DROP INDEX CONCURRENTLY idx_orders_priority")
```

#### Django (Python)

```python
from django.db import migrations

class Migration(migrations.Migration):
    atomic = False  # Required for CONCURRENTLY

    operations = [
        migrations.RunSQL(
            sql="CREATE INDEX CONCURRENTLY idx_orders_priority ON orders (priority);",
            reverse_sql="DROP INDEX CONCURRENTLY idx_orders_priority;",
        ),
    ]
```

#### Flyway (Java)

Flyway migrations are already raw SQL files — this is the default:

```sql
-- V5__add_priority_index.sql
CREATE INDEX CONCURRENTLY idx_orders_priority ON orders (priority);

-- Note: Flyway wraps migrations in a transaction by default.
-- For CONCURRENTLY, you need to disable this per-migration.
-- In Flyway config or the migration itself, depending on version.
```

For Flyway, set `flyway.postgresql.transactional.lock = false` or use callbacks to manage transaction boundaries for concurrent operations.

#### Liquibase (Java)

```xml
<changeSet id="add-priority-index" author="dev">
    <sql>CREATE INDEX CONCURRENTLY idx_orders_priority ON orders (priority);</sql>
    <rollback>
        <sql>DROP INDEX CONCURRENTLY idx_orders_priority;</sql>
    </rollback>
</changeSet>
```

Or better, use raw SQL changelogs instead of XML.

#### Laravel (PHP)

```php
public function up()
{
    // Laravel's Schema builder doesn't support CONCURRENTLY
    DB::statement(
        'CREATE INDEX CONCURRENTLY idx_orders_priority ON orders (priority)'
    );
}

public function down()
{
    DB::statement('DROP INDEX CONCURRENTLY idx_orders_priority');
}
```

#### Prisma (Node.js)

Prisma generates migration SQL files that you can edit before running:

```bash
# Generate migration without applying
npx prisma migrate dev --create-only --name add_priority_index
```

Then edit the generated SQL file in `prisma/migrations/`:

```sql
-- CreateIndex
CREATE INDEX CONCURRENTLY "idx_orders_priority" ON "orders" ("priority");
```

Note: Prisma wraps migrations in transactions. For `CONCURRENTLY`, you need to remove the transaction wrapper from the generated SQL or split into a separate migration step.

#### Diesel (Rust)

Diesel migrations are already raw SQL — `up.sql` and `down.sql`:

```sql
-- up.sql
CREATE INDEX CONCURRENTLY idx_orders_priority ON orders (priority);

-- down.sql
DROP INDEX CONCURRENTLY idx_orders_priority;
```

Diesel doesn't wrap migrations in transactions by default, making concurrent operations straightforward.

#### goose / golang-migrate (Go)

Both are raw SQL by default:

```sql
-- +goose Up
-- +goose StatementBegin
CREATE INDEX CONCURRENTLY idx_orders_priority ON orders (priority);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX CONCURRENTLY idx_orders_priority;
-- +goose StatementEnd
```

For goose, use `-- +goose NO TRANSACTION` at the top of the file to disable the transaction wrapper.

---

## Migration Testing

"It worked on staging" is not a test plan. Staging with 1,000 rows tells you nothing about a migration on 50M rows. Here's how to actually test.

### 1. Production-Sized Staging Data

The most reliable test is running the migration against a database with production-scale data.

```bash
# Dump production schema + data (or a representative subset)
pg_dump --no-owner --no-acl -Fc production_db > prod_dump.custom

# Restore to staging
pg_restore -d staging_db --no-owner --no-acl prod_dump.custom

# If full dump is too large, dump structure + a sample:
pg_dump --schema-only production_db > schema.sql
psql staging_db < schema.sql

# Then populate with realistic row counts using generate_series or
# a sampling query:
INSERT INTO staging_db.orders
SELECT * FROM dblink('production_db', 'SELECT * FROM orders TABLESAMPLE SYSTEM(10)')
AS t(id int, ...);
```

### 2. Migration Dry Run

Test the migration without committing:

```sql
BEGIN;

-- Run your migration DDL
ALTER TABLE orders ADD COLUMN priority integer NOT NULL DEFAULT 0;

-- Check it looks right
\d orders
SELECT * FROM orders LIMIT 5;

-- Time the operation
\timing on
-- (re-run the ALTER TABLE if needed to measure)

-- ROLLBACK — don't commit
ROLLBACK;
```

For destructive operations, wrap in a transaction on staging so you can inspect and rollback.

### 3. Timing Estimation

Measure the migration duration on staging with production-sized data:

```sql
\timing on

-- Run the migration
ALTER TABLE orders ADD COLUMN priority integer NOT NULL DEFAULT 0;

-- Record the time
-- Scale: if staging has 10M rows and production has 50M, multiply by ~5
-- (linear scaling is approximate — I/O patterns differ)
```

For backfill operations, measure a single batch and extrapolate:

```sql
\timing on

-- Time a single batch
UPDATE orders SET priority = 0
WHERE id BETWEEN 1 AND 5000
  AND priority IS NULL;

-- If that took 200ms for 5,000 rows, and you have 50M rows:
-- 50,000,000 / 5,000 = 10,000 batches
-- 10,000 * 200ms = 2,000 seconds ≈ 33 minutes (plus sleep between batches)
```

### 4. Schema Diff Tools

Verify that your migration produces the expected schema changes.

#### migra (Python)

Compares two PostgreSQL databases and generates the DDL to transform one into the other:

```bash
pip install migra

# Compare staging (pre-migration) with staging (post-migration)
migra postgresql://localhost/staging_before postgresql://localhost/staging_after

# Output is the DDL diff — verify it matches your migration
```

migra is excellent for catching drift between environments or verifying that your migration produces the exact schema you intended.

#### pgdiff

```bash
# Compare two database schemas
pgdiff --from postgresql://localhost/db_before --to postgresql://localhost/db_after
```

#### pg_dump schema comparison

The low-tech approach — diff the schema dumps:

```bash
pg_dump --schema-only db_before > before.sql
pg_dump --schema-only db_after > after.sql
diff before.sql after.sql
```

### 5. Lock Testing

Verify that your migration doesn't hold unexpected locks:

```sql
-- In session 1: start a long-running query to simulate production traffic
BEGIN;
SELECT * FROM orders WHERE id = 1 FOR UPDATE;
-- Don't commit — hold the lock

-- In session 2: run your migration
SET lock_timeout = '5s';
ALTER TABLE orders ADD COLUMN priority integer NOT NULL DEFAULT 0;

-- If session 2 times out, your migration will block behind
-- long-running transactions in production. Plan accordingly.
```

### 6. Pre-Production Validation Checklist

- [ ] Migration tested on staging with production-scale data
- [ ] Migration timing measured and acceptable
- [ ] Lock behavior verified (no unexpected `ACCESS EXCLUSIVE` on hot tables)
- [ ] Rollback SQL tested on staging
- [ ] Schema diff confirms expected changes (no surprises)
- [ ] Application code compatible with both old and new schema during deploy
- [ ] Monitoring dashboards ready (lock waits, replication lag, query latency)
- [ ] Backfill script tested if applicable (batch size, progress tracking, advisory locks)
- [ ] Communication plan for relevant teams (if migration requires coordination)
- [ ] Runbook written: who runs it, when, what to monitor, when to rollback

---

*Last updated: 2026-05-12*
