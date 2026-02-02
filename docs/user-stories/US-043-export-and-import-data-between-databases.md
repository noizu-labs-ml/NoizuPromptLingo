# US-043 - Export and Import Data Between Databases

**ID**: US-043
**Persona**: P-003 - Vibe Coder
**PRD Group**: collaboration
**Priority**: medium
**Status**: draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a vibe coder, I want to export artifacts and chat history to share with teammates, So that we can collaborate across different NPL installations.

## Acceptance Criteria

- [ ] Export selected artifacts with revision history as portable archive
- [ ] Export chat room with all events and attachments
- [ ] Export task queue with acceptance criteria
- [ ] Import archive into different NPL instance
- [ ] Resolve ID conflicts during import (renumbering)
- [ ] Preserve timestamps and author metadata

## Technical Notes

Current system stores everything locally with auto-increment IDs. This story extends the capability to enable cross-instance data portability, which is essential for collaborative workflows across distributed NPL installations.

## Dependencies

- Related stories: US-004
- Related personas: P-003

## Context

This story extends US-004 (Share Artifact in Chat) to support cross-instance sharing. The current implementation stores all data locally with auto-incrementing IDs, which creates challenges when sharing data between different NPL installations. A portable archive format that can handle ID conflicts and preserve metadata is needed to enable true collaborative workflows across team members using different NPL instances.
