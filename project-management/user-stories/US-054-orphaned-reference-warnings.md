---
id: US-054
title: "Orphaned Reference Warnings"
slug: "orphaned-reference-warnings"
personas: [P-001, P-003, P-008]
epic: "Consistency Engine"
priority: "must-have"
complexity: "M"
tags: [consistency, references, links, orphans, validation]
---

# US-054: Orphaned Reference Warnings

## User Story

**As a** webcomic creator (P-008),
**I want to** be warned when an entry references another entry by name or ID that no longer exists or has been renamed,
**So that** I don't have broken internal links silently corrupting my 500-page canon's integrity.

## Acceptance Criteria

- [ ] Given an entry contains an inline reference (e.g., `[[character:Mira Voss]]`) to another entry, when that referenced entry is deleted or its slug changes, then the system creates an "error" severity orphaned reference issue listing the source entry, the broken reference text, and the last known target.
- [ ] Given an orphaned reference issue exists, when I view the issue detail, then I am offered options to: create a new entry with that name, relink to a renamed entry, or remove the reference from the source entry.
- [ ] Given I perform a batch rename of an entry, when the rename completes, then all references to the old name across the universe are automatically updated and no orphaned reference issues are created.
- [ ] Given a universe has 500+ entries, when a full orphan scan runs, then it completes within 60 seconds and reports a count of scanned references alongside any flagged issues.

## Notes

Depends on US-056 (resolution workflow), US-057 (consistency dashboard). Batch rename auto-update in criterion 3 is the preferred resolution path; requires reference indexing at write time.
