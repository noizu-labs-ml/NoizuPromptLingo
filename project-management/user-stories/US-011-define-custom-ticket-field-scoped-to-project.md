---
id: US-011
title: "Define a custom ticket field scoped to a project"
slug: "define-custom-ticket-field-scoped-to-project"
personas: [P-003]
epic: "Tickets & Boards"
priority: "should-have"
complexity: "M"
tags: [tickets, custom-fields, project-scoping]
---

# US-011: Define a custom ticket field scoped to a project

## User Story

**As a** Delivery Lead (P-003),
**I want to** define a new custom field scoped to my project, with a name, type, and required flag,
**So that** tickets on my board can capture the metadata my team actually needs without waiting on a platform-wide schema change.

## Acceptance Criteria

- [ ] Given a project with no custom fields yet, when Priya defines a new field "story_points" of type "number" scoped to that project, then it becomes available as an optional field on ticket creation/edit forms for that project only.
- [ ] Given a custom field defined as "required" for a specific ticket type, when a ticket of that type is created without it, then creation is rejected per US-006's validation behavior.
- [ ] Given a custom field defined in Project A, when a ticket is created in Project B, then that field is not offered or accepted — scoping is enforced per-project.
- [ ] Given an existing custom field with tickets already using it, when Priya attempts to delete the field, then she is shown the count of tickets that reference it and must explicitly confirm before deletion proceeds.

## Notes

Project-scoped counterpart to US-012's org-scoped custom ticket *types*; this story is about fields, not types. US-006 depends on fields like these already existing.
