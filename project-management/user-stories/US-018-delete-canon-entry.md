---
id: US-018
title: "Delete a Canon Entry"
slug: "delete-canon-entry"
personas: [P-003, P-005]
epic: "Canon Editor — Core"
priority: "must-have"
complexity: "S"
tags: [canon, entry, delete, safety]
---

# US-018: Delete a Canon Entry

## User Story

**As a** narrative designer (P-003),
**I want to** delete a canon entry that is no longer part of the project's lore,
**So that** the knowledge graph and consistency checks are not polluted by retired world elements.

## Acceptance Criteria

- [ ] Given I am viewing a canon entry, when I click "Delete Entry," then a confirmation dialog appears listing all entries that reference this entry by inline link (US-022), warning that those links will become broken.
- [ ] Given I confirm deletion, when the entry is deleted, then it is soft-deleted (recoverable for 30 days via US-025 versioning) and removed from the Canon Editor list and Knowledge Graph immediately.
- [ ] Given the entry was referenced by other entries via inline links, when deletion completes, then those references are flagged as "broken link" warnings visible in the referencing entries.
- [ ] Given the entry had status "Canon," when deletion is confirmed, then a consistency re-check is automatically queued.

## Notes

Depends on US-016. Hard deletion after 30 days. The broken-link warning list in the confirmation dialog is critical for P-003 managing a multi-writer team. Related: US-022 (inline linking), US-025 (versioning/recovery).
