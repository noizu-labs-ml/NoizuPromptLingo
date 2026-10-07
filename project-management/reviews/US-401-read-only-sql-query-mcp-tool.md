# Review: Query the platform database read-only through an MCP tool

- **Story**: `project-management/user-stories/US-401-read-only-sql-query-mcp-tool.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No DB-access MCP tool exists on either fleet — confirmed, matching the story's own "confirmed open space" note. The Python server (`src/npl_mcp/launcher.py`) registers no SQL/query tool; its asyncpg pool (`src/npl_mcp/storage/pool.py:19-32`, `NPL_DB_*` env, min 1 / max 5) is consumed only by internal services (storage/metrics.py, storage/error_log.py, instructions/, tool_sessions/, browser/secrets), never with caller-supplied SQL. On the Elixir backend, `lib/noizu_prompt_lingua/mcp/toolset_provider.ex` uses `repo.query!` but only with fixed internal statements for toolset config — no caller-supplied SQL path. Nothing anywhere sets `statement_timeout`, enforces read-only, or applies row limits. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| SELECT returns rows with column names/types as JSON | Not Met | no evidence found — no SQL tool registered in `src/npl_mcp/launcher.py` or Elixir `lib/noizu_prompt_lingua/mcp/toolsets` |
| Statement timeout → server-side cancel, connection returned, timeout error | Not Met | no evidence found — no `statement_timeout` in Python src or Elixir backend config (`config/*.exs`) |
| Row limit with truncation marker + total count | Not Met | no evidence found |
| INSERT/UPDATE/DELETE/DDL/multi-statement rejected pre-execution | Not Met | no evidence found — no read-only guard exists |
| Pool exhaustion → clear "pool exhausted" error, not a hang | Not Met | `src/npl_mcp/storage/pool.py:23-31` creates the pool with no `command_timeout`/acquire-timeout config; asyncpg `acquire()` waits indefinitely by default |

## Gaps / Risks

- The shared Python pool has no acquire timeout — the existing internal services already hang unboundedly under pool exhaustion; the story's error-not-hang requirement has no precedent to copy from.
- Internal `repo.query!` calls in `lib/noizu_prompt_lingua/mcp/toolset_provider.ex:88,136,213,440,554,582,611` interpolate table names; fine today (fixed strings), but any future "generic query" reuse would be injection-prone.
- Story notes correctly distinguish this from PRD-N2 storage-providers; no conflict found in code.

## BDD Scenario

```gherkin
Feature: Read-only SQL query MCP tool

  Scenario: Authorized SELECT returns JSON rows
    Given an authorized MCP caller with the db-query tool in its toolset
    When it calls the DB query tool with "SELECT id, name FROM projects LIMIT 3"
    Then the response contains 3 rows with column names and types serialized as JSON

  Scenario: Statement timeout cancels server-side
    Given the statement timeout is configured to 5 seconds
    When the caller submits "SELECT pg_sleep(30)"
    Then the tool returns a timeout error within 5 seconds
    And the underlying Postgres backend is cancelled
    And the pool connection is returned to the pool

  Scenario: Row limit truncation
    Given the row limit is configured to 100
    When the caller submits a SELECT matching 5,000 rows
    Then the response contains exactly 100 rows
    And includes a "truncated: true" marker and a total-available count

  Scenario: Write statements rejected
    When the caller submits "INSERT INTO projects (name) VALUES ('x')"
    Then the tool rejects it before execution with a read-only violation error
    And no rows are modified

  Scenario: Pool exhaustion returns promptly
    Given the pool allows 5 concurrent queries and 6 are in flight
    When the 6th query arrives
    Then it receives a "pool exhausted" error without waiting indefinitely
```
