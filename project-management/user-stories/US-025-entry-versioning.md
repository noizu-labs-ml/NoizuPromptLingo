---
id: US-025
title: "Entry Versioning and History"
slug: "entry-versioning"
personas: [P-001, P-004, P-007]
epic: "Canon Editor — Core"
priority: "should-have"
complexity: "L"
tags: [canon, versioning, history, recovery, audit]
---

# US-025: Entry Versioning and History

## User Story

**As an** epic novelist (P-001),
**I want to** view the full edit history of any canon entry and restore a previous version,
**So that** I can confidently experiment with rewrites knowing I can always recover an earlier draft.

## Acceptance Criteria

- [ ] Given I am viewing a canon entry, when I click "Version History," then a sidebar panel lists all saved versions with timestamp, author, and a one-line summary of what changed (field names that were modified).
- [ ] Given I select a previous version from the history list, when I click "Preview," then I see a side-by-side diff of the selected version versus the current version with field-level highlighting.
- [ ] Given I am previewing a previous version, when I click "Restore this version," then the entry content is reverted and a new version record is created capturing the restore action (not overwriting history).
- [ ] Given the AI agent (P-007) modifies an entry via API, when the change is saved, then the version history records the author as "AI Agent ({agent name})" distinguishing it from human edits.

## Notes

Depends on US-016 and US-017. Versioning must cover all field types including rich text and relationship fields. Version records older than 90 days may be pruned on free-tier accounts. Related: US-018 (delete — soft-delete uses the same versioning store), US-024 (status changes are versioned).
