# AT-004: Task Complexity Assignment

**Category**: Unit
**Related FR**: FR-002
**Status**: Not Started

## Description

Validates complexity rating assignment with valid range (1-5) and activity logging.

## Test Implementation

```python
async def test_assign_complexity():
    """Assign valid complexity rating to task."""
    task = await create_task(queue_id=1, title="Task")
    updated = await assign_task_complexity(
        task_id=task["id"],
        complexity=3,
        notes="Estimated 4-6 hours",
        persona="tech-lead"
    )
    assert updated["complexity"] == 3


async def test_assign_complexity_invalid():
    """Reject complexity outside 1-5 range."""
    task = await create_task(queue_id=1, title="Task")
    with pytest.raises(ValueError):
        await assign_task_complexity(
            task_id=task["id"],
            complexity=10  # invalid
        )


async def test_update_complexity():
    """Update existing complexity rating."""
    task = await create_task(queue_id=1, title="Task")
    await assign_task_complexity(task["id"], complexity=2)
    updated = await assign_task_complexity(
        task["id"],
        complexity=4,
        notes="More complex than thought"
    )
    assert updated["complexity"] == 4
```

## Acceptance Criteria

- [ ] Complexity values 1-5 accepted
- [ ] Invalid complexity rejected
- [ ] Notes stored with rating
- [ ] Activity feed logs complexity assignment
- [ ] Complexity can be updated

## Coverage

Covers:
- Valid complexity assignment (1-5)
- Range validation
- Update scenarios
- Activity logging
