# FR-007: create_chat_room Tool

**Status**: Draft

## Description

Create a persistent chat room for collaboration.

## Interface

```python
async def create_chat_room(
    name: str,
    topic: str | None = None,
    visibility: Literal["public", "private", "restricted"] | None = None,
    members: list[str] | None = None,
    ctx: Context
) -> ChatRoomRecord:
    """Create a persistent chat room for collaboration."""
```

## Behavior

- **Given** room name and optional configuration
- **When** create_chat_room is invoked
- **Then**
  - Validates room name uniqueness
  - Creates room with event-sourced message log
  - Generates invite code for restricted rooms
  - Initializes member roster with creator as admin
  - Returns ChatRoomRecord with room_id, created_at, invite_code

## Edge Cases

- **Duplicate name**: Return conflict error
- **Empty member list**: Create with creator only
- **Invalid visibility**: Use default "public"
- **Long name (>100 chars)**: Truncate with warning

## Related User Stories

- US-031-045

## Test Coverage

Expected test count: 8-10 tests
Target coverage: 100% for this FR
