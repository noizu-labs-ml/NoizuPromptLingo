# Review: Optimize Database Storage

- **Story**: `project-management/user-stories/US-046-optimize-database-storage.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No storage-optimization capability exists. Greps for `VACUUM`, `compress`, `retention`, and archive/prune logic across `src/` return no database-maintenance code — the only "retention"/"archive" hits are unrelated (sessions, browser diff, stub catalog). The chat event store (`npl_chat_events`, event-sourced via `src/npl_mcp/chat/chat.py`) has no pruning, compaction, or retention path; the versioned artifact store (`src/npl_mcp/artifacts/`) has no blob compression or revision culling; and there is no size-threshold warning or scheduler anywhere. The story's SQLite framing is also stale — the MCP server's storage is PostgreSQL (`src/npl_mcp/storage/pool.py`), so "VACUUM" would translate to Postgres maintenance (`VACUUM FULL`/pg_repack) rather than the SQLite file rebuild the notes describe.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Run VACUUM to rebuild database and reclaim space | Not Met | no evidence found; grep for `VACUUM` in `src/`: zero hits |
| Show space savings report (before/after sizes) | Not Met | no evidence found |
| Archive old chat events beyond retention period | Not Met | no retention/prune code for `npl_chat_events` (grep: zero hits) |
| Compress artifact revision blobs (if large) | Not Met | no compression logic in `src/npl_mcp/artifacts/` |
| Warn when database exceeds size threshold | Not Met | no size checks or alerts in `src/` |
| Schedule automatic VACUUM during idle periods | Not Met | no scheduler or idle-detection exists |

## Gaps / Risks

- Cross-cutting staleness: like US-045 (db profiles), the story assumes the retired SQLite architecture; acceptance criteria need re-basing on PostgreSQL/Liquibase before implementation.
- The event-sourced chat design guarantees unbounded growth and nothing today caps it — no retention job, no manual tool, and no monitoring hook, so this is a slow-moving operational risk rather than a feature gap.
- No tests exist for any storage-maintenance behavior (there is nothing to test).

## BDD Scenario

```gherkin
Feature: Optimize database storage

  Scenario: Reclaim space (not implemented)
    Given the chat event table has grown large from deleted/obsolete records
    When the developer runs the storage-optimization command
    Then no such command exists — no VACUUM wrapper, report, or retention job
    And the database file grows unbounded with no warning or cleanup path
```

(Scenario describes target behavior — none of it is executable today.)
