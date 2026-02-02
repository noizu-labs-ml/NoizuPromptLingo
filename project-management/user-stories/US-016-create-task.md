# User Story: Create Task in Queue

**ID**: US-016
**Persona**: P-003 (Vibe Coder)
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a **vibe coder**,
I want to **create a new task in a task queue with required fields (queue_id, title, description)**,
So that **I can capture work items without leaving my flow**.

## Acceptance Criteria

- [ ] **Required fields**: Can create task with `queue_id`, `title`, and `description`
- [ ] **Priority**: Can set priority level (integer, where 1=highest, 5=lowest)
- [ ] **Assignment**: Can optionally assign to persona using `assigned_to` parameter
- [ ] **Acceptance criteria**: Can set `acceptance_criteria` text field
- [ ] **Deadline**: Can set optional `deadline` (ISO 8601 timestamp)
- [ ] **Creator tracking**: Can specify `created_by` parameter for attribution
- [ ] **Initial status**: Task starts in `pending` status (not `in_progress`, `blocked`, `review`, or `done`)
- [ ] **Response format**: Returns `task_id`, `queue_id`, and `web_url` on success
- [ ] **Error handling**: Returns clear error if `queue_id` is invalid or missing
- [ ] **Verification**: Created task is visible in `list_tasks` for the specified queue
- [ ] **Verification**: Created task details retrievable via `get_task` using returned `task_id`

## Notes

- Low-friction task creation encourages capturing work items
- Only `queue_id`, `title`, and `description` are required; all other fields optional
- Tasks can be refined later using `update_task` command
- Status lifecycle: `pending` → `in_progress` → `blocked` → `review` → `done`
- Priority scale: 1 (highest/most urgent) to 5 (lowest/least urgent)

## Open Questions

- Should there be templates for common task types?
- Should `created_by` default to current user/persona if not specified?
- Should we validate that `assigned_to` persona exists before creating task?

## Related Commands

- `create_task_queue` - Create a task queue before adding tasks
- `create_task` - This command (Task Queue Tools)
- `update_task` - Update task details after creation
- `update_task_status` - Change task status (pending → in_progress → blocked → review → done)
- `list_tasks` - View tasks in a queue
- `get_task` - Retrieve full task details
- `add_task_message` - Add comments/questions to a task

## Example Request

```json
{
  "queue_id": 5,
  "title": "Add dark mode",
  "description": "Implement UI theme switching with toggle control",
  "acceptance_criteria": "User can toggle dark mode; theme persists across sessions",
  "priority": 2,
  "deadline": "2026-03-01T00:00:00Z",
  "created_by": "alice",
  "assigned_to": "bob"
}
```

## Example Response

```json
{
  "status": "ok",
  "result": {
    "task_id": 21,
    "queue_id": 5,
    "web_url": "http://127.0.0.1:8765/tasks/5/task/21"
  }
}
```
