# AT-005: Todo Creation from Chat

**Category**: Integration
**Related FR**: FR-001
**Status**: Passing

## Description

Validates that todos can be created from chat messages and maintain message references.

## Test Implementation

```python
def test_create_todo_from_message():
    """Test todo creation from chat message."""
    # Setup
    room = create_chat_room("tasks", ["alice"])
    msg = send_message(room.id, "alice", "Need to fix the login bug")

    # Action
    todo = create_todo(room.id, "alice", "Fix login bug", event_id=msg.id)

    # Assert
    assert todo["message"] == "Fix login bug"
    assert todo["source_event_id"] == msg.id
    assert todo["room_id"] == room.id
```

## Acceptance Criteria

- [ ] Todo created with message text
- [ ] Todo references source message
- [ ] Todo appears in session task list
- [ ] Chat message shows todo creation indicator

## Coverage

Covers:
- Todo creation from message
- Message reference preservation
- Todo visibility in task lists
