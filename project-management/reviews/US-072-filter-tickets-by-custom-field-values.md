# Review: Filter Tickets by Custom Field Values

- **Story**: `project-management/user-stories/US-072-filter-tickets-by-custom-field-values.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Custom-field *storage* and *definition* exist on the Elixir backend: `Schema.Ticket.custom_fields` is a JSONB map (`backend/lib/noizu_prompt_lingua/schema/ticket.ex:19`), and `ticket_field_definitions` (with `field_type` in ~w(text select multi_select number …) and an `options` map) plus full definition CRUD exist (`schema/ticket_field_definition.ex:12-13`, `domains/tickets/definitions.ex:34-86`). However, **no ticket query filters by custom-field values**. `Ticket.List` (`domains/tickets/tools/ticket_list.ex:21-40`) accepts only built-in filters (status, type, priority, assignee, queue, parent, tag, updated range); `PMBridge.list/1` (`domains/tickets/pm_bridge.ex:61-131`) applies only list-valued built-in facets and a tag filter client-side — no custom-field facet anywhere. The VFS tickets projection reads/writes individual `fields/{slug}.json` but offers no search. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Filter by custom field name + value returns only matching tickets | Not Met | `ticket_list.ex:21-40` input fields contain no custom-field filter; no evidence found in `pm_bridge.ex` |
| Multiple custom-field filters AND built-in filter combine with AND semantics | Not Met | no custom-field filtering exists to combine; built-in filters AND correctly (`pm_bridge.ex:122-131`), but the criterion is unimplementable as specified |
| Select/enum filter with value outside allowed options returns validation error | Not Met | `ticket_field_definition.ex` stores `options`, but no filter path consults them; no evidence found |
| Partial-text (substring) search on free-text custom fields | Not Met | no evidence found |

## Gaps / Risks

- Filtering JSONB maps from TRP v1's list API would require either a JSONB containment query server-side or broader client-side fetch; `pm_bridge.ex:45-58` documents that the TRP contract is scalar-only, which constrains implementation.
- `ticket_create`/`ticket_update` merge `custom_fields` without validating values against the field definition's `options` — so even the prerequisite (validated enum custom fields) is absent.

## BDD Scenario

```gherkin
Feature: Filter tickets by custom field values
  Story is NOT implemented — custom fields are stored and definable but not queryable.

  Scenario: Delivery lead builds a sprint-planning view
    Given tickets exist with custom_fields %{"component" => "billing", "risk" => "high"}
    When the agent calls Ticket.List with organization=<org> and status="open"
    Then results are filtered by status only
    And there is no argument that can express Component=billing or Risk=high
    And the caller must fetch pages of tickets and filter the JSON client-side
```
