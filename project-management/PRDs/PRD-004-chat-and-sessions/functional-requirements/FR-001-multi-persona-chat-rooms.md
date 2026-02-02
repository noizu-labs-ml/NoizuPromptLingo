# FR-001: Multi-Persona Chat Rooms

**Status**: Completed

## Description

System must provide multi-persona chat rooms with @mention detection, notifications, artifact sharing, and message reactions.

## Interface

```python
# Create chat room
async def create_chat_room(
    name: str,
    members: list[str],
    session_id: str | None = None,
    description: str = ""
) -> dict:
    """Create a chat room with specified members."""

# Send message with auto @mention detection
async def send_message(
    room_id: int,
    persona: str,
    message: str,
    reply_to_id: int | None = None
) -> dict:
    """Send message to chat room, automatically detecting @mentions."""

# React to message
async def react_to_message(
    event_id: int,
    persona: str,
    emoji: str
) -> dict:
    """Add emoji reaction to message."""

# Share artifact
async def share_artifact(
    room_id: int,
    persona: str,
    artifact_id: int,
    comment: str = ""
) -> dict:
    """Share artifact in chat room."""

# Create todo from message
async def create_todo(
    room_id: int,
    persona: str,
    message: str,
    event_id: int | None = None
) -> dict:
    """Create todo item from chat message."""

# Get chat feed
async def get_chat_feed(
    room_id: int,
    limit: int = 50,
    before_id: int | None = None
) -> list[dict]:
    """Retrieve chat feed with pagination."""

# Get notifications
async def get_notifications(
    persona: str,
    unread_only: bool = True
) -> list[dict]:
    """Get notifications for persona."""

# Mark notification as read
async def mark_notification_read(
    notification_id: int
) -> dict:
    """Mark notification as read."""
```

## Behavior

- **Given** user sends message with "@username" text
- **When** message is processed
- **Then** notification is created for mentioned user

- **Given** user shares artifact in chat
- **When** artifact is shared
- **Then** artifact event appears in chat feed with preview

- **Given** user reacts to message
- **When** reaction is added
- **Then** reaction count updates for that emoji

## Edge Cases

- **@mention of non-existent user**: Silently ignored, no notification created
- **Duplicate reactions**: Same user + same emoji on same message = no-op
- **Empty message**: Rejected with validation error
- **Invalid room_id**: Returns error message

## Related User Stories

- US-004
- US-006
- US-007
- US-022
- US-027
- US-028

## Test Coverage

**Tools Implemented**: 8
**Expected test count**: 12-15 tests
**Current coverage**: 78%
**Target coverage**: 100%
