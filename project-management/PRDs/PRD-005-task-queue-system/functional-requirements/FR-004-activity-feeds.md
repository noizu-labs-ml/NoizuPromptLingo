# FR-004: Activity Feed System

**Status**: Active

## Description

System must maintain activity feeds for tasks and queues, supporting message posting and incremental polling. Enables real-time collaboration and status tracking.

## Interface

```python
async def add_task_message(
    task_id: int,
    message: str,
    persona: str,
    message_type: str = "comment"
) -> dict:
    """Post message to task activity feed.

    Args:
        message_type: "comment", "status_change", "assignment", etc.

    Returns:
        dict with keys: id, task_id, event_type, persona, data, created_at
    """

async def get_task_feed(
    task_id: int,
    since: Optional[str] = None,
    limit: int = 50
) -> dict:
    """Retrieve task activity feed with polling support.

    Args:
        since: ISO8601 timestamp for incremental updates

    Returns:
        dict with keys: events (list), next_since (timestamp for next poll)
    """

async def get_task_queue_feed(
    queue_id: int,
    since: Optional[str] = None,
    limit: int = 50
) -> dict:
    """Retrieve queue-level activity feed (all tasks in queue).

    Returns:
        dict with keys: events (list), next_since (timestamp for next poll)
    """
```

## Behavior

- **Given** task_id and message content
- **When** add_task_message called
- **Then** event created in task_events table with type "comment"

- **Given** task status changes via update_task_status
- **When** status update occurs
- **Then** activity feed automatically logs status_change event

- **Given** task_id and since timestamp
- **When** get_task_feed called
- **Then** returns events after timestamp, provides next_since for polling

- **Given** queue_id
- **When** get_task_queue_feed called
- **Then** returns events for all tasks in queue

## Edge Cases

- **Invalid since timestamp**: Treated as "from beginning"
- **Large feeds**: Limit parameter controls page size (default 50)
- **Concurrent updates**: Timestamp-based polling may miss events between polls (acceptable trade-off)
- **Event ordering**: Events ordered by created_at ascending

## Related User Stories

- US-015
- US-018
- US-026

## Test Coverage

Expected test count: 12-15 tests
Target coverage: 100% for this FR

**Test categories**:
- Message posting
- Feed retrieval (with/without since)
- Polling behavior (next_since)
- Queue-level feed aggregation
- Event ordering
- Limit parameter handling
