# FR-014: create_task Tool

**Status**: Draft

## Description

Create a task in the queue with priority and labels.

## Interface

```python
async def create_task(
    title: str,
    description: str | None = None,
    priority: Literal["low", "medium", "high", "critical"] | None = None,
    labels: list[str] | None = None,
    parent_task: str | None = None,
    ctx: Context
) -> TaskRecord:
    """Create a task in the queue."""
```

## Behavior

- **Given** task title and optional metadata
- **When** create_task is invoked
- **Then**
  - Creates task in backlog status
  - Validates parent task exists if specified
  - Applies default priority (medium) if not specified
  - Triggers queue update notification
  - Returns TaskRecord with task_id, status, created_at

## Edge Cases

- **Empty title**: Reject with validation error
- **Invalid parent**: Return not found error
- **Invalid priority**: Use default "medium"
- **Too many labels (>20)**: Cap at 20

## Related User Stories

- US-046-060

## Test Coverage

Expected test count: 10-12 tests
Target coverage: 100% for this FR
