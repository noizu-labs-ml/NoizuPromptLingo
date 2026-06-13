# FR-009: react Tool

**Status**: Draft

## Description

Add or remove emoji reaction to a message.

## Interface

```python
async def react(
    message_id: str,
    emoji: str,
    action: Literal["add", "remove"] | None = None,
    ctx: Context
) -> ReactionRecord:
    """Add emoji reaction to a message."""
```

## Behavior

- **Given** message ID and emoji
- **When** react is invoked
- **Then**
  - Validates message exists and is in accessible room
  - Toggles reaction state (add if not present, remove if present)
  - Updates reaction counts atomically
  - Appends reaction event to room log
  - Returns ReactionRecord with reaction_id, emoji, count

## Edge Cases

- **Invalid message**: Return not found error
- **Invalid emoji**: Accept any unicode emoji or shortcode
- **Double add**: Ignore (idempotent)
- **Remove non-existent**: Ignore (idempotent)

## Related User Stories

- US-031-045

## Test Coverage

Expected test count: 8-10 tests
Target coverage: 100% for this FR
