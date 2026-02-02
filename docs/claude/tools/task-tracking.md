# Task Tracking

## Overview

Task tracking tools help organize complex, multi-step work through a structured workflow:

1. **Create** tasks with TaskCreate
2. **List** tasks with TaskList to see what's available
3. **Get** task details with TaskGet before starting work
4. **Update** status to `in_progress` when starting
5. **Update** status to `completed` when done
6. **Repeat** TaskList to find newly unblocked work

**Typical task lifecycle**: `pending` → `in_progress` → `completed`

---

## TaskCreate

**Purpose**: Create structured task lists for complex work.

**When to use**:
- Complex multi-step tasks (3+ steps) — The 3+ step threshold is a heuristic for when tracking provides value. Example: "Add validation, update tests, update docs" (3 steps, worth tracking). Example not worth tracking: "Open file X, change variable Y" (2 steps, inline instead).
- User provides multiple tasks
- After receiving new instructions
- In plan mode
- Tracking implementation progress

**When NOT to use**:
- Single straightforward task
- Trivial tasks
- Purely conversational requests

**Parameters**:
- `subject` (required): Brief imperative title
- `description` (required): Detailed requirements — A good description should include:
  - What change is being made (the "what")
  - Why it's being made (the "why", if not obvious)
  - Any constraints or edge cases to consider
  - How to verify completion (acceptance criteria)
- `activeForm` (recommended): Present continuous form
- `metadata` (optional): Arbitrary key-value data

**Example**:
```json
{
  "subject": "Implement user authentication",
  "description": "Add JWT-based authentication with login/logout endpoints, middleware for protected routes, and token refresh logic",
  "activeForm": "Implementing user authentication"
}
```

**Creating multiple tasks**: Call TaskCreate multiple times in sequence, once per task. Dependencies can be set afterward using TaskUpdate.

**Key points**:
- All tasks created with status `pending`
- Subject should be imperative: "Run tests"
- activeForm should be continuous: "Running tests"
- Check TaskList first to avoid duplicates

---

## TaskUpdate

**Purpose**: Update task status, details, or dependencies.

**When to use**:
- Mark task as in_progress when starting
- Mark task as completed when finished
- Update task details
- Set up dependencies
- Delete obsolete tasks

**Parameters**:
- `taskId` (required): Task ID to update
- `status` (optional): "pending", "in_progress", "completed", "deleted"
- `subject` (optional): New title
- `description` (optional): New description
- `activeForm` (optional): New active form
- `owner` (optional): Assign to agent — This is metadata for tracking/human review purposes. It does not route tasks to specific agents.
- `addBlocks` (optional): Tasks this blocks — Other task IDs that cannot start until this one completes
- `addBlockedBy` (optional): Tasks blocking this — Task IDs that must complete before this can start
- `metadata` (optional): Metadata updates (set key to null to delete it)

**Dependency examples**:
```
Task 1: Design schema (ID: "1")
Task 2: Create tables (ID: "2", blockedBy: ["1"]) — waits for schema design
Task 3: Add API endpoints (ID: "3", blockedBy: ["2"]) — waits for tables
Task 4: Update docs (ID: "4", blockedBy: ["1", "3"]) — waits for both schema and endpoints
```

**Status workflow**:
- Status progresses linearly: `pending` → `in_progress` → `completed`
- Use `deleted` to permanently remove a task
- Cannot move backwards (e.g., completed → in_progress)

**Staleness warning**: Always use TaskGet to read latest task state before updating to avoid overwriting concurrent changes.

**Examples**:

Start work:
```json
{
  "taskId": "1",
  "status": "in_progress"
}
```

Complete task:
```json
{
  "taskId": "1",
  "status": "completed"
}
```

Delete task:
```json
{
  "taskId": "1",
  "status": "deleted"
}
```

Set dependencies:
```json
{
  "taskId": "2",
  "addBlockedBy": ["1"]
}
```

Update metadata:
```json
{
  "taskId": "1",
  "metadata": {
    "priority": "high",
    "estimate": "4h",
    "oldKey": null
  }
}
```
(Note: Setting a key to `null` deletes it from metadata)

**Critical rules**:
- ONLY mark completed when FULLY done
- Keep in_progress if tests fail or blocked
- ALWAYS use TaskGet before TaskUpdate to get latest state
- Status is linear: pending → in_progress → completed (no backwards movement)

**When is a task truly complete?**

| Task type | Completion criteria |
|-----------|--------------------|
| Implementation | Code written AND all tests passing |
| Documentation | Written AND reviewed AND formatting validated |
| Bug fix | Fixed AND edge cases tested AND root cause documented |
| Refactoring | Old code removed/new code written AND tests passing AND performance verified |

**Keep `in_progress` status when**:

| Situation | Action |
|-----------|--------|
| Tests failing | Keep in_progress, don't mark completed |
| Blocked by dependency | Keep in_progress, set `addBlockedBy` |
| Need user clarification | Keep in_progress, add note in description about what's needed |
| Partial implementation | Keep in_progress, mark completed only when all parts are done |

---

## TaskList

**Purpose**: View all tasks and their status.

**When to use**:
- Check available tasks
- See overall progress
- Find blocked tasks
- After completing a task
- Before creating new tasks

**Usage**:
```json
{}
```

**Returns summary for each task**:
- `id`: Task identifier
- `subject`: Brief title
- `status`: "pending", "in_progress", or "completed"
- `owner`: Agent ID if assigned, empty if available
- `blockedBy`: List of task IDs that must complete first (empty = ready to start)

**Best practice**:
- Work on tasks in ID order (lowest first)
- Check after each completion for newly unblocked work

---

## TaskGet

**Purpose**: Retrieve full details for a specific task.

**When to use**:
- Before starting work on a task
- Need complete requirements
- Check dependencies
- After being assigned a task

**Parameters**:
- `taskId` (required): Task ID

**Usage**:
```json
{
  "taskId": "1"
}
```

**Returns full task details**:
- `id`: Task identifier
- `subject`: Task title
- `description`: Detailed requirements and context
- `status`: "pending", "in_progress", or "completed"
- `activeForm`: Present continuous form for display
- `owner`: Assigned agent (if any)
- `blocks`: Tasks waiting on this one
- `blockedBy`: Tasks that must complete before this one
- `metadata`: Arbitrary key-value data

**Note**: Use this before TaskUpdate to ensure you have the latest task state and avoid stale data issues.