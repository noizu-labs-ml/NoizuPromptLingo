---
id: US-089
title: "Conflict resolution when two users edit same mockup"
slug: "conflict-resolution-concurrent-edit"
personas: [P-001, P-002, P-005]
epic: "Edge Cases & Error States"
priority: "should-have"
complexity: "L"
tags: [collaboration, conflict-resolution, concurrency]
---

# US-089: Conflict resolution when two users edit same mockup

## User Story

**As an** Enterprise Architect (P-005),
**I want to** be notified and given options when a concurrent edit conflict occurs on a shared mockup,
**So that** my changes are not silently overwritten by a teammate's simultaneous edits.

## Acceptance Criteria

- [ ] Given two users have the same mockup open for editing, when both submit changes, then the second save receives a conflict error indicating the mockup was updated since it was loaded
- [ ] Given a conflict is detected, when the conflicting user reviews the error, then they see a diff view showing their changes versus the current saved version, with options to keep theirs, accept the other, or merge
- [ ] Given the user resolves the conflict, when they submit their resolution, then the mockup is saved with the resolved content and both users' views refresh

## Notes

Optimistic locking via `updated_at` version field is the recommended initial approach. Real-time collaborative editing (OT/CRDT) is out of scope for v1 but the conflict UI should be designed to accommodate it later. This story represents the highest complexity in this epic.
