# AT-003: Task Status Transitions

**Category**: Unit
**Related FR**: FR-002
**Status**: Not Started

## Description

Validates task status workflow transitions and enforcement of "done" restriction.

## Test Implementation

```python
async def test_status_transition_to_in_progress():
    """Transition task from pending to in_progress."""
    task = await create_task(queue_id=1, title="Task")
    updated = await update_task_status(
        task_id=task["id"],
        status="in_progress",
        persona="developer"
    )
    assert updated["status"] == "in_progress"


async def test_ai_cannot_mark_done():
    """AI personas cannot mark tasks as done."""
    task = await create_task(queue_id=1, title="Task")
    with pytest.raises(PermissionError):
        await update_task_status(
            task_id=task["id"],
            status="done",
            persona="ai-assistant"
        )


async def test_human_can_mark_done():
    """Human personas can mark tasks as done."""
    task = await create_task(queue_id=1, title="Task")
    updated = await update_task_status(
        task_id=task["id"],
        status="done",
        persona="human-developer"
    )
    assert updated["status"] == "done"
```

## Acceptance Criteria

- [ ] Status transitions follow workflow (pending → in_progress → blocked → review → done)
- [ ] AI personas cannot set status to "done"
- [ ] Human personas can set status to "done"
- [ ] Activity feed logs status changes
- [ ] Notes attached to status updates

## Coverage

Covers:
- Valid status transitions
- Business rule enforcement (human-only "done")
- Persona-based authorization
- Activity logging
