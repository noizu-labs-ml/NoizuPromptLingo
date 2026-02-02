# AT-001: Queue Creation

**Category**: Unit
**Related FR**: FR-001
**Status**: Not Started

## Description

Validates task queue creation with required and optional parameters.

## Test Implementation

```python
async def test_create_task_queue_minimal():
    """Create queue with only required parameters."""
    queue = await create_task_queue(
        name="Sprint 1",
        description="Q1 sprint tasks"
    )
    assert queue["name"] == "Sprint 1"
    assert queue["status"] == "active"
    assert queue["chat_room_id"] is None


async def test_create_task_queue_with_chat():
    """Create queue with chat room association."""
    queue = await create_task_queue(
        name="Sprint 1",
        description="Q1 sprint tasks",
        chat_room_id=1
    )
    assert queue["chat_room_id"] == 1
```

## Acceptance Criteria

- [ ] Queue created with valid name and description
- [ ] Default status is "active"
- [ ] Optional chat_room_id stored correctly
- [ ] Unique queue ID generated

## Coverage

Covers:
- Basic queue creation
- Optional parameter handling
- Default value assignment
