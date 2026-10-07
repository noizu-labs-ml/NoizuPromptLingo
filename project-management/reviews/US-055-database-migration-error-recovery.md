# Review: Database Migration Error Recovery

- **Story**: `project-management/user-stories/US-055-database-migration-error-recovery.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No migration system exists in the Python MCP server. `src/npl_mcp/storage/` contains only `pool.py`, `error_log.py`, and `metrics.py` — the `db.py` file the story targets does not exist (the storage layer has evidently moved to an asyncpg pool). Repo-wide greps for `migrat`, `rollback`, `--to-version`, and `.bak` across `src/npl_mcp/` return no implementation hits; no `npl-db` CLI command is registered in `src/npl_mcp/launcher.py`. Schema appears provisioned out-of-band: grep finds no `CREATE TABLE` DDL anywhere in `src/npl_mcp/` (e.g. `src/npl_mcp/artifacts/reviews.py:54` only INSERTs into `npl_reviews`), so table creation lives outside the codebase entirely. Confidence: high that the story is unimplemented.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Migration system tracks version and supports rollback | Not Met | no evidence found in `src/npl_mcp/` |
| Failed migrations automatically roll back and log error details | Not Met | no evidence found |
| Pre-migration backup created automatically (`.sqlite.bak`) | Not Met | no evidence found; storage is PostgreSQL (asyncpg), not SQLite |
| Manual recovery command `npl-db rollback --to-version N` | Not Met | no `npl-db` entry point in `src/npl_mcp/launcher.py` |
| Migration failures block server startup with clear error | Not Met | no migration runner exists to fail |
| Integration with existing Database class (`src/npl_mcp/storage/db.py`) | Not Met | `storage/db.py` does not exist; current modules are `pool.py`, `error_log.py`, `metrics.py` |

## Gaps / Risks

- Story is stale in two ways: it targets a nonexistent `db.py` and assumes SQLite, while the server now uses PostgreSQL via `storage/pool.py`. A re-spec is needed before implementation.
- Schema is provisioned entirely out-of-band with no in-code DDL or version tracking, so schema drift between environments is undetectable from the repo.

## BDD Scenario

```gherkin
Feature: Safe database migration with rollback

  Scenario: Attempt manual rollback after a bad migration
    Given a failed schema migration
    When the operator runs `npl-db rollback --to-version N`
    Then the command fails — no such CLI command exists today
```
