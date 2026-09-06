# Review: Create a ticket with a custom type and custom fields

- **Story**: `project-management/user-stories/US-006-create-ticket-with-custom-type-and-fields.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Ticket creation with a custom type and custom fields exists on two surfaces. MCP: `Ticket.Create` (`backend/lib/noizu_prompt_lingua/domains/tickets/tools/ticket_create.ex:17-40`) accepts `ticket_type` (schema advertises `user_story` as a valid slug) and a `custom_fields` object, passing both through `PMBridge` (`backend/lib/noizu_prompt_lingua/domains/tickets/pm_bridge.ex:225-236`) to the remote TRP items API. HTTP: `POST /api/v1/organizations/:org_id/tickets` (`backend/lib/noizu_prompt_lingua_web/controllers/ticket_controller.ex:42-79`) does the same. Type and field definitions live in `Domains.Tickets.Definitions` (`backend/lib/noizu_prompt_lingua/domains/tickets/definitions.ex`, org-scoped field/type defs with required/position on type-field associations). `Ticket.Get` returns `custom_fields` plus the resolved `type_fields` for the ticket's type (`ticket_get.ex:53-54`), so supplied values are retrievable. However, no custom-field validation is implemented anywhere in this repo: nothing rejects an unknown field name or enforces a required field — the NPL side forwards `custom_fields` verbatim, and whether the remote TRP service validates is not verifiable here. Listing "alongside standard-type tickets" works via `Ticket.List` (`ticket_list.ex`) filtered by `queue_id`/`ticket_type`, but there is no board fetch that renders tickets per stage column (`Ticket.Queue.Feed` is a stub: `queue_feed.ex:18-23`).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Ticket created with type="user_story" and both custom field values retrievable via fetch | Met | `ticket_create.ex:17-38,53-60`; `pm_bridge.ex:225-236` (item_type alias + custom_fields passthrough); `ticket_get.ex:53-54` (custom_fields + type_fields in response) |
| Unknown custom field rejected with validation error naming the field | Not Met | No validation in NPL: `pm_bridge.ex` forwards attrs verbatim; no evidence found of field-name checking against definitions on the create path |
| Missing required custom field rejected and no ticket created | Not Met | `Definitions` supports `required` on type-field associations (`definitions.ex:186-206`), but nothing consults it during ticket create; no evidence found |
| Created user_story ticket appears on the project's default board alongside standard types, distinguishable by type label | Partially Met | `ticket_list.ex:23` filters by queue; `Ticket.List` returns `ticket_type` per row; but no board/column fetch exists (`queue_feed.ex:18-23` stub returns "Activity feed not yet implemented") |

## Gaps / Risks

- No client-side (or verifiable server-side, within this repo) validation of `custom_fields` against the type's field definitions — unknown fields are silently stored, required fields silently omitted.
- Type-field `required` flags are definable but never enforced.
- "Board" rendering path is missing in the backend; the story's board-fetch criterion has no implementation to render into.
- Error surface for TRP validation failures is an opaque `"Failed: ..."` inspect dump (`ticket_create.ex:77-78`).

## BDD Scenario

```gherkin
Feature: Create tickets with custom types and custom fields

  Scenario: Create a user_story ticket with custom fields
    Given the org has a "user_story" type definition with fields "persona" and "acceptance_criteria"
    When an agent calls Ticket.Create with ticket_type="user_story",
      custom_fields={"persona": "P-003", "acceptance_criteria": "..."},
      organization and a project
    Then the ticket is persisted with ticket_type="user_story"
    And Ticket.Get on the new ticket returns custom_fields containing both values
    And the resolved type_fields list describes "persona" and "acceptance_criteria"

  Scenario: List tickets on a board queue
    When Ticket.List is called filtered by queue_id
    Then the user_story ticket appears alongside task/bug tickets
    And each row carries its ticket_type label
```
