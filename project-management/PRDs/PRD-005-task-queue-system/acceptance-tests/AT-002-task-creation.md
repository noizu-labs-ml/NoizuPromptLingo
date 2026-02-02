# AT-002: Task Creation

**Category**: Unit
**Related FR**: FR-002
**Status**: Not Started

## Description

Validates task creation with all parameter combinations and priority levels.

## Test Implementation

```python
async def test_create_task_minimal():
    """Create task with minimal required fields."""
    task = await create_task(
        queue_id=1,
        title="Implement login"
    )
    assert task["title"] == "Implement login"
    assert task["status"] == "pending"
    assert task["priority"] == 1  # default


async def test_create_task_with_priority():
    """Create task with explicit priority."""
    task = await create_task(
        queue_id=1,
        title="Fix critical bug",
        priority=3  # urgent
    )
    assert task["priority"] == 3


async def test_create_task_invalid_priority():
    """Reject task with invalid priority value."""
    with pytest.raises(ValueError):
        await create_task(
            queue_id=1,
            title="Task",
            priority=5  # invalid
        )
```

## Acceptance Criteria

- [ ] Task created with valid queue_id and title
- [ ] Default status is "pending"
- [ ] Priority values 0-3 accepted
- [ ] Invalid priority rejected
- [ ] Optional fields stored correctly

## Coverage

Covers:
- Basic task creation
- Priority validation (0-3)
- Default value assignment
- Error handling for invalid input
