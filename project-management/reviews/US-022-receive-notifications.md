# Review: Receive Notifications (Kinds, Filters, Aggregation)

- **Story**: `project-management/user-stories/US-022-receive-notifications.md`
- **Status**: Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The notification pipeline is implemented in the Elixir backend. Generation covers multiple event kinds: chat mentions/watchers/thread replies with mute gating and 5-minute chat-digest coalescing (`backend/lib/noizu_prompt_lingua/domains/notifications/dispatch.ex:65`), and ticket-assigned notifications (`dispatch.ex:248`). Delivery/aggregation uses a `dedup_key` partial-unique-index upsert so repeat events merge instead of spamming (`notifications.ex:68`). Retrieval supports polling via PubSub long-poll (rate-limited), kind filtering (`maybe_kinds`), and read-state ops (`mark_read`/`mark_seen`/`ack`/`clear`) with ids or `:all` (`notifications.ex:308-320`). The Python MCP read side (`src/npl_mcp/chat/chat.py:318,363`) lets agents list (with `unread_only`) and mark-read. Gaps versus the story: there are no per-persona *notification webhook* integrations (webhook events exist, but not persona-scoped notification webhooks), and "delete" semantics are expressed as `clear`/`ack` rather than literal deletion. Confidence: high.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Notifications generated for relevant events (chat, tickets) | Met | `dispatch.ex:65` (chat) and `dispatch.ex:248` (ticket_assigned) |
| Dedup/aggregation prevents floods | Met | `dedup_key` upsert w/ partial unique index (`notifications.ex:68`) |
| Recipients can filter by kind | Met | `maybe_kinds` filtering in `notifications.ex` |
| Recipients can clear/read one or all notifications | Met | `notifications.ex:308-320` (ids or `:all`); `chat.py:363` |
| Per-persona webhook/external delivery | Not Met | no per-persona notification webhook delivery found (event webhooks exist, but not wired to notifications) |

## Gaps / Risks

- Digest coalescing window (5 min) is hard-coded; per-user digest preferences are not configurable.
- Python MCP side remains read-only; anything that should notify agents from Python-resident events needs an Elixir-side or direct-DB write path.

## BDD Scenario

```gherkin
Feature: Receive notifications across kinds
  Scenario: Agent receives, filters, and clears notifications
    Given an agent subscribed to a room and assigned a ticket
    When several chat messages and a ticket assignment occur
    Then distinct notifications are created (mentions immediate, digest coalesced)
    When the agent lists notifications filtered by kind
    Then only the matching kinds are returned
    When it calls clear with :all
    Then its notification list is empty
```
