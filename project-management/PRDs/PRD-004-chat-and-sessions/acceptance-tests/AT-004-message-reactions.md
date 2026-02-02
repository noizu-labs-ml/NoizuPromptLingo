# AT-004: Message Reactions

**Category**: Unit
**Related FR**: FR-001
**Status**: Passing

## Description

Validates that users can react to messages with emoji and reactions are tracked.

## Test Implementation

```python
def test_react_to_message():
    """Test emoji reactions on messages."""
    # Setup
    room = create_chat_room("chat", ["alice", "bob"])
    msg = send_message(room.id, "alice", "Great work!")

    # Action
    react_to_message(msg.id, "bob", "👍")
    react_to_message(msg.id, "alice", "👍")

    # Assert
    feed = get_chat_feed(room.id)
    message = [e for e in feed if e["id"] == msg.id][0]
    reactions = message["data"].get("reactions", {})
    assert reactions.get("👍") == 2
```

## Acceptance Criteria

- [ ] Reaction adds emoji to message
- [ ] Multiple users can react with same emoji
- [ ] Reaction count increments correctly
- [ ] Duplicate reactions are ignored

## Coverage

Covers:
- Single user reaction
- Multiple user reactions
- Same emoji from different users
- Duplicate reaction handling
