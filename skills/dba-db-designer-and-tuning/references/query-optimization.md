# PostgreSQL Query Optimization Reference

A practical reference for diagnosing and fixing slow queries in PostgreSQL. Written for mid-to-senior developers who need to answer: **"Why is this query slow, and how do I fix it?"**

---

## Table of Contents

1. [Reading EXPLAIN Output](#1-reading-explain-output)
2. [Common Plan Node Types](#2-common-plan-node-types)
3. [Query Anti-Patterns and Rewrites](#3-query-anti-patterns-and-rewrites)
4. [Join Optimization](#4-join-optimization)
5. [Subquery vs CTE vs Lateral Join](#5-subquery-vs-cte-vs-lateral-join)
6. [Statistics and the Planner](#6-statistics-and-the-planner)
7. [Locking and Concurrency](#7-locking-and-concurrency)
8. [Common Tuning Scenarios](#8-common-tuning-scenarios)
9. [Materialized Views](#9-materialized-views)

---

## 1. Reading EXPLAIN Output

### The Basics: EXPLAIN vs EXPLAIN ANALYZE

`EXPLAIN` shows what the planner **intends** to do. `EXPLAIN ANALYZE` **actually runs the query** and reports real timing. Never use `EXPLAIN ANALYZE` on destructive statements without wrapping in a transaction you roll back.

```sql
-- Plan only (does not execute)
EXPLAIN SELECT * FROM orders WHERE customer_id = 42;

-- Plan + actual execution stats
EXPLAIN ANALYZE SELECT * FROM orders WHERE customer_id = 42;

-- Full diagnostic output (run the query, show buffer I/O, YAML format)
EXPLAIN (ANALYZE, BUFFERS, FORMAT YAML)
  SELECT * FROM orders WHERE customer_id = 42;

-- Safe EXPLAIN ANALYZE for mutations
BEGIN;
EXPLAIN ANALYZE DELETE FROM orders WHERE created_at < '2020-01-01';
ROLLBACK;
```

### Anatomy of a Plan Node

Every line in EXPLAIN output is a **plan node**. Here is a single node dissected:

```
Index Scan using idx_orders_customer_id on orders  (cost=0.43..8.45 rows=1 width=64)
                                                         (actual time=0.019..0.021 rows=1 loops=1)
  Index Cond: (customer_id = 42)
  Buffers: shared hit=4
```

| Field | Meaning |
|-------|---------|
| `cost=0.43..8.45` | Estimated startup cost..total cost in arbitrary planner units. Startup cost is work before first row emitted. Total cost is work to return all rows. |
| `rows=1` | Estimated number of rows this node will return. |
| `width=64` | Estimated average row width in bytes. |
| `actual time=0.019..0.021` | Real wall-clock time in milliseconds: time-to-first-row..time-to-last-row. |
| `rows=1` (actual) | Actual number of rows returned. |
| `loops=1` | How many times this node was executed. Multiply actual time and rows by loops to get true totals. |
| `Buffers: shared hit=4` | Pages read from shared buffer cache. `shared read=N` means pages fetched from OS/disk. |

### Reading Nested Nodes

Plans are trees. Indentation shows parent-child relationships. **Execution flows bottom-up and inside-out**: leaf nodes execute first, feeding rows to their parents.

```sql
EXPLAIN ANALYZE
SELECT o.id, c.name
FROM orders o
JOIN customers c ON c.id = o.customer_id
WHERE o.total > 1000
ORDER BY o.created_at DESC
LIMIT 20;
```

```
Limit  (cost=1234.56..1234.61 rows=20 width=48)
       (actual time=12.345..12.367 rows=20 loops=1)
  ->  Sort  (cost=1234.56..1240.12 rows=2225 width=48)
            (actual time=12.344..12.355 rows=20 loops=1)
        Sort Key: o.created_at DESC
        Sort Method: top-N heapsort  Memory: 27kB
        ->  Hash Join  (cost=100.00..1180.00 rows=2225 width=48)
                       (actual time=1.234..10.567 rows=2225 loops=1)
              Hash Cond: (o.customer_id = c.id)
              ->  Seq Scan on orders o  (cost=0.00..950.00 rows=2225 width=36)
                                        (actual time=0.012..6.789 rows=2225 loops=1)
                    Filter: (total > 1000)
                    Rows Removed by Filter: 47775
              ->  Hash  (cost=70.00..70.00 rows=2400 width=20)
                        (actual time=1.100..1.100 rows=2400 loops=1)
                    Buckets: 4096  Batches: 1  Memory Usage: 150kB
                    ->  Seq Scan on customers c  (cost=0.00..70.00 rows=2400 width=20)
                                                  (actual time=0.005..0.500 rows=2400 loops=1)
```

**Reading order:**
1. Seq Scan on `customers` -- loads all customers into a hash table
2. Seq Scan on `orders` -- filters `total > 1000`, producing 2225 rows (removed 47775)
3. Hash Join -- matches `customer_id` to the hash table
4. Sort -- sorts by `created_at DESC` using top-N heapsort (only needs top 20)
5. Limit -- returns the first 20 rows

### Key Diagnostic Signals

**Estimated vs actual rows divergence:** When `rows=1` (estimated) but `actual rows=50000`, the planner chose the wrong strategy. Run `ANALYZE` on the table.

**Loops > 1:** The node executes multiple times. A nested loop with `loops=10000` on an index scan means 10000 individual index lookups. Multiply `actual time` by `loops` for true cost.

**Buffers shared read:** High `shared read` relative to `shared hit` means data is not cached -- cold query or working set exceeds `shared_buffers`.

**Rows Removed by Filter:** Large numbers here on a Seq Scan mean a missing or unused index.

### FORMAT Options

```sql
-- Default text format (human-readable, good for quick diagnosis)
EXPLAIN ANALYZE SELECT ...;

-- YAML format (machine-parseable, includes all fields, good for tooling)
EXPLAIN (ANALYZE, BUFFERS, FORMAT YAML) SELECT ...;

-- JSON format (good for feeding into visualization tools like explain.depesz.com)
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) SELECT ...;
```

YAML and JSON formats include fields not shown in text format, such as `I/O Read Time` and `I/O Write Time` (when `track_io_timing = on`).

---

## 2. Common Plan Node Types

### Seq Scan (Sequential Scan)

**What it does:** Reads every row of the table from disk, evaluating the filter condition on each.

**When it's good:**
- Small tables (< ~10k rows depending on row width)
- Queries that return a large fraction of the table (>5-10%)
- No suitable index exists and the table fits comfortably in memory

**When it's a red flag:**
- Large table with a highly selective WHERE clause
- `Rows Removed by Filter` is orders of magnitude larger than rows returned
- Appears inside a nested loop (executed many times)

```
Seq Scan on orders  (cost=0.00..25000.00 rows=50 width=64)
  Filter: (status = 'cancelled' AND region = 'EU')
  Rows Removed by Filter: 999950
```

This is scanning 1M rows to find 50. An index on `(status, region)` would fix it.

---

### Index Scan

**What it does:** Traverses a B-tree (or other) index to find matching rows, then fetches the actual table row (heap tuple) for each match.

**When it's good:**
- Highly selective queries returning a small fraction of the table
- Queries that need columns beyond what the index covers
- ORDER BY matches the index order (avoids separate sort)

**When it's a red flag:**
- Rarely a red flag. If the planner picks it, selectivity is usually favorable.
- Can be slow if the table is badly bloated (index points to dead tuples, causing extra heap fetches)

```
Index Scan using idx_orders_customer_id on orders  (cost=0.43..8.45 rows=5 width=64)
  Index Cond: (customer_id = 42)
```

---

### Index Only Scan

**What it does:** Reads data entirely from the index without touching the heap (table). Only possible when all columns needed by the query are in the index.

**When it's good:**
- The ideal scan type for covered queries. Fastest possible read path.
- COUNT queries on indexed columns
- Queries selecting only indexed columns

**When it's a red flag:**
- `Heap Fetches` is high. This means the visibility map is stale (VACUUM hasn't run recently), forcing heap access anyway.

```
Index Only Scan using idx_orders_cust_status on orders  (cost=0.43..4.50 rows=5 width=8)
  Index Cond: (customer_id = 42)
  Heap Fetches: 0
```

`Heap Fetches: 0` is the goal. If you see `Heap Fetches: 5000`, run `VACUUM` on the table.

---

### Bitmap Index Scan + Bitmap Heap Scan

**What it does:** Two-phase process. The Bitmap Index Scan builds a bitmap of which heap pages contain matching rows. The Bitmap Heap Scan then reads those pages sequentially, re-checking the condition on each row.

**When it's good:**
- Moderate selectivity (too many rows for a plain index scan, too few for a seq scan)
- Combining multiple indexes via BitmapAnd / BitmapOr
- Reduces random I/O by converting it to sequential page reads

**When it's a red flag:**
- `Recheck Cond` with `Rows Removed by Recheck` means pages contained non-matching rows (lossy bitmap). Not necessarily bad, but watch the ratio.
- "Lossy" bitmap means `work_mem` was too small to hold an exact bitmap, so it fell back to page-level granularity.

```
Bitmap Heap Scan on orders  (cost=50.00..5000.00 rows=2000 width=64)
  Recheck Cond: (status = 'pending')
  ->  Bitmap Index Scan on idx_orders_status  (cost=0.00..49.50 rows=2000 width=0)
        Index Cond: (status = 'pending')
```

Multiple indexes combined:

```
Bitmap Heap Scan on orders  (cost=100.00..6000.00 rows=200 width=64)
  Recheck Cond: ((status = 'pending') AND (region = 'EU'))
  ->  BitmapAnd
        ->  Bitmap Index Scan on idx_orders_status  (cost=0.00..49.50 rows=2000 width=0)
              Index Cond: (status = 'pending')
        ->  Bitmap Index Scan on idx_orders_region  (cost=0.00..45.00 rows=5000 width=0)
              Index Cond: (region = 'EU')
```

---

### Nested Loop

**What it does:** For each row from the outer (top) input, scans the inner (bottom) input for matching rows. Total work is proportional to `outer_rows * inner_scan_cost`.

**When it's good:**
- Outer side has few rows (e.g., LIMIT, highly selective filter)
- Inner side uses an index scan (fast lookup per outer row)
- The only join strategy that supports non-equi joins and LATERAL

**When it's a red flag:**
- Outer side has many rows and inner side is a Seq Scan (O(n*m) disaster)
- `loops=50000` on the inner Index Scan -- each loop is cheap, but 50k of them adds up

```
Nested Loop  (cost=0.43..500.00 rows=100 width=72)
  ->  Seq Scan on line_items li  (cost=0.00..50.00 rows=100 width=8)
        Filter: (order_id = 42)
  ->  Index Scan using products_pkey on products p  (cost=0.43..4.45 rows=1 loops=100)
        Index Cond: (id = li.product_id)
```

100 line items, each doing one index lookup on products. This is fine.

---

### Hash Join

**What it does:** Builds a hash table from the smaller input (inner/build side), then probes it with each row from the larger input (outer/probe side).

**When it's good:**
- Equi-joins on medium-to-large tables
- Both sides have reasonable cardinality
- The build side fits in `work_mem`

**When it's a red flag:**
- `Batches > 1` -- the hash table didn't fit in `work_mem` and spilled to disk. Increase `work_mem` or reduce the build side.
- Build side is unexpectedly large due to bad row estimates

```
Hash Join  (cost=200.00..15000.00 rows=50000 width=72)
  Hash Cond: (o.customer_id = c.id)
  ->  Seq Scan on orders o  (cost=0.00..12000.00 rows=500000 width=52)
  ->  Hash  (cost=150.00..150.00 rows=5000 width=20)
        Buckets: 8192  Batches: 1  Memory Usage: 300kB
        ->  Seq Scan on customers c  (cost=0.00..150.00 rows=5000 width=20)
```

`Batches: 1` is what you want. If you see `Batches: 16`, the hash spilled.

---

### Merge Join

**What it does:** Takes two inputs that are already sorted (or sorts them first), then walks through both in lockstep, matching rows.

**When it's good:**
- Both inputs are already sorted (e.g., from index scans matching the join key order)
- Very large joins where sorted input avoids random access
- The result needs to be sorted by the join key anyway

**When it's a red flag:**
- Preceded by expensive explicit Sort nodes when neither input has a useful index order. The sort cost can outweigh the merge benefit.

```
Merge Join  (cost=0.86..50000.00 rows=100000 width=72)
  Merge Cond: (o.id = li.order_id)
  ->  Index Scan using orders_pkey on orders o  (cost=0.43..30000.00 rows=500000 width=52)
  ->  Index Scan using idx_line_items_order_id on line_items li  (cost=0.43..20000.00 rows=100000 width=20)
```

Both sides feed pre-sorted data via indexes. Efficient.

---

### Sort

**What it does:** Sorts input rows by the specified key(s). Uses quicksort in memory or external merge sort on disk.

**When it's good:**
- Required for ORDER BY, DISTINCT, Merge Join, GroupAggregate
- `Sort Method: quicksort Memory: NkB` -- entirely in memory, fast

**When it's a red flag:**
- `Sort Method: external merge Disk: NkB` -- spilled to disk. Increase `work_mem` for this query.
- Sorting millions of rows for a `LIMIT 10` -- a matching index would avoid the sort entirely.

```
Sort  (cost=50000.00..51000.00 rows=500000 width=64)
  Sort Key: created_at DESC
  Sort Method: external merge  Disk: 50000kB
  ->  Seq Scan on orders  ...
```

Fix: `CREATE INDEX idx_orders_created_at_desc ON orders (created_at DESC)` or increase `work_mem`.

---

### HashAggregate

**What it does:** Builds a hash table keyed by the GROUP BY columns. Accumulates aggregate values (SUM, COUNT, etc.) in the hash entries.

**When it's good:**
- Moderate number of groups
- Groups fit in `work_mem`

**When it's a red flag:**
- `Batches > 1` or `Disk Usage` appears -- hash table spilled. Increase `work_mem`.
- Very high number of groups (millions) -- may be more efficient as GroupAggregate with a pre-sorted input.

```
HashAggregate  (cost=15000.00..15500.00 rows=5000 width=12)
  Group Key: customer_id
  Batches: 1  Memory Usage: 600kB
  ->  Seq Scan on orders  ...
```

---

### GroupAggregate

**What it does:** Reads pre-sorted input and aggregates rows that share the same group key. Requires sorted input (from an index or explicit Sort).

**When it's good:**
- Input is already sorted by the GROUP BY columns (from an index)
- Very large number of groups (doesn't need to hold all groups in memory simultaneously)
- Streaming output: emits groups one at a time

**When it's a red flag:**
- Preceded by an expensive Sort node when a HashAggregate would be faster (planner usually gets this right)

---

### Materialize

**What it does:** Reads the full output of a child node into memory (or temp files), allowing the parent to rescan it without re-executing the child.

**When it's good:**
- Inner side of a Nested Loop that must be rescanned for each outer row, and the child is not rescannnable on its own (e.g., a subquery)

**When it's a red flag:**
- Materializing a very large result set. Check if the plan could use a Hash Join instead.

---

### CTE Scan

**What it does:** Scans the materialized result of a Common Table Expression (WITH clause).

**When it's good:**
- CTE is referenced multiple times (materialization avoids repeated computation)
- PostgreSQL 12+: CTEs are inlined by default unless recursive or referenced multiple times

**When it's a red flag:**
- Pre-PostgreSQL 12: CTEs are always materialized, creating an optimization fence. The planner cannot push predicates into the CTE.

```
CTE Scan on recent_orders  (cost=5000.00..5500.00 rows=500 width=64)
  Filter: (total > 100)
  CTE recent_orders
    ->  Seq Scan on orders  ...
```

In PG < 12, the filter `total > 100` is applied **after** materializing all rows from the CTE. In PG 12+, the CTE is inlined and the filter is pushed down.

---

### Subquery Scan

**What it does:** Wraps a subquery's output as a scannable relation. Often appears with UNION, EXCEPT, or subqueries in FROM.

**When it's good:**
- Usually just structural glue in the plan; not itself a performance concern.

**When it's a red flag:**
- When it prevents predicate pushdown. If a filter appears on the Subquery Scan node rather than inside the subquery, the planner couldn't push it down.

---

## 3. Query Anti-Patterns and Rewrites

### 3.1 SELECT * When You Need 2 Columns

**Problem:** Fetches all columns, bloating I/O, preventing Index Only Scans, and increasing network transfer.

```sql
-- Bad: fetches all 30 columns
SELECT * FROM orders WHERE customer_id = 42;

-- Good: fetch only what you need
SELECT id, total FROM orders WHERE customer_id = 42;
```

With a covering index `(customer_id) INCLUDE (id, total)`, the rewrite enables an Index Only Scan that never touches the heap.

---

### 3.2 Correlated Subqueries to JOINs or LATERAL

**Problem:** The subquery executes once per outer row. With 100k outer rows, that's 100k separate queries.

```sql
-- Bad: correlated subquery executes per row
SELECT c.name,
       (SELECT MAX(o.total) FROM orders o WHERE o.customer_id = c.id) AS max_order
FROM customers c;

-- Good: JOIN
SELECT c.name, MAX(o.total) AS max_order
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
GROUP BY c.id, c.name;

-- Good: LATERAL (when you need top-N per row)
SELECT c.name, recent.total
FROM customers c
CROSS JOIN LATERAL (
  SELECT o.total
  FROM orders o
  WHERE o.customer_id = c.id
  ORDER BY o.created_at DESC
  LIMIT 1
) recent;
```

---

### 3.3 NOT IN With NULLs to NOT EXISTS

**Problem:** `NOT IN` with a subquery that can return NULL produces unexpected results -- if any value in the subquery is NULL, the entire `NOT IN` evaluates to NULL (not TRUE), returning zero rows. Even without NULLs, the planner often can't use a hash anti-join with `NOT IN`.

```sql
-- Bad: breaks if any excluded_customer_id is NULL, and often slower
SELECT * FROM orders
WHERE customer_id NOT IN (SELECT id FROM excluded_customers);

-- Good: correct semantics, better plans
SELECT * FROM orders o
WHERE NOT EXISTS (
  SELECT 1 FROM excluded_customers ec WHERE ec.id = o.customer_id
);
```

---

### 3.4 OR Conditions Preventing Index Use to UNION ALL

**Problem:** `OR` across different columns prevents the planner from using a single index. It may fall back to a Seq Scan.

```sql
-- Bad: can't use idx_orders_customer_id or idx_orders_email effectively
SELECT * FROM orders
WHERE customer_id = 42 OR email = 'alice@example.com';

-- Good: each branch uses its own index
SELECT * FROM orders WHERE customer_id = 42
UNION ALL
SELECT * FROM orders WHERE email = 'alice@example.com'
  AND customer_id != 42;  -- avoid duplicates if needed

-- Alternative: use a BitmapOr (PostgreSQL may do this automatically)
-- but UNION ALL makes the intent explicit and guarantees index use
```

Note: PostgreSQL can sometimes automatically use BitmapOr to combine two index scans. Check your EXPLAIN output before rewriting.

---

### 3.5 LIKE '%prefix' to Trigram or Reverse Index

**Problem:** Leading wildcard `%prefix` cannot use a standard B-tree index. The entire table is scanned.

```sql
-- Bad: seq scan on large table
SELECT * FROM products WHERE name LIKE '%widget';

-- Good: trigram index (requires pg_trgm extension)
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_products_name_trgm ON products USING gin (name gin_trgm_ops);
-- Now LIKE '%widget%', ILIKE, and similarity queries use the index

-- Alternative: reverse index for suffix matching
CREATE INDEX idx_products_name_rev ON products (reverse(name));
SELECT * FROM products WHERE reverse(name) LIKE reverse('%widget');
-- Becomes: WHERE reverse(name) LIKE 'tegdiw%' -- uses the B-tree
```

---

### 3.6 OFFSET Pagination to Keyset Pagination

**Problem:** `OFFSET 100000` still reads and discards 100,000 rows. Performance degrades linearly with page depth.

```sql
-- Bad: reads 100,020 rows, discards 100,000
SELECT * FROM orders ORDER BY created_at DESC LIMIT 20 OFFSET 100000;

-- Good: keyset pagination (constant time regardless of page depth)
-- First page
SELECT * FROM orders ORDER BY created_at DESC, id DESC LIMIT 20;

-- Next page (using last row's values as cursor)
SELECT * FROM orders
WHERE (created_at, id) < ('2024-06-15 10:30:00', 999850)
ORDER BY created_at DESC, id DESC
LIMIT 20;
```

Requires an index on `(created_at DESC, id DESC)` and a tie-breaker column (here `id`) for deterministic ordering.

---

### 3.7 COUNT(*) on Large Tables to pg_class Estimate

**Problem:** `COUNT(*)` requires a full table scan (or full index scan) in PostgreSQL. There is no stored row count.

```sql
-- Bad: scans entire table (10M rows = seconds)
SELECT COUNT(*) FROM orders;

-- Good: fast approximate count from planner statistics
SELECT reltuples::bigint AS estimate
FROM pg_class
WHERE relname = 'orders';

-- Good: exact count only when needed, with a timeout
SET statement_timeout = '2s';
SELECT COUNT(*) FROM orders;

-- Good: HyperLogLog for distinct counts (requires extension)
-- Or maintain a materialized count in a summary table
```

The `pg_class.reltuples` estimate is updated by ANALYZE and VACUUM. Accuracy depends on how recently those ran.

---

### 3.8 DISTINCT on Large Result Sets to GROUP BY or EXISTS

**Problem:** `DISTINCT` sorts or hashes the entire result set. If you only need existence, this is wasteful.

```sql
-- Bad: sorts/hashes all matching rows to deduplicate
SELECT DISTINCT customer_id FROM orders WHERE status = 'active';

-- Good: semantically identical but often better optimized
SELECT customer_id FROM orders WHERE status = 'active'
GROUP BY customer_id;

-- Better: if you need "which customers have active orders"
SELECT c.id, c.name
FROM customers c
WHERE EXISTS (
  SELECT 1 FROM orders o WHERE o.customer_id = c.id AND o.status = 'active'
);
-- EXISTS stops at the first match per customer
```

---

### 3.9 Implicit Type Casts Preventing Index Use

**Problem:** When the column type and the value type don't match, PostgreSQL inserts an implicit cast. If the cast is on the column side, the index is unusable.

```sql
-- Table: orders.id is integer
-- Bad: string literal forces cast on the column
SELECT * FROM orders WHERE id = '42';
-- Usually fine for int vs text (PG handles this), but watch for:

-- Table: events.external_id is text
-- Bad: comparing text column to integer. PG casts the column: external_id::integer = 42
-- This prevents index use on external_id
SELECT * FROM events WHERE external_id = 42;

-- Good: match types explicitly
SELECT * FROM events WHERE external_id = '42';
```

Common culprits: `bigint` vs `integer` in joins, `text` vs `varchar`, `timestamp` vs `timestamptz`. Check with `EXPLAIN` -- a function call wrapping the column in the Index Cond is the giveaway.

---

### 3.10 Functions in WHERE Preventing Index Use

**Problem:** Applying a function to a column in a WHERE clause prevents B-tree index use on that column.

```sql
-- Bad: index on created_at is useless
SELECT * FROM orders WHERE DATE(created_at) = '2024-06-15';
SELECT * FROM orders WHERE EXTRACT(YEAR FROM created_at) = 2024;
SELECT * FROM orders WHERE LOWER(email) = 'alice@example.com';

-- Good: rewrite as range predicate (uses B-tree index on created_at)
SELECT * FROM orders
WHERE created_at >= '2024-06-15' AND created_at < '2024-06-16';

-- Good: expression index if the function is necessary
CREATE INDEX idx_orders_email_lower ON orders (LOWER(email));
SELECT * FROM orders WHERE LOWER(email) = 'alice@example.com';
```

---

### 3.11 N+1 Queries via Application Code

**Problem:** ORM loads a list of parents, then issues one query per parent to fetch children. 100 parents = 101 queries.

```python
# Bad: N+1 in application code (Python / SQLAlchemy example)
customers = session.query(Customer).limit(100).all()
for c in customers:
    orders = session.query(Order).filter_by(customer_id=c.id).all()  # 100 separate queries
```

```sql
-- Good: single query with JOIN
SELECT c.id, c.name, o.id AS order_id, o.total
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
WHERE c.id IN (1, 2, 3, ..., 100);

-- Good: two queries with IN-list (common ORM "eager load" strategy)
SELECT * FROM customers WHERE id IN (1, 2, ..., 100);
SELECT * FROM orders WHERE customer_id IN (1, 2, ..., 100);
-- Application code stitches them together in memory
```

ORM-specific solutions: SQLAlchemy `joinedload()` / `selectinload()`, Django `select_related()` / `prefetch_related()`, Ecto `preload()`.

---

### 3.12 Unnecessary ORDER BY in Subqueries

**Problem:** Sorting inside a subquery, CTE, or view that the outer query re-sorts or doesn't need sorted. Wasted CPU and memory.

```sql
-- Bad: ORDER BY in subquery is pointless (outer query re-sorts)
SELECT * FROM (
  SELECT id, total FROM orders ORDER BY created_at DESC
) sub
ORDER BY total DESC
LIMIT 10;

-- Good: remove inner ORDER BY
SELECT * FROM (
  SELECT id, total FROM orders
) sub
ORDER BY total DESC
LIMIT 10;
```

Exception: `ORDER BY` in a subquery is meaningful when combined with `LIMIT` inside the subquery (top-N per group pattern).

---

## 4. Join Optimization

### When PostgreSQL Picks Each Join Type

| Join Type | Chosen When | Cost Profile |
|-----------|-------------|--------------|
| **Nested Loop** | Outer side is small (< ~1000 rows) AND inner side has an index. Also: non-equi joins, LATERAL. | O(outer * inner_lookup). Great when outer is tiny. |
| **Hash Join** | Equi-join. Inner (build) side fits in `work_mem`. Both sides have moderate-to-large cardinality. | O(inner + outer). Build cost is linear, probe is ~O(1) per row. |
| **Merge Join** | Both sides are already sorted (from indexes) by the join key. Or the sort cost is low relative to the join. | O(inner*log(inner) + outer*log(outer)) for sorting + O(inner + outer) for merge. |

### Influencing Join Order

PostgreSQL considers all possible join orderings for small queries (up to `join_collapse_limit` tables, default 8). Beyond that, it uses a genetic query optimizer (GEQO) with heuristic ordering.

```sql
-- Check current limits
SHOW join_collapse_limit;    -- Default: 8
SHOW from_collapse_limit;    -- Default: 8
SHOW geqo_threshold;         -- Default: 12

-- For a specific complex query, you can override per-session:
SET LOCAL join_collapse_limit = 12;  -- Consider more orderings (slower planning, better plan)
SET LOCAL join_collapse_limit = 1;   -- Force the written join order (use explicit JOIN syntax)
```

**Forcing join order:**

```sql
-- When join_collapse_limit = 1, PostgreSQL respects the explicit JOIN order:
SELECT ...
FROM small_table s
JOIN medium_table m ON m.id = s.medium_id       -- join small to medium first
JOIN large_table l ON l.id = m.large_id          -- then join result to large
```

This is a last resort. If you need it, the root cause is usually stale statistics or a structural problem the planner can't see.

### Join Selectivity

The planner estimates join selectivity as `1/max(n_distinct_left, n_distinct_right)` for equi-joins. When this estimate is wrong:
- The planner may pick Nested Loop when Hash Join would be better (or vice versa)
- Row estimates cascade -- a bad estimate early in the plan corrupts everything downstream

Fix: `ANALYZE` both tables. If the correlation between columns is complex, use extended statistics (see Section 6).

### Dealing with Many-Table Joins

For queries joining 10+ tables:

1. **Check `join_collapse_limit`:** If the query has more tables than this limit, the planner falls back to heuristic ordering. Temporarily raise the limit if planning time is acceptable.

2. **Materialize intermediate results:** Break the query into CTEs or temp tables for the most selective filters first.

3. **Check statistics:** Run `ANALYZE` on all involved tables. Missing statistics are the #1 cause of bad plans on complex joins.

4. **Use EXPLAIN to find the bottleneck:** The slowest node in the plan tree tells you where to focus.

---

## 5. Subquery vs CTE vs Lateral Join

### Subqueries (Inline)

The planner can freely optimize: push predicates down, flatten into joins, re-order.

```sql
-- Planner can push the WHERE into the subquery
SELECT * FROM (
  SELECT id, total, customer_id FROM orders
) sub
WHERE sub.customer_id = 42;
-- Equivalent to: SELECT id, total, customer_id FROM orders WHERE customer_id = 42
```

**Use when:** The query is a building block the planner should optimize holistically.

### Common Table Expressions (CTEs)

**PostgreSQL 12+ behavior:** Non-recursive CTEs referenced once are inlined (treated like subqueries). The planner optimizes through them freely.

**Force materialization** (when you want the optimization fence):
```sql
WITH expensive_calc AS MATERIALIZED (
  SELECT customer_id, SUM(total) AS lifetime_value
  FROM orders
  GROUP BY customer_id
)
SELECT c.name, ec.lifetime_value
FROM customers c
JOIN expensive_calc ec ON ec.customer_id = c.id
WHERE ec.lifetime_value > 10000;
```

**Force inlining** (explicitly, for clarity):
```sql
WITH recent AS NOT MATERIALIZED (
  SELECT * FROM orders WHERE created_at > NOW() - INTERVAL '7 days'
)
SELECT * FROM recent WHERE total > 100;
-- Planner combines both filters into a single scan
```

**Pre-PostgreSQL 12 trap:** All CTEs were materialized. This meant:

```sql
-- PG 11 and earlier: this materializes ALL orders, then filters
WITH all_orders AS (
  SELECT * FROM orders
)
SELECT * FROM all_orders WHERE customer_id = 42;
-- Fix for PG 11: use a subquery instead
```

### LATERAL Joins

LATERAL allows a subquery in FROM to reference columns from preceding tables. It's like a correlated subquery but in the FROM clause, letting you return multiple columns and rows.

```sql
-- Top 3 orders per customer (LATERAL is the clean way)
SELECT c.name, top_orders.*
FROM customers c
CROSS JOIN LATERAL (
  SELECT o.id, o.total, o.created_at
  FROM orders o
  WHERE o.customer_id = c.id
  ORDER BY o.total DESC
  LIMIT 3
) top_orders;
```

**Use when:**
- Top-N per group
- Calling a set-returning function per row
- The subquery depends on the outer row and returns multiple columns

**Performance:** Executes as a Nested Loop internally. Needs an efficient inner path (usually an index scan). If the outer side has many rows and the inner side has no index, this will be slow.

### Decision Matrix

| Scenario | Use |
|----------|-----|
| Simple filter/transform the planner should optimize through | Subquery |
| Referenced multiple times in the same query | CTE (materialized) |
| Expensive calculation you want computed once | CTE with MATERIALIZED |
| Top-N per group | LATERAL |
| Set-returning function per row | LATERAL |
| PG 11 or older, need predicate pushdown | Subquery (avoid CTE) |
| PG 12+, referenced once, no preference | Either (CTE is inlined automatically) |

---

## 6. Statistics and the Planner

### How the Planner Estimates Rows

The planner uses per-column statistics stored in `pg_stats` to estimate how many rows will match a given condition. Bad estimates lead to bad plans.

```sql
-- View statistics for a column
SELECT
  schemaname, tablename, attname,
  n_distinct,
  most_common_vals,
  most_common_freqs,
  histogram_bounds,
  correlation,
  null_frac
FROM pg_stats
WHERE tablename = 'orders' AND attname = 'status';
```

| Statistic | Meaning |
|-----------|---------|
| `n_distinct` | Number of distinct values. Negative means fraction of rows (e.g., -0.5 = half as many distinct values as rows). |
| `most_common_vals` | Array of the most frequently occurring values. |
| `most_common_freqs` | Frequency of each MCV (fraction of rows with that value). |
| `histogram_bounds` | Equal-frequency histogram boundaries for values not in MCV list. |
| `correlation` | Physical row order vs logical order (-1 to 1). High correlation = sequential access is efficient. |
| `null_frac` | Fraction of rows that are NULL. |

### When to Increase Statistics Target

The default `statistics target` is 100 (meaning 100 MCVs and 100 histogram buckets). For columns with many distinct values or skewed distributions, this may be too few.

```sql
-- Check current target
SELECT attstattarget
FROM pg_attribute
WHERE attrelid = 'orders'::regclass AND attname = 'customer_id';
-- -1 means "use default_statistics_target" (usually 100)

-- Increase for a specific column
ALTER TABLE orders ALTER COLUMN customer_id SET STATISTICS 1000;
ANALYZE orders;

-- Increase the server-wide default (rare, usually per-column is better)
-- SET default_statistics_target = 500;
```

**When to increase:**
- The planner consistently mis-estimates rows for this column (check estimated vs actual in EXPLAIN ANALYZE)
- The column has thousands of distinct values with uneven distribution
- The column is used in complex WHERE clauses or as a join key

**Cost:** Higher statistics targets make `ANALYZE` slower and use more memory in `pg_statistic`. 500-1000 is reasonable for problem columns. 10000 is rarely needed.

### Extended Statistics for Correlated Columns

The planner assumes column values are independent. When they're correlated (e.g., `city` and `zipcode`), estimates can be wildly wrong.

```sql
-- Example: city and state are correlated
-- Planner estimates: P(city='Portland') * P(state='OR') = very small
-- Reality: Portland + OR is common; Portland + ME exists but is rare

-- Create extended statistics
CREATE STATISTICS stats_orders_city_state (dependencies, ndistinct, mcv)
  ON city, state FROM orders;
ANALYZE orders;

-- Verify they're being used
EXPLAIN ANALYZE SELECT * FROM orders WHERE city = 'Portland' AND state = 'OR';
-- Check if row estimates improved
```

Types of extended statistics:
- `dependencies`: Tracks functional dependencies between columns
- `ndistinct`: Tracks distinct-value counts for column combinations
- `mcv` (PG 12+): Tracks most common value combinations

### Forcing a Re-Plan

When statistics are stale, queries get bad plans:

```sql
-- Update statistics for one table
ANALYZE orders;

-- Update statistics for the entire database
ANALYZE;

-- Check when ANALYZE last ran
SELECT relname, last_analyze, last_autoanalyze, n_live_tup, n_dead_tup
FROM pg_stat_user_tables
WHERE relname = 'orders';
```

If `last_analyze` is NULL or old, the planner is working with stale data. Configure `autovacuum` to run ANALYZE more frequently on high-churn tables:

```sql
ALTER TABLE orders SET (autovacuum_analyze_scale_factor = 0.02);
-- Default is 0.1 (10% of table must change before auto-analyze). 0.02 = 2%.
```

---

## 7. Locking and Concurrency

### Row-Level Locks

```sql
-- FOR UPDATE: exclusive lock, blocks other FOR UPDATE and FOR SHARE
-- Use when you will modify the selected rows
SELECT * FROM accounts WHERE id = 42 FOR UPDATE;

-- FOR SHARE: shared lock, blocks FOR UPDATE but allows other FOR SHARE
-- Use when you need to ensure the row isn't modified while you read it
SELECT * FROM accounts WHERE id = 42 FOR SHARE;

-- SKIP LOCKED: skip rows that are already locked (useful for job queues)
SELECT * FROM jobs WHERE status = 'pending'
ORDER BY created_at
LIMIT 1
FOR UPDATE SKIP LOCKED;

-- NOWAIT: error immediately if the row is locked (don't wait)
SELECT * FROM accounts WHERE id = 42 FOR UPDATE NOWAIT;
```

### Advisory Locks

Application-level locks not tied to any row or table. Useful for coordinating processes.

```sql
-- Session-level advisory lock (held until explicit unlock or session end)
SELECT pg_advisory_lock(12345);          -- Blocks until acquired
SELECT pg_try_advisory_lock(12345);      -- Returns TRUE/FALSE, never blocks
SELECT pg_advisory_unlock(12345);        -- Release

-- Transaction-level advisory lock (released at end of transaction)
SELECT pg_advisory_xact_lock(12345);

-- Two-key variant (namespace your locks)
SELECT pg_advisory_lock(1, 42);  -- class=1, id=42
```

Common use cases: preventing duplicate cron jobs, serializing access to an external resource, rate limiting.

### Deadlock Detection

PostgreSQL automatically detects deadlocks (default check interval: 1 second, controlled by `deadlock_timeout`) and aborts one of the transactions.

```sql
-- Transaction 1:
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;  -- locks row 1
UPDATE accounts SET balance = balance + 100 WHERE id = 2;  -- waits for T2's lock on row 2

-- Transaction 2 (concurrent):
BEGIN;
UPDATE accounts SET balance = balance - 50 WHERE id = 2;   -- locks row 2
UPDATE accounts SET balance = balance + 50 WHERE id = 1;   -- waits for T1's lock on row 1
-- DEADLOCK: PostgreSQL kills one transaction with:
-- ERROR: deadlock detected
```

**Prevention:** Always lock rows in a consistent order (e.g., by primary key ascending).

### Finding Blockers with pg_stat_activity

```sql
-- Find blocked queries and what's blocking them
SELECT
  blocked.pid AS blocked_pid,
  blocked.query AS blocked_query,
  blocked.wait_event_type,
  blocked.wait_event,
  blocking.pid AS blocking_pid,
  blocking.query AS blocking_query,
  blocking.state AS blocking_state,
  NOW() - blocking.query_start AS blocking_duration
FROM pg_stat_activity blocked
JOIN pg_locks bl ON bl.pid = blocked.pid AND NOT bl.granted
JOIN pg_locks gl ON gl.locktype = bl.locktype
  AND gl.database IS NOT DISTINCT FROM bl.database
  AND gl.relation IS NOT DISTINCT FROM bl.relation
  AND gl.page IS NOT DISTINCT FROM bl.page
  AND gl.tuple IS NOT DISTINCT FROM bl.tuple
  AND gl.virtualxid IS NOT DISTINCT FROM bl.virtualxid
  AND gl.transactionid IS NOT DISTINCT FROM bl.transactionid
  AND gl.classid IS NOT DISTINCT FROM bl.classid
  AND gl.objid IS NOT DISTINCT FROM bl.objid
  AND gl.objsubid IS NOT DISTINCT FROM bl.objsubid
  AND gl.pid != bl.pid
  AND gl.granted
JOIN pg_stat_activity blocking ON blocking.pid = gl.pid
WHERE blocked.wait_event_type = 'Lock';

-- Simpler: just show waiting queries
SELECT pid, query, wait_event_type, wait_event, state,
       NOW() - query_start AS duration
FROM pg_stat_activity
WHERE wait_event_type = 'Lock';
```

### How Long-Running Queries Affect VACUUM

VACUUM cannot remove dead tuples that are still visible to any running transaction. A long-running query (even a read-only SELECT) holds back the `xmin` horizon, preventing cleanup.

```sql
-- Find the oldest running transaction
SELECT pid, query, state, backend_xmin,
       NOW() - xact_start AS transaction_age
FROM pg_stat_activity
WHERE backend_xmin IS NOT NULL
ORDER BY backend_xmin
LIMIT 5;

-- Check if autovacuum is being held back
SELECT relname, n_dead_tup, last_autovacuum
FROM pg_stat_user_tables
WHERE n_dead_tup > 10000
ORDER BY n_dead_tup DESC;
```

**Impact:** Tables accumulate dead tuples (bloat), queries slow down, disk usage grows. Set `idle_in_transaction_session_timeout` to kill forgotten transactions:

```sql
-- Kill idle-in-transaction sessions after 10 minutes
ALTER DATABASE mydb SET idle_in_transaction_session_timeout = '10min';

-- Per-session statement timeout for long queries
SET statement_timeout = '30s';
```

---

## 8. Common Tuning Scenarios

### "This Aggregation Query Is Slow"

**Diagnosis:**

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, SUM(total), COUNT(*)
FROM orders
WHERE created_at > '2024-01-01'
GROUP BY customer_id;
```

**Check for:**

1. **HashAggregate spilling to disk** -- `Batches > 1` or `Disk Usage` in the plan.
   ```sql
   -- Fix: increase work_mem for this query
   SET LOCAL work_mem = '256MB';
   -- Then re-run the query
   ```

2. **Seq Scan when an index exists on `created_at`** -- stale statistics.
   ```sql
   ANALYZE orders;
   ```

3. **Too many groups** -- if `customer_id` has millions of distinct values, HashAggregate needs memory proportional to the number of groups.
   ```sql
   -- Consider a partial aggregation with a materialized view
   CREATE MATERIALIZED VIEW mv_order_totals AS
   SELECT customer_id, DATE_TRUNC('month', created_at) AS month,
          SUM(total) AS monthly_total, COUNT(*) AS order_count
   FROM orders
   GROUP BY customer_id, DATE_TRUNC('month', created_at);

   CREATE UNIQUE INDEX ON mv_order_totals (customer_id, month);
   ```

4. **Sort-based GroupAggregate with expensive Sort** -- the planner chose to sort instead of hash.
   ```sql
   -- Check if disabling sort helps (diagnostic only, don't leave this on)
   SET LOCAL enable_sort = off;
   EXPLAIN ANALYZE SELECT ...;  -- does HashAggregate give a better plan?
   ```

---

### "Bulk INSERT Is Slow"

**Techniques, from easiest to most aggressive:**

1. **Use COPY instead of INSERT:**
   ```sql
   -- 10-50x faster than individual INSERTs
   COPY orders (customer_id, total, created_at)
   FROM '/tmp/orders.csv' WITH (FORMAT csv, HEADER);

   -- From application code, use COPY protocol (most drivers support it)
   -- Python: psycopg2 copy_expert(), asyncpg copy_records_to_table()
   ```

2. **Batch INSERTs** (if COPY isn't possible):
   ```sql
   -- Bad: one INSERT per row
   INSERT INTO orders (customer_id, total) VALUES (1, 100);
   INSERT INTO orders (customer_id, total) VALUES (2, 200);

   -- Good: multi-row INSERT (up to ~1000 rows per statement)
   INSERT INTO orders (customer_id, total) VALUES
     (1, 100), (2, 200), (3, 300), ...;
   ```

3. **Disable indexes during bulk load, rebuild after:**
   ```sql
   -- Drop indexes
   DROP INDEX idx_orders_customer_id;
   DROP INDEX idx_orders_created_at;

   -- Load data
   COPY orders FROM '/tmp/orders.csv' WITH (FORMAT csv);

   -- Rebuild indexes (CREATE INDEX CONCURRENTLY if the table is live)
   CREATE INDEX idx_orders_customer_id ON orders (customer_id);
   CREATE INDEX idx_orders_created_at ON orders (created_at);
   ```

4. **Disable triggers and constraints temporarily:**
   ```sql
   ALTER TABLE orders DISABLE TRIGGER ALL;
   -- ... bulk load ...
   ALTER TABLE orders ENABLE TRIGGER ALL;
   ```

5. **Adjust WAL settings** (for initial data loads, not production traffic):
   ```sql
   SET LOCAL synchronous_commit = off;    -- Don't wait for WAL flush
   -- For truly bulk loads into empty tables:
   -- Consider UNLOGGED tables (no WAL at all, data lost on crash)
   ```

6. **Increase `checkpoint_timeout` and `max_wal_size`** to reduce checkpoint frequency during bulk loads (requires superuser / postgresql.conf).

---

### "DELETE of Millions of Rows Is Slow"

**Problem:** `DELETE FROM orders WHERE created_at < '2020-01-01'` on a 50M row table acquires locks, generates WAL, updates indexes, and creates dead tuples that VACUUM must clean up.

**Approach 1: Batch deletes**
```sql
-- Delete in batches of 10,000 to limit lock duration and WAL generation
DO $$
DECLARE
  rows_deleted INTEGER;
BEGIN
  LOOP
    DELETE FROM orders
    WHERE id IN (
      SELECT id FROM orders
      WHERE created_at < '2020-01-01'
      LIMIT 10000
    );
    GET DIAGNOSTICS rows_deleted = ROW_COUNT;
    EXIT WHEN rows_deleted = 0;
    PERFORM pg_sleep(0.1);  -- Brief pause to let other transactions through
    COMMIT;
  END LOOP;
END $$;

-- Simpler version using ctid (avoids subquery):
DELETE FROM orders
WHERE ctid IN (
  SELECT ctid FROM orders
  WHERE created_at < '2020-01-01'
  LIMIT 10000
);
-- Run in a loop from application code
```

**Approach 2: Partition + DROP (best for recurring purges)**
```sql
-- Retroactively partition by range on created_at
-- (Requires restructuring the table -- plan this ahead)
CREATE TABLE orders (
  id BIGSERIAL,
  customer_id INTEGER,
  total NUMERIC,
  created_at TIMESTAMPTZ
) PARTITION BY RANGE (created_at);

CREATE TABLE orders_2023 PARTITION OF orders
  FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');
CREATE TABLE orders_2024 PARTITION OF orders
  FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

-- Purging old data is instant:
DROP TABLE orders_2019;  -- No dead tuples, no VACUUM, instant
-- Or detach first if you want to archive:
ALTER TABLE orders DETACH PARTITION orders_2019;
```

**Approach 3: Recreate the table** (if deleting most rows)
```sql
-- When keeping 5% and deleting 95%, it's faster to keep than delete
CREATE TABLE orders_new AS
SELECT * FROM orders WHERE created_at >= '2020-01-01';

-- Recreate indexes, constraints, etc. on orders_new
-- Then swap:
BEGIN;
ALTER TABLE orders RENAME TO orders_old;
ALTER TABLE orders_new RENAME TO orders;
COMMIT;

DROP TABLE orders_old;
```

---

### "This JOIN Between Two Large Tables Is Slow"

**Diagnosis:**

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT o.id, o.total, c.name
FROM orders o
JOIN customers c ON c.id = o.customer_id
WHERE o.created_at > '2024-01-01';
```

**Check for:**

1. **Hash Join spilling to disk** -- `Batches > 1`:
   ```sql
   SET LOCAL work_mem = '512MB';
   -- Re-run. If batches drop to 1, the join fits in memory now.
   ```

2. **Wrong join type** -- Nested Loop on two large tables:
   ```sql
   -- Check row estimates. If estimated rows=100 but actual rows=1000000,
   -- the planner chose Nested Loop thinking the outer side was tiny.
   ANALYZE orders;
   ANALYZE customers;
   ```

3. **Missing index on join key:**
   ```sql
   -- If customers.id lacks a primary key or unique index (unlikely but check)
   -- If orders.customer_id lacks an index (common)
   CREATE INDEX idx_orders_customer_id ON orders (customer_id);
   ```

4. **Merge Join with expensive Sorts** -- both sides lack indexes on the join key:
   ```sql
   -- If the plan shows Sort nodes before the Merge Join, indexes on the
   -- join keys would eliminate the sorts.
   ```

5. **Consider partial results:**
   ```sql
   -- If you only need aggregates, push the aggregation down
   SELECT c.name, SUM(o.total)
   FROM orders o
   JOIN customers c ON c.id = o.customer_id
   WHERE o.created_at > '2024-01-01'
   GROUP BY c.id, c.name;
   -- The GROUP BY may allow the planner to use a more efficient strategy
   ```

---

### "Query Was Fast Yesterday, Slow Today"

**Systematic checklist:**

1. **Check if ANALYZE has run recently:**
   ```sql
   SELECT relname, last_analyze, last_autoanalyze,
          n_live_tup, n_dead_tup,
          n_mod_since_analyze
   FROM pg_stat_user_tables
   WHERE relname IN ('orders', 'customers')
   ORDER BY n_mod_since_analyze DESC;
   -- If n_mod_since_analyze is large, statistics are stale
   ANALYZE orders;
   ```

2. **Check for table bloat** (dead tuples not cleaned up):
   ```sql
   SELECT relname, n_dead_tup, n_live_tup,
          ROUND(n_dead_tup::numeric / GREATEST(n_live_tup, 1) * 100, 1) AS dead_pct,
          last_autovacuum
   FROM pg_stat_user_tables
   WHERE n_dead_tup > 10000
   ORDER BY n_dead_tup DESC;

   -- If dead_pct is high (>20%), VACUUM is behind
   VACUUM (VERBOSE) orders;
   ```

3. **Compare the old plan vs the new plan:**
   ```sql
   -- If you have the old plan saved (from logs or pg_stat_statements), compare.
   -- Force the planner to reconsider:
   ANALYZE orders;
   -- Then check EXPLAIN ANALYZE again.
   ```

4. **Check for lock contention:**
   ```sql
   SELECT pid, query, wait_event_type, wait_event, state,
          NOW() - query_start AS duration
   FROM pg_stat_activity
   WHERE state != 'idle'
   ORDER BY duration DESC;
   ```

5. **Check `pg_stat_statements` for plan changes** (requires extension):
   ```sql
   SELECT query, calls, mean_exec_time, stddev_exec_time,
          rows, shared_blks_hit, shared_blks_read
   FROM pg_stat_statements
   WHERE query LIKE '%orders%'
   ORDER BY mean_exec_time DESC
   LIMIT 10;

   -- Large stddev_exec_time relative to mean suggests plan instability
   ```

6. **Check for data skew changes:**
   ```sql
   -- Did a bulk import happen that changed the data distribution?
   SELECT most_common_vals, most_common_freqs
   FROM pg_stats
   WHERE tablename = 'orders' AND attname = 'status';
   -- If a previously rare value became common, the planner's cached
   -- selectivity estimates are wrong. ANALYZE fixes this.
   ```

7. **Check system resources:**
   ```sql
   -- Is the server under memory pressure? (from OS)
   -- Is shared_buffers being competed for?
   SELECT * FROM pg_stat_bgwriter;
   -- High buffers_backend (vs buffers_checkpoint/buffers_clean) means
   -- backends are doing their own writes -- shared_buffers is too small
   -- or checkpoint frequency is too low.
   ```

---

## 9. Materialized Views

### When to Materialize

Materialized views pre-compute and store query results. Use them when:

- A complex aggregation or JOIN is queried frequently but the underlying data changes slowly
- Dashboard queries that scan millions of rows but only need hourly/daily granularity
- Denormalized "read models" for reporting that would otherwise require expensive multi-table JOINs
- Cross-database or cross-schema aggregations where the source data is too slow to query live

Do NOT use materialized views when:
- The underlying data changes frequently and staleness is unacceptable (use TimescaleDB continuous aggregates instead)
- The view is small enough that the base query is already fast (<100ms)
- You need real-time data (materialized views are stale by definition until refreshed)

### Creating and Refreshing

```sql
-- Create with initial data:
CREATE MATERIALIZED VIEW mv_monthly_revenue AS
SELECT
  DATE_TRUNC('month', created_at) AS month,
  region,
  SUM(total) AS revenue,
  COUNT(*) AS order_count,
  AVG(total) AS avg_order_value
FROM orders
GROUP BY DATE_TRUNC('month', created_at), region
WITH DATA;

-- Create empty (populate later):
CREATE MATERIALIZED VIEW mv_monthly_revenue AS
SELECT ... WITH NO DATA;

-- Full refresh (replaces all data, blocks concurrent reads):
REFRESH MATERIALIZED VIEW mv_monthly_revenue;

-- Concurrent refresh (requires a UNIQUE index, does not block reads):
CREATE UNIQUE INDEX ON mv_monthly_revenue (month, region);
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_monthly_revenue;
```

### How `CONCURRENTLY` Works Internally

A non-concurrent refresh:
1. Acquires `AccessExclusiveLock` on the materialized view (blocks ALL queries)
2. Truncates the view's storage
3. Runs the view query and inserts all results
4. Releases the lock

A concurrent refresh:
1. Acquires `ExclusiveLock` (blocks other refreshes and DDL, but NOT reads)
2. Runs the view query into a temporary staging area
3. Computes a diff between old and new data using the UNIQUE index
4. Applies INSERT/DELETE for changed rows
5. Releases the lock

**The diff step is expensive.** For a materialized view with 10M rows where 1% changed, `CONCURRENTLY` reads all 10M rows twice (old + new) to find the 100K differences. On views where most data changes each refresh, `CONCURRENTLY` is slower than a full refresh.

**Rule of thumb:** Use `CONCURRENTLY` when <20% of rows change per refresh. Above that, a full refresh during a maintenance window may be faster.

### Indexing Materialized Views

Materialized views support all PostgreSQL index types. Index them like any table:

```sql
-- B-tree for point lookups and range queries:
CREATE INDEX ON mv_monthly_revenue (region, month DESC);

-- The UNIQUE index required for CONCURRENTLY also serves as a query index:
CREATE UNIQUE INDEX ON mv_monthly_revenue (month, region);

-- GIN for JSONB or full-text search on materialized data:
CREATE INDEX ON mv_search_results USING gin (search_vector);
```

**Indexes are maintained during refresh.** A full refresh drops and rebuilds all indexes (expensive). A concurrent refresh updates indexes incrementally (cheaper per-change but more total work if many rows change).

### Refresh Strategies

| Strategy | Implementation | Best For |
|----------|---------------|----------|
| **Scheduled cron** | `pg_cron`: `SELECT cron.schedule('0 * * * *', 'REFRESH MATERIALIZED VIEW CONCURRENTLY mv_hourly')` | Regular intervals, predictable staleness |
| **Application-triggered** | Call `REFRESH` after batch operations complete | Event-driven updates, minimal staleness |
| **Lazy refresh** | Check `pg_stat_user_tables.n_tup_ins` on source tables; refresh only when threshold exceeded | Reduce unnecessary refreshes on slowly-changing data |
| **Staggered** | Refresh different MVs at different offsets to avoid I/O spikes | Multiple materialized views on the same database |

```sql
-- Using pg_cron (requires extension):
CREATE EXTENSION pg_cron;

-- Refresh hourly:
SELECT cron.schedule('refresh_mv_revenue', '5 * * * *',
  'REFRESH MATERIALIZED VIEW CONCURRENTLY mv_monthly_revenue');

-- Check when last refresh happened:
SELECT schemaname, matviewname, ispopulated
FROM pg_matviews
WHERE matviewname = 'mv_monthly_revenue';

-- There is no built-in "last refreshed" timestamp. Track it yourself:
CREATE TABLE mv_refresh_log (
  view_name TEXT PRIMARY KEY,
  last_refreshed TIMESTAMPTZ
);

-- After refresh:
INSERT INTO mv_refresh_log VALUES ('mv_monthly_revenue', NOW())
ON CONFLICT (view_name) DO UPDATE SET last_refreshed = NOW();
```

### Materialized View Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| Refreshing every minute | Full refresh on large views causes I/O spikes and lock contention | Refresh at the minimum frequency your staleness tolerance allows; use `CONCURRENTLY` |
| No UNIQUE index + `CONCURRENTLY` | Refresh fails with error | Add a unique index on the view's natural key |
| Materialized view on a view on a view | Each layer adds planning overhead; inner views can't be optimized through | Flatten into a single query |
| Using MV as a cache for hot OLTP queries | MV is stale by definition; OLTP queries need fresh data | Use proper caching (Redis, application cache) or indexed queries |
| Forgetting to refresh after migrations | Schema changes to source tables don't propagate to MVs | Add refresh to migration scripts; monitor `ispopulated` column |
| `SELECT *` in MV definition | Future column additions to source tables don't propagate; MV becomes stale in structure | Explicitly name all columns in the MV query |

### Materialized Views vs Other Caching Strategies

| Strategy | Freshness | Query Flexibility | Maintenance |
|----------|-----------|-------------------|-------------|
| **Materialized view** | Stale until refresh | Full SQL (indexes, JOINs, aggregations on the MV) | `REFRESH` + index maintenance |
| **UNLOGGED table + INSERT** | Custom (application controls) | Full SQL | Application manages lifecycle |
| **Redis/Memcached** | TTL-based | Key-value only | Application manages serialization |
| **Application-level cache** | TTL or event-based | Language-native objects | Invalidation logic in app code |
| **TimescaleDB CAgg** | Near-real-time (incremental + live merge) | Full SQL on aggregated time-series | Automatic background refresh |

### Monitoring Materialized Views

```sql
-- Size of materialized views:
SELECT
  schemaname, matviewname,
  pg_size_pretty(pg_total_relation_size(schemaname || '.' || matviewname)) AS total_size,
  ispopulated
FROM pg_matviews
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(schemaname || '.' || matviewname) DESC;

-- Check if refresh is currently running (look for REFRESH in active queries):
SELECT pid, query, state, now() - query_start AS duration
FROM pg_stat_activity
WHERE query ILIKE '%refresh materialized%'
  AND state != 'idle';

-- Dead tuples on MV (indicates concurrent refresh is working — old rows being replaced):
SELECT relname, n_live_tup, n_dead_tup, last_vacuum, last_autovacuum
FROM pg_stat_user_tables
WHERE relname LIKE 'mv_%';
```

---

## Quick Reference: Diagnostic Queries

```sql
-- Top 10 slowest query patterns (requires pg_stat_statements)
SELECT LEFT(query, 80) AS query_preview,
       calls, mean_exec_time::numeric(10,2) AS avg_ms,
       total_exec_time::numeric(10,2) AS total_ms,
       rows
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Tables most in need of VACUUM
SELECT relname, n_dead_tup, n_live_tup, last_autovacuum, last_autoanalyze
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC
LIMIT 10;

-- Index usage (find unused indexes)
SELECT schemaname, relname, indexrelname,
       idx_scan, idx_tup_read, idx_tup_fetch,
       pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY pg_relation_size(indexrelid) DESC;

-- Cache hit ratio (should be >99% for OLTP)
SELECT
  SUM(heap_blks_hit) AS hit,
  SUM(heap_blks_read) AS read,
  ROUND(SUM(heap_blks_hit)::numeric / GREATEST(SUM(heap_blks_hit) + SUM(heap_blks_read), 1) * 100, 2) AS hit_ratio
FROM pg_statio_user_tables;

-- Current locks
SELECT l.locktype, l.mode, l.granted, l.pid, a.query
FROM pg_locks l
JOIN pg_stat_activity a ON a.pid = l.pid
WHERE NOT l.granted;

-- Table sizes (including indexes and toast)
SELECT relname,
       pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
       pg_size_pretty(pg_relation_size(relid)) AS table_size,
       pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) AS index_toast_size
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(relid) DESC
LIMIT 10;
```
