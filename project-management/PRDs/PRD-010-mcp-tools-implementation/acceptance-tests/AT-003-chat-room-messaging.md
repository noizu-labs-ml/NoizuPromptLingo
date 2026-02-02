# AT-003: Chat Room Messaging

**Category**: Integration
**Related FR**: FR-007, FR-008, FR-009
**Status**: Not Started

## Description

Validates chat room creation, messaging, and reactions.

## Test Implementation

```python
async def test_chat_room_messaging():
    """Test chat room creation and messaging."""
    # Create room
    room = await chat_manager.create_room(
        name="test-room",
        visibility="public"
    )

    # Send message
    msg = await chat_manager.send_message(
        room_id=room.id,
        content="Hello world!",
        mentions=["agent-1"]
    )
    assert msg.sequence == 1

    # Add reaction
    reaction = await chat_manager.react(
        message_id=msg.id,
        emoji="👍"
    )
    assert reaction.count == 1

    # Thread reply
    reply = await chat_manager.send_message(
        room_id=room.id,
        content="Reply!",
        reply_to=msg.id
    )
    assert reply.sequence == 2
```

## Acceptance Criteria

- [ ] Rooms created with unique names
- [ ] Messages have sequential ordering
- [ ] Reactions toggle correctly
- [ ] Threading works properly
- [ ] Mentions trigger notifications

## Coverage

Covers:
- Normal path: Room creation and messaging
- Edge cases: Multiple reactions
- Error conditions: Invalid room access
