# FR-008: send_message Tool

**Status**: Draft

## Description

Send a message to a chat room with threading and mentions.

## Interface

```python
async def send_message(
    room_id: str,
    content: str,
    reply_to: str | None = None,
    mentions: list[str] | None = None,
    ctx: Context
) -> MessageRecord:
    """Send a message to a chat room."""
```

## Behavior

- **Given** room ID and message content
- **When** send_message is invoked
- **Then**
  - Validates sender has room access
  - Appends immutable event to room log
  - Triggers mention notifications for mentioned members
  - Updates room activity timestamp
  - Returns MessageRecord with message_id, timestamp, sequence

## Edge Cases

- **No access to room**: Return permission denied error
- **Empty content**: Reject with validation error
- **Invalid reply_to**: Proceed without threading
- **Mentions non-members**: Ignore invalid mentions

## Related User Stories

- US-031-045

## Test Coverage

Expected test count: 10-12 tests
Target coverage: 100% for this FR
