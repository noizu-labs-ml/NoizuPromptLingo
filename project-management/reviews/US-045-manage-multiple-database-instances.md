# Review: Manage Multiple Database Instances

- **Story**: `project-management/user-stories/US-045-manage-multiple-database-instances.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No profile abstraction exists. The Python MCP server's storage layer is PostgreSQL (asyncpg) configured through a single flat set of environment variables — `NPL_DB_HOST`, `NPL_DB_PORT`, `NPL_DB_NAME`, `NPL_DB_USER`, `NPL_DB_PASSWORD` (`src/npl_mcp/storage/pool.py:24-28`) — one active connection, no named profiles, no clone, no listing, no archiving. The story's technical notes reference the legacy `NPL_MCP_DATA_DIR` SQLite era; that variable no longer appears anywhere in `src/` (grep: zero hits). There is also no production-guard mechanism (no "prod" flag, confirmation gate, or read-only mode) anywhere in the storage path. The concept of "environment switching" today degenerates to editing env vars and restarting the process.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Create named database profiles (dev, test, prod) | Not Met | no evidence found; single-connection config at `src/npl_mcp/storage/pool.py:24-28` |
| Switch active database via environment variable or CLI flag | Partially Met | Env vars select *the* database (`pool.py:24-28`), but there is one implicit "active" DB — no profile to switch to, no CLI flag |
| Clone database to new profile | Not Met | no evidence found |
| List all database profiles with metadata | Not Met | no evidence found |
| Archive or delete old profiles | Not Met | no evidence found |
| Prevent accidental operations on production database | Not Met | no guard, confirmation, or read-only mode in the storage layer (grep: zero hits) |

## Gaps / Risks

- The story's premise (SQLite + `NPL_MCP_DATA_DIR`) is stale: the backend moved to PostgreSQL via Liquibase (`liquibase/changelogs/`), so a redesign — e.g. a profiles table plus a connection-factory keyed by profile — is needed before any criterion can be implemented.
- The safety criterion (prod protection) is the highest-value item and is entirely absent; today a mispointed `NPL_DB_*` env silently targets whatever database the variables name.
- No tests cover connection configuration or environment switching.

## BDD Scenario

```gherkin
Feature: Manage multiple database instances

  Scenario: Create and switch profiles (not implemented)
    Given the MCP server is running
    When I create a "staging" profile cloned from "dev" and switch to it
    Then no such command exists — only the flat NPL_DB_* environment variables
    And a restart with different env vars is the only way to change databases

  Scenario: Production guard (not implemented)
    Given the active database is tagged "prod"
    When a destructive operation is attempted without explicit override
    Then nothing blocks it — no production-guard mechanism exists today
```

(Scenario describes target behavior — none of it is executable today.)
