# US-038 - Apply Database Schema Migration

**ID**: US-038
**Persona**: P-005 - Dave the Fellow Developer
**PRD Group**: coordination
**Priority**: high
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As Dave, I want to apply schema migrations safely, so that I can update database structure without losing data.

## Acceptance Criteria

- [ ] View pending migrations before applying
- [ ] Preview migration SQL statements
- [ ] Rollback failed migrations
- [ ] Verify migration applied successfully
- [ ] See migration history with timestamps

## Technical Notes

Current system auto-applies migrations on startup with no review or rollback capability. The basic migration system exists in `migrations.py` with version tracking in `schema_version` table, but lacks interactive controls and safety features.

## Dependencies

- Related stories: US-039, US-041, US-043
- Related personas: P-005

## Context

Three separate SQLite databases are managed (MCP, NIMPS, KB), and migrations run automatically via `run_migrations()` on startup. This story addresses the need for controlled, reviewable migration workflows with rollback capabilities for safer database schema evolution.
