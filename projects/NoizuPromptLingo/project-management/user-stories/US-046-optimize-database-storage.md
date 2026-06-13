# US-046 - Optimize Database Storage

**ID**: US-046
**Persona**: P-005 - Dave the Fellow Developer
**PRD Group**: coordination
**Priority**: low
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As Dave, I want to reclaim disk space from deleted records, So that database file size doesn't grow unbounded.

## Acceptance Criteria

- [ ] Run VACUUM to rebuild database and reclaim space
- [ ] Show space savings report (before/after sizes)
- [ ] Archive old chat events beyond retention period
- [ ] Compress artifact revision blobs (if large)
- [ ] Warn when database exceeds size threshold
- [ ] Schedule automatic VACUUM during idle periods

## Technical Notes

Infrastructure documentation shows event-sourced chat but no compaction strategy exists. SQLite VACUUM command can rebuild the database file and reclaim space, but needs user-friendly wrapper with safety checks.

## Dependencies

- Related stories: US-009
- Related personas: P-005

## Context

This story relates to US-009 (Review Artifact History) in terms of revision retention policies. The current implementation uses event-sourced chat architecture without any compaction or cleanup strategy, which means database files will grow unbounded over time. A storage optimization capability is needed to maintain system performance and manage disk space effectively.
