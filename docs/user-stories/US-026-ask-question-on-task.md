# User Story: Ask Question on Task

**ID**: US-026
**Persona**: P-001 (AI Agent)
**Priority**: Medium
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As an **AI agent**,
I want to **post questions or messages on a task's activity feed**,
So that **I can request clarification without leaving the task context**.

## Acceptance Criteria

- [ ] Can add message to specific task's feed using `add_task_message`
- [ ] Message includes persona identifier (who posted it)
- [ ] Message timestamp recorded automatically
- [ ] Message appears in task activity feed via `get_task_feed`
- [ ] Can @mention specific personas for notifications
- [ ] Returns event ID for reference and threading
- [ ] Messages visible in task detail view (web UI or API)
- [ ] Messages are append-only (no editing after posting)
- [ ] Messages support basic markdown formatting

## Technical Details

### Message Format

Messages posted to a task's activity feed include:
- **task_id**: Target task identifier
- **persona**: Identifier of the posting agent or user
- **message**: Text content (supports markdown)
- **timestamp**: Automatically recorded when message is created
- **event_id**: Unique identifier returned for reference

### Threading

Currently, task feed messages are flat (no nested replies). For complex discussions requiring threading:
- Create a dedicated chat room (US-007: Create Chat Room)
- Link the chat room to the task via metadata
- Use task feed for simple questions and status updates only

### @Mentions and Notifications

When a message includes `@persona-id`:
- Mentioned persona receives notification (US-022: Receive Notifications)
- Notification links to the specific task and message
- Multiple personas can be mentioned in a single message

## Notes

- Keeps discussion tied to task context
- Alternative to separate chat room for simple questions
- Messages are immutable after posting (no editing)
- For extended discussions, prefer creating a linked chat room

## Dependencies

- Task must exist (US-016: Create Task)
- Notification system for @mentions (US-022: Receive Notifications)

## Open Questions

- Should there be a way to mark a message as "answered" or "resolved"?
- Should task owner receive automatic notifications for all messages?
- Should messages support attachments (screenshots, code snippets)?

## Related Clarifications

### Task Status and Blocking

Per US-018 (Update Task Status), posting a question does NOT automatically change task status to "blocked". The NPL MCP Task Queue system handles blocking differently:
- Task status remains "in_progress" when blocked
- Use the NPL MCP task management tools to track dependencies
- Use `add_task_message` to explain what the blocker is
- This allows agents to communicate blocking reasons while maintaining clear dependency tracking

**Note:** This story refers to the NPL MCP Task Queue system (managed via `add_task_message`, `get_task_feed`, etc.), which is distinct from Claude Code's built-in TaskCreate/TaskUpdate tools used for tracking Claude's own internal work.

## Related Commands

- `add_task_message` (Task Queue Tools) - Post a message to a task's activity feed
- `get_task_feed` (Task Queue Tools) - Retrieve all messages and events for a specific task
- `get_task_queue_feed` (Task Queue Tools) - View activity across all tasks in a queue

## Example Usage

### Posting a Question

```python
result = await client.call("add_task_message", {
    "task_id": 42,
    "persona": "agent-001",
    "message": "@dave-developer How should I handle null values in the user_name field? Should I use empty string or skip the field entirely?"
})
# Returns: {"event_id": 512, "task_id": 42, "persona": "agent-001", "type": "message"}
```

### Retrieving Task Feed

```python
feed = await client.call("get_task_feed", {"task_id": 42})
# Returns list of events including status changes, assignments, and messages
```
