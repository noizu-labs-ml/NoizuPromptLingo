# AT-003: Chat Message Posting

**Category**: Integration
**Related FR**: FR-002
**Status**: Not Started

## Description

Validate that chat messages can be posted to rooms and appear in the message feed.

## Test Implementation

```python
def test_post_message_to_chat_room():
    """Test posting a message to a chat room."""
    # Setup: Create session and room
    session = create_test_session("test-session")
    room = create_test_room(session, "test-room")

    # Action: POST message
    response = client.post(
        f"/session/{session.id}/room/{room.id}/message",
        data={"message": "Hello, world!"}
    )

    # Assert
    assert response.status_code == 200

    # Verify message appears in feed
    feed_response = client.get(f"/api/room/{room.id}/feed")
    messages = feed_response.json()
    assert any(m["text"] == "Hello, world!" for m in messages)
```

## Acceptance Criteria

- [ ] Messages are posted successfully
- [ ] Messages appear in feed
- [ ] Chronological order is maintained
- [ ] @mentions are parsed

## Coverage

Covers:
- Normal path: message posting
- Edge case: empty message
- Error condition: invalid room ID
