---
id: US-017
title: "Edit a Canon Entry"
slug: "edit-canon-entry"
personas: [P-001, P-004, P-008]
epic: "Canon Editor — Core"
priority: "must-have"
complexity: "M"
tags: [canon, entry, edit, core]
---

# US-017: Edit a Canon Entry

## User Story

**As a** fiction podcaster (P-004),
**I want to** edit any field of an existing canon entry,
**So that** I can correct errors, add new lore, and keep my records consistent with the latest episode.

## Acceptance Criteria

- [ ] Given I am viewing a canon entry, when I click "Edit," then all fields become editable in-place without navigating to a separate edit page.
- [ ] Given I am editing an entry, when I make changes but have not saved, then a visual indicator (e.g., "Unsaved changes" badge) is displayed and the browser warns me before navigating away.
- [ ] Given I save changes to an entry, when the save completes, then a new version is recorded in the entry's version history (US-025) and the "Last edited" timestamp updates.
- [ ] Given an entry has status "Canon" (US-023), when I save an edit, then I am not blocked, but a toast notification reminds me "This entry is marked Canon — changes will affect consistency checks."

## Notes

Depends on US-016 (create entry). In-place editing reduces context-switching for P-001 who edits frequently. Versioning behavior detailed in US-025. Related: US-021 (rich text editing), US-022 (inline linking).
