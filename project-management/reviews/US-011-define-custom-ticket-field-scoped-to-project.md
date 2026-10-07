# Review: Define a custom ticket field scoped to a project

- **Story**: `project-management/user-stories/US-011-define-custom-ticket-field-scoped-to-project.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The backend implements project-scoped field definitions end to end at the definition layer: `Ticket.Field.Definition.Create` MCP tool resolves org/project scope via `Resolve.scope/2` (`backend/lib/noizu_prompt_lingua/domains/tickets/tools/field_definition_create.ex:44-58`), the `TicketFieldDefinition` schema models global/org/project scoping with `disabled` tombstones (`backend/lib/noizu_prompt_lingua/schema/ticket_field_definition.ex:14-35`), and `Definitions.resolve_field/3` / `effective_fields/2` apply project > org > global precedence (`backend/lib/noizu_prompt_lingua/domains/tickets/definitions.ex:27-29,78-88`). Fields attach to types with a `required` flag (`definitions.ex:186-210`). However, the `required` flag is stored and never enforced at ticket creation — no code path in `Tickets.create` or `Ticket.Create` consults type fields to reject a missing required value — and deletion (`Ticket.Field.Definition.Delete`) proceeds immediately with no usage count and no confirmation.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| New "story_points" number field scoped to project, available only for that project | Met | `field_definition_create.ex:44-58` (project requires org, scopes definition); `ticket_field_definition.ex:16-35` (scope columns); `definitions.ex:78-83` resolves per (org, project) |
| Required field for a ticket type: creation without it is rejected | Not Met | `required` is recorded on the type↔field join (`definitions.ex:200`), but no enforcement exists — `ticket_create.ex:45-58` passes `custom_fields` straight through; no validator references required type fields |
| Field defined in Project A not offered/accepted in Project B | Met | Scoping is per-project bucket with `filter_visible`/`resolve_field` restricted to the context's project (`definitions.ex:64-107`); cross-project leakage requires no path |
| Delete shows count of referencing tickets and requires explicit confirmation | Not Met | `field_definition_delete.ex:28-34` deletes immediately on slug match; no usage count query, no confirmation step |

## Gaps / Risks

- The required-field guarantee is cosmetic: data model supports it, runtime does not. Tickets of a type with required fields can be created empty, breaking US-006's assumed validation behavior downstream.
- Destructive deletion of a definition in use is a single unconfirmed call — the exact hazard AC4 was written to prevent.
- Scope resolution reads through the TRP shared-key plane (300s TTL cache, `definitions.ex:1-18`); a just-created project field may be invisible for up to the TTL, so "immediately available" is not strictly true.
- `get_field_in_scope` filters by exact `organization_id`/`project_id` equality on rows fetched through `list_fields`, which degrades to `[]` on TRP errors (`definitions.ex:64-76`) — deletes would then fail confusingly with "not found".

## BDD Scenario

```gherkin
Feature: Project-scoped custom ticket fields

  Scenario: Delivery lead defines story_points for her project
    Given project A has no custom fields
    When Priya calls Ticket.Field.Definition.Create with org, project A, slug "story_points", field_type "number"
    Then the field is created project-scoped
    And it resolves for project A but not for project B in the same org

  Scenario: Creating a ticket missing a required field
    Given "story_points" is attached to type "story" with required: true
    When a ticket of type "story" is created without story_points
    Then no error occurs (required is stored but never enforced)

  Scenario: Deleting a field in use
    Given 12 tickets carry values for "story_points"
    When Priya calls Ticket.Field.Definition.Delete with slug "story_points"
    Then the field is deleted immediately
    And she was never shown a referencing-ticket count or asked to confirm
```
