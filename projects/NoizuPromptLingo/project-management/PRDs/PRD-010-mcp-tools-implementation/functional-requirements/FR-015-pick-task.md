# FR-015: pick_task Tool

**Status**: Draft

## Description

Claim the next available task from queue with filtering.

## Interface

```python
async def pick_task(
    agent_id: str,
    filter: dict | None = None,
    count: int | None = None,
    ctx: Context
) -> TaskAssignment:
    """Claim the next available task from queue.

    Filter structure:
    {
        "labels": ["required", "labels"],
        "priority_min": "medium",
        "complexity_max": 8
    }
    """
```

## Behavior

- **Given** agent ID and optional filters
- **When** pick_task is invoked
- **Then**
  - Atomically claims task to prevent race conditions
  - Applies filter criteria to available tasks
  - Updates task status to in_progress
  - Records assignment timestamp
  - Returns TaskAssignment with task_id, assigned_at, deadline_estimate

## Edge Cases

- **No matching tasks**: Return null/empty result
- **Count >1**: Return array of assignments
- **Agent already has task**: Allow multiple assignments
- **Invalid filter**: Ignore invalid criteria

## Related User Stories

- US-046-060

## Test Coverage

Expected test count: 12-15 tests (including concurrency tests)
Target coverage: 100% for this FR
