---
id: US-012
title: "Define a custom ticket type scoped to an org"
slug: "define-custom-ticket-type-scoped-to-org"
personas: [P-004]
epic: "Tickets & Boards"
priority: "could-have"
complexity: "M"
tags: [tickets, custom-types, org-scoping, governance]
---

# US-012: Define a custom ticket type scoped to an org

## User Story

**As the** Org Owner (P-004),
**I want to** define a new custom ticket type at the organization level,
**So that** every project in my org can consistently use domain-specific ticket types (e.g. "incident", "spike") without each project reinventing them separately.

## Acceptance Criteria

- [ ] Given an org with only the default ticket types, when Marcus defines a new org-scoped type "spike" with an associated field set, then every project within that org can immediately create tickets of type "spike".
- [ ] Given a custom type already in use by tickets in one project, when Marcus attempts to delete that type from the org, then he is shown the count of tickets that would be orphaned and must explicitly confirm before deletion proceeds.
- [ ] Given a project-level custom field defined under US-011 with the same name as an org-level field on the same ticket type, when a ticket is created, then the more specific project-level definition takes precedence, per a documented resolution order.
- [ ] Given a non-owner org member attempting to define a custom ticket type, when the call is made, then it is rejected with an authorization error — this action is owner-scoped.

## Notes

Org-scoped counterpart to US-011 (project-scoped fields); together they let "user_story"/"prd" (US-006, US-014) exist as first-class types without hardcoding them into the platform schema.
