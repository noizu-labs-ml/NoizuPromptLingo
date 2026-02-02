# FR-011: create_todo Tool

**Status**: Draft

## Description

Create a todo item associated with a chat room.

## Interface

```python
async def create_todo(
    room_id: str,
    title: str,
    assignee: str | None = None,
    due_date: str | None = None,
    linked_message: str | None = None,
    ctx: Context
) -> TodoRecord:
    """Create a todo item associated with a room."""
```

## Behavior

- **Given** room ID and todo title
- **When** create_todo is invoked
- **Then**
  - Creates todo in pending state
  - Associates with room for visibility
  - Links to message context if provided
  - Notifies assignee if specified
  - Returns TodoRecord with todo_id, status, created_at

## Edge Cases

- **Invalid assignee**: Create unassigned todo
- **Invalid date format**: Reject with validation error
- **Non-existent room**: Return not found error
- **Empty title**: Reject with validation error

## Related User Stories

- US-031-045

## Test Coverage

Expected test count: 8-10 tests
Target coverage: 100% for this FR
