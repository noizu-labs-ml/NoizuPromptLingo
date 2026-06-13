# US-055 - Database Migration Error Recovery

**ID**: US-055
**Persona**: P-003 - Vibe Coder
**PRD Group**: npl_load
**Priority**: critical
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a vibe coder, I need automatic rollback and error recovery for database migrations so that I don't corrupt the SQLite database during rapid iteration.

## Acceptance Criteria

- [ ] Migration system tracks version and supports rollback (addresses gap in docs-summary.md line 82)
- [ ] Failed migrations automatically roll back and log error details
- [ ] Pre-migration backup created automatically (`.sqlite.bak`)
- [ ] Manual recovery command: `npl-db rollback --to-version N`
- [ ] Migration failures block server startup with clear error message
- [ ] Integration with existing Database class (src/npl_mcp/storage/db.py)

## Technical Notes

This story addresses a known architectural gap identified in `.tmp/docs-summary.md` (line 82: "No database migration system"). The migration system should be robust, automatic, and integrate seamlessly with the existing Database class in `src/npl_mcp/storage/db.py`.

The system should:
- Track migration versions in the database
- Create automatic backups before applying migrations
- Roll back automatically on failure
- Provide manual rollback commands for recovery
- Block server startup if migrations fail to prevent data corruption

## Dependencies

- Related stories: (addresses architectural gap from docs-summary.md)
- Related personas: P-003

## Priority Rationale

**Critical priority** - This story addresses a fundamental architectural gap. Database corruption during migration is a catastrophic failure mode that can result in complete data loss. Automatic rollback and recovery mechanisms are essential for safe database schema evolution.
