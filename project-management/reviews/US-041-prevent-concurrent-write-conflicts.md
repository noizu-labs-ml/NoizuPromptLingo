# Review: Prevent Concurrent Write Conflicts

- **Story**: `project-management/user-stories/US-041-prevent-concurrent-write-conflicts.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No optimistic-locking, versioned-write, or conflict-merge mechanism exists. The story's premise (three SQLite databases with WAL) is stale: the Python MCP server uses PostgreSQL via asyncpg (`src/npl_mcp/storage/pool.py:1-30`) and the Elixir backend uses Ecto/Postgres. Searches found no version column checks in update paths (e.g. `src/npl_mcp/tasks/tasks.py`, `src/npl_mcp/chat/chat.py`), no `Ecto.Changeset.optimistic_lock` usage in `backend/lib`, no busy-timeout/retry logic, and no conflict report surfaces. The coordination-domain stories (US-039/040/041/042/043/044 DB cluster) share this premise and none are implemented. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Optimistic locking with version columns / ETag-style rejection | Not Met | no evidence found in `src/` or `backend/lib` |
| Second writer gets a clear conflict error naming the first writer | Not Met | no evidence found |
| Retry flow offering "view their changes / overwrite / merge" | Not Met | no evidence found |
| Conflict report persisted for audit | Not Met | no evidence found |

## Gaps / Risks

- Concurrent edits currently silently last-write-win (plain UPDATE paths with no version check).
- Story premise is SQLite-specific; a re-scope for Postgres should use version columns + `UPDATE ... WHERE version = ?` guard rows or Ecto optimistic locks.

## BDD Scenario

```gherkin
Feature: Concurrent write conflict handling
  Scenario: Two agents edit the same task simultaneously
    Given two coordinators open the same task record
    When the second save is issued after the first lands
    Then no conflict is detected and the first writer's changes are
      silently overwritten
```
