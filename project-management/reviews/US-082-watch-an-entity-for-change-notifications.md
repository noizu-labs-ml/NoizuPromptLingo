# Review: Watch an Entity for Change Notifications

- **Story**: `project-management/user-stories/US-082-watch-an-entity-for-change-notifications.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Implemented on the Elixir backend (`/Users/keithbrings/Work/Space/Noizu/projects/NoizuPromptLingo/backend`). The generic primitive exists twice: `Ticket.Watch` (`backend/lib/noizu_prompt_lingua/domains/tickets/tools/ticket_watch.ex:1-35`, watch/unwatch for tickets) and the entity-generic `Notifications.Watch` (`backend/lib/noizu_prompt_lingua/domains/notifications/tools/watch.ex:1-80`, entity_type includes "ticket" and "artifact"), both backed by `Services.Watch` (`backend/lib/noizu_prompt_lingua/services/watch.ex`) with per-watch substring/regex filters. Change notification flows through `Notifications.dispatch.watch_update/3` (`backend/lib/noizu_prompt_lingua/domains/notifications/dispatch.ex:301-342`), which loads the entity via `@entity_schemas` (ticket AND artifact included, `dispatch.ex:35-44`), filters out the actor, applies per-watch filters, and notifies each watcher. Unwatch deletes the row and is honored live. Gaps: no "watched-items list" (list MY watches) exists — only per-entity watcher enumeration; and while artifact is a watchable type, no artifact-change code path calling `watch_update("artifact", ...)` was found. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Watch action adds entity to user's watched-items list | Partially Met | `Watch.watch/4` upserts the watch row (`services/watch.ex:14-27`); but no function or tool lists a persona's watches — only `watchers/2`/`watchers_with_filter/2` enumerate watchers of an entity (`services/watch.ex:36-48`) |
| State change → notification for each watcher | Met | `dispatch.watch_update/3` (`dispatch.ex:301-342`) notifies all filtered watchers except the actor; wired into ticket flows (`mcp/vfs/tickets.ex:1199-1212`); Phoenix.PubSub wake broadcast alongside (`dispatch.ex` presence/notify paths) |
| Unwatch → no further notifications | Met | `Watch.unwatch/3` deletes the row (`services/watch.ex:29-34`); `watch_update` queries watchers live, so deleted watches receive nothing; tool surfaces not-found cleanly (`tools/watch.ex:56-66`) |
| Generic primitive: ticket and artifact both watchable independently by same user | Partially Met | `Notifications.Watch` accepts entity_type ticket/artifact and `@entity_schemas` maps both (`dispatch.ex:35-44`); but no artifact-change call site invokes `watch_update("artifact", ...)` — artifact watchers would never be notified in practice |

## Gaps / Risks

- Watchers of artifacts are registered but never fired: without an artifact-update hook calling `watch_update/3`, criterion 4 works at the storage layer only.
- No "list my watches" surface — users cannot see or manage what they watch; unwatch requires remembering entity_type + entity_id.
- `Watch.watch/4` does not verify the entity exists or that the persona can access it (no authz/404 check in `tools/watch.ex`), so watches can be pinned to nonexistent or foreign entities; notifications later resolve org from the entity or fall back to change attrs (`dispatch.ex:307-309`).

## BDD Scenario

```gherkin
Feature: Watch an entity for change notifications
  Scenario: Operator watches a ticket
    When the operator calls Notifications.Watch with persona, entity_type "ticket", entity_id
    Then the watch row is stored (idempotent upsert, optional filter)
    And when the ticket's status changes, watch_update notifies the operator (excluding the actor) with kind "watch_update"
  Scenario: Same user watches a ticket and an artifact independently
    When the user watches both entity types
    Then both rows coexist keyed by (entity_type, entity_id, persona)
    But artifact changes fire no notification today — no watch_update("artifact") call site exists (gap)
  Scenario: User unwatches
    When the user issues Unwatch for the entity
    Then the watch row is deleted and subsequent changes produce no notification for them
  Scenario: Review watched items
    When the user asks for their watched-items list
    Then no listing function or tool exists today (gap)
```
