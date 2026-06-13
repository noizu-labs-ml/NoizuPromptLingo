---
id: US-019
title: "Import Existing Materials into a Universe"
slug: "import-existing-materials"
personas: [P-001, P-008]
epic: "Universe Management"
priority: "should-have"
complexity: "XL"
tags: [universe, import, migration, onboarding]
---

# US-019: Import Existing Materials into a Universe

## User Story

**As a** webcomic creator (P-008),
**I want to** import my existing lore documents (Markdown, plain text, or JSON) into a universe,
**So that** I can migrate my 500-page script archive without manually re-entering every character and location.

## Acceptance Criteria

- [ ] Given I am in Universe Settings under "Import," when I upload a Markdown or plain text file (max 10 MB), then the system parses the document and presents a review UI showing detected entities (proposed entry name, type, and source excerpt) before committing.
- [ ] Given I am in the import review UI, when I change a detected entity type or name, then my correction is applied before the import is committed.
- [ ] Given I confirm the import, when it completes, then all imported entries are created with status "Draft" (not "Canon") and tagged with an "imported" tag for easy filtering.
- [ ] Given an import fails mid-process, when the error occurs, then no partial entries are committed — the operation is atomic.

## Notes

JSON import format is documented in the export spec (referenced in the API for P-007). P-008's use case drives the plain-text parser requirement. Related: US-016 (create entry), US-007 (AI agent import via API).
