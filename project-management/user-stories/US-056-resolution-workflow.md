---
id: US-056
title: "Consistency Issue Resolution Workflow"
slug: "resolution-workflow"
personas: [P-001, P-002, P-003]
epic: "Consistency Engine"
priority: "must-have"
complexity: "L"
tags: [consistency, resolution, workflow, merge, canon]
---

# US-056: Consistency Issue Resolution Workflow

## User Story

**As a** narrative designer (P-003),
**I want to** resolve consistency issues by choosing to pick one side, merge conflicting entries, or mark a conflict as intentional,
**So that** I can systematically clear my issue backlog with the right fix for each situation rather than deleting work indiscriminately.

## Acceptance Criteria

- [ ] Given a consistency issue is open, when I open its detail view, then I am presented with three resolution actions: "Pick Side" (choose which entry's data is canonical), "Merge" (combine fields from both entries into one), and "Mark Intentional" (suppress the issue and record a rationale).
- [ ] Given I choose "Pick Side" on a timeline contradiction, when I confirm my selection, then the losing entry's conflicting field is flagged with a strikethrough annotation, the issue is marked resolved, and an audit log entry is created recording who picked which side and when.
- [ ] Given I choose "Merge" on a duplicate name issue, when I complete the merge wizard, then one entry absorbs the other's fields (with conflict resolution per field), all references to the absorbed entry are redirected to the surviving entry, and the absorbed entry is archived rather than deleted.
- [ ] Given I choose "Mark Intentional" and supply a rationale, when I confirm, then the issue is suppressed from all active dashboards, the rationale is stored on the issue, and the issue remains visible in the audit log with a "suppressed" status.

## Notes

"Mark Intentional" is the escape hatch for deliberate retcons and unreliable-narrator devices. Depends on US-055 (severity levels), US-057 (consistency dashboard), US-059 (audit log). Related: US-053 (duplicate names), US-054 (orphaned references).
