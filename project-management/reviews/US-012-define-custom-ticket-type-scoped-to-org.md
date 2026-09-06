# Review: Define a custom ticket type scoped to an org

- **Story**: `project-management/user-stories/US-012-define-custom-ticket-type-scoped-to-org.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The definition machinery is solid: `Ticket.Definition.Create` (`backend/lib/noizu_prompt_lingua/domains/tickets/tools/definition_create.ex`) defines a type at global/org/project scope with a field set (`{slug, required}` entries) and a status workflow; `TicketTypeDefinition` + `TicketTypeField` schemas back it; and `Definitions.resolve_type/3` / `effective_types/2` apply the documented project > org > global precedence with `disabled` tombstones (`backend/lib/noizu_prompt_lingua/domains/tickets/definitions.ex:27-29,150-161`). Resolution precedence for same-named fields across scopes (AC3) is real and rank-ordered. However, deletion (`Ticket.Definition.Delete`) is an immediate soft-delete with no orphaned-ticket count and no confirmation, and the owner-scoped authorization requirement is unmet: `DefinitionCreate` declares no `authz` metadata, and the `ToolGuard` (`backend/lib/noizu_prompt_lingua/mcp/tool_guard.ex:59-67`) skips role checks entirely for tools without authz meta (OAuth PDP only) — so any authenticated member with access to the toolset can define org-wide types.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Org owner defines "spike" type with field set; every project can use it immediately | Met | `definition_create.ex` (org-scoped create with `fields` array); `resolve_type` per (org, project) falls through to org-level definitions (`definitions.ex:150-157`) |
| Deleting a type in use: shown orphaned-ticket count, explicit confirmation required | Not Met | `definition_delete.ex:28-34` deletes on slug match with no usage count and no confirmation step |
| Same-named project-level field wins over org-level, per documented resolution order | Met | Rank ordering project(3) > org(2) > global(1) with `pick_winner` and tombstone suppression (`definitions.ex:23-29,78-88`); precedence documented in module doc (`definitions.ex:8-11`) |
| Non-owner attempt rejected with authorization error | Not Met | `DefinitionCreate` has no `authz` meta; `tool_guard.ex:60-66` runs OAuth-PDP-only for such tools — no owner/admin role ladder check is applied |

## Gaps / Risks

- The AC4 gap is the sharpest: the role ladder and deny-closed machinery exist (`tool_guard.ex:14-18`) but are simply not attached to the definition tools, so org-level governance ("this action is owner-scoped") is unenforced.
- Destructive delete of an in-use type is unconfirmed — mirrored gap in the sibling story US-011; both ACs were written to force a count-and-confirm UX that no tool implements.
- Types are soft-deleted (`definitions.ex:131`), which mitigates data loss but means "deleted" types may still resolve or not depending on tombstone visibility — behavior around in-flight tickets after delete is unspecified.
- Ticket creation does not validate `ticket_type` against defined types (`ticket_create.ex:56-57` defaults any unknown string to a valid ticket), so "every project can create tickets of type spike" is trivially true — but so is any misspelled type, weakening the governance value of registered types.

## BDD Scenario

```gherkin
Feature: Org-scoped custom ticket types

  Scenario: Org owner registers a "spike" type
    When Marcus calls Ticket.Definition.Create with org scope, slug "spike", and a field set
    Then the type is created at org level with its status workflow
    And every project in the org resolves "spike" via resolve_type

  Scenario: Project field shadows an org field of the same slug
    Given org-level field "risk" and project-level field "risk"
    When Definitions.resolve_field runs for that project
    Then the project-level definition wins per the documented rank order

  Scenario: A non-owner member defines an org type
    When a plain member calls Ticket.Definition.Create for the org
    Then the call succeeds (no role gate is attached to the tool)

  Scenario: Deleting a type in use by 30 tickets
    When Marcus calls Ticket.Definition.Delete with slug "spike"
    Then the type is soft-deleted immediately with no orphan count or confirmation
```
