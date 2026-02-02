# User Story: Create Todo from Chat

**ID**: US-028
**Persona**: P-003 (Vibe Coder)
**Priority**: Low
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a **vibe coder**,
I want to **create a quick todo item in a chat room**,
So that **action items from discussions are captured without leaving the conversation**.

## Acceptance Criteria

- [ ] **Required fields**: Can create todo with `room_id`, `persona` (creator), and `description`
- [ ] **Optional assignment**: Can optionally assign to a different persona using `assigned_to` parameter
- [ ] **Chat event creation**: Todo appears as a `todo_created` event in chat feed with event_id
- [ ] **Event details**: Event includes `todo_id`, `description`, `creator` persona, `assigned_to` persona (if set), and timestamp
- [ ] **Creator tracking**: Creator persona is recorded and immutable after creation
- [ ] **Response format**: Returns `todo_id` for tracking and future operations
- [ ] **Initial state**: Todo created with `status: "pending"` by default
- [ ] **State transitions**: Todos support status changes: `pending` → `completed` (via future `complete_todo` command)
- [ ] **Empty validation**: Empty or whitespace-only descriptions rejected with clear error
- [ ] **Room validation**: Returns error if `room_id` is invalid or does not exist
- [ ] **Verification**: Created todo visible in chat feed via `get_chat_feed` for the specified room

## Notes

### Todos vs. Tasks Distinction

**Chat Todos** (this feature):
- Lightweight, ephemeral action items captured during discussions
- Live within a specific chat room context
- Simple lifecycle: `pending` → `completed`
- No priority levels, deadlines, or acceptance criteria fields
- Ideal for: "Review this", "Check the docs", "Ask Alice about X"
- Created with `create_todo` (Chat Tools)

**Task Queue Tasks** (US-016):
- Formal work items with full project management features
- Live in dedicated task queues, tracked across project
- Complex lifecycle: `pending` → `in_progress` → `blocked` → `review` → `done`
- Support priority, deadlines, acceptance criteria, task messages
- Ideal for: Feature development, bug fixes, deliverables
- Created with `create_task` (Task Queue Tools)

**Promotion Path**: If a chat todo grows in scope, it can be manually promoted to a full task queue task by creating a task with similar details.

## Dependencies

- US-007: Chat room must exist before todos can be created
- Valid `room_id` required

## Open Questions

- ~~How do todos differ from tasks?~~ **RESOLVED**: See Notes section for clear distinction
- ~~Should todos sync to task queue?~~ **RESOLVED**: No automatic sync; manual promotion if todo grows in scope
- Should `complete_todo` command also post a completion event to chat feed?
- Should there be a `list_todos` command to view all pending todos in a room?
- Should completed todos remain visible in chat feed or be filtered by default?

## Related Commands

- `create_todo` (Chat Tools) - This command, creates a todo in a chat room
- `get_chat_feed` (Chat Tools) - View todos after creation as part of chat events
- `send_message` (Chat Tools) - Related communication in same room
- `create_task` (Task Queue Tools) - For formal tasks (compare/contrast with todos)

## Example Request

```json
{
  "room_id": 9,
  "persona": "bob",
  "description": "Review the design spec",
  "assigned_to": "alice"
}
```

## Example Response

```json
{
  "status": "ok",
  "result": {
    "todo_id": 33
  }
}
```

## Example Chat Feed Event

After creating a todo, the chat feed will include an event like:

```json
{
  "event_id": 103,
  "type": "todo_created",
  "timestamp": "2026-02-02T15:30:00Z",
  "todo_id": 33,
  "creator": "bob",
  "assigned_to": "alice",
  "description": "Review the design spec",
  "status": "pending"
}
```
