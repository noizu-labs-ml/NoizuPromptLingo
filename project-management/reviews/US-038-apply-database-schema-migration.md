# Review: Apply Database Schema Migration

- **Story**: `project-management/user-stories/US-038-apply-database-schema-migration.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The story describes the legacy Python SQLite world (`migrations.py`, `schema_version` table, auto-apply on startup for MCP/NIMPS/KB databases). None of that exists in the current tree: there is no `migrations.py`, no `run_migrations`, and no `schema_version` reference anywhere under `src/` (the Python storage layer is now PostgreSQL via asyncpg with only `pool.py`, `metrics.py`, `error_log.py` in `src/npl_mcp/storage/`). The Elixir backend uses standard Ecto migrations (`backend/lib/supports/migration.ex` wraps `Ecto.Migration`; `backend/priv/repo/migrations/`), which provide versioned, reviewable migration files and reversible up/down through mix tasks — but that is framework tooling, not the story's requested in-app workflow. No interactive surface exists anywhere for: viewing pending migrations, previewing SQL, one-click rollback, verification, or in-app migration history.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| View pending migrations before applying | Not Met | no in-app surface; Ecto `mix ecto.migrations` is CLI-only framework tooling |
| Preview migration SQL statements | Not Met | no evidence found in either codebase |
| Rollback failed migrations | Partially Met | Ecto migrations support `mix ecto.rollback` per migration file (`backend/lib/supports/migration.ex:1-12`), but no product feature automates or surfaces rollback of a failed run |
| Verify migration applied successfully | Not Met | no verification step beyond the CLI's own exit status |
| Migration history with timestamps | Partially Met | `schema_migrations` is maintained by Ecto (framework behavior), but no product surface displays it |

## Gaps / Risks

- The story's stated baseline (Python `migrations.py` auto-apply) has been removed from the codebase — the story needs re-basing against the current dual-stack reality (Postgres + Ecto migrations) before it can be specified or implemented.
- The Python MCP server's tables (`npl_tasks`, `npl_chat_*`, `npl_reviews`, etc.) currently have no visible migration mechanism in `src/npl_mcp/storage/`; how their schema evolves is unaddressed — that gap is arguably this story's real target on the Python side.

## BDD Scenario

```gherkin
Feature: Apply Database Schema Migration

  Scenario: Reviewable migration workflow (not available)
    Given a developer has added a new migration changing a table
    When they open the migration management surface
    Then no such surface exists to list pending migrations or preview SQL

  Scenario: Framework-level fallback (today)
    Given the Elixir backend repo with committed Ecto migrations
    When the developer runs mix ecto.migrations / ecto.rollback from the CLI
    Then Ecto applies or reverts versioned migrations and records them in schema_migrations
    But no in-app review, preview, verification, or history view is offered
```
