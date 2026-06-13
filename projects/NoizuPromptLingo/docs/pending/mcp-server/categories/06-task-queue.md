# Category: Task Queue System

**Category ID**: C-06
**Tool Count**: 13
**Status**: Documented
**Source**: worktrees/main/mcp-server
**Documentation Source Date**: 2026-02-02

## Overview

The Task Queue System provides comprehensive task management capabilities for organizing agent work assignments. It enables creation of task queues, individual tasks with priorities and deadlines, complexity assessment, artifact linking, activity tracking, and real-time feed monitoring. The system supports multi-persona collaboration through integrated chat rooms, status workflows (pending → in_progress → blocked → review → done), and event-driven activity feeds for polling updates.

## Features Implemented

### Feature 1: Task Queue Management
**Description**: Create and manage task queues that organize collections of related work items. Queues can be associated with sessions and chat rooms for Q&A.

**MCP Tools**:
- `create_task_queue(name, description, session_id, chat_room_id)` - Create a new task queue with optional session and chat room integration
- `get_task_queue(queue_id)` - Get queue details with task statistics (total tasks, by status)
- `list_task_queues(status, limit)` - List queues with summary stats, filter by active/archived

**Database Tables**:
- `task_queues` - Queue metadata (name, description, session_id, chat_room_id, status, timestamps)

**Web Routes**:
- `GET /tasks` - List all task queues
- `GET /tasks/{queue_id}` - Queue detail view with tasks
- `POST /api/tasks/queues` - Create queue via API
- `GET /api/tasks/queues` - List queues via API
- `GET /api/tasks/queues/{queue_id}` - Get queue details via API

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/tasks/manager.py`
- Database: `worktrees/main/mcp-server/src/npl_mcp/storage/migrations.py` (migration 5)
- MCP Tools: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 1437-1495)
- Tests: `worktrees/main/mcp-server/tests/` (not explicitly tested in test_basic.py)

**Test Coverage**: Not explicitly tested (0%)

**Example Usage**:
```python
# Create a queue for design work
queue = await create_task_queue(
    name="dashboard-redesign",
    description="Q4 2025 dashboard redesign tasks",
    session_id="ses-20251009",
    chat_room_id=5
)
# Returns: {"queue_id": 1, "name": "dashboard-redesign", ...}

# List active queues
queues = await list_task_queues(status="active", limit=50)
```

### Feature 2: Task Creation and Management
**Description**: Create individual tasks within queues, update task details, and manage task lifecycle.

**MCP Tools**:
- `create_task(queue_id, title, description, acceptance_criteria, priority, deadline, created_by, assigned_to)` - Create task with full metadata
- `get_task(task_id)` - Get task details with linked artifacts
- `list_tasks(queue_id, status, assigned_to, limit)` - List tasks in queue with filtering
- `update_task(task_id, title, description, acceptance_criteria, priority, deadline, assigned_to, persona)` - Update task details

**Database Tables**:
- `tasks` - Task data (queue_id, title, description, acceptance_criteria, priority, deadline, complexity, status, assignees, timestamps)

**Web Routes**:
- `GET /tasks/{queue_id}/task/{task_id}` - Task detail view
- `POST /api/tasks/queues/{queue_id}/tasks` - Create task via API
- `GET /api/tasks/{task_id}` - Get task details via API
- `GET /api/tasks/queues/{queue_id}/tasks` - List tasks via API
- `PATCH /api/tasks/{task_id}` - Update task via API

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/tasks/manager.py`
- Database: `worktrees/main/mcp-server/src/npl_mcp/storage/migrations.py` (migration 5)
- MCP Tools: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 1497-1663)

**Test Coverage**: Not explicitly tested (0%)

**Example Usage**:
```python
# Create a task
task = await create_task(
    queue_id=1,
    title="Implement login form",
    description="Create responsive login form with validation",
    acceptance_criteria="- Form validates email\n- Password strength meter\n- Remember me checkbox",
    priority=2,  # high priority
    deadline="2025-10-15T17:00:00",
    created_by="product-manager",
    assigned_to="frontend-dev"
)

# Update task priority
await update_task(
    task_id=1,
    priority=3,  # urgent
    persona="product-manager"
)
```

### Feature 3: Task Status Workflow
**Description**: Manage task progression through defined status flow with validation. Only human operators can mark tasks as "done".

**MCP Tools**:
- `update_task_status(task_id, status, persona, notes)` - Update task status with optional notes

**Status Flow**: `pending` → `in_progress` → `blocked` → `review` → `done`

**Database Tables**:
- `tasks` (status column)
- `task_events` (status change events)

**Web Routes**:
- `POST /tasks/{queue_id}/task/{task_id}/status` - Update status from web form
- `PATCH /api/tasks/{task_id}/status` - Update status via API

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/tasks/manager.py`
- MCP Tools: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 1575-1601)

**Test Coverage**: Not explicitly tested (0%)

**Example Usage**:
```python
# Agent starts working on task
await update_task_status(
    task_id=1,
    status="in_progress",
    persona="frontend-dev",
    notes="Starting implementation"
)

# Agent hits a blocker
await update_task_status(
    task_id=1,
    status="blocked",
    persona="frontend-dev",
    notes="Waiting for API schema definition"
)

# Human marks complete
await update_task_status(
    task_id=1,
    status="done",
    persona="human-operator",
    notes="Reviewed and merged"
)
```

### Feature 4: Task Complexity Assessment
**Description**: Assign complexity scores to tasks after agent review to help with estimation and planning.

**MCP Tools**:
- `assign_task_complexity(task_id, complexity, notes, persona)` - Assign 1-5 complexity score

**Complexity Scale**:
- 1 = Trivial
- 2 = Simple
- 3 = Moderate
- 4 = Complex
- 5 = Very complex

**Database Tables**:
- `tasks` (complexity, complexity_notes columns)
- `task_events` (complexity_assigned event)

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/tasks/manager.py`
- MCP Tools: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 1603-1626)

**Test Coverage**: Not explicitly tested (0%)

**Example Usage**:
```python
# Agent assesses task complexity
await assign_task_complexity(
    task_id=1,
    complexity=3,  # moderate
    notes="Requires UI work plus validation logic. Estimated 4-6 hours.",
    persona="tech-lead"
)
```

### Feature 5: Task Artifact Linking
**Description**: Link artifacts, git branches, or files to tasks for tracking deliverables and work products.

**MCP Tools**:
- `add_task_artifact(task_id, artifact_type, artifact_id, git_branch, description, created_by)` - Link artifact to task

**Artifact Types**: `artifact`, `git_branch`, `file`

**Database Tables**:
- `task_artifacts` - Links between tasks and artifacts (task_id, artifact_id, artifact_type, git_branch, description, created_by, created_at)

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/tasks/manager.py`
- Database: `worktrees/main/mcp-server/src/npl_mcp/storage/migrations.py` (migration 5)
- MCP Tools: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 1665-1694)

**Test Coverage**: Not explicitly tested (0%)

**Example Usage**:
```python
# Link artifact to task
await add_task_artifact(
    task_id=1,
    artifact_type="artifact",
    artifact_id=42,
    description="Login form mockup v2",
    created_by="designer"
)

# Link git branch
await add_task_artifact(
    task_id=1,
    artifact_type="git_branch",
    git_branch="feature/login-form",
    description="Implementation branch",
    created_by="frontend-dev"
)
```

### Feature 6: Task Activity Feed
**Description**: Track all task-related events (messages, status changes, artifacts) and provide polling mechanism for updates.

**MCP Tools**:
- `add_task_message(task_id, persona, message)` - Add message/question to task feed
- `get_task_feed(task_id, since, limit)` - Get activity feed for specific task
- `get_task_queue_feed(queue_id, since, limit)` - Get activity feed for entire queue

**Event Types**:
- `task_created`
- `status_changed`
- `message_added`
- `artifact_linked`
- `complexity_assigned`
- `task_updated`

**Database Tables**:
- `task_events` - Event log (task_id, queue_id, event_type, persona, data, created_at)

**Web Routes**:
- `POST /tasks/{queue_id}/task/{task_id}/message` - Add message from web form
- `GET /api/tasks/queues/{queue_id}/feed` - Queue feed via API
- `GET /api/tasks/{task_id}/feed` - Task feed via API
- `POST /api/tasks/{task_id}/message` - Add message via API

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/tasks/manager.py`
- Database: `worktrees/main/mcp-server/src/npl_mcp/storage/migrations.py` (migration 5)
- MCP Tools: `worktrees/main/mcp-server/src/npl_mcp/unified.py` (lines 1696-1765)

**Test Coverage**: Not explicitly tested (0%)

**Example Usage**:
```python
# Add a message to task
await add_task_message(
    task_id=1,
    persona="frontend-dev",
    message="Should the password field support pasting? Security team input needed."
)

# Poll for updates (use returned next_since for subsequent calls)
feed = await get_task_feed(
    task_id=1,
    since="2025-10-09T14:30:00",
    limit=50
)
# Returns: {
#   "events": [...],
#   "next_since": "2025-10-09T15:45:00",
#   "has_more": false
# }
```

## MCP Tools Reference

### Tool Signatures

```python
create_task_queue(name: str, description: Optional[str] = None, session_id: Optional[str] = None, chat_room_id: Optional[int] = None) -> dict

get_task_queue(queue_id: int) -> dict

list_task_queues(status: Optional[str] = None, limit: int = 50) -> list

create_task(queue_id: int, title: str, description: Optional[str] = None, acceptance_criteria: Optional[str] = None, priority: int = 1, deadline: Optional[str] = None, created_by: Optional[str] = None, assigned_to: Optional[str] = None) -> dict

get_task(task_id: int) -> dict

list_tasks(queue_id: int, status: Optional[str] = None, assigned_to: Optional[str] = None, limit: int = 100) -> list

update_task_status(task_id: int, status: str, persona: Optional[str] = None, notes: Optional[str] = None) -> dict

assign_task_complexity(task_id: int, complexity: int, notes: Optional[str] = None, persona: Optional[str] = None) -> dict

update_task(task_id: int, title: Optional[str] = None, description: Optional[str] = None, acceptance_criteria: Optional[str] = None, priority: Optional[int] = None, deadline: Optional[str] = None, assigned_to: Optional[str] = None, persona: Optional[str] = None) -> dict

add_task_artifact(task_id: int, artifact_type: str, artifact_id: Optional[int] = None, git_branch: Optional[str] = None, description: Optional[str] = None, created_by: Optional[str] = None) -> dict

add_task_message(task_id: int, persona: str, message: str) -> dict

get_task_queue_feed(queue_id: int, since: Optional[str] = None, limit: int = 100) -> dict

get_task_feed(task_id: int, since: Optional[str] = None, limit: int = 50) -> dict
```

## Database Model

### Tables

- `task_queues`: Queue metadata with name, description, session/chat room associations, status (active/archived), timestamps
- `tasks`: Individual task records with queue_id, title, description, acceptance_criteria, priority (0-3), deadline, complexity (1-5), status (pending/in_progress/blocked/review/done), created_by, assigned_to, timestamps
- `task_events`: Activity feed with task_id, queue_id, event_type, persona, JSON data, timestamp
- `task_artifacts`: Links between tasks and artifacts/branches with task_id, artifact_id, artifact_type, git_branch, description, created_by, timestamp

### Relationships

```
task_queues (1) -> (N) tasks
task_queues (1) -> (N) task_events
tasks (1) -> (N) task_events
tasks (1) -> (N) task_artifacts
task_artifacts (N) -> (1) artifacts [optional]
task_queues (N) -> (1) chat_rooms [optional]
task_queues (N) -> (1) sessions [optional]
```

### Indexes

```sql
CREATE INDEX idx_task_queues_status ON task_queues(status);
CREATE INDEX idx_task_queues_session ON task_queues(session_id);
CREATE INDEX idx_tasks_queue ON tasks(queue_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_priority ON tasks(priority DESC);
CREATE INDEX idx_tasks_deadline ON tasks(deadline);
CREATE INDEX idx_tasks_assigned ON tasks(assigned_to);
CREATE INDEX idx_task_events_task ON task_events(task_id);
CREATE INDEX idx_task_events_queue ON task_events(queue_id);
CREATE INDEX idx_task_events_created ON task_events(created_at);
CREATE INDEX idx_task_artifacts_task ON task_artifacts(task_id);
CREATE INDEX idx_task_artifacts_artifact ON task_artifacts(artifact_id);
```

## User Stories Mapping

This category addresses:
- Task management and work coordination
- Multi-agent collaboration workflows
- Progress tracking and status monitoring
- Deliverable linking and documentation

Potential related user stories (if they exist):
- US-XXX: Agent work assignment and tracking
- US-XXX: Multi-persona task coordination
- US-XXX: Task complexity estimation
- US-XXX: Work item status management

## Suggested PRD Mapping

- PRD-06: Task Queue System
  - Task queue creation and management
  - Individual task lifecycle management
  - Status workflow enforcement
  - Complexity assessment
  - Artifact linking
  - Activity feed and event tracking

## API Documentation

### MCP Tools

#### create_task_queue
Create a new task queue for organizing work items.

**Parameters**:
- `name` (str, required): Unique name for the queue
- `description` (str, optional): Description of queue's purpose
- `session_id` (str, optional): Session to associate with
- `chat_room_id` (int, optional): Chat room for Q&A about tasks

**Returns**: Dict with queue_id, name, description, session_id, chat_room_id, status, web_url

#### get_task_queue
Get task queue details with task counts.

**Parameters**:
- `queue_id` (int, required): ID of the queue

**Returns**: Dict with queue details and task statistics (total, pending, in_progress, blocked, review, done counts)

#### list_task_queues
List task queues with summary stats.

**Parameters**:
- `status` (str, optional): Filter by status ('active', 'archived')
- `limit` (int, default=50): Maximum queues to return

**Returns**: List of queue dicts with task counts and web_url

#### create_task
Create a new task in a queue.

**Parameters**:
- `queue_id` (int, required): ID of the task queue
- `title` (str, required): Task title
- `description` (str, optional): Task description
- `acceptance_criteria` (str, optional): Criteria for task completion
- `priority` (int, default=1): Priority level (0=low, 1=normal, 2=high, 3=urgent)
- `deadline` (str, optional): ISO timestamp deadline
- `created_by` (str, optional): Persona who created the task
- `assigned_to` (str, optional): Persona assigned to the task

**Returns**: Dict with task_id, metadata, and web_url

#### get_task
Get task details with linked artifacts.

**Parameters**:
- `task_id` (int, required): ID of the task

**Returns**: Dict with task details, artifacts, and web_url

#### list_tasks
List tasks in a queue.

**Parameters**:
- `queue_id` (int, required): ID of the queue
- `status` (str, optional): Filter by status (pending, in_progress, blocked, review, done)
- `assigned_to` (str, optional): Filter by assignee
- `limit` (int, default=100): Maximum tasks to return

**Returns**: List of task dicts ordered by priority and deadline

#### update_task_status
Update task status following defined workflow.

**Parameters**:
- `task_id` (int, required): ID of the task
- `status` (str, required): New status (pending, in_progress, blocked, review, done)
- `persona` (str, optional): Persona making the change
- `notes` (str, optional): Notes about the status change

**Returns**: Updated task dict

**Note**: Only human operators can mark tasks as 'done'

#### assign_task_complexity
Assign complexity score to a task after review.

**Parameters**:
- `task_id` (int, required): ID of the task
- `complexity` (int, required): Score 1-5 (1=trivial, 2=simple, 3=moderate, 4=complex, 5=very complex)
- `notes` (str, optional): Notes about complexity assessment
- `persona` (str, optional): Agent persona making the assessment

**Returns**: Updated task dict

#### update_task
Update task details.

**Parameters**:
- `task_id` (int, required): ID of the task
- `title` (str, optional): New title
- `description` (str, optional): New description
- `acceptance_criteria` (str, optional): New criteria
- `priority` (int, optional): New priority
- `deadline` (str, optional): New deadline
- `assigned_to` (str, optional): New assignee
- `persona` (str, optional): Persona making the change

**Returns**: Updated task dict

#### add_task_artifact
Link an artifact or git branch to a task.

**Parameters**:
- `task_id` (int, required): ID of the task
- `artifact_type` (str, required): Type of artifact ('artifact', 'git_branch', 'file')
- `artifact_id` (int, optional): ID of artifact if type is 'artifact'
- `git_branch` (str, optional): Git branch name if type is 'git_branch'
- `description` (str, optional): Description of the artifact
- `created_by` (str, optional): Persona uploading the artifact

**Returns**: Dict with task_artifact_id

#### add_task_message
Add a message/question to a task's activity feed.

**Parameters**:
- `task_id` (int, required): ID of the task
- `persona` (str, required): Persona sending the message
- `message` (str, required): Message content

**Returns**: Dict with event_id

#### get_task_queue_feed
Get activity feed for a task queue (for polling).

**Parameters**:
- `queue_id` (int, required): ID of the queue
- `since` (str, optional): ISO timestamp to get events after
- `limit` (int, default=100): Maximum events to return

**Returns**: Dict with events list and next_since timestamp for polling

**Usage**: Pass the returned 'next_since' value in subsequent calls to only get new events.

#### get_task_feed
Get activity feed for a specific task.

**Parameters**:
- `task_id` (int, required): ID of the task
- `since` (str, optional): ISO timestamp to get events after
- `limit` (int, default=50): Maximum events to return

**Returns**: Dict with events list and next_since timestamp

### Web Endpoints

#### GET /tasks
List all task queues

**Response**: HTML page with queue list

#### GET /tasks/{queue_id}
Task queue detail view

**Response**: HTML page with queue details and task list

#### GET /tasks/{queue_id}/task/{task_id}
Task detail view

**Response**: HTML page with task details and activity feed

#### POST /tasks/{queue_id}/task/{task_id}/message
Add message from web form

**Form Data**: persona, message

**Response**: 303 redirect to task detail

#### POST /tasks/{queue_id}/task/{task_id}/status
Update task status from web form

**Form Data**: status, persona, notes

**Response**: 303 redirect to task detail

#### GET /api/tasks/queues
List task queues (API)

**Query Params**: status (optional), limit (default=50)

**Response**: JSON array of queue objects

#### POST /api/tasks/queues
Create task queue (API)

**Body**: `{"name": "...", "description": "...", "session_id": "..."}`

**Response**: 201 with queue object

#### GET /api/tasks/queues/{queue_id}
Get task queue details (API)

**Response**: JSON queue object or 404

#### GET /api/tasks/queues/{queue_id}/tasks
List tasks in queue (API)

**Query Params**: status (optional), limit (default=100)

**Response**: JSON array of task objects

#### GET /api/tasks/{task_id}
Get task details (API)

**Response**: JSON task object or 404

#### PATCH /api/tasks/{task_id}
Update task details (API)

**Body**: `{"title": "...", "description": "...", ...}`

**Response**: JSON updated task object

#### PATCH /api/tasks/{task_id}/status
Update task status (API)

**Body**: `{"status": "...", "persona": "...", "notes": "..."}`

**Response**: JSON updated task object

#### POST /api/tasks/{task_id}/message
Add message to task (API)

**Body**: `{"persona": "...", "message": "..."}`

**Response**: 201 with event object

#### GET /api/tasks/queues/{queue_id}/feed
Get queue activity feed (API)

**Query Params**: since (optional ISO timestamp), limit (default=100)

**Response**: JSON feed object

#### GET /api/tasks/{task_id}/feed
Get task activity feed (API)

**Query Params**: since (optional ISO timestamp), limit (default=50)

**Response**: JSON feed object

## Dependencies

### Internal
- **Artifact Management** (C-02): Links tasks to versioned artifacts
- **Chat System** (C-05): Integrates with chat rooms for task Q&A
- **Session Management** (C-04): Associates task queues with sessions
- **Database Layer** (C-01): Uses Database class for persistence

### External
- **FastAPI**: Web routes and API endpoints
- **SQLite**: Data persistence via aiosqlite
- **FastMCP**: MCP tool registration

## Testing

- **Test Files**: Not explicitly tested in `worktrees/main/mcp-server/tests/test_basic.py`
- **Coverage**: 0% (no task-specific tests found)
- **Key Test Cases**:
  - Task queue creation and retrieval
  - Task lifecycle (create, update, status changes)
  - Status workflow validation
  - Complexity assignment
  - Artifact linking
  - Activity feed polling
  - Multi-persona collaboration

**Testing Gap**: This is a fully implemented feature set with 13 MCP tools, complete database schema, web routes, and API endpoints, but currently has no test coverage. Recommended priority for test implementation.

## Documentation References

- **README**: worktrees/main/mcp-server/README.md (no explicit task queue section found)
- **USAGE**: worktrees/main/mcp-server/USAGE.md (no explicit task queue examples found)
- **PRD**: Not found in worktrees/main/mcp-server/docs/
- **Status**: worktrees/main/mcp-server/PROJECT_STATUS.md (no task queue coverage metrics)

## Implementation Notes

1. **Status Workflow Enforcement**: The system enforces a defined status progression (pending → in_progress → blocked → review → done), but only human operators can mark tasks as 'done'. This prevents agents from prematurely closing tasks.

2. **Priority System**: Uses integer priorities (0=low, 1=normal, 2=high, 3=urgent) with database index on priority DESC for efficient sorted queries.

3. **Event-Driven Architecture**: All task changes generate events in task_events table, enabling polling-based updates via get_task_feed and get_task_queue_feed.

4. **Artifact Integration**: Tasks can link multiple artifacts, git branches, or files via task_artifacts table, providing full traceability of deliverables.

5. **Chat Integration**: Task queues optionally link to chat rooms, enabling real-time discussion about tasks without cluttering the task feed.

6. **Session Association**: Task queues can be associated with sessions for organizational grouping.

7. **Complexity Estimation**: Separate from priority, complexity scores (1-5) help with planning and estimation after agent review.

8. **Polling Optimization**: Feed endpoints return `next_since` timestamp for efficient polling - clients pass this value to only retrieve new events.

9. **Web UI Integration**: Full web interface with HTML views and REST API endpoints for human interaction.

10. **Migration-Based Schema**: Task tables added via migration 5 in migrations.py, ensuring clean upgrade path for existing databases.

## Gaps and Limitations

- **No Test Coverage**: Despite being fully implemented, no tests exist for this feature set
- **No Documentation**: README and USAGE.md don't mention task queues
- **No PRD**: No product requirements document found
- **No Metrics**: PROJECT_STATUS.md doesn't track task queue coverage
- **Single Workflow**: Status flow is fixed; no support for custom workflows
- **No Dependencies**: Tasks can't declare dependencies on other tasks
- **No Time Tracking**: No built-in time tracking or estimates (only deadlines)
- **No Recurring Tasks**: No support for recurring or template tasks
- **No Subtasks**: Flat task structure; no hierarchical subtasks
