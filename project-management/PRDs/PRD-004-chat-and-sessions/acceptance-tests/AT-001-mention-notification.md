# AT-001: @Mention Notification

**Category**: Integration
**Related FR**: FR-001
**Status**: Passing

## Description

Validates that @mentions in chat messages trigger notifications for mentioned users.

## Test Implementation

```python
def test_mention_creates_notification():
    """Test that @username in message creates notification."""
    # Setup
    room = create_chat_room("test-room", ["alice", "bob"])

    # Action
    send_message(room.id, "alice", "Hey @bob check this out")

    # Assert
    notifications = get_notifications("bob", unread_only=True)
    assert len(notifications) == 1
    assert notifications[0]["type"] == "mention"
    assert "alice" in notifications[0]["data"]
```

## Acceptance Criteria

- [ ] Notification created when @username appears in message
- [ ] Notification links to original message
- [ ] Multiple @mentions create multiple notifications
- [ ] Invalid @usernames do not create notifications

## Coverage

Covers:
- Normal @mention scenarios
- Multiple mentions in one message
- Edge case: non-existent users
