---
id: US-014
title: "Duplicate a Universe"
slug: "duplicate-universe"
personas: [P-003, P-001]
epic: "Universe Management"
priority: "could-have"
complexity: "M"
tags: [universe, duplicate, copy, fork]
---

# US-014: Duplicate a Universe

## User Story

**As a** narrative designer (P-003),
**I want to** duplicate an existing universe to create a sandbox or alternate-continuity fork,
**So that** my team can experiment with major lore changes without risking the canonical project.

## Acceptance Criteria

- [ ] Given I am on Universe Settings, when I click "Duplicate Universe," then I am prompted for a new name (pre-filled as "{original name} — Copy") before duplication begins.
- [ ] Given I confirm the duplicate action, when the process completes, then all entries, relationships, tags, and settings are copied into the new universe; generated content is excluded by default.
- [ ] Given the duplication is running, when it takes longer than 3 seconds, then a progress indicator is shown and I am not blocked from using the rest of the app.
- [ ] Given the duplication completes, when I navigate to the new universe, then it is fully independent — changes to the copy do not affect the original.

## Notes

Depends on US-009, US-010. Generated content exclusion avoids duplicating AI-cost artifacts. Duplication counts against the user's universe plan limit. Related: US-013 (delete).
