# MySQL / InnoDB Indexing Strategy Reference

> Target audience: senior developers running MySQL 8.0+ or MariaDB 10.6+ who need to understand not just *what* index to create but *why* InnoDB's architecture makes the answer fundamentally different from PostgreSQL.
>
> **The single most important thing to understand:** In InnoDB, the table *is* the primary key index. Every indexing decision flows from this fact.

---

## 1. InnoDB Index Architecture

### The Clustered Index

InnoDB stores the entire table as a B+tree ordered by the primary key. This is the **clustered index** — it's not a separate data structure alongside the table; it *is* the table.

```
Clustered Index (Primary Key B+tree):
┌─────────────┐
│  Internal    │ ← PK values as routing keys
│  Nodes       │
└──────┬──────┘
       │
┌──────▼──────┐
│  Leaf Pages  │ ← FULL ROW DATA stored here
│  (16KB each) │   Sorted by PK value
└─────────────┘
```

**If you don't define a PRIMARY KEY**, InnoDB uses the first `UNIQUE NOT NULL` index. If none exists, it creates a hidden 6-byte row ID as the clustered key. You never want this — the hidden row ID provides no query benefit and you lose control over physical ordering.

### Secondary Indexes

Every non-primary index is a **secondary index**. Its leaf nodes store:
1. The indexed column values
2. The primary key value (NOT a physical row pointer)

```
Secondary Index (e.g., INDEX(email)):
┌─────────────┐
│  Internal    │ ← email values as routing keys
│  Nodes       │
└──────┬──────┘
       │
┌──────▼──────┐
│  Leaf Pages  │ ← (email, PK_value) pairs
└─────────────┘
       │
       │ "Bookmark lookup": use PK_value to
       │ traverse clustered index for full row
       ▼
┌─────────────┐
│  Clustered   │
│  Index       │ ← Full row data
└─────────────┘
```

**This two-hop design has cascading consequences:**

| Consequence | Impact | Mitigation |
|-------------|--------|------------|
| **Wide PKs bloat every secondary index** | A 16-byte UUID PK × 5 secondary indexes = 80 extra bytes per row across all indexes | Use `BIGINT AUTO_INCREMENT` PK; expose UUIDs as a separate indexed column |
| **Secondary index lookups are always two B+tree traversals** | ~2× the I/O of a PostgreSQL index scan (which has a direct heap pointer) | Use covering indexes to avoid the bookmark lookup |
| **Random PK values cause page splits in the clustered index** | UUIDv4 inserts scatter across the B+tree; splits fragment pages and waste ~50% of page space | Use auto-increment, UUIDv7 (time-ordered), or `uuid_to_bin(uuid, 1)` |
| **PK determines physical row order** | Range scans on the PK are sequential I/O (fast); range scans on secondary indexes are random I/O (slow for large result sets) | Design the PK to match your most common range scan pattern |
| **Deleting a secondary index entry doesn't free clustered index space** | The row still exists in the clustered index; only the secondary index entry is removed | This is rarely a problem but surprises people coming from PostgreSQL |

### Why PK Choice Matters More in MySQL Than PostgreSQL

In PostgreSQL, the primary key index is a separate B-tree. The heap file stores rows in insertion order regardless of PK. A bad PK wastes index space but doesn't affect table storage.

In MySQL, the PK *is* the table storage. A bad PK:
- Fragments the entire table (not just one index)
- Bloats every secondary index (they all carry the PK)
- Makes the most common workload pattern (recent-first queries) either fast or slow depending on whether the PK correlates with time

**The ideal InnoDB PK for most OLTP tables: `BIGINT AUTO_INCREMENT`.** It's narrow (8 bytes), sequential (no page splits), and the clustered index naturally orders rows chronologically.

---

## 2. Index Types

### B+tree (Default)

Every InnoDB index is a B+tree. There is no separate "B-tree" vs "B+tree" choice — InnoDB only implements B+tree.

```sql
-- These are all equivalent:
CREATE INDEX idx_name ON users (name);
CREATE INDEX idx_name ON users (name) USING BTREE;
-- "BTREE" is the only option for InnoDB. HASH is silently converted to BTREE.
```

**Supports:** `=`, `<>`, `<`, `<=`, `>`, `>=`, `BETWEEN`, `IN`, `IS NULL`, `IS NOT NULL`, `LIKE 'prefix%'`, `ORDER BY`, `GROUP BY`

**Does NOT support:** `LIKE '%suffix'`, `LIKE '%middle%'` (use FULLTEXT), function applications on the column (use generated columns)

### Fulltext Index

InnoDB fulltext indexes (5.6+) use an inverted index design with auxiliary tables.

```sql
CREATE FULLTEXT INDEX idx_ft ON articles (title, body);

-- Query with MATCH ... AGAINST:
SELECT * FROM articles
WHERE MATCH(title, body) AGAINST('database tuning' IN NATURAL LANGUAGE MODE);

-- Boolean mode (AND, OR, NOT, phrase matching):
SELECT * FROM articles
WHERE MATCH(title, body) AGAINST('+database +tuning -mysql' IN BOOLEAN MODE);

-- With relevance scoring:
SELECT *, MATCH(title, body) AGAINST('database tuning') AS relevance
FROM articles
WHERE MATCH(title, body) AGAINST('database tuning')
ORDER BY relevance DESC;
```

**Inside baseball on InnoDB fulltext:**

| Aspect | Detail |
|--------|--------|
| **Tokenization** | Uses a built-in parser (CJK-aware in 5.7.6+). Custom parsers via plugin API. Default minimum word length: 3 characters (`innodb_ft_min_token_size`). |
| **Stopwords** | Default stopword list is English-centric. Customize via `innodb_ft_server_stopword_table` or `innodb_ft_user_stopword_table`. |
| **Transaction visibility** | Fulltext index updates are NOT transactional in the same way B+tree indexes are. New inserts are batched in a cache (`innodb_ft_cache_size`, default 8MB) and flushed periodically. Until flushed, new rows may not appear in fulltext searches. |
| **DELETE handling** | Deleted rows are NOT immediately removed from the fulltext index. They're added to a delete list. Run `OPTIMIZE TABLE` to physically purge them. This can cause stale results. |
| **Performance** | Much slower than PostgreSQL's GIN+tsvector for large datasets. InnoDB fulltext doesn't support GIN's posting-list compression or fast updates. For serious search, use Elasticsearch/Meilisearch. |

### Spatial Index (R-tree)

```sql
-- Requires a geometry column with SRID:
ALTER TABLE locations ADD COLUMN geom POINT NOT NULL SRID 4326;
CREATE SPATIAL INDEX idx_geom ON locations (geom);

-- Query:
SELECT * FROM locations
WHERE ST_Contains(
  ST_GeomFromText('POLYGON((...))'),
  geom
);
```

Spatial indexes in MySQL are R-tree based. They work but are far less capable than PostGIS. For serious geospatial work, use PostgreSQL + PostGIS.

### No Hash Index in InnoDB

MySQL syntax accepts `USING HASH`, but InnoDB silently converts it to B+tree. Hash indexes only exist in the MEMORY (HEAP) storage engine and in NDB Cluster. The Adaptive Hash Index (AHI) is an internal InnoDB optimization, not a user-creatable index type.

---

## 3. Index Selection Decision Table

| # | Query Pattern | Recommended Index | MySQL-Specific Notes |
|---|---------------|-------------------|---------------------|
| 1 | Equality (`WHERE email = ?`) | B+tree | Standard. If case-insensitive, use a `utf8mb4_0900_ai_ci` collation (default in 8.0) rather than `LOWER()` — the collation handles it at the index level. |
| 2 | Range (`WHERE created_at > ?`) | B+tree | Same as PG. |
| 3 | Prefix LIKE (`WHERE name LIKE 'foo%'`) | B+tree | Works natively. No need for operator classes like PG's `text_pattern_ops`. |
| 4 | Suffix/infix LIKE (`LIKE '%foo%'`) | FULLTEXT | No `pg_trgm` equivalent. FULLTEXT only helps for word-boundary searches. For true substring: consider generated columns + B+tree, or external search engine. |
| 5 | Full-text search | FULLTEXT | Use `MATCH ... AGAINST`. Boolean mode for complex queries. |
| 6 | JSON key access (`WHERE data->>'$.type' = ?`) | B+tree on generated column | MySQL can't index JSON expressions directly. Create a generated column: `ALTER TABLE t ADD COLUMN type VARCHAR(50) GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(data, '$.type'))) STORED, ADD INDEX(type);` |
| 7 | JSON containment (`JSON_CONTAINS(data, ?)`) | Multi-valued index (8.0.17+) | `CREATE INDEX idx ON t ((CAST(data->'$.tags' AS UNSIGNED ARRAY)));` — indexes JSON arrays for `MEMBER OF` and `JSON_OVERLAPS` queries. |
| 8 | Composite equality + range | B+tree multi-column | Equality first, range last — same as PG. |
| 9 | ORDER BY | B+tree matching sort order | Mixed ASC/DESC actually works in 8.0+ (unlike pre-8.0 where DESC was ignored). |
| 10 | Covering query (avoid bookmark lookup) | B+tree with all needed columns | Critical in MySQL: the covering index eliminates the clustered index lookup. `Using index` in EXPLAIN Extra confirms coverage. |
| 11 | Subset filter (`WHERE status = 'active'`) | No partial indexes in MySQL | Workarounds: generated column + index, or accept scanning the full index. See Section 6. |
| 12 | Geospatial | SPATIAL (R-tree) | Basic support. Use PostGIS for anything beyond simple bounding-box queries. |

---

## 4. Composite Index Design

### Column Ordering

The rules are the same as PostgreSQL — equality columns first, range columns next, sort columns last — but the implementation differences matter:

```sql
-- Query: WHERE status = 'active' AND created_at > '2024-01-01' ORDER BY priority DESC

-- GOOD:
CREATE INDEX idx_optimal ON tasks (status, created_at, priority);
-- Equality on status → range on created_at → pre-sorted by priority within each status+date range
-- But: ORDER BY priority DESC only avoids a sort if it matches the index direction.
-- In 8.0+, you can do:
CREATE INDEX idx_optimal ON tasks (status ASC, created_at ASC, priority DESC);
```

### The InnoDB "Free" Covering of the PK

Since every secondary index implicitly includes the PK columns, they're "free" for covering index purposes:

```sql
-- PK: id BIGINT AUTO_INCREMENT
-- Index: (status, created_at)

-- This query is covered WITHOUT explicitly adding id:
SELECT id, status, created_at FROM orders WHERE status = 'pending';
-- The index already contains (status, created_at, id)
-- EXPLAIN shows "Using index" — no bookmark lookup needed

-- But this is NOT covered:
SELECT id, status, created_at, total FROM orders WHERE status = 'pending';
-- 'total' is not in the index → bookmark lookup required
```

This means you can often get covering behavior without `INCLUDE` (which MySQL doesn't have — see Section 5).

### The Leftmost Prefix Rule

Same as PostgreSQL. An index on `(a, b, c)` can serve queries on `(a)`, `(a, b)`, or `(a, b, c)`, but not `(b)` or `(b, c)`.

**MySQL 8.0.13+ has Index Skip Scan** — a limited optimization that PostgreSQL still lacks:

```sql
-- Index: (gender, age)
-- Query: WHERE age > 25   (no gender filter)

-- Without skip scan: full table scan (can't use the index)
-- With skip scan (8.0.13+): MySQL infers the distinct values of 'gender'
-- and rewrites internally as:
--   (gender = 'M' AND age > 25) UNION ALL (gender = 'F' AND age > 25)
-- This uses the index!
```

**Skip scan conditions:**
- Leading column must have low cardinality (few distinct values)
- The optimizer must decide it's cheaper than a full scan
- Check `EXPLAIN` for `Using index for skip scan`

### Composite Index Sizing

Remember: every secondary index leaf stores the PK. Budget accordingly:

```
Index leaf entry size = SUM(indexed_column_sizes) + PK_size + overhead (~12 bytes)

Example: INDEX(status VARCHAR(20), created_at DATETIME) on PK BIGINT
= 20 + 8 + 8 + 12 = ~48 bytes per entry

Example: INDEX(status VARCHAR(20), created_at DATETIME) on PK UUID BINARY(16)
= 20 + 8 + 16 + 12 = ~56 bytes per entry
```

On 100M rows, that's 4.8 GB vs 5.6 GB — the UUID PK costs an extra 800 MB *per secondary index*.

---

## 5. Features MySQL Lacks (and Workarounds)

### No Partial Indexes

PostgreSQL's `CREATE INDEX ... WHERE condition` doesn't exist in MySQL. This is one of the biggest missing features for performance tuning.

**Workarounds:**

```sql
-- Scenario: 95% of orders are 'completed', you only query active ones.
-- In PG: CREATE INDEX idx_active ON orders (created_at) WHERE status != 'completed';

-- MySQL Workaround 1: Generated column + index
ALTER TABLE orders ADD COLUMN is_active TINYINT
  GENERATED ALWAYS AS (CASE WHEN status != 'completed' THEN 1 ELSE NULL END) STORED;
CREATE INDEX idx_active ON orders (is_active, created_at);
-- NULL values are NOT included in B+tree indexes in MySQL (unlike PG).
-- So only the active rows get indexed. This is as close to a partial index as MySQL gets.

-- MySQL Workaround 2: Covering index with low-cardinality leading column
CREATE INDEX idx_status_created ON orders (status, created_at);
-- Less efficient than a partial index but works. The optimizer can use
-- Index Condition Pushdown to filter status at the index level.
```

**The NULL trick is the key insight:** MySQL B+tree indexes exclude NULL entries for the indexed column. By making the generated column NULL for rows you don't want indexed, you get partial-index-like behavior.

### No INCLUDE Columns (Covering Index Syntax)

PostgreSQL 11+ has `CREATE INDEX ... INCLUDE (col1, col2)` for non-key columns. MySQL doesn't.

**Workaround:** Add the covering columns as trailing key columns.

```sql
-- PG:  CREATE INDEX idx ON orders (status) INCLUDE (total, created_at);
-- MySQL equivalent:
CREATE INDEX idx ON orders (status, total, created_at);
-- total and created_at participate in the key sort (unlike PG's INCLUDE).
-- But for covering-index purposes, the effect is the same.
```

The downside: the extra key columns slightly affect the B+tree structure and sort behavior. In practice, this rarely matters.

### No Expression Indexes (Until Generated Columns)

PostgreSQL has `CREATE INDEX ON t (LOWER(email))`. MySQL doesn't support functions in index definitions directly.

**Workaround:** Generated columns (5.7.6+ for stored, 5.7.8+ for virtual):

```sql
-- PG: CREATE INDEX ON users (LOWER(email));

-- MySQL:
ALTER TABLE users ADD COLUMN email_lower VARCHAR(255)
  GENERATED ALWAYS AS (LOWER(email)) STORED;
CREATE INDEX idx_email_lower ON users (email_lower);

-- Or use VIRTUAL (not stored on disk, computed on read, still indexable in 5.7.8+):
ALTER TABLE users ADD COLUMN email_lower VARCHAR(255)
  GENERATED ALWAYS AS (LOWER(email)) VIRTUAL;
CREATE INDEX idx_email_lower ON users (email_lower);
-- VIRTUAL is generally preferred: no storage cost, index is still maintained.
```

**8.0.13+ functional indexes** — MySQL finally added direct expression indexing:

```sql
-- 8.0.13+: functional index (expression index)
CREATE INDEX idx_email_lower ON users ((LOWER(email)));
-- Note the double parentheses — required syntax.
-- Internally, MySQL creates a hidden virtual generated column.

-- Works for JSON too:
CREATE INDEX idx_type ON events ((CAST(data->>'$.type' AS CHAR(50))));
```

### No GIN, GiST, BRIN, SP-GiST

MySQL has exactly one general-purpose index type: B+tree. Everything that PostgreSQL handles with specialized index types, MySQL must solve with B+tree + workarounds:

| PG Index Type | PG Use Case | MySQL Alternative |
|---------------|-------------|-------------------|
| GIN (tsvector) | Full-text search | FULLTEXT index (less capable) |
| GIN (jsonb) | JSON containment | Multi-valued index (8.0.17+) for arrays; generated column + B+tree for scalar paths |
| GIN (array) | Array containment/overlap | Multi-valued index or normalized table |
| GIN (pg_trgm) | Trigram/substring search | FULLTEXT (word-boundary only) or external search engine |
| GiST | Geospatial, range types | SPATIAL index (R-tree, limited) |
| BRIN | Time-series on correlated columns | No equivalent. Rely on clustered index ordering by PK. |
| SP-GiST | IP addresses, phone prefixes | No equivalent. Use B+tree with prefix matching. |

---

## 6. Invisible Indexes — MySQL's Killer Feature for Index Tuning

Invisible indexes (8.0+) are maintained by InnoDB (updated on INSERT/UPDATE/DELETE) but ignored by the optimizer. This lets you test the impact of dropping an index without actually dropping it.

```sql
-- Make an index invisible:
ALTER TABLE orders ALTER INDEX idx_old_status INVISIBLE;

-- The index still exists and is maintained (write cost unchanged).
-- But the optimizer cannot use it.
-- Monitor query performance for a week.

-- If no regression: safely drop it
DROP INDEX idx_old_status ON orders;

-- If regression detected: make visible again (instant, no rebuild)
ALTER TABLE orders ALTER INDEX idx_old_status VISIBLE;

-- Create a new index as invisible to test before exposing to production queries:
CREATE INDEX idx_experimental ON orders (region, status) INVISIBLE;
-- Run EXPLAIN with the optimizer switch to test it:
SET optimizer_switch = 'use_invisible_indexes=on';
EXPLAIN SELECT * FROM orders WHERE region = 'EU' AND status = 'pending';
SET optimizer_switch = 'use_invisible_indexes=off';
```

**PostgreSQL has no equivalent.** In PG, you drop the index and recreate it if you were wrong (which can take hours on large tables). MySQL's invisible indexes make index auditing dramatically safer.

### The Index Audit Workflow

```sql
-- Step 1: Find unused indexes
SELECT * FROM sys.schema_unused_indexes;

-- Step 2: Make them invisible (don't drop yet)
ALTER TABLE t1 ALTER INDEX idx_suspect_1 INVISIBLE;
ALTER TABLE t2 ALTER INDEX idx_suspect_2 INVISIBLE;

-- Step 3: Wait one full business cycle (1-4 weeks)
-- Monitor for slow queries in the slow log or Performance Schema

-- Step 4: Drop indexes with no regression
DROP INDEX idx_suspect_1 ON t1;
DROP INDEX idx_suspect_2 ON t2;

-- Step 5: Re-enable any that caused problems
ALTER TABLE t3 ALTER INDEX idx_needed VISIBLE;
```

---

## 7. Prefix Indexes — A MySQL-Specific Optimization

MySQL allows indexing only the first N characters of a string column:

```sql
-- Full column index (all bytes):
CREATE INDEX idx_url ON pages (url);

-- Prefix index (first 50 characters):
CREATE INDEX idx_url_prefix ON pages (url(50));
```

**When prefix indexes make sense:**
- Very long string columns (URLs, file paths, descriptions)
- The first N characters provide sufficient selectivity
- You want to save index storage space

**When they don't:**
- `ORDER BY url` — prefix indexes cannot be used for sorting (the full value is needed)
- `GROUP BY url` — same problem
- Covering queries — the index only contains the prefix, so a bookmark lookup is always required
- When selectivity is poor in the prefix (many URLs start with `https://www.example.com/...`)

**Choosing the prefix length:**

```sql
-- Find the optimal prefix length by measuring selectivity:
SELECT
  COUNT(DISTINCT LEFT(url, 10)) / COUNT(*) AS sel_10,
  COUNT(DISTINCT LEFT(url, 20)) / COUNT(*) AS sel_20,
  COUNT(DISTINCT LEFT(url, 50)) / COUNT(*) AS sel_50,
  COUNT(DISTINCT url) / COUNT(*) AS sel_full
FROM pages;

-- Results:
-- sel_10 = 0.12   (12% selectivity — too low)
-- sel_20 = 0.65   (65% — decent)
-- sel_50 = 0.97   (97% — nearly as good as full)
-- sel_full = 1.00  (100%)
-- Conclusion: prefix(50) captures 97% of the selectivity at a fraction of the index size.
```

PostgreSQL doesn't need prefix indexes because it has `text_pattern_ops` for prefix matching and can use expression indexes for other transformations. MySQL's prefix indexes fill a real gap.

---

## 8. Multi-Valued Indexes (8.0.17+)

Multi-valued indexes index the individual elements of a JSON array — MySQL's answer to PostgreSQL's GIN index on arrays.

```sql
-- Table with a JSON array column:
CREATE TABLE products (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255),
  tags JSON
);

-- Index individual array elements:
CREATE INDEX idx_tags ON products ((CAST(tags->'$[*]' AS CHAR(50) ARRAY)));

-- Query using MEMBER OF:
SELECT * FROM products WHERE 'electronics' MEMBER OF(tags->'$[*]');

-- Query using JSON_OVERLAPS (any element in common):
SELECT * FROM products WHERE JSON_OVERLAPS(tags, '["electronics", "sale"]');

-- Query using JSON_CONTAINS:
SELECT * FROM products WHERE JSON_CONTAINS(tags, '"electronics"');
```

**Limitations:**
- Only works on JSON arrays, not objects
- The `CAST ... AS ... ARRAY` syntax is required
- Cannot be a covering index (always requires bookmark lookup)
- `EXPLAIN` shows `Using where` because the index provides candidate rows that need recheck

**Compared to PostgreSQL:**
- PG's GIN on native arrays (`tags TEXT[]`) is more mature and flexible
- PG's `jsonb_path_ops` GIN index is more powerful for nested JSON containment
- MySQL's multi-valued index is specifically for flat JSON arrays — adequate for tags/labels, insufficient for deep nested queries

---

## 9. Optimizer Hints for Index Selection

MySQL 8.0 introduced optimizer hints (inline `/*+ ... */` comments) that override the optimizer's index choice. These replace the older `FORCE INDEX`, `USE INDEX`, and `IGNORE INDEX` syntax.

### Modern Optimizer Hints (8.0+)

```sql
-- Force a specific index:
SELECT /*+ INDEX(orders idx_status_date) */ *
FROM orders
WHERE status = 'pending' AND created_at > '2024-01-01';

-- Forbid a specific index:
SELECT /*+ NO_INDEX(orders idx_old_status) */ *
FROM orders
WHERE status = 'pending';

-- Force a join order:
SELECT /*+ JOIN_ORDER(customers, orders) */ c.name, o.total
FROM customers c
JOIN orders o ON o.customer_id = c.id;

-- Force a join strategy:
SELECT /*+ HASH_JOIN(orders) */ *
FROM orders o JOIN customers c ON c.id = o.customer_id;

-- Force index merge:
SELECT /*+ INDEX_MERGE(orders idx_status, idx_date) */ *
FROM orders
WHERE status = 'pending' OR created_at > '2024-01-01';

-- Disable index condition pushdown for a table:
SELECT /*+ NO_ICP(orders) */ *
FROM orders WHERE status = 'pending' AND total > 100;

-- Set a per-query work_mem equivalent (join/sort buffer):
SELECT /*+ SET_VAR(sort_buffer_size = 16777216) */ *
FROM orders ORDER BY created_at;
```

### Legacy Hint Syntax (Still Works, Less Flexible)

```sql
-- Force a specific index:
SELECT * FROM orders FORCE INDEX (idx_status_date)
WHERE status = 'pending' AND created_at > '2024-01-01';

-- Suggest an index (optimizer may still override):
SELECT * FROM orders USE INDEX (idx_status_date)
WHERE status = 'pending' AND created_at > '2024-01-01';

-- Prevent a specific index:
SELECT * FROM orders IGNORE INDEX (idx_old_status)
WHERE status = 'pending';
```

**When to use hints:**
- **Temporary workaround** for a known optimizer bug (plan to remove when upgrading)
- **Benchmark comparisons** to test whether a different plan is actually faster
- **Emergency triage** in production when the optimizer suddenly picks a bad plan after data changes

**When NOT to use hints:**
- As permanent fixtures in application code (they hide the real problem: usually stale statistics or schema issues)
- Without benchmarking both the hinted and unhinted plans
- In ORMs that generate SQL (hints may be dropped or cause syntax errors)

**PostgreSQL has no equivalent to optimizer hints.** PG's philosophy is "fix the planner, don't give the user escape hatches." This is philosophically clean but means PG users have fewer tools when the planner goes wrong (other than `SET enable_*` per-session, which is a blunter instrument).

---

## 10. Index Maintenance

### Detecting Unused Indexes

```sql
-- sys schema shortcut:
SELECT * FROM sys.schema_unused_indexes;

-- Manual query from Performance Schema:
SELECT
  object_schema AS db,
  object_name AS tbl,
  index_name AS idx,
  count_star AS rows_read
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE index_name IS NOT NULL
  AND count_star = 0
  AND object_schema NOT IN ('mysql', 'sys', 'performance_schema', 'information_schema')
ORDER BY object_schema, object_name;
```

**Caveat:** Performance Schema statistics are reset on server restart (unless you use a persistent consumer, which most installations don't). Check across a full business cycle before declaring an index unused.

### Detecting Redundant Indexes

```sql
-- sys schema:
SELECT * FROM sys.schema_redundant_indexes;
-- Shows indexes that are a leftmost prefix of another index on the same table.
```

### Detecting Duplicate Indexes

```sql
-- Exact duplicates (same columns, same order):
SELECT
  a.TABLE_SCHEMA, a.TABLE_NAME,
  a.INDEX_NAME AS idx_1,
  b.INDEX_NAME AS idx_2,
  a.COLUMN_NAME
FROM INFORMATION_SCHEMA.STATISTICS a
JOIN INFORMATION_SCHEMA.STATISTICS b
  ON a.TABLE_SCHEMA = b.TABLE_SCHEMA
  AND a.TABLE_NAME = b.TABLE_NAME
  AND a.SEQ_IN_INDEX = b.SEQ_IN_INDEX
  AND a.COLUMN_NAME = b.COLUMN_NAME
  AND a.INDEX_NAME < b.INDEX_NAME
WHERE a.TABLE_SCHEMA NOT IN ('mysql', 'sys', 'performance_schema', 'information_schema')
GROUP BY a.TABLE_SCHEMA, a.TABLE_NAME, a.INDEX_NAME, b.INDEX_NAME;
```

### Online Index Operations

```sql
-- Add index without blocking DML (default in 8.0):
ALTER TABLE orders ADD INDEX idx_region (region), ALGORITHM=INPLACE, LOCK=NONE;

-- Drop index (instant metadata operation):
ALTER TABLE orders DROP INDEX idx_old_region, ALGORITHM=INPLACE, LOCK=NONE;

-- Rename index (instant):
ALTER TABLE orders RENAME INDEX idx_old TO idx_new;

-- Rebuild a fragmented index:
ALTER TABLE orders DROP INDEX idx_region, ADD INDEX idx_region (region),
  ALGORITHM=INPLACE, LOCK=NONE;
-- Or: OPTIMIZE TABLE orders; (rebuilds all indexes, but locks for analysis phase)
```

### Index Fragmentation

InnoDB pages have a fill factor of ~15/16 (~93.75%) after initial creation. Over time, random inserts and page splits fragment the B+tree.

```sql
-- Check fragmentation per table (approximate):
SELECT
  TABLE_SCHEMA, TABLE_NAME,
  DATA_LENGTH, INDEX_LENGTH, DATA_FREE,
  ROUND(DATA_FREE / (DATA_LENGTH + INDEX_LENGTH + DATA_FREE) * 100, 1) AS frag_pct
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA NOT IN ('mysql', 'sys', 'performance_schema', 'information_schema')
  AND DATA_FREE > 1048576  -- >1MB free
ORDER BY DATA_FREE DESC
LIMIT 20;

-- Rebuild to reclaim space (online in 8.0):
ALTER TABLE orders ENGINE=InnoDB;
-- This is the MySQL equivalent of PostgreSQL's pg_repack.
```

---

## 11. Index Design Patterns for Common Scenarios

### Pattern: Soft Delete

```sql
-- MySQL lacks partial indexes, so the NULL trick on a generated column:
ALTER TABLE users ADD COLUMN is_live TINYINT
  GENERATED ALWAYS AS (IF(deleted_at IS NULL, 1, NULL)) STORED;
CREATE INDEX idx_live_users ON users (is_live, email);
-- Only non-deleted users are indexed.
-- Query: WHERE is_live = 1 AND email = 'alice@example.com'
```

### Pattern: Latest Record Per Entity

```sql
-- PK: id AUTO_INCREMENT
-- Index: (device_id, created_at DESC)  — 8.0+ real descending index
CREATE INDEX idx_latest ON readings (device_id, created_at DESC);

-- Query:
SELECT * FROM readings
WHERE device_id = 42
ORDER BY created_at DESC
LIMIT 1;
-- Uses the index to jump directly to device_id=42's newest entry.
```

### Pattern: Job Queue (Claim Next Unclaimed)

```sql
-- Generated column + index (partial index equivalent):
ALTER TABLE jobs ADD COLUMN is_pending TINYINT
  GENERATED ALWAYS AS (IF(status = 'pending', 1, NULL)) STORED;
CREATE INDEX idx_pending ON jobs (is_pending, priority DESC, created_at ASC);

-- Claim next job:
SELECT id FROM jobs
WHERE is_pending = 1
ORDER BY priority DESC, created_at ASC
LIMIT 1
FOR UPDATE SKIP LOCKED;
-- SKIP LOCKED (8.0+) is MySQL's equivalent of PG's SKIP LOCKED.
```

### Pattern: Multi-Tenant

```sql
-- Every query includes tenant_id. Make it the leading column of every index:
CREATE INDEX idx_tenant_status ON orders (tenant_id, status, created_at);
CREATE INDEX idx_tenant_customer ON orders (tenant_id, customer_id);

-- If using BIGINT AUTO_INCREMENT PK, consider a composite PK:
-- (tenant_id, id) — clusters data by tenant for better locality
-- But: this changes every FK reference and every secondary index structure.
-- Only worth it for large multi-tenant databases (100k+ tenants).
```

### Pattern: Covering Index for Dashboard Query

```sql
-- Dashboard shows: order count, total revenue, by status, for the last 7 days
-- Without covering index: bookmark lookup for every matching row

CREATE INDEX idx_dashboard ON orders (status, created_at)
  -- In MySQL, we add the aggregate source columns as trailing key columns:
  COMMENT 'covers dashboard aggregation';
-- Since we're doing COUNT(*) and SUM(total), and MySQL's secondary index
-- already includes the PK, we need 'total' in the index:
CREATE INDEX idx_dashboard ON orders (status, created_at, total);

SELECT status, COUNT(*), SUM(total)
FROM orders
WHERE created_at > NOW() - INTERVAL 7 DAY
GROUP BY status;
-- EXPLAIN should show "Using index" — no bookmark lookup.
```

---

## 12. Quick Reference: MySQL vs PostgreSQL Index Feature Comparison

| Feature | PostgreSQL | MySQL (InnoDB) |
|---------|-----------|----------------|
| Default index type | B-tree (separate from heap) | B+tree (clustered by PK) |
| Partial indexes | Yes (`WHERE` clause) | No (workaround: generated column with NULL) |
| Expression indexes | Yes (any immutable function) | Yes (8.0.13+ functional index; older: generated column) |
| Covering indexes (INCLUDE) | Yes (PG 11+) | No (workaround: trailing key columns) |
| Invisible indexes | No | Yes (8.0+) — huge advantage for index auditing |
| Descending indexes | Yes | Yes (8.0+ — real; pre-8.0 ignored) |
| GIN (inverted index) | Yes (FTS, JSONB, arrays, trigrams) | No (FULLTEXT is weaker; multi-valued index for JSON arrays) |
| GiST (spatial, ranges) | Yes | SPATIAL (R-tree, limited) |
| BRIN (block range) | Yes | No |
| SP-GiST | Yes | No |
| Hash index | Yes | No (silently converted to B+tree) |
| Index skip scan | No | Yes (8.0.13+, limited) |
| Optimizer hints for indexes | No (only `SET enable_*`) | Yes (`/*+ INDEX() */`, `FORCE INDEX`) |
| Index-only scan | Yes ("Index Only Scan") | Yes ("Using index" in Extra) |
| CREATE INDEX CONCURRENTLY | Yes (no write lock) | Default behavior in 8.0 (ALGORITHM=INPLACE, LOCK=NONE) |
| Unique constraints on nullable columns | One NULL per unique | Multiple NULLs per unique (different semantics!) |
| PK in secondary index leaves | No (stores heap TID) | Yes (stores PK value — wider indexes) |
