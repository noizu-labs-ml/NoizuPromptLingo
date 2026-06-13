# Query Audit Report

## Audit Metadata
- **Database**: {name, version}
- **Application**: {project name}
- **Date**: {YYYY-MM-DD}
- **Auditor**: {name}
- **Scope**: {all queries / specific module / top N by runtime}
- **Source**: {pg_stat_statements / application logs / ORM query log / manual collection}
- **Time Window**: {e.g., last 7 days of production traffic}

## Configuration Snapshot

Capture relevant settings at audit time for reproducibility.

| Setting | Value |
|---------|-------|
| `shared_buffers` | {e.g., 4GB} |
| `work_mem` | {e.g., 64MB} |
| `effective_cache_size` | {e.g., 12GB} |
| `random_page_cost` | {e.g., 1.1} |
| `max_connections` | {e.g., 200} |
| `default_statistics_target` | {e.g., 100} |

---

## Top Slow Queries

### Query 1: {descriptive name}

- **Source**: {file:line or ORM model.method()}
- **Frequency**: {calls/hour}
- **Avg Duration**: {ms}
- **Max Duration**: {ms}
- **Rows Returned (avg)**: {count}
- **Current Plan Summary**: {Seq Scan / Nested Loop / Hash Join / etc.}
- **Triggered By**: {user action / background job / API endpoint}

#### SQL

```sql
{paste the query here, with parameter placeholders}
```

#### EXPLAIN ANALYZE Output

```
{paste full EXPLAIN ANALYZE (BUFFERS, FORMAT TEXT) output}
```

#### Analysis

- **Bottleneck**: {what is slow and why -- e.g., "Seq Scan on orders (2.4M rows) because no index on customer_id"}
- **Root Cause**: {missing index / bad join order / implicit cast preventing index use / correlated subquery / N+1 from ORM / stale statistics / etc.}
- **Data Volume**: {relevant table sizes and row counts}

#### Recommendation

- **Action**: {add index / rewrite query / add covering index / materialize view / batch the operation / etc.}
- **Specific Change**:
  ```sql
  {e.g., CREATE INDEX CONCURRENTLY idx_orders_customer_id ON orders(customer_id);}
  ```
- **Expected Improvement**: {estimated reduction, e.g., "2400ms to ~5ms based on index selectivity"}
- **Migration Required**: Yes / No
- **Downtime Required**: Yes ({duration}) / No
- **Risk**: {e.g., "CONCURRENTLY avoids locking but requires extra disk space during build"}

#### After Fix

```sql
{optimized query, if rewritten}
```

```
{new EXPLAIN ANALYZE output after fix is applied}
```

- **Actual Improvement**: {measured reduction}

---

### Query 2: {descriptive name}

- **Source**: {file:line or ORM model.method()}
- **Frequency**: {calls/hour}
- **Avg Duration**: {ms}
- **Max Duration**: {ms}
- **Rows Returned (avg)**: {count}
- **Current Plan Summary**: {Seq Scan / Nested Loop / Hash Join / etc.}
- **Triggered By**: {user action / background job / API endpoint}

#### SQL

```sql
{query}
```

#### EXPLAIN ANALYZE Output

```
{plan}
```

#### Analysis

- **Bottleneck**: {what is slow and why}
- **Root Cause**: {missing index / bad join / implicit cast / etc.}
- **Data Volume**: {relevant table sizes}

#### Recommendation

- **Action**: {add index / rewrite query / etc.}
- **Specific Change**:
  ```sql
  {change}
  ```
- **Expected Improvement**: {estimated reduction}
- **Migration Required**: Yes / No
- **Downtime Required**: Yes ({duration}) / No
- **Risk**: {notes}

#### After Fix

```sql
{optimized query}
```

```
{new EXPLAIN output}
```

- **Actual Improvement**: {measured reduction}

---

{Copy this block for additional queries.}

---

## N+1 Query Patterns

ORM-generated N+1 patterns deserve a dedicated section since they are the most common performance issue.

| Location | Parent Query | Child Query | N (avg) | Total Time | Fix |
|----------|-------------|-------------|---------|------------|-----|
| {file:line} | {e.g., User.all} | {e.g., User -> posts} | {e.g., 150} | {ms} | {preload / join / subquery} |
| -- | -- | -- | -- | -- | -- |

---

## Summary

| Query | Before (ms) | After (ms) | Improvement | Effort | Status |
|-------|-------------|------------|-------------|--------|--------|
| {name} | -- | -- | --% | S/M/L | Pending / Applied / Verified |
| -- | -- | -- | -- | -- | -- |

## Recommendations Priority

| Priority | Action | Effort | Impact | Dependencies |
|----------|--------|--------|--------|-------------|
| 1 | -- | Low / Medium / High | Low / Medium / High / Critical | {e.g., requires migration window} |
| 2 | -- | -- | -- | -- |
| 3 | -- | -- | -- | -- |

## General Observations

{Notes on overall database health, patterns observed across queries, systemic issues, configuration recommendations, or follow-up audits needed.}

- **Statistics freshness**: {Are autovacuum/autoanalyze keeping stats current?}
- **Index usage**: {Any unused indexes identified via pg_stat_user_indexes?}
- **Table bloat**: {Any tables with significant dead tuple ratios?}
- **Connection patterns**: {Connection pool saturation, idle connections, etc.}
