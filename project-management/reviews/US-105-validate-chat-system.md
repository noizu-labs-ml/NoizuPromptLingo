# Review: Validate Chat System Implementation

- **Story**: `project-management/user-stories/US-105-validate-chat-system.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The chat system is broader than the story's 8 tools: 16 `Chat.*` MCP tools are registered in `src/npl_mcp/launcher.py:1190-1380`, backed by `src/npl_mcp/chat/chat.py` — rooms (`room_create` :28, `room_get` :42, `room_list` :9), messages (`message_create` :95, `message_list` :62 with pagination), members (`room_add_member` :150, `room_list_members` :177), events (`event_create` :201, `event_list` :232), reactions (`react_to_event` :277), todos (`create_todo` :288), artifact sharing (`share_artifact` :303), and notifications (`notification_list` :318, `notification_mark_read` :363). Web API routes exist for chat rooms/messages (`src/npl_mcp/api/router.py:2671+`), but the story's HTML pages (`GET /room/{id}`, `POST /room/{id}/message`) do not exist. Critically, the "event-driven" claim does not hold as described: `message_create` (:95-109) inserts into `npl_chat_messages` and nothing else — it creates no chat event and no notification rows, so message-driven notification propagation is not implemented. There is no chat test file at all in `tests/` (no `test_chat*.py`), so the 78% coverage claim is unverifiable. Permissions are limited to membership lists; no access-control checks gate reads/writes.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| All 8 chat tools functional, coverage verified at 78%+ | Partially Met | All 8 exist and more (`launcher.py:1190-1380`); zero chat tests in `tests/`, coverage claim unverifiable |
| Event-driven architecture (message creation triggers notifications) | Not Met | `chat.py:95-109` `message_create` inserts the message row only; no event/trigger/notification side-effects |
| Notification system working (chat_events propagate to notifications) | Partially Met | `notification_list`/`notification_mark_read` (`chat.py:318-380`) read/mark `npl_chat_notifications`, and `react_to_event` writes reaction events — but no producer links message creation to notification rows |
| Web routes for chat rooms functional (GET /room/{id}, POST /room/{id}/message) | Partially Met | JSON API routes exist (`router.py:2671+`); the named HTML routes do not (`web/` dir is empty) |
| Chat room permissions and member lists validated | Partially Met | `room_add_member`/`room_list_members` (`chat.py:150-199`) maintain membership; no permission enforcement found on any chat operation |
| Message threading and reactions working correctly | Partially Met | Reactions implemented (`chat.py:277-286`); no threading model found (no parent_message_id) |
| Performance baseline established for chat operations | Not Met | No benchmark/baseline evidence found |

## Gaps / Risks

- No tests at all for the chat subsystem despite it being called "the primary collaboration interface".
- Notifications have consumers but no producers wired to chat activity — `Chat.Notifications` will only ever surface rows written by something else.
- No authorization: any caller can read/write any room regardless of membership.
- Story's counts and coverage figures (8 tools, 78%) are stale relative to the 16-tool implementation.

## BDD Scenario

```gherkin
Feature: Multi-agent chat collaboration

  Scenario: Create a room and exchange messages
    When an agent calls Chat.CreateRoom with a name
    Then the room is created and returned
    When Chat.SendMessage posts to the room
    Then the message is stored with author and timestamp
    And Chat.ListMessages returns it with pagination

  Scenario: React and extract a todo
    Given a message exists as a chat event
    When an agent calls Chat.React with an emoji
    Then the reaction is recorded on the event
    And Chat.CreateTodo can turn a message into a task

  Scenario: Manage membership
    When Chat.AddMember adds a persona to a room
    Then Chat.ListMembers includes that persona

  Scenario: Message triggers notification (NOT yet working)
    Given a user watches a room for new messages
    When another agent posts a message
    Then no notification row is created, because message_create has no notification side-effects
```
