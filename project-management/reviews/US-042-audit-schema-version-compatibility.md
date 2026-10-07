# Review: Audit Schema Version Compatibility

- **Story**: `project-management/user-stories/US-042-audit-schema-version-compatibility.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No schema-version audit tooling exists. The story's premise (three SQLite databases, per-database schema versioning via `PRAGMA user_version`) is stale: storage is PostgreSQL (`src/npl_mcp/storage/pool.py:1-30`), and schema on the platform side is owned by Liquibase per the monorepo policy (with Ecto migrations in the Elixir backend). Searches found no compatibility-matrix generation, no version comparison logic, no drift detection, and no audit report anywhere in `src/` or `backend/lib`. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Read current schema version of each database | Not Met | no evidence found |
| Compare against expected/target version matrix | Not Met | no evidence found |
| Flag incompatible/drifted databases | Not Met | no evidence found |
| Emit structured audit report | Not Met | no evidence found |

## Gaps / Risks

- Premise is stale (SQLite → Postgres). A re-scoped version should audit Liquibase changelog state vs deployed DB (via `liquibase-shell` targets) and Ecto migration status.
- Without drift detection, schema mismatch between environments is currently only discovered at runtime failure.

## BDD Scenario

```gherkin
Feature: Schema version compatibility audit
  Scenario: Operator audits schema drift before a release
    Given the platform's PostgreSQL deployments across environments
    When the operator requests a schema compatibility audit
    Then no such audit tool exists and drift can only be found by manual inspection
```
