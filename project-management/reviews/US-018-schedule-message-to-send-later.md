# Review: Schedule a message to send later

- **Story**: `project-management/user-stories/US-018-schedule-message-to-send-later.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No message-scheduling functionality exists. `Chat.SendMessage` (`src/npl_mcp/launcher.py:1249-1256`) posts immediately to `npl_chat_messages` via `message_create` (`src/npl_mcp/chat/chat.py:95-109`); there is no send-at parameter, no pending/scheduled state on the message model (DDL in `liquibase/changelogs/changeset-013.chat-tables.yaml` has no such columns), no durable scheduler or worker process anywhere in `src/npl_mcp/` (no APScheduler/celery/cron-style loop; grep for "schedul" across `src/` hits nothing in the chat path), and no edit/cancel surface for pending messages. Notifications — the other half of AC 2 — are also inert: `npl_chat_notifications` is read by `Chat.Notifications` (`launcher.py:1363-1378`) but nothing in `src/` ever inserts into it. Confidence: high — full chat module, tool registrations, and schema changelogs reviewed.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Scheduled message stored pending; absent from timeline until send time | Not Met | `message_create` inserts with immediate visibility; no pending state or send-at column; no evidence found |
| Scheduler delivers at send time with normal notifications | Not Met | no scheduler/worker process exists in `src/`; nothing writes `npl_chat_notifications` |
| Pending messages viewable, editable (content/time), cancellable before firing | Not Met | no scheduled-message listing, update, or cancel tools; no evidence found |
| Past send-at time rejected with validation error | Not Met | no scheduling parameter exists to validate |

## Gaps / Risks

- Story itself notes this requires "a durable scheduler/worker process, not just a timestamp flag" — neither exists; this is greenfield work (worker process, pending-state schema, cancellation API).
- AC 2's notification behavior is double-blocked: even live messages generate no notifications today (no producer writes `npl_chat_notifications`), so US-021-style notification flow is a prerequisite.
- No chat tests exist; scheduling would need infra-level test support (clock control).

## BDD Scenario

```gherkin
Feature: Schedule a message for future delivery

  Scenario: Operator queues a reminder for tomorrow
    Given Jordan composes a message in a room
    When he attempts to set a future send-at time
    Then Chat.SendMessage offers no such parameter
    And the message can only be sent immediately

  Scenario: Send time arrives
    Given no scheduler process runs in the codebase
    When the wall clock passes any hypothetical send time
    Then nothing delivers pending messages or fires notifications

  Scenario: Operator schedules into the past
    When a send-at timestamp in the past is attempted
    Then the request cannot even be expressed
    And no validation path exists to reject it
```
