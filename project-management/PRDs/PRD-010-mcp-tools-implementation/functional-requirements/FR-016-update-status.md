# FR-016: update_status Tool

**Status**: Draft

## Description

Update task status with history tracking.

## Interface

```python
async def update_status(
    task_id: str,
    status: Literal["backlog", "in_progress", "review", "blocked", "completed", "cancelled"],
    notes: str | None = None,
    blockers: list[str] | None = None,
    ctx: Context
) -> StatusUpdate:
    """Update task status."""
```

## Behavior

- **Given** task ID and new status
- **When** update_status is invoked
- **Then**
  - Validates status transition is valid
  - Records status history for tracking
  - Notifies watchers of status change
  - Updates task metrics (time in status)
  - Returns StatusUpdate with previous_status, new_status, updated_at

## Edge Cases

- **Invalid transition**: Reject with validation error
- **Blocked without blockers**: Accept but log warning
- **Non-existent task**: Return not found error
- **Already in target status**: Accept (idempotent)

## Related User Stories

- US-046-060

## Test Coverage

Expected test count: 12-15 tests
Target coverage: 100% for this FR
