---
id: US-037
title: "Playbook Cloning"
slug: "playbook-cloning"
personas: [P-007, P-003, P-001]
epic: "Playbook System"
priority: "should-have"
complexity: "S"
tags: [playbook, cloning, reuse, productivity]
---

# US-037: Playbook Cloning

## User Story

**As a** Playbook Author/Automation Engineer (P-007),
**I want to** clone an existing playbook into a new independent copy,
**So that** I can use a proven playbook as a starting point for a new variant without affecting the original.

## Acceptance Criteria

- [ ] Given I view any playbook in the library, when I select "Clone", then a new playbook is created with a name like "Copy of {original name}", version 1.0, and my identity as the author
- [ ] Given a cloned playbook is created, when I view it, then it contains an exact copy of the source playbook's latest approved version, with a reference link to the source playbook in its metadata
- [ ] Given I edit the cloned playbook, when I save changes, then the original playbook is entirely unaffected
- [ ] Given I clone a playbook, when the clone is created, then it starts in "Draft" state and requires its own approval cycle before being activated

## Notes

Cloning is a lightweight productivity feature. It differs from marketplace install (US-034) in that cloning is always within the same workspace. The source reference in metadata helps with lineage tracking.
