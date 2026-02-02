# FR-017: assign_task Tool

**Status**: Draft

## Description

Assign task to specific agent with reassignment support.

## Interface

```python
async def assign_task(
    task_id: str,
    assignee_id: str,
    force: bool | None = None,
    ctx: Context
) -> AssignmentRecord:
    """Assign task to specific agent."""
```

## Behavior

- **Given** task ID and assignee ID
- **When** assign_task is invoked
- **Then**
  - Validates assignee exists and is available
  - Updates assignment atomically
  - Notifies previous and new assignee
  - Records assignment history
  - Returns AssignmentRecord with previous_assignee, new_assignee, assigned_at

## Edge Cases

- **Already assigned**: Require force=true to reassign
- **Non-existent assignee**: Return not found error
- **Self-assignment**: Allow
- **Unassign (empty assignee)**: Allow

## Related User Stories

- US-046-060

## Test Coverage

Expected test count: 10-12 tests
Target coverage: 100% for this FR
