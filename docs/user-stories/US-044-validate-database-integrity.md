# US-044 - Validate Database Integrity

**ID**: US-044
**Persona**: P-005 - Dave the Fellow Developer
**PRD Group**: coordination
**Priority**: high
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As Dave, I want to verify database integrity after crashes, So that I can detect and repair corruption before it causes failures.

## Acceptance Criteria

- [ ] Run PRAGMA integrity_check and report results
- [ ] Check foreign key constraints (PRAGMA foreign_key_check)
- [ ] Verify artifact files exist for all revisions
- [ ] Detect orphaned records (artifacts without revisions, etc.)
- [ ] Repair or quarantine corrupted records
- [ ] Generate integrity report with severity levels

## Technical Notes

Infrastructure documentation mentions local-first design but no integrity checks currently exist. SQLite provides PRAGMA commands for introspection and validation that should be wrapped in user-friendly tooling.

## Dependencies

- Related stories: None
- Related personas: P-005

## Context

This represents a NEW capability addressing data integrity validation. The current system lacks any mechanism to detect or repair database corruption that might occur after crashes or unexpected shutdowns. Given the local-first architecture and reliance on SQLite, integrity validation is critical for maintaining system reliability.
