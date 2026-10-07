# Review: Backup and Restore Database

- **Story**: `project-management/user-stories/US-039-backup-and-restore-database.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No backup/restore mechanism exists. The story's premise (three local SQLite databases) also no longer matches the codebase: the Python MCP server persists via PostgreSQL (asyncpg pool at `src/npl_mcp/storage/pool.py:1-30`), and the Elixir backend uses Ecto/Postgres. A repo-wide search of `src/` found no `pg_dump`/`pg_restore` wrappers, no backup listing, no integrity-verify-before-restore, and no SQL-dump export tool. The only "backup" code is `npl_persona` persona-file backup (`src/npl_persona/compat.py:397`, CLI `src/npl_persona/cli.py:163-167`), which backs up persona files, not databases. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Create timestamped backup of all three databases | Not Met | no evidence found (no backup code in `src/npl_mcp`) |
| List backups with metadata (size, timestamp, schema version) | Not Met | no evidence found |
| Restore from backup with confirmation prompt | Not Met | no evidence found |
| Verify backup integrity before restore | Not Met | no evidence found |
| Export database to portable format (SQL dump) | Not Met | no evidence found |

## Gaps / Risks

- Story premise is stale: "all three SQLite databases" — storage is now Postgres; the story should be re-scoped (pg_dump/pg_restore or Infisical/k8s-native backup) before implementation.
- Data-protection gap flagged `critical` in the story remains open for production deployments.

## BDD Scenario

```gherkin
Feature: Database backup and restore
  Scenario: Project manager backs up state before a risky change
    Given the NPL platform running on its Postgres storage
    When the project manager requests a backup through any MCP tool or CLI
    Then no such tool exists and the operation cannot be performed
```
