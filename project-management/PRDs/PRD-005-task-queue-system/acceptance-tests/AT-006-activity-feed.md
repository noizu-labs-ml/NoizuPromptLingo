# AT-006: Activity Feed with Polling

**Category**: Integration
**Related FR**: FR-004
**Status**: Not Started

## Description

Validates activity feed posting, retrieval, and incremental polling behavior.

## Test Implementation

```python
async def test_add_task_message():
    """Post message to task activity feed."""
    task = await create_task(queue_id=1, title="Task")
    message = await add_task_message(
        task_id=task["id"],
        message="Need clarification on requirements",
        persona="developer"
    )
    assert message["event_type"] == "comment"
    assert message["persona"] == "developer"


async def test_get_task_feed():
    """Retrieve task activity feed."""
    task = await create_task(queue_id=1, title="Task")
    await add_task_message(task["id"], "Message 1", "dev1")
    await add_task_message(task["id"], "Message 2", "dev2")

    feed = await get_task_feed(task_id=task["id"])
    assert len(feed["events"]) == 2
    assert "next_since" in feed


async def test_incremental_polling():
    """Poll for new events using since timestamp."""
    task = await create_task(queue_id=1, title="Task")
    await add_task_message(task["id"], "Message 1", "dev1")

    feed1 = await get_task_feed(task_id=task["id"])
    since = feed1["next_since"]

    await add_task_message(task["id"], "Message 2", "dev2")
    feed2 = await get_task_feed(task_id=task["id"], since=since)

    assert len(feed2["events"]) == 1
    assert feed2["events"][0]["data"]["message"] == "Message 2"


async def test_queue_level_feed():
    """Retrieve activity feed for entire queue."""
    queue = await create_task_queue("Queue", "Desc")
    task1 = await create_task(queue["id"], "Task 1")
    task2 = await create_task(queue["id"], "Task 2")

    await add_task_message(task1["id"], "Msg 1", "dev1")
    await add_task_message(task2["id"], "Msg 2", "dev2")

    feed = await get_task_queue_feed(queue_id=queue["id"])
    assert len(feed["events"]) == 2
```

## Acceptance Criteria

- [ ] Messages posted with persona attribution
- [ ] get_task_feed returns events with next_since
- [ ] Polling with since returns only new events
- [ ] Queue-level feed aggregates all task events
- [ ] Events ordered by created_at ascending

## Coverage

Covers:
- Message posting
- Feed retrieval
- Incremental polling (since parameter)
- Queue-level aggregation
- Event ordering
