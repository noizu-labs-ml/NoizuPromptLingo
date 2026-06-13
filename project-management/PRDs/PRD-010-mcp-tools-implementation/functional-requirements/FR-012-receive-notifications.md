# FR-012: receive_notifications Tool

**Status**: Draft

## Description

Retrieve pending notifications for the current user with pagination.

## Interface

```python
async def receive_notifications(
    since: str | None = None,
    types: list[str] | None = None,
    limit: int | None = None,
    ctx: Context
) -> NotificationList:
    """Retrieve pending notifications for current user."""
```

## Behavior

- **Given** optional filters and pagination cursor
- **When** receive_notifications is invoked
- **Then**
  - Retrieves notifications for authenticated user
  - Filters by type (mention, reaction, todo, artifact, review)
  - Supports cursor-based pagination
  - Marks retrieved notifications as read (configurable)
  - Returns NotificationList with items, next_cursor, unread_count

## Edge Cases

- **No notifications**: Return empty list with unread_count=0
- **Invalid cursor**: Start from beginning
- **Invalid types**: Ignore invalid, use valid ones
- **Large limit (>100)**: Cap at 100

## Related User Stories

- US-031-045

## Test Coverage

Expected test count: 10-12 tests
Target coverage: 100% for this FR
