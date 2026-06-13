# MySQL Query Optimization Reference

> Target audience: senior developers running MySQL 8.0+ who need to diagnose and fix slow queries. Covers EXPLAIN internals, optimizer behavior, anti-patterns, and the tools that MySQL provides that PostgreSQL doesn't (and vice versa).

---

## 1. Reading EXPLAIN Output

### Three EXPLAIN Formats

MySQL offers three output formats, each useful for different purposes:

#### EXPLAIN (Traditional — Tabular)

```sql
EXPLAIN SELECT o.id, c.name FROM orders o JOIN customers c ON c.id = o.customer_id WHERE o.status = 'pending';
```

```
+----+-------------+-------+------+---------------------+------------+---------+-------------------+------+----------+-------+
| id | select_type | table | type | possible_keys       | key        | key_len | ref               | rows | filtered | Extra |
+----+-------------+-------+------+---------------------+------------+---------+-------------------+------+----------+-------+
|  1 | SIMPLE      | o     | ref  | idx_status,idx_cust | idx_status | 82      | const             | 1500 |   100.00 | NULL  |
|  1 | SIMPLE      | c     | eq_ref| PRIMARY            | PRIMARY    | 8       | db.o.customer_id  |    1 |   100.00 | NULL  |
+----+-------------+-------+------+---------------------+------------+---------+-------------------+------+----------+-------+
```

#### EXPLAIN FORMAT=TREE (8.0.16+ — Execution Plan Tree)

```sql
EXPLAIN FORMAT=TREE SELECT o.id, c.name FROM orders o JOIN customers c ON c.id = o.customer_id WHERE o.status = 'pending';
```

```
-> Nested loop inner join  (cost=2150 rows=1500)
    -> Index lookup on o using idx_status (status='pending')  (cost=675 rows=1500)
    -> Single-row index lookup on c using PRIMARY (id=o.customer_id)  (cost=0.98 rows=1)
```

This is the closest to PostgreSQL's EXPLAIN output. Read bottom-up and inside-out.

#### EXPLAIN ANALYZE (8.0.18+ — Actual Execution)

```sql
EXPLAIN ANALYZE SELECT o.id, c.name FROM orders o JOIN customers c ON c.id = o.customer_id WHERE o.status = 'pending';
```

```
-> Nested loop inner join  (cost=2150 rows=1500) (actual time=0.15..12.4 rows=1487 loops=1)
    -> Index lookup on o using idx_status (status='pending')  (cost=675 rows=1500) (actual time=0.08..3.2 rows=1487 loops=1)
    -> Single-row index lookup on c using PRIMARY (id=o.customer_id)  (cost=0.98 rows=1) (actual time=0.005..0.006 rows=1 loops=1487)
```

**EXPLAIN ANALYZE actually executes the query.** Unlike `EXPLAIN`, it's not just a plan estimate. Do NOT run it on destructive statements without wrapping in a transaction.

```sql
-- Safe EXPLAIN ANALYZE for mutations:
START TRANSACTION;
EXPLAIN ANALYZE DELETE FROM orders WHERE created_at < '2020-01-01';
ROLLBACK;
```

### Key Columns in Traditional EXPLAIN

| Column | What It Means | What to Watch For |
|--------|---------------|-------------------|
| `id` | Query block number. Same id = same SELECT. Subqueries get higher ids. | Multiple ids = subqueries or UNIONs. |
| `select_type` | `SIMPLE`, `PRIMARY`, `SUBQUERY`, `DERIVED`, `UNION`, `MATERIALIZED` | `DEPENDENT SUBQUERY` = correlated subquery (executes per outer row). `MATERIALIZED` = subquery result cached in temp table. |
| `type` | Access method for this table (see Section 2) | **`ALL` = full table scan** (red flag on large tables). `index` = full index scan (also often bad). |
| `possible_keys` | Indexes the optimizer considered | NULL = no applicable index exists. |
| `key` | The index actually chosen | NULL = no index used (table scan). |
| `key_len` | Bytes of the index key used | Tells you how many columns of a composite index were used. Compare to the total key length to see if trailing columns were skipped. |
| `ref` | What value is compared to the index | `const` = literal value. `db.table.column` = join column. `func` = expression result. |
| `rows` | Estimated rows examined | Multiply by `filtered` percentage to get estimated result rows. |
| `filtered` | Percentage of rows that pass additional conditions not handled by the index | Low `filtered` (e.g., 10%) means the index gets 10x more rows than needed — missing index on the filter column. |
| `Extra` | Additional execution notes (see Section 3) | The most information-dense column. |

### Reading `key_len` to Debug Composite Indexes

`key_len` tells you how many bytes of the chosen index are being used. This reveals how many columns of a composite index the optimizer can leverage.

```sql
-- Index: (status VARCHAR(20), created_at DATETIME, priority INT)
-- Character set: utf8mb4 (4 bytes/char)

-- Byte calculation per column:
-- status: 20 chars × 4 bytes + 2 (length prefix) + 1 (NULL flag) = 83 bytes
-- created_at: 8 bytes + 1 (NULL flag) = 9 bytes (or 5+1 for DATETIME without fractional seconds)
-- priority: 4 bytes + 1 (NULL flag) = 5 bytes

-- If key_len = 83: only status column used
-- If key_len = 92: status + created_at used
-- If key_len = 97: all three columns used
```

**Common key_len values:**

| Type | NOT NULL | NULLABLE | Notes |
|------|----------|----------|-------|
| `INT` | 4 | 5 | +1 byte for NULL flag |
| `BIGINT` | 8 | 9 | |
| `DATETIME` | 5 | 6 | 8 bytes if fractional seconds precision > 0 |
| `TIMESTAMP` | 4 | 5 | |
| `VARCHAR(N)` utf8mb4 | N×4 + 2 | N×4 + 2 + 1 | +2 for length prefix |
| `CHAR(N)` utf8mb4 | N×4 | N×4 + 1 | No length prefix |
| `UUID` (BINARY(16)) | 16 | 17 | |

---

## 2. Access Types (The `type` Column)

Ordered from best to worst:

| Type | Meaning | Performance | When You See It |
|------|---------|-------------|-----------------|
| `system` | Table has exactly one row | Instant | Constant system table lookups |
| `const` | At most one matching row (PK or UNIQUE lookup) | Instant | `WHERE id = 42` on PRIMARY KEY |
| `eq_ref` | One row per join match (PK/UNIQUE join) | Excellent | Inner side of join on PK: `JOIN customers c ON c.id = o.customer_id` |
| `ref` | All rows matching a non-unique index value | Good | `WHERE status = 'pending'` on INDEX(status) |
| `fulltext` | Fulltext index search | Depends | `WHERE MATCH(body) AGAINST('query')` |
| `ref_or_null` | Like `ref` but also searches for NULL | Good | `WHERE status = 'pending' OR status IS NULL` |
| `index_merge` | Multiple indexes combined | Varies | `WHERE status = 'pending' OR region = 'EU'` using two separate indexes |
| `unique_subquery` | Subquery returns unique values | Good | `WHERE id IN (SELECT DISTINCT ...)` |
| `range` | Index range scan | Good | `WHERE created_at > '2024-01-01'`, `WHERE id IN (1,2,3)`, `WHERE name BETWEEN 'A' AND 'M'` |
| `index` | Full index scan (reads every entry in the index) | **Mediocre** | Covering query but no WHERE clause, or ORDER BY matches index but no filter |
| `ALL` | **Full table scan** | **Bad** on large tables | No usable index, or optimizer decided scan is cheaper |

### When `ALL` Is Actually Fine

- Tables with fewer than ~1000 rows
- Queries that genuinely need most rows (aggregation over entire table)
- When the filtered result is >20-30% of the table (sequential I/O beats random index lookups)

### `index_merge` — Usually a Sign of Missing Composite Index

```sql
-- Two separate indexes: idx_status(status), idx_region(region)
EXPLAIN SELECT * FROM orders WHERE status = 'pending' AND region = 'EU';
-- type: index_merge
-- Extra: Using intersect(idx_status, idx_region); Using where

-- Better: create a composite index
CREATE INDEX idx_status_region ON orders (status, region);
-- Now: type: ref, key: idx_status_region — single index lookup, no merge
```

The optimizer's index merge is clever but slower than a proper composite index. If you see `index_merge` on a frequent query, create the right composite index.

---

## 3. The `Extra` Column Decoded

| Extra Value | Meaning | Action |
|-------------|---------|--------|
| `Using index` | **Covering index** — all data read from the index, no bookmark lookup | Excellent. No action needed. |
| `Using where` | Row filter applied at the server layer (not fully handled by the index) | Check if a better index could push the filter to the storage engine |
| `Using index condition` | **Index Condition Pushdown (ICP)** — filter evaluated at the index level before reading the base row | Good. Better than `Using where` alone. |
| `Using temporary` | A temporary table was created (for GROUP BY, DISTINCT, or ORDER BY) | Often fixable by adding an index matching the GROUP BY/ORDER BY |
| `Using filesort` | An in-memory or on-disk sort was performed | Add an index matching the ORDER BY to avoid the sort |
| `Using join buffer (hash join)` | Hash join (8.0.18+) or Block Nested Loop | Check if an index on the join column would enable a nested loop with index lookup |
| `Using MRR` | Multi-Range Read optimization — batches random index lookups into sequential disk reads | Good. InnoDB reads index entries, sorts by PK, then fetches rows in PK order. |
| `Using index for skip scan` | Index skip scan (8.0.13+) | Leading column of index was skipped. Fine if it works; verify it's faster than alternatives. |
| `FirstMatch(tbl)` | Semi-join FirstMatch strategy — stops after first match for EXISTS/IN subqueries | Good. Avoids reading all matching rows. |
| `LooseScan` | Semi-join LooseScan strategy — skips duplicates using the index | Good. Efficient for `IN (SELECT DISTINCT ...)` patterns. |
| `Materialize` | Subquery or CTE result materialized into a temp table | Check if the subquery can be rewritten as a JOIN |
| `Start temporary` / `End temporary` | Duplicate weedout strategy for semi-joins | Less efficient than FirstMatch or LooseScan. Consider rewriting. |
| `Using index for group-by` | GROUP BY resolved using the index without reading rows | Excellent. Loose index scan for GROUP BY. |
| `Impossible WHERE` | WHERE clause always evaluates to FALSE | Bug in your query or data model mismatch |
| `Select tables optimized away` | Entire query resolved from index metadata (e.g., `SELECT MIN(id) FROM t` where id is the PK) | Instant. No action needed. |
| `No matching min/max row` | MIN/MAX query on empty result set | Expected on empty tables/filters |

### Red Flag Combinations

| Pattern | Severity | Fix |
|---------|----------|-----|
| `type=ALL` + `Using where` on large table | High | Missing index on the WHERE column(s) |
| `Using temporary` + `Using filesort` | Medium-High | Add index matching GROUP BY + ORDER BY pattern |
| `Using filesort` on large result set | Medium | Add index matching ORDER BY; or accept if result is small |
| `type=ALL` + `Using join buffer` | High | Missing index on the join column |
| `Dependent subquery` in select_type | High | Rewrite as JOIN (correlated subquery executes per outer row) |

---

## 4. Query Anti-Patterns and Rewrites (MySQL-Specific)

### 4.1 Implicit Type Conversion Killing Index Usage

MySQL performs implicit type conversion when comparing different types. If the conversion applies to the column, the index is unusable.

```sql
-- Table: users.phone VARCHAR(20), INDEX(phone)

-- BAD: numeric literal compared to VARCHAR column
-- MySQL converts the VARCHAR column to number for each row → full scan
SELECT * FROM users WHERE phone = 5551234567;
-- EXPLAIN: type=ALL (full table scan despite index existing)

-- GOOD: match types
SELECT * FROM users WHERE phone = '5551234567';
-- EXPLAIN: type=ref, key=idx_phone
```

**The rule:** MySQL converts the "lower" type to the "higher" type. String vs number → string converted to number (on the COLUMN side). This means the index on the string column is bypassed.

```sql
-- Also dangerous: different character sets or collations in JOIN conditions
-- If orders.customer_code is utf8mb4 and legacy.code is latin1:
SELECT * FROM orders o JOIN legacy l ON o.customer_code = l.code;
-- MySQL must convert one side → index on that side is unusable
-- Fix: ALTER TABLE legacy CONVERT TO CHARACTER SET utf8mb4;
```

### 4.2 Subquery Materialization vs Derived Table Merging

MySQL's optimizer can either **materialize** a subquery (compute it once, store in temp table) or **merge** it into the outer query. The choice significantly affects performance.

```sql
-- Derived table that CAN be merged (8.0+ merges by default):
SELECT * FROM (
  SELECT id, total FROM orders WHERE status = 'pending'
) sub
WHERE sub.total > 100;
-- Optimizer merges: SELECT id, total FROM orders WHERE status = 'pending' AND total > 100

-- Derived table that CANNOT be merged (materialized instead):
SELECT * FROM (
  SELECT status, SUM(total) AS total FROM orders GROUP BY status
) sub
WHERE sub.total > 10000;
-- The GROUP BY prevents merging. MySQL materializes the subquery into a temp table.
-- If the temp table is large, this is slow.
```

**Check if merging happened:**
```sql
EXPLAIN FORMAT=TREE SELECT ...;
-- Merged: you'll see the filters combined into a single scan
-- Materialized: you'll see "Materialize" in the plan tree
```

**Force merging (if you know it's safe):**
```sql
SELECT /*+ MERGE(sub) */ * FROM (SELECT ...) sub WHERE ...;

-- Or force materialization (if merging produces a bad plan):
SELECT /*+ NO_MERGE(sub) */ * FROM (SELECT ...) sub WHERE ...;
```

### 4.3 `IN (SELECT ...)` vs `EXISTS` vs `JOIN`

MySQL 8.0 handles `IN (SELECT ...)` much better than 5.7 (semi-join optimization), but there are still gotchas:

```sql
-- MySQL 8.0 can optimize this as a semi-join:
SELECT * FROM customers WHERE id IN (SELECT customer_id FROM orders WHERE total > 1000);
-- EXPLAIN shows: FirstMatch or LooseScan strategy — efficient

-- But if the subquery is correlated or too complex, it falls back to materialization:
SELECT * FROM customers c
WHERE c.id IN (
  SELECT o.customer_id FROM orders o
  WHERE o.total > c.credit_limit  -- correlated!
);
-- This may execute the subquery per outer row → slow

-- Rewrite as EXISTS (often better for correlated subqueries):
SELECT * FROM customers c
WHERE EXISTS (
  SELECT 1 FROM orders o
  WHERE o.customer_id = c.id AND o.total > c.credit_limit
);

-- Or rewrite as JOIN (if you need columns from both tables):
SELECT DISTINCT c.*
FROM customers c
JOIN orders o ON o.customer_id = c.id AND o.total > c.credit_limit;
```

### 4.4 `ORDER BY` + `LIMIT` Without Matching Index

```sql
-- BAD: sorts entire result set, then takes 10 rows
SELECT * FROM orders WHERE status = 'pending' ORDER BY created_at DESC LIMIT 10;
-- If index is only on (status): reads all pending rows, sorts in memory, returns 10
-- EXPLAIN Extra: Using filesort

-- GOOD: composite index covers both filter and sort
CREATE INDEX idx_status_created ON orders (status, created_at DESC);
-- Now: reads first 10 entries from the index. No sort needed.
-- EXPLAIN Extra: Using index condition (no filesort)
```

### 4.5 `GROUP BY` Implicit Sorting (Pre-8.0 vs Post-8.0)

**Pre-8.0:** `GROUP BY col` implicitly sorted by `col`. Many applications depended on this undocumented behavior.

**8.0+:** `GROUP BY` no longer implies `ORDER BY`. If you need sorted output, add an explicit `ORDER BY`.

```sql
-- Pre-8.0: returned rows sorted by status (implicitly)
SELECT status, COUNT(*) FROM orders GROUP BY status;

-- Post-8.0: returns rows in ANY order
SELECT status, COUNT(*) FROM orders GROUP BY status;

-- If you need sorting, be explicit:
SELECT status, COUNT(*) FROM orders GROUP BY status ORDER BY status;

-- Performance win: if you DON'T need sorting, MySQL 8.0 can use HashAggregate
-- instead of sort-based aggregation. This is faster for large groups.
```

### 4.6 The `SELECT COUNT(*)` Problem

MySQL (InnoDB) does NOT store a row count. `SELECT COUNT(*)` requires a full index scan.

```sql
-- Slow on large tables (scans the smallest index):
SELECT COUNT(*) FROM orders;

-- Fast approximate count (from INFORMATION_SCHEMA):
SELECT TABLE_ROWS FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'mydb' AND TABLE_NAME = 'orders';
-- WARNING: TABLE_ROWS is an ESTIMATE (based on sampling).
-- Can be off by 10-40% on large tables.

-- Fast exact count for filtered queries (if an index covers it):
SELECT COUNT(*) FROM orders WHERE status = 'pending';
-- If INDEX(status) exists, this is a covering index scan on just the pending rows.
-- Much faster than a full table scan.

-- Pattern for applications that need an exact total count:
-- Maintain a counter table or use a materialized summary.
```

### 4.7 `DISTINCT` When You Mean `EXISTS`

```sql
-- BAD: reads all matching rows, deduplicates
SELECT DISTINCT c.id, c.name
FROM customers c
JOIN orders o ON o.customer_id = c.id
WHERE o.total > 1000;

-- GOOD: stops at first match per customer
SELECT c.id, c.name
FROM customers c
WHERE EXISTS (
  SELECT 1 FROM orders o
  WHERE o.customer_id = c.id AND o.total > 1000
);
```

### 4.8 Large `IN` Lists

```sql
-- MySQL handles large IN lists well (up to ~10,000 values typically):
SELECT * FROM products WHERE id IN (1, 2, 3, ..., 5000);
-- Optimizer converts to a range scan on the index.

-- But beyond ~65,536 values, the query can fail or be extremely slow.
-- Workaround for very large lists: use a temp table
CREATE TEMPORARY TABLE tmp_ids (id BIGINT PRIMARY KEY);
INSERT INTO tmp_ids VALUES (1), (2), (3), ...;
SELECT p.* FROM products p JOIN tmp_ids t ON t.id = p.id;
DROP TEMPORARY TABLE tmp_ids;
```

---

## 5. Join Optimization

### Join Types in MySQL

MySQL 8.0 supports three join strategies:

| Strategy | When Used | Notes |
|----------|----------|-------|
| **Nested Loop Join** | Default for most joins; inner side has an index | One loop per outer row, index lookup per inner row. Efficient when outer side is small. |
| **Block Nested Loop (BNL)** | Pre-8.0.18: no usable index on inner side | Reads blocks of outer rows into a buffer, scans inner table once per block. Replaced by hash join in 8.0.18+. |
| **Hash Join** (8.0.18+) | No usable index on either side, equi-join | Builds hash table on smaller input, probes with larger. MySQL's first real hash join (PG has had this forever). |

**MySQL does NOT support Merge Join.** PostgreSQL uses merge join when both sides are pre-sorted. MySQL relies on nested loop (with index) or hash join (without index).

### Hash Join Details (8.0.18+)

```sql
EXPLAIN FORMAT=TREE
SELECT o.id, c.name
FROM orders o
JOIN customers c ON c.id = o.customer_id
WHERE o.region = 'EU';
```

```
-> Inner hash join (c.id = o.customer_id)  (cost=15000 rows=50000)
    -> Table scan on o with condition (o.region = 'EU')  (cost=12000 rows=50000)
    -> Hash
        -> Table scan on c  (cost=500 rows=5000)
```

**Hash join is chosen when:**
- No index on the join column of the inner table
- The build side (smaller table) fits in `join_buffer_size`
- Equi-join condition (`=`)

**When the hash table doesn't fit:**
- MySQL spills to disk (grace hash join)
- Controlled by `join_buffer_size` (default 256KB — often too small)

```ini
# Increase for hash join workloads:
join_buffer_size = 8M   # Per-join, per-session. Don't set too high globally.
                         # 256KB × 500 connections = 128 MB just for join buffers.
                         # Use SET SESSION for specific heavy queries.
```

### Controlling Join Order

```sql
-- Optimizer hint to force join order:
SELECT /*+ JOIN_ORDER(orders, customers, products) */ ...

-- Legacy syntax:
SELECT STRAIGHT_JOIN o.id, c.name
FROM orders o
JOIN customers c ON c.id = o.customer_id;
-- STRAIGHT_JOIN forces left-to-right join order.
```

### The `eq_ref` vs `ref` Difference

```
eq_ref: inner side is PK or UNIQUE — at most ONE row per outer row (most efficient join)
ref:    inner side is non-unique index — potentially MANY rows per outer row
```

If you expect `eq_ref` but see `ref`, check that the join column has a UNIQUE or PRIMARY constraint.

---

## 6. Optimizer Trace — Deep Debugging

When EXPLAIN doesn't tell you enough, the optimizer trace shows every decision the optimizer made.

```sql
SET optimizer_trace = 'enabled=on';
SET optimizer_trace_max_mem_size = 1048576;  -- 1MB (default is often too small)

-- Run your query:
SELECT * FROM orders WHERE status = 'pending' AND created_at > '2024-01-01';

-- Read the trace:
SELECT * FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE\G

SET optimizer_trace = 'enabled=off';
```

### What the Trace Shows

The trace is a JSON document with three sections:

1. **`join_preparation`** — Query parsing, transformation, view merging
2. **`join_optimization`** — The interesting part: index selection, join order, cost estimates
3. **`join_execution`** — Runtime details (minimal for non-EXPLAIN ANALYZE)

**Key things to look for in `join_optimization`:**

```json
{
  "rows_estimation": [
    {
      "table": "orders",
      "range_analysis": {
        "table_scan": { "rows": 1000000, "cost": 103345 },
        "potential_range_indexes": [
          { "index": "idx_status", "usable": true },
          { "index": "idx_created", "usable": true },
          { "index": "idx_status_created", "usable": true }
        ],
        "best_covering_index_scan": { ... },
        "analyzing_range_alternatives": {
          "range_scan_alternatives": [
            {
              "index": "idx_status",
              "ranges": ["'pending' <= status <= 'pending'"],
              "cost": 1650.1,
              "rows": 1500,
              "chosen": false,
              "cause": "cost"   // <-- WHY this index was rejected
            },
            {
              "index": "idx_status_created",
              "ranges": ["'pending' <= status <= 'pending' AND '2024-01-01' < created_at"],
              "cost": 675.5,
              "rows": 750,
              "chosen": true    // <-- THIS is the chosen index
            }
          ]
        }
      }
    }
  ]
}
```

**The `cause` field tells you why an index was rejected:**

| Cause | Meaning |
|-------|---------|
| `cost` | A cheaper alternative was found |
| `not_applicable` | Index doesn't support this query pattern |
| `no_valid_range_for_this_index` | The WHERE clause can't form a range on this index |
| `too_many_ranges` | Too many OR/IN values to enumerate (degrades to full scan) |

---

## 7. Performance Schema Queries for Query Optimization

### Find Queries That Examine Too Many Rows

```sql
SELECT
  DIGEST_TEXT,
  COUNT_STAR AS executions,
  SUM_ROWS_EXAMINED / COUNT_STAR AS avg_rows_examined,
  SUM_ROWS_SENT / COUNT_STAR AS avg_rows_sent,
  ROUND(SUM_ROWS_EXAMINED / GREATEST(SUM_ROWS_SENT, 1), 0) AS examine_to_sent_ratio,
  ROUND(AVG_TIMER_WAIT / 1e9, 2) AS avg_ms
FROM performance_schema.events_statements_summary_by_digest
WHERE SUM_ROWS_EXAMINED > 0
  AND COUNT_STAR > 100  -- frequent queries only
ORDER BY SUM_ROWS_EXAMINED / GREATEST(SUM_ROWS_SENT, 1) DESC
LIMIT 20;
-- examine_to_sent_ratio >> 10 means the query reads 10x more rows than it returns
-- → missing index or non-selective filter
```

### Find Queries Using Temporary Tables or Filesort

```sql
SELECT
  DIGEST_TEXT,
  COUNT_STAR,
  SUM_SORT_MERGE_PASSES,
  SUM_SORT_ROWS,
  SUM_CREATED_TMP_TABLES,
  SUM_CREATED_TMP_DISK_TABLES,
  ROUND(AVG_TIMER_WAIT / 1e9, 2) AS avg_ms
FROM performance_schema.events_statements_summary_by_digest
WHERE (SUM_CREATED_TMP_DISK_TABLES > 0 OR SUM_SORT_MERGE_PASSES > 0)
  AND COUNT_STAR > 10
ORDER BY SUM_CREATED_TMP_DISK_TABLES DESC
LIMIT 20;
-- SUM_CREATED_TMP_DISK_TABLES > 0: temp table didn't fit in memory (spilled to disk)
-- SUM_SORT_MERGE_PASSES > 0: sort didn't fit in sort_buffer_size
```

### Find Queries with No Good Index

```sql
SELECT
  DIGEST_TEXT,
  COUNT_STAR,
  SUM_NO_GOOD_INDEX_USED,
  SUM_NO_INDEX_USED,
  ROUND(AVG_TIMER_WAIT / 1e9, 2) AS avg_ms
FROM performance_schema.events_statements_summary_by_digest
WHERE SUM_NO_INDEX_USED > 0
  AND COUNT_STAR > 100
ORDER BY SUM_NO_INDEX_USED DESC
LIMIT 20;
```

---

## 8. Common Tuning Scenarios

### "This Query Was Fast, Now It's Slow"

```sql
-- Step 1: Check if statistics are stale
ANALYZE TABLE orders;
-- MySQL's InnoDB samples a fixed number of pages (default: 20 pages per
-- innodb_stats_persistent_sample_pages). After bulk data changes, the sample
-- may not represent the new data distribution.

-- Step 2: Increase sample size temporarily
SET GLOBAL innodb_stats_persistent_sample_pages = 100;
ANALYZE TABLE orders;
SET GLOBAL innodb_stats_persistent_sample_pages = 20;  -- reset

-- Step 3: Check for histogram staleness (8.0+)
-- Histograms are NOT automatically refreshed:
ANALYZE TABLE orders UPDATE HISTOGRAM ON status, region WITH 256 BUCKETS;

-- Step 4: Compare plans
EXPLAIN FORMAT=TREE SELECT ...;
-- If the plan changed (different index, different join order), stale stats are likely the cause.

-- Step 5: Check for lock contention
SELECT * FROM performance_schema.data_locks WHERE LOCK_STATUS = 'WAITING';
```

### "Bulk INSERT is Slow"

```sql
-- 1. Use LOAD DATA INFILE (MySQL's COPY equivalent):
LOAD DATA INFILE '/tmp/data.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
-- 10-50x faster than INSERT statements.

-- 2. Multi-row INSERT (if LOAD DATA isn't possible):
INSERT INTO orders (customer_id, total) VALUES
  (1, 100), (2, 200), (3, 300), ...;
-- Batch 1000-5000 rows per INSERT.

-- 3. Disable indexes during bulk load (for initial loads only):
ALTER TABLE orders DISABLE KEYS;  -- MyISAM only. For InnoDB, drop + recreate indexes.
-- InnoDB: DROP non-primary indexes, load, then CREATE INDEX.

-- 4. Transaction batching:
SET autocommit = 0;
INSERT INTO orders VALUES ...;  -- batch of 10000
INSERT INTO orders VALUES ...;  -- another batch
COMMIT;
-- Committing every 10000 rows reduces fsync overhead.

-- 5. Tune for bulk loads:
SET SESSION innodb_flush_log_at_trx_commit = 2;  -- relax durability during load
SET SESSION unique_checks = 0;                    -- skip uniqueness checks (if data is clean)
SET SESSION foreign_key_checks = 0;               -- skip FK validation (re-enable after!)
-- REMEMBER TO RE-ENABLE THESE AFTER THE LOAD.
```

### "This Aggregation Is Slow"

```sql
EXPLAIN ANALYZE
SELECT region, COUNT(*), SUM(total)
FROM orders
WHERE created_at > '2024-01-01'
GROUP BY region;
```

**Check for:**

1. **Full table scan** — Missing index on `created_at`.
2. **`Using temporary; Using filesort`** — The GROUP BY doesn't match any index.
   ```sql
   CREATE INDEX idx_region_created ON orders (region, created_at);
   -- Or, if the filter is more selective:
   CREATE INDEX idx_created_region ON orders (created_at, region);
   ```
3. **Loose index scan opportunity** — If aggregating MIN/MAX per group:
   ```sql
   SELECT region, MIN(created_at), MAX(total)
   FROM orders
   GROUP BY region;
   -- With INDEX(region, created_at) or INDEX(region, total),
   -- MySQL can use "Using index for group-by" (loose index scan).
   -- This reads ONE entry per group instead of all entries.
   ```

### "DELETE of Millions of Rows Is Slow"

Same fundamental problem as PostgreSQL, different mechanics:

```sql
-- Batch delete with LIMIT:
REPEAT
  DELETE FROM orders WHERE created_at < '2020-01-01' LIMIT 10000;
UNTIL ROW_COUNT() = 0 END REPEAT;
-- Or from application code:
-- WHILE affected_rows > 0: DELETE ... LIMIT 10000; SLEEP 0.1;

-- Better: partition by range and DROP PARTITION (instant):
ALTER TABLE orders DROP PARTITION p2019;
-- Requires the table to be partitioned by created_at (plan ahead).

-- Alternative: CREATE TABLE ... SELECT (keep what you need, swap):
CREATE TABLE orders_new LIKE orders;
INSERT INTO orders_new SELECT * FROM orders WHERE created_at >= '2020-01-01';
RENAME TABLE orders TO orders_old, orders_new TO orders;
DROP TABLE orders_old;
-- Requires downtime for the RENAME (brief lock) and rebuilding indexes.
```

---

## 9. MySQL vs PostgreSQL Query Optimization Comparison

| Capability | PostgreSQL | MySQL 8.0 |
|------------|-----------|-----------|
| **EXPLAIN output** | Tree format (default), JSON, YAML, TEXT | Tabular (default), TREE (8.0.16+), JSON |
| **EXPLAIN ANALYZE** | Since forever | 8.0.18+ (relatively new) |
| **Optimizer trace** | No (`auto_explain` is less detailed) | Yes (deep JSON trace of every decision) |
| **Optimizer hints** | None (philosophy: fix the planner) | Extensive (`/*+ ... */` syntax) |
| **Hash join** | Yes (since early versions) | 8.0.18+ only |
| **Merge join** | Yes | No |
| **Parallel query** | Yes (workers per gather) | No (single-threaded query execution) |
| **CTE inlining** | 12+ (automatic) | 8.0+ (automatic, same behavior) |
| **Window functions** | Yes (optimized with dedicated nodes) | 8.0+ (less optimized than PG) |
| **LATERAL join** | Yes (full support) | 8.0.14+ (limited) |
| **Semi-join optimization** | Yes (multiple strategies) | 8.0+ (FirstMatch, LooseScan, Materialize, DuplicateWeedout) |
| **Partial indexes** | Yes | No |
| **Extended statistics** | Yes (dependencies, ndistinct, mcv) | Histograms only (8.0+, manual refresh) |
| **Prepared statement plan caching** | Yes (can cause plan instability) | Yes (same issue, controlled by `prepared_stmt_count`) |
| **JIT compilation** | Yes (11+) | No |
| **Buffer pool analysis** | `pg_buffercache` extension | `INFORMATION_SCHEMA.INNODB_BUFFER_POOL_STATS` + `sys.innodb_buffer_stats_by_table` |

The key takeaway: PostgreSQL has a more sophisticated planner and more query execution strategies. MySQL compensates with optimizer hints (to override bad decisions) and optimizer trace (to understand why decisions were made). Both approaches work; they just put the burden in different places.
