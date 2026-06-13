# PostgreSQL Indexing Strategy Reference

A practical reference for choosing, designing, and maintaining indexes in PostgreSQL. Written for mid-to-senior developers who need to answer: **"What index do I need?"**

---

## Table of Contents

1. [Index Types](#1-index-types)
2. [Index Selection Decision Table](#2-index-selection-decision-table)
3. [Composite Index Design](#3-composite-index-design)
4. [Partial Indexes](#4-partial-indexes)
5. [Expression Indexes](#5-expression-indexes)
6. [Covering Indexes (INCLUDE)](#6-covering-indexes-include)
7. [Index Maintenance](#7-index-maintenance)
8. [Anti-Patterns](#8-anti-patterns)
9. [Cost Estimation and EXPLAIN](#9-cost-estimation-and-explain)

---

## 1. Index Types

### B-tree

**How it works:** Stores keys in a balanced tree structure where each internal node contains sorted keys and pointers to child nodes, enabling binary-search-style traversal. Leaf nodes form a doubly-linked list for efficient range scans.

**Ideal use case:** Equality lookups, range queries, sorting, and any comparison using `<`, `<=`, `=`, `>=`, `>`, `BETWEEN`, `IN`, `IS NULL`, and `IS NOT NULL`. This is the default index type and the correct choice for 80%+ of indexing needs.

**Syntax:**
```sql
-- Explicit (default, so the USING clause is optional)
CREATE INDEX idx_orders_created_at ON orders USING btree (created_at);

-- Equivalent shorthand
CREATE INDEX idx_orders_created_at ON orders (created_at);

-- Descending with NULLS FIRST
CREATE INDEX idx_orders_amount_desc ON orders (amount DESC NULLS FIRST);
```

**Performance characteristics:**
- Lookup: O(log n)
- Range scan: O(log n + k) where k = number of matching rows
- Insertion: O(log n), plus potential page splits
- Supports `ORDER BY` elimination when sort order matches index order

**Storage overhead:** Moderate. Typically 2-3x the size of the indexed column data. A B-tree on an integer column over 10M rows is roughly 200-300 MB. Each leaf page is 8 KB by default.

---

### Hash

**How it works:** Maps each key through a hash function to a bucket. Lookups go directly to the bucket, making equality checks fast but range queries impossible.

**Ideal use case:** Pure equality lookups (`=`) on columns where you will never need range scans or sorting. Practical use cases are narrow -- B-tree handles equality well and also supports ranges.

**Syntax:**
```sql
CREATE INDEX idx_sessions_token ON sessions USING hash (token);
```

**Performance characteristics:**
- Equality lookup: O(1) amortized
- Does NOT support: `<`, `>`, `BETWEEN`, `ORDER BY`, `IS NULL`
- Slightly faster than B-tree for equality-only workloads on large tables
- WAL-logged since PostgreSQL 10 (safe for replication)

**Storage overhead:** Lower than B-tree for wide keys (long strings, UUIDs). For narrow keys (integers), B-tree is comparable or smaller.

**When to actually use it:** Rarely. Consider it when you have a very wide key (e.g., 256-byte tokens) used exclusively for equality checks and you want to save space vs. B-tree.

---

### GiST (Generalized Search Tree)

**How it works:** A balanced tree that supports user-defined decomposition of data into tree structure. Each internal node contains a "bounding" predicate that covers all children, enabling top-down search by testing containment at each level.

**Ideal use case:** Geometric/spatial data (PostGIS), range types, full-text search (with `tsvector`), nearest-neighbor queries, exclusion constraints.

**Syntax:**
```sql
-- Geometric: find points within a bounding box
CREATE INDEX idx_locations_point ON locations USING gist (coordinates);

-- Range type: find overlapping time ranges
CREATE INDEX idx_reservations_during ON reservations USING gist (during);

-- Full-text search (alternative to GIN, see trade-offs below)
CREATE INDEX idx_articles_fts ON articles USING gist (search_vector);

-- Exclusion constraint: no overlapping reservations for the same room
ALTER TABLE reservations
  ADD CONSTRAINT no_overlap
  EXCLUDE USING gist (room_id WITH =, during WITH &&);
```

**Performance characteristics:**
- Supports operators: `<<`, `>>`, `&&` (overlap), `@>` (contains), `<@` (contained by), `<->` (distance)
- Lossy for some data types -- may require recheck against the heap
- Slower than GIN for full-text search queries, but faster for updates
- Supports `ORDER BY <->` for K-nearest-neighbor (KNN) scans

**Storage overhead:** Higher than B-tree. Typically 3-5x indexed data size due to bounding-box overhead.

---

### SP-GiST (Space-Partitioned GiST)

**How it works:** A non-balanced tree that partitions space into non-overlapping regions using structures like quadtrees, k-d trees, or radix trees. Unlike GiST, child nodes never overlap, which can yield faster searches when data clusters well in partitioned space.

**Ideal use case:** Phone numbers (radix tree), IP addresses (`inet`), geometric points when data has natural spatial clustering, text with prefix searches.

**Syntax:**
```sql
-- IP address lookups
CREATE INDEX idx_logs_ip ON access_logs USING spgist (client_ip);

-- Point data with quadtree partitioning
CREATE INDEX idx_coords ON places USING spgist (location);

-- Text prefix searches (radix tree)
CREATE INDEX idx_phones ON contacts USING spgist (phone_number);
```

**Performance characteristics:**
- Can outperform GiST when data partitions cleanly into non-overlapping regions
- Supports: `<<`, `>>`, `@>`, `<@`, `=`, `~=`
- Not suitable for data with heavy overlap (use GiST instead)
- Does not support KNN ordering

**Storage overhead:** Generally lower than GiST due to simpler node structure. Comparable to or slightly larger than B-tree.

---

### GIN (Generalized Inverted Index)

**How it works:** Builds an inverted index -- a sorted list of all distinct element values (keys), each pointing to the set of rows containing that value. Similar to how a book's back-of-book index maps terms to page numbers.

**Ideal use case:** Full-text search (`tsvector`/`tsquery`), JSONB containment (`@>`), array operators (`&&`, `@>`, `<@`), trigram similarity (`pg_trgm`).

**Syntax:**
```sql
-- Full-text search
CREATE INDEX idx_articles_search ON articles USING gin (search_vector);

-- JSONB containment queries
CREATE INDEX idx_events_data ON events USING gin (metadata jsonb_path_ops);

-- Array overlap/containment
CREATE INDEX idx_products_tags ON products USING gin (tags);

-- Trigram similarity (requires pg_trgm extension)
CREATE INDEX idx_users_name_trgm ON users USING gin (name gin_trgm_ops);
```

**Performance characteristics:**
- Exact match and containment lookups are very fast (O(1) per key + bitmap merge)
- Slower to build and update than B-tree or GiST -- uses a "pending list" to batch inserts
- Queries against a GIN with a large pending list can be slow; tune `gin_pending_list_limit`
- `jsonb_path_ops` is smaller and faster than default `jsonb_ops` but only supports `@>` (containment)

**Storage overhead:** High. Can be 2-10x the source data depending on the number of distinct keys. JSONB GIN indexes on wide documents can be very large.

**GIN vs GiST for full-text search:**
| Factor | GIN | GiST |
|--------|-----|------|
| Query speed | Faster (3x typical) | Slower |
| Build time | Slower (3x typical) | Faster |
| Update cost | Higher (pending list) | Lower |
| Index size | Larger | Smaller (lossy) |
| Ranking support | No built-in | `<->` for distance |

**Rule of thumb:** Use GIN for read-heavy FTS workloads, GiST for write-heavy or when you need KNN ranking.

---

### BRIN (Block Range Index)

**How it works:** Stores summary information (min/max values) for each range of consecutive physical table pages (default 128 pages per range). Instead of pointing to individual rows, it tells the planner which page ranges can be skipped entirely.

**Ideal use case:** Very large tables where the indexed column is naturally correlated with physical row order -- timestamps on append-only tables, auto-incrementing IDs, log tables, time-series data.

**Syntax:**
```sql
-- Timestamp on an append-only events table
CREATE INDEX idx_events_ts ON events USING brin (created_at);

-- With custom pages-per-range (smaller = more precise, larger index)
CREATE INDEX idx_events_ts ON events USING brin (created_at) WITH (pages_per_range = 32);
```

**Performance characteristics:**
- Extremely fast to build (single sequential scan)
- Scans return block ranges, not individual rows -- requires heap recheck
- Useless if column values have no correlation with physical storage order
- Not effective after heavy UPDATE/DELETE without `VACUUM` (physical order becomes fragmented)

**Storage overhead:** Extremely small. A BRIN on a 100GB table might be 100 KB. This is the primary advantage.

**Critical requirement:** The column must be correlated with physical storage order. Check with:
```sql
SELECT correlation
FROM pg_stats
WHERE tablename = 'events' AND attname = 'created_at';
-- Values near 1.0 or -1.0 = good candidate for BRIN
-- Values near 0.0 = BRIN will be useless, use B-tree
```

---

## 2. Index Selection Decision Table

| # | Query Pattern | Recommended Index | Why | Example |
|---|---------------|-------------------|-----|---------|
| 1 | Equality lookup (`=`) | B-tree | O(log n) lookup, supports all comparison operators, handles NULLs | `CREATE INDEX idx_users_email ON users (email);` |
| 2 | Range scan (`BETWEEN`, `<`, `>`) | B-tree | Leaf pages are linked for efficient range traversal | `CREATE INDEX idx_orders_date ON orders (created_at);` |
| 3 | Prefix LIKE (`LIKE 'foo%'`) | B-tree with `text_pattern_ops` | Treats LIKE prefix as a range scan; requires ops class for non-C locales | `CREATE INDEX idx_names_prefix ON users (name text_pattern_ops);` |
| 4 | Full-text search (`@@`) | GIN on `tsvector` | Inverted index maps each lexeme to matching rows | `CREATE INDEX idx_fts ON articles USING gin (search_vector);` |
| 5 | JSONB containment (`@>`) | GIN with `jsonb_path_ops` | Smaller index, fast containment checks on nested JSON | `CREATE INDEX idx_meta ON events USING gin (metadata jsonb_path_ops);` |
| 6 | JSONB arbitrary key access (`->`, `->>`) | B-tree on expression | GIN is overkill if you always query the same path | `CREATE INDEX idx_meta_type ON events ((metadata->>'type'));` |
| 7 | Array overlap (`&&`) / containment (`@>`) | GIN | Inverted index maps each element to rows containing it | `CREATE INDEX idx_tags ON products USING gin (tags);` |
| 8 | Geometric nearest-neighbor (`<->`) | GiST | Supports KNN ordering via index | `CREATE INDEX idx_geo ON locations USING gist (point);` |
| 9 | Range type overlap (`&&`) | GiST | Supports overlap, containment, and exclusion constraints on ranges | `CREATE INDEX idx_ranges ON bookings USING gist (time_range);` |
| 10 | Composite equality + range | B-tree (multi-column) | Equality columns first, range column last | `CREATE INDEX idx_eq_range ON orders (status, created_at);` |
| 11 | ORDER BY (single column) | B-tree | Avoids sort step; match ASC/DESC and NULLS FIRST/LAST | `CREATE INDEX idx_orders_date_desc ON orders (created_at DESC);` |
| 12 | COUNT / aggregate with filter | Partial B-tree | Scan only the subset that matters | `CREATE INDEX idx_active ON orders (id) WHERE status = 'active';` |
| 13 | JOIN key (FK column) | B-tree | Enables nested loop joins with index lookup on inner table | `CREATE INDEX idx_order_items_order_id ON order_items (order_id);` |
| 14 | IS NULL filter | B-tree (partial) | B-tree indexes include NULLs; partial index keeps it small | `CREATE INDEX idx_unprocessed ON jobs (id) WHERE completed_at IS NULL;` |
| 15 | Trigram / fuzzy pattern matching (`%`, `ILIKE`) | GIN with `pg_trgm` | Indexes all trigrams for substring and similarity search | `CREATE INDEX idx_trgm ON users USING gin (name gin_trgm_ops);` |
| 16 | Multi-column sort (mixed directions) | B-tree with matched directions | Sort order must exactly match index column order and direction | `CREATE INDEX idx_multi ON orders (status ASC, created_at DESC);` |
| 17 | IP address range queries | SP-GiST or GiST | Space-partitioned tree handles `inet`/`cidr` containment efficiently | `CREATE INDEX idx_ip ON logs USING spgist (client_ip);` |
| 18 | Time-series on append-only table | BRIN | Tiny index, column naturally correlates with physical order | `CREATE INDEX idx_ts ON events USING brin (created_at);` |
| 19 | Unique constraint | B-tree (UNIQUE) | Enforces uniqueness and serves as an index | `CREATE UNIQUE INDEX idx_email ON users (email);` |
| 20 | Existence check (`EXISTS` subquery) | B-tree on correlated column | Enables index lookup in the subquery for each outer row | `CREATE INDEX idx_reviews_product ON reviews (product_id);` |

---

## 3. Composite Index Design

### Column Ordering Rules

The order of columns in a composite index is critical and follows a hierarchy:

```
1. Equality columns first    (WHERE status = 'active')
2. Range columns next        (WHERE created_at > '2024-01-01')
3. Sort columns last         (ORDER BY amount DESC)
```

**Why this order matters:** PostgreSQL traverses the B-tree left to right. Equality predicates narrow to a precise subtree. A range predicate after an equality column can still use the index efficiently. But a range predicate before an equality column forces a scan across multiple subtrees.

### Examples

```sql
-- Query: WHERE status = 'shipped' AND created_at > '2024-01-01' ORDER BY amount DESC

-- GOOD: equality, range, sort
CREATE INDEX idx_optimal ON orders (status, created_at, amount DESC);
-- Traverses to status='shipped', scans created_at range, returns pre-sorted by amount

-- BAD: range before equality
CREATE INDEX idx_suboptimal ON orders (created_at, status, amount DESC);
-- Scans all created_at > '2024-01-01', then filters status in each subtree
```

### The Leftmost Prefix Rule

A composite index `(a, b, c)` can satisfy queries on:
- `(a)` -- yes
- `(a, b)` -- yes
- `(a, b, c)` -- yes
- `(b)` -- **no** (cannot skip leading column)
- `(a, c)` -- partially (uses `a`, then scans/filters `c`)
- `(b, c)` -- **no**

### Index Skip Scan Limitation

As of PostgreSQL 16, **PostgreSQL does not implement index skip scan**. This means a composite index `(status, user_id)` cannot efficiently answer `WHERE user_id = 42` by "skipping" through distinct `status` values. Some other databases (MySQL 8.0+, Oracle) support this.

**Workarounds:**
```sql
-- Option 1: Create a separate index on user_id
CREATE INDEX idx_user_id ON orders (user_id);

-- Option 2: If status has few distinct values, rewrite the query
SELECT * FROM orders
WHERE user_id = 42
  AND status IN ('pending', 'shipped', 'delivered', 'cancelled');
-- This converts the skip scan into equality lookups on the leading column
```

### Multi-Column Sort Matching

The index sort direction must match the query exactly:

```sql
-- Query: ORDER BY status ASC, created_at DESC
CREATE INDEX idx_match ON orders (status ASC, created_at DESC);
-- Works: index order matches query order

-- This also works (PostgreSQL can scan the index backward):
CREATE INDEX idx_reverse ON orders (status DESC, created_at ASC);
-- Backward scan satisfies: ORDER BY status ASC, created_at DESC

-- This does NOT work:
CREATE INDEX idx_mismatch ON orders (status ASC, created_at ASC);
-- Cannot satisfy ORDER BY status ASC, created_at DESC -- requires a sort step
```

---

## 4. Partial Indexes

A partial index includes only rows that satisfy a `WHERE` predicate. This makes the index smaller, faster to scan, and cheaper to maintain.

### When to Use

- When queries consistently filter to a small subset of rows
- When the majority of rows share a value you never query by
- When you need a conditional unique constraint

### Indexing Only Active Records

```sql
-- 95% of orders are 'completed', you only query pending/processing
CREATE INDEX idx_orders_pending ON orders (user_id, created_at)
  WHERE status IN ('pending', 'processing');

-- Query must include matching predicate for the planner to use it:
SELECT * FROM orders
WHERE status IN ('pending', 'processing')
  AND user_id = 123
ORDER BY created_at;
-- Uses idx_orders_pending

SELECT * FROM orders WHERE user_id = 123;
-- Does NOT use idx_orders_pending (missing the WHERE clause match)
```

### Indexing NULLs

```sql
-- Index only unprocessed jobs (completed_at IS NULL)
CREATE INDEX idx_jobs_unprocessed ON jobs (priority, created_at)
  WHERE completed_at IS NULL;

-- Tiny index even on a table with millions of completed jobs
-- Query: SELECT * FROM jobs WHERE completed_at IS NULL ORDER BY priority, created_at;
```

### Conditional Unique Constraints

```sql
-- Only one active subscription per user (allow multiple cancelled)
CREATE UNIQUE INDEX idx_one_active_sub ON subscriptions (user_id)
  WHERE status = 'active';

-- This allows:
--   user_id=1, status='active'    (OK)
--   user_id=1, status='cancelled' (OK)
--   user_id=1, status='active'    (FAILS: unique violation)
```

### Soft Deletes

```sql
-- Only index non-deleted records
CREATE INDEX idx_products_active ON products (category_id, name)
  WHERE deleted_at IS NULL;
```

---

## 5. Expression Indexes

An expression index (also called a functional index) indexes the result of a function or expression applied to column values.

### Case-Insensitive Lookups

```sql
CREATE INDEX idx_users_email_lower ON users (LOWER(email));

-- Query MUST use the same expression:
SELECT * FROM users WHERE LOWER(email) = 'alice@example.com';  -- uses index
SELECT * FROM users WHERE email = 'alice@example.com';         -- does NOT use index
```

### Date Extraction

```sql
CREATE INDEX idx_orders_month ON orders (DATE_TRUNC('month', created_at));

-- Uses index:
SELECT COUNT(*) FROM orders
WHERE DATE_TRUNC('month', created_at) = '2024-06-01';

-- Does NOT use index (different expression):
SELECT COUNT(*) FROM orders
WHERE EXTRACT(MONTH FROM created_at) = 6 AND EXTRACT(YEAR FROM created_at) = 2024;
```

### JSONB Path Expressions

```sql
-- Index a specific JSONB key
CREATE INDEX idx_events_type ON events ((metadata->>'type'));

-- Uses index:
SELECT * FROM events WHERE metadata->>'type' = 'login';

-- For integer comparisons inside JSONB, cast explicitly:
CREATE INDEX idx_events_priority ON events (((metadata->>'priority')::int));
SELECT * FROM events WHERE (metadata->>'priority')::int > 5;
```

### When the Optimizer Can and Cannot Use Expression Indexes

**Will use:**
- Query expression exactly matches the indexed expression (same function, same arguments, same casting)

**Will NOT use:**
- Semantically equivalent but syntactically different expressions
- `LOWER(email) = 'x'` index will not match `email ILIKE 'x'`
- `DATE_TRUNC('month', ts)` index will not match `ts >= '2024-06-01' AND ts < '2024-07-01'`
- Nested function calls that contain the indexed expression as a sub-expression

**Rule:** The query predicate must be textually identical to the indexed expression. PostgreSQL does not perform algebraic simplification to match expressions.

### Immutability Requirement

The function used in an expression index must be `IMMUTABLE` -- it must return the same result for the same inputs, always. `LOWER()`, `DATE_TRUNC()`, and arithmetic operators qualify. `NOW()`, `CURRENT_DATE`, and `random()` do not.

```sql
-- This will fail:
CREATE INDEX idx_bad ON events (AGE(created_at));
-- ERROR: functions in index expression must be marked IMMUTABLE
```

---

## 6. Covering Indexes (INCLUDE)

A covering index contains all columns needed by a query, enabling an **index-only scan** -- PostgreSQL reads the answer entirely from the index without touching the heap (table) pages.

### Syntax

```sql
CREATE INDEX idx_orders_covering ON orders (user_id, status)
  INCLUDE (total, created_at);
```

The `INCLUDE` columns are stored in the leaf pages of the index but are **not part of the search key**. They cannot be used for lookups, sorting, or uniqueness -- they are data passengers.

### When to Use INCLUDE

```sql
-- Query: SELECT total, created_at FROM orders WHERE user_id = 42 AND status = 'shipped';

-- Without INCLUDE: index scan finds matching rows, then fetches heap pages for total/created_at
-- With INCLUDE: index-only scan returns total and created_at directly from the index
```

### INCLUDE vs Adding More Key Columns

```sql
-- Option A: all columns as key columns
CREATE INDEX idx_a ON orders (user_id, status, total, created_at);
-- Wider B-tree nodes, deeper tree, slower writes
-- total and created_at participate in sort order (usually unwanted)

-- Option B: INCLUDE (preferred)
CREATE INDEX idx_b ON orders (user_id, status) INCLUDE (total, created_at);
-- Narrower key, shallower tree, faster writes
-- total and created_at are payload only
```

### Trade-offs

| Factor | Without INCLUDE | With INCLUDE |
|--------|----------------|--------------|
| Index size | Smaller | Larger (stores extra columns in leaves) |
| Write cost | Lower | Slightly higher (more data per leaf) |
| Read (matching query) | Heap fetch required | Index-only scan (much faster) |
| Visibility map dependency | N/A | Index-only scan requires recently vacuumed pages |

### Visibility Map Requirement

Index-only scans work only when the visibility map confirms that all tuples on a heap page are visible to all transactions. On tables with frequent updates, many pages are not all-visible, and PostgreSQL falls back to a regular index scan. Run `VACUUM` to update the visibility map.

```sql
-- Check index-only scan effectiveness:
EXPLAIN (ANALYZE, BUFFERS) SELECT total FROM orders WHERE user_id = 42 AND status = 'shipped';
-- Look for "Heap Fetches: 0" -- this means the index-only scan worked fully
-- "Heap Fetches: 5000" means visibility map is stale; run VACUUM
```

### Unique Indexes with INCLUDE

```sql
-- Unique on (email), but also store name for index-only scans
CREATE UNIQUE INDEX idx_users_email_covering ON users (email) INCLUDE (name);
```

---

## 7. Index Maintenance

### Detecting Index Bloat

Index bloat occurs when dead tuples fragment the index structure, wasting space and slowing scans.

```sql
-- Install pgstattuple (ships with PostgreSQL, just needs CREATE EXTENSION)
CREATE EXTENSION IF NOT EXISTS pgstattuple;

-- Check bloat on a specific index
SELECT * FROM pgstatindex('idx_orders_created_at');
-- Key fields:
--   tree_level      : depth of B-tree (> 3 on a small table = bloated)
--   leaf_pages      : number of leaf pages
--   empty_pages     : pages with no live tuples (wasted)
--   deleted_pages   : pages marked for reuse
--   avg_leaf_density: percentage of leaf page space used (< 50% = bloated)
--   leaf_fragmentation: percentage of leaf pages out of order

-- Quick bloat estimate for all indexes in a schema
SELECT
  schemaname,
  indexrelname AS index_name,
  pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
  idx_scan AS times_used,
  idx_tup_read AS tuples_read,
  idx_tup_fetch AS tuples_fetched
FROM pg_stat_user_indexes
ORDER BY pg_relation_size(indexrelid) DESC;
```

### Rebuilding Indexes

```sql
-- REINDEX: rebuilds the index, blocks writes on the table
REINDEX INDEX idx_orders_created_at;

-- REINDEX CONCURRENTLY (PostgreSQL 12+): rebuilds without blocking writes
-- Takes longer, uses more disk (builds new index alongside old one)
REINDEX INDEX CONCURRENTLY idx_orders_created_at;

-- Rebuild all indexes on a table
REINDEX TABLE orders;
REINDEX TABLE CONCURRENTLY orders;
```

### Detecting Unused Indexes

Unused indexes waste disk, slow down writes, and increase vacuum overhead. Query `pg_stat_user_indexes` to find them:

```sql
SELECT
  schemaname || '.' || relname AS table,
  indexrelname AS index,
  pg_size_pretty(pg_relation_size(indexrelid)) AS size,
  idx_scan AS scans_since_reset
FROM pg_stat_user_indexes
WHERE idx_scan = 0
  AND indexrelname NOT LIKE '%_pkey'    -- keep primary keys
  AND indexrelname NOT LIKE '%_unique%' -- keep unique constraints (they enforce logic)
ORDER BY pg_relation_size(indexrelid) DESC;
```

**Important caveats:**
- Statistics reset on server restart unless you use `pg_stat_reset()`
- An index with `idx_scan = 0` might be used for unique constraint enforcement even without scans
- Check across a full business cycle (weekly/monthly patterns) before dropping
- Replicas may use indexes the primary does not -- check both

### Monitoring Index Usage Over Time

```sql
-- Record a baseline, then compare after a business cycle
CREATE TABLE index_usage_snapshots AS
SELECT
  now() AS snapshot_at,
  indexrelid,
  schemaname,
  relname,
  indexrelname,
  idx_scan,
  pg_relation_size(indexrelid) AS index_bytes
FROM pg_stat_user_indexes;

-- After a week/month, compare:
SELECT
  curr.indexrelname,
  curr.idx_scan - prev.idx_scan AS scans_delta,
  pg_size_pretty(curr.index_bytes) AS current_size
FROM pg_stat_user_indexes curr
JOIN index_usage_snapshots prev USING (indexrelid)
WHERE curr.idx_scan - prev.idx_scan = 0
ORDER BY curr.index_bytes DESC;
```

### Safe Index Removal Process

```sql
-- Step 1: Mark as invalid (stops planner from using it, but keeps it for rollback)
-- PostgreSQL has no ALTER INDEX ... DISABLE, so use this pattern:

-- Step 1: Record index definition for rollback
SELECT pg_get_indexdef(indexrelid) FROM pg_stat_user_indexes
WHERE indexrelname = 'idx_suspect';

-- Step 2: Drop with a safety net
BEGIN;
DROP INDEX idx_suspect;
-- Monitor for performance regression
-- If problems: ROLLBACK;
-- If clean: COMMIT;
```

---

## 8. Anti-Patterns

### 1. Indexing Every Column

**Problem:** Each index adds write overhead (INSERT, UPDATE, DELETE must maintain every index), consumes disk, and increases vacuum time.

**Guideline:** Index only columns that appear in `WHERE`, `JOIN ON`, or `ORDER BY` clauses of actual queries. If you cannot point to a query that uses the index, do not create it.

### 2. Redundant Indexes

**Problem:** Index `(a, b)` makes index `(a)` redundant because the composite index satisfies all queries that the single-column index would serve (leftmost prefix rule).

```sql
-- Redundant pair:
CREATE INDEX idx_a   ON orders (user_id);           -- redundant
CREATE INDEX idx_ab  ON orders (user_id, status);    -- covers (user_id) queries too

-- NOT redundant (reversed order):
CREATE INDEX idx_ab  ON orders (user_id, status);
CREATE INDEX idx_ba  ON orders (status, user_id);    -- serves different query patterns
```

**Detection query:**
```sql
-- Find indexes that are a leftmost prefix of another index on the same table
SELECT
  a.indexrelid::regclass AS shorter_index,
  b.indexrelid::regclass AS longer_index,
  pg_size_pretty(pg_relation_size(a.indexrelid)) AS wasted_space
FROM pg_index a
JOIN pg_index b ON a.indrelid = b.indrelid
  AND a.indexrelid != b.indexrelid
  AND a.indkey::text = (
    SELECT string_agg(x::text, ' ')
    FROM unnest(b.indkey) WITH ORDINALITY AS t(x, ord)
    WHERE ord <= array_length(a.indkey, 1)
  )
WHERE NOT a.indisunique  -- keep unique indexes (they serve a constraint purpose)
ORDER BY pg_relation_size(a.indexrelid) DESC;
```

### 3. Indexes on Tiny Tables

**Problem:** For tables with fewer than a few thousand rows, a sequential scan reads 1-2 pages. An index scan reads the index page(s) plus the heap page(s) -- more total I/O. PostgreSQL's planner correctly chooses seqscan for tiny tables, so the index is never used.

**Guideline:** Do not create indexes on tables you expect to remain under ~10,000 rows, unless you need a unique constraint.

### 4. Missing Indexes on Foreign Key Columns

**Problem:** PostgreSQL does NOT automatically create indexes on foreign key columns (unlike some other databases). Without an index on the FK column:
- `DELETE` on the parent table triggers a sequential scan on the child table (to check for referencing rows)
- `JOIN` queries between parent and child use sequential scan on the child

```sql
-- Always index FK columns:
ALTER TABLE order_items ADD CONSTRAINT fk_order
  FOREIGN KEY (order_id) REFERENCES orders(id);

-- PostgreSQL does NOT create this automatically -- you must:
CREATE INDEX idx_order_items_order_id ON order_items (order_id);
```

**This is one of the most common PostgreSQL performance problems.** A `DELETE FROM orders WHERE id = 42` on a table with 10M order_items will seqscan the entire order_items table without this index.

### 5. Not Using Partial Indexes When Filtering a Dominant Value

**Problem:** When 90%+ of rows have the same value (e.g., `status = 'completed'`) and you only query the rare values, a full index wastes space and I/O indexing rows you never search for.

```sql
-- BAD: full index on a column where 95% of values are 'completed'
CREATE INDEX idx_status ON orders (status);
-- Index size: 200 MB, but only 5% of entries are ever queried

-- GOOD: partial index on the values you actually query
CREATE INDEX idx_active_orders ON orders (created_at)
  WHERE status IN ('pending', 'processing');
-- Index size: 10 MB, covers all your actual queries
```

### 6. Over-Indexing Write-Heavy Tables

**Problem:** Every index is updated on every INSERT and UPDATE to the table. On write-heavy tables (logging, event streams, queues), excessive indexes can reduce write throughput dramatically.

**Benchmarks to expect:**
- 0 indexes: baseline write speed
- 1 index: ~10-15% slower writes
- 5 indexes: ~40-60% slower writes
- 10+ indexes: writes can be 2-5x slower

**Guideline for write-heavy tables:**
- Use BRIN instead of B-tree where correlation supports it (much cheaper maintenance)
- Use partial indexes to minimize the indexed row set
- Batch-insert into unindexed staging tables, then move data with indexes
- Profile: `pg_stat_user_tables.n_tup_ins` vs `pg_stat_user_indexes.idx_scan` -- if inserts >> scans, you have too many indexes

### 7. Indexing for Queries That Do Not Exist

**Problem:** Creating indexes based on hypothetical future queries or "just in case." Every index has ongoing maintenance cost.

**Guideline:** Create indexes reactively in response to observed slow queries (`pg_stat_statements`, `log_min_duration_statement`), not proactively based on table schema.

---

## 9. Cost Estimation and EXPLAIN

### Reading EXPLAIN Output for Index Usage

```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM orders WHERE user_id = 42 AND status = 'shipped';
```

**Key scan types in the output:**

| Scan Type | What It Means | When It Happens |
|-----------|---------------|-----------------|
| `Seq Scan` | Full table scan, reading every page | No usable index, or planner estimated seq scan is cheaper |
| `Index Scan` | Traverse index, fetch matching heap tuples | Selective query, small result set relative to table size |
| `Index Only Scan` | Read from index without heap access | Covering index + visibility map up to date |
| `Bitmap Index Scan` | Build a bitmap of matching pages from the index | Moderate selectivity (too many rows for index scan, too few for seq scan) |
| `Bitmap Heap Scan` | Fetch heap pages using the bitmap | Always follows a Bitmap Index Scan |

### Index Scan vs Bitmap Index Scan vs Sequential Scan

PostgreSQL chooses based on estimated selectivity:

```
Selectivity          Typical Choice        Why
< 1-5% of rows      Index Scan            Random I/O is worth it for few rows
5-20% of rows        Bitmap Index Scan     Build bitmap, then sequential heap access
> 20% of rows        Seq Scan              Sequential I/O cheaper than random at scale
```

These thresholds are approximate and depend on:
- `random_page_cost` (default 4.0, set lower for SSDs: 1.1-1.5)
- `seq_page_cost` (default 1.0)
- `effective_cache_size` (how much data is likely cached)
- Table width (narrow rows = more rows per page = seq scan more attractive)

### When PostgreSQL Chooses NOT to Use Your Index

**1. Low selectivity (too many matching rows):**
```sql
-- Index exists on status, but 80% of orders are 'completed'
EXPLAIN SELECT * FROM orders WHERE status = 'completed';
-- Seq Scan (correct: reading 80% of the table sequentially is faster than 80% random reads)
```

**2. Small table:**
```sql
-- Table has 500 rows, fits in 3 pages
EXPLAIN SELECT * FROM config WHERE key = 'timeout';
-- Seq Scan (correct: 3 pages is faster to scan than index traversal + heap fetch)
```

**3. Type mismatch / expression mismatch:**
```sql
-- Index on user_id (integer)
EXPLAIN SELECT * FROM orders WHERE user_id = '42';
-- May still use index (implicit cast), or may not if cast prevents index use

-- Index on LOWER(email), query uses email directly
EXPLAIN SELECT * FROM users WHERE email = 'Alice@Example.com';
-- Seq Scan (correct: the expression does not match the indexed expression)
```

**4. Statistics are stale:**
```sql
-- After bulk loading data, ANALYZE updates statistics
ANALYZE orders;
-- Without fresh statistics, the planner may estimate wrong selectivity
```

**5. Correlated columns confuse single-column stats:**
```sql
-- status='shipped' AND warehouse='west' are correlated in practice
-- but PostgreSQL estimates them independently, may choose wrong plan
-- Fix: CREATE STATISTICS (PostgreSQL 10+)
CREATE STATISTICS stat_orders_status_warehouse (dependencies)
  ON status, warehouse FROM orders;
ANALYZE orders;
```

### Useful EXPLAIN Patterns

```sql
-- See actual vs estimated rows (bad estimates = planner makes wrong choices)
EXPLAIN (ANALYZE) SELECT ...;
-- Check: "rows=1000" (estimated) vs "actual rows=500000" (actual) = stale stats

-- See buffer usage (is the index actually reducing I/O?)
EXPLAIN (ANALYZE, BUFFERS) SELECT ...;
-- "Buffers: shared hit=5 read=2" = 7 pages total (good for index scan)
-- "Buffers: shared hit=50000 read=12000" = suspicious for an indexed query

-- See just the plan without running (safe for expensive queries)
EXPLAIN SELECT ...;

-- Get machine-readable output for tooling
EXPLAIN (FORMAT JSON) SELECT ...;
```

### Forcing Index Usage (for Testing Only)

```sql
-- Disable seq scan to confirm an index CAN be used (do not use in production)
SET enable_seqscan = off;
EXPLAIN SELECT * FROM orders WHERE status = 'completed';
-- If it now uses an index scan but is slower, the planner was right to choose seq scan

-- Reset
SET enable_seqscan = on;
```

### The `pg_stat_statements` Approach

Rather than guessing which queries need indexes, let the database tell you:

```sql
-- Enable the extension
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Find the slowest queries by total time
SELECT
  calls,
  round(total_exec_time::numeric, 2) AS total_ms,
  round(mean_exec_time::numeric, 2) AS avg_ms,
  rows,
  query
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;

-- Find queries with the worst avg time (potential missing index)
SELECT
  calls,
  round(mean_exec_time::numeric, 2) AS avg_ms,
  query
FROM pg_stat_statements
WHERE calls > 100  -- ignore rare queries
ORDER BY mean_exec_time DESC
LIMIT 20;
```

---

## Quick Reference Card

```
Need an index?
  1. What does the query look like?      → Decision Table (Section 2)
  2. Multiple columns?                   → Equality first, range next, sort last (Section 3)
  3. Filtering out most rows?            → Partial index (Section 4)
  4. Function in WHERE clause?           → Expression index (Section 5)
  5. Want to avoid heap access?          → INCLUDE columns (Section 6)
  6. Is the index actually being used?   → pg_stat_user_indexes (Section 7)
  7. Is the planner ignoring my index?   → EXPLAIN ANALYZE (Section 9)
  8. Are writes getting slow?            → Audit anti-patterns (Section 8)
```
