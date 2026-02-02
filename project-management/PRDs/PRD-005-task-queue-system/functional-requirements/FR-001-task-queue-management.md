# FR-001: Task Queue Management

**Status**: Active

## Description

System must support creation, retrieval, and listing of task queues. Each queue acts as a container for related tasks and includes optional chat room and session associations for collaboration.

## Interface

```python
async def create_task_queue(
    name: str,
    description: str,
    chat_room_id: Optional[int] = None,
    session_id: Optional[int] = None
) -> dict:
    """Create a new task queue.

    Returns:
        dict with keys: id, name, description, chat_room_id, session_id,
        status, created_at, updated_at
    """

async def get_task_queue(queue_id: int) -> dict:
    """Retrieve task queue by ID with task summary statistics."""

async def list_task_queues(
    session_id: Optional[int] = None,
    status: Optional[str] = None
) -> list[dict]:
    """List all task queues with optional filtering."""
```

## Behavior

- **Given** user provides queue name and description
- **When** create_task_queue is called
- **Then** new queue is created with unique ID and "active" status

- **Given** queue_id exists
- **When** get_task_queue is called
- **Then** returns queue metadata plus task count summary

- **Given** queues exist in database
- **When** list_task_queues is called
- **Then** returns all queues matching filters (session_id, status)

## Edge Cases

- **Duplicate names**: Allowed (no uniqueness constraint on queue name)
- **Invalid chat_room_id**: Foreign key constraint fails gracefully
- **Deleted queue**: Returns 404 for get operations

## Related User Stories

- US-015
- US-016

## Test Coverage

Expected test count: 8-10 tests
Target coverage: 100% for this FR

**Test categories**:
- Queue creation with/without chat_room_id
- Queue retrieval (valid/invalid IDs)
- Queue listing with filters
- Database constraint enforcement
