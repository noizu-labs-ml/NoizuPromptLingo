# User Story: Pick Up Task from Queue

**ID**: US-014
**Persona**: P-001 (AI Agent)
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As an **AI agent**,
I want to **list and pick up pending tasks from an NPL MCP task queue**,
So that **I can work on assigned items in priority order**.

## Context

This user story addresses the **NPL MCP Task Queue system** (`create_task_queue`, `list_tasks`, `get_task`, etc.), which manages work items in queues with status tracking (pending → in_progress → blocked → review → done). This is distinct from Claude Code's built-in TaskCreate/TaskList/TaskUpdate tools used for tracking Claude's own work.

## Acceptance Criteria

- [ ] Can list all available task queues using `list_task_queues`
- [ ] Can list tasks in a specific queue filtered by status (pending, in_progress, blocked, review, done)
- [ ] Can filter tasks by assigned persona using `list_tasks` with `assigned_to` parameter
- [ ] Tasks are returned with priority information and can be ordered by priority field
- [ ] Can update task status from "pending" to "in_progress" using `update_task_status` when claiming a task
- [ ] Can retrieve full task details (title, description, acceptance_criteria, priority, deadline) using `get_task`
- [ ] Agent can determine task ownership by checking `assigned_to` field in task details

## Notes

- **Picking logic**: Agent queries `list_tasks` with `status: "pending"` and `assigned_to: null` (or their own persona ID) to find available work
- **Priority ordering**: Sort by priority field (lower numbers = higher priority) when multiple pending tasks exist
- **Assignment semantics**:
  - Tasks can be pre-assigned via `create_task` with `assigned_to` parameter
  - Tasks can be self-assigned by calling `update_task` to set `assigned_to` field
  - Status transition `pending → in_progress` via `update_task_status` signals task claim
- **Concurrency**: Status update is atomic; if multiple agents attempt to claim the same task, only one will succeed
- **Polling interval**: Agents typically check for new work every 30-60 seconds or after completing a task

## Testable Behavior

**Scenario 1: Agent discovers available work**
```
Given: Queue "feature-backlog" exists with 3 pending tasks
When: Agent calls list_tasks(queue_id=5, status="pending", assigned_to=null)
Then: Returns tasks with priority ordering
And: Each task shows task_id, title, status, priority fields
```

**Scenario 2: Agent claims highest priority task**
```
Given: Task #42 has priority=1, status="pending", assigned_to=null
When: Agent calls update_task(task_id=42, assigned_to="agent-01")
And: Agent calls update_task_status(task_id=42, status="in_progress")
Then: Task ownership is recorded
And: Task status transitions to "in_progress"
And: Task no longer appears in pending unassigned queries
```

**Scenario 3: Agent retrieves task details before starting**
```
Given: Task #42 is assigned to agent-01
When: Agent calls get_task(task_id=42)
Then: Returns complete task details (title, description, acceptance_criteria, priority, deadline)
And: Agent has full context to begin work
```

**Scenario 4: Concurrent claim prevention**
```
Given: Task #42 is pending and unassigned
When: Agent-01 and Agent-02 simultaneously call update_task_status(task_id=42, status="in_progress")
Then: Only one agent's update succeeds
And: The other agent receives a conflict/error response
```

## Open Questions

- **Assignment strategy**: Should agents primarily self-assign from unassigned pending tasks, or should a coordinator pre-assign tasks? (Recommend: Support both - allow pre-assignment via `create_task`, but also enable self-service claiming)
- **Timeout handling**: How to detect and recover tasks stuck in `in_progress` state? (Recommend: Implement deadline-based timeout mechanism with automatic status reset or escalation)
- **Priority conflicts**: When multiple queues exist, how should agents prioritize across queues? (Recommend: Cross-queue priority scoring or explicit queue priority levels)
- **Blocked task visibility**: Should blocked tasks appear in default `list_tasks` results or be filtered out? (Recommend: Include with clear `blockedBy` metadata showing dependencies)

## Related MCP Tools

Primary tools for this workflow:
- `list_task_queues` - Discover available task queues
- `list_tasks` - Query tasks by queue, status, and assignment
- `get_task` - Retrieve full task details before claiming
- `update_task_status` - Transition task to `in_progress` when starting work
- `update_task` - Self-assign by setting `assigned_to` field

Supporting tools:
- `get_task_queue` - View queue metadata and task count breakdowns
- `get_task_feed` - Monitor task activity and updates
- `add_task_message` - Ask questions or report status on a task

**Note**: See `docs/reference/mcp.md` for detailed MCP Task Queue Tools documentation.
