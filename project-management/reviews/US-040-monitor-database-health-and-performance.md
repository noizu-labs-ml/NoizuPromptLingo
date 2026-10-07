# Review: Monitor Database Health and Performance

- **Story**: `project-management/user-stories/US-040-monitor-database-health-and-performance.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No database health/performance monitoring tooling exists in either codebase. The story assumes SQLite WAL/statistics tables; actual storage is PostgreSQL (`src/npl_mcp/storage/pool.py:1-30`, asyncpg), so the story's premise is stale. Searches of `src/npl_mcp/` and the Elixir backend (`backend/lib/noizu_prompt_lingua/`) found no `pg_stat_*` queries, no slow-query analysis, no WAL checkpoints, no cache-hit/lock monitoring, and no health-report MCP tool. The only related surface is the generic Ping tool (`src/npl_mcp/browser/`), which is not database health. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Report DB file sizes and table counts | Not Met | no evidence found |
| Report WAL checkpoint statistics | Not Met | no evidence found (WAL is SQLite-specific; no `pg_stat_wal` equivalent either) |
| Report cache hit ratios and slow queries | Not Met | no evidence found |
| Report lock contention and blocked queries | Not Met | no evidence found |
| Output structured health report with recommendations | Not Met | no evidence found |

## Gaps / Risks

- Story premise is stale: written for SQLite; storage is now Postgres. Re-scope criteria to `pg_stat_statements`, `pg_stat_activity`, `pg_locks`, and pg vector/extension health before implementing.
- No observability hook (Prometheus/Grafana or Infisical-managed metrics exporter) exists as an alternative either.

## BDD Scenario

```gherkin
Feature: Database health monitoring
  Scenario: Coordinator checks DB health before a load spike
    Given the NPL platform running on PostgreSQL
    When the coordinator requests a database health report via MCP
    Then no such tool exists and the request cannot be served
```
