---
id: US-006
title: "Create a ticket with a custom type and custom fields"
slug: "create-ticket-with-custom-type-and-fields"
personas: [P-003]
epic: "Tickets & Boards"
priority: "must-have"
complexity: "M"
tags: [tickets, custom-types, custom-fields]
---

# US-006: Create a ticket with a custom type and custom fields

## User Story

**As a** Delivery Lead (P-003),
**I want to** create a ticket using a custom type such as "user_story" and populate custom fields defined for that type,
**So that** I can track product-management artifacts like stories and PRDs as first-class tickets on the same board instead of bolting on a separate schema.

## Acceptance Criteria

- [ ] Given a project where "user_story" has been registered as a ticket type with custom fields "persona" and "acceptance_criteria", when Priya creates a ticket of type "user_story" and supplies values for both custom fields, then the ticket is persisted with type="user_story" and both custom field values are retrievable via a ticket fetch.
- [ ] Given a ticket creation call that references a custom field not defined for that ticket type, when submitted, then the call is rejected with a validation error naming the unknown field.
- [ ] Given a ticket creation call missing a custom field marked required for that type, when submitted, then the call is rejected and no ticket is created.
- [ ] Given a successfully created "user_story" ticket, when it is listed on the project's default board, then it appears alongside standard-type tickets in the same queue, distinguishable by its type label.

## Notes

"user_story" and "prd" are ticket *types*, not separate schemas. See US-012 for org-scoped custom type definition and US-011 for project-scoped custom field definition; this story assumes those already exist and exercises ticket creation against them.
