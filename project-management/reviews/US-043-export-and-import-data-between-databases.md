# Review: Export and Import Data Between Databases

- **Story**: `project-management/user-stories/US-043-export-and-import-data-between-databases.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No database export/import tooling exists. The story's premise (three SQLite databases, table-by-table JSON export/import with FK-preserving ordering) is stale: storage is PostgreSQL (`src/npl_mcp/storage/pool.py:1-30`), Ecto/Postgres on the Elixir backend. Searches found no export/import functions, no staging validation, no FK-ordering logic, and no row-count reconciliation report in either codebase. The nearest capability is `tools/git_dump.py`/`tools/git_tree.py`, which dump *repository* files to text, not databases. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Export each database to a portable format preserving FK references | Not Met | no evidence found |
| Import into a target database with validation before commit | Not Met | no evidence found |
| Row counts + integrity checks reported post-import | Not Met | no evidence found |
| Support selective table export | Not Met | no evidence found |

## Gaps / Risks

- Premise is stale (SQLite → Postgres); re-scope to `pg_dump`/`pg_restore`/`COPY`-based flows.
- Migration between environments currently requires manual DBA work with no tooling support.

## BDD Scenario

```gherkin
Feature: Export/import data between databases
  Scenario: Operator migrates data to a fresh environment
    Given two PostgreSQL deployments (source and target)
    When the operator requests an export and subsequent import
    Then no such tool exists and the migration cannot be performed
```
