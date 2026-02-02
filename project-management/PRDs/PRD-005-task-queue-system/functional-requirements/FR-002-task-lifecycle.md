# FR-002: Task Lifecycle Management

**Status**: Active

## Description

System must support full task lifecycle from creation through completion, including status transitions, assignment, complexity ratings, and updates. Status workflow enforces business rules (e.g., only humans mark tasks "done").

## Interface

```python
async def create_task(
    queue_id: int,
    title: str,
    description: str = "",
    acceptance_criteria: str = "",
    priority: int = 1,
    deadline: Optional[str] = None,
    assigned_to: Optional[str] = None,
    created_by: str = "system"
) -> dict:
    """Create new task in queue.

    Args:
        priority: 0=low, 1=normal, 2=high, 3=urgent
    """

async def get_task(task_id: int) -> dict:
    """Retrieve task with full details and linked artifacts."""

async def list_tasks(
    queue_id: Optional[int] = None,
    status: Optional[str] = None,
    assigned_to: Optional[str] = None,
    priority: Optional[int] = None
) -> list[dict]:
    """List tasks with filtering options."""

async def update_task_status(
    task_id: int,
    status: str,
    persona: str,
    notes: str = ""
) -> dict:
    """Update task status with activity logging.

    Status workflow: pending → in_progress → blocked → review → done
    Note: Only humans can set status to "done"
    """

async def assign_task_complexity(
    task_id: int,
    complexity: int,
    notes: str = "",
    persona: str = "system"
) -> dict:
    """Assign complexity rating (1-5) to task."""

async def update_task(
    task_id: int,
    title: Optional[str] = None,
    description: Optional[str] = None,
    acceptance_criteria: Optional[str] = None,
    priority: Optional[int] = None,
    deadline: Optional[str] = None,
    assigned_to: Optional[str] = None
) -> dict:
    """Update task fields."""
```

## Behavior

- **Given** valid queue_id and task details
- **When** create_task is called
- **Then** task created with status "pending"

- **Given** task exists with status "pending"
- **When** update_task_status("in_progress") called
- **Then** status updates and activity event logged

- **Given** task status is not "done"
- **When** AI persona calls update_task_status("done")
- **Then** request denied (only humans can mark done)

- **Given** task exists
- **When** assign_task_complexity called with rating 1-5
- **Then** complexity stored and event logged

## Edge Cases

- **Invalid priority**: Values outside 0-3 rejected
- **Invalid complexity**: Values outside 1-5 rejected
- **Invalid status transition**: Some transitions may be restricted
- **Deadline format**: Must be ISO8601 datetime string
- **Done by AI**: Explicitly blocked (business rule)

## Related User Stories

- US-014
- US-016
- US-018
- US-030

## Test Coverage

Expected test count: 25-30 tests
Target coverage: 100% for this FR

**Test categories**:
- Task creation (all parameter combinations)
- Task retrieval and listing
- Status transitions (valid/invalid)
- Complexity assignment
- Priority handling
- Deadline validation
- AI vs human "done" enforcement
