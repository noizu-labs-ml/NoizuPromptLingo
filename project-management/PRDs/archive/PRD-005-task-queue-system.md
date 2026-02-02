# PRD: Task Queue System

**PRD ID**: PRD-005
**Version**: 1.0
**Status**: Documented
**Documentation Source**: worktrees/main/mcp-server
**Last Updated**: 2026-02-02

## Executive Summary

Comprehensive task management with queues, individual tasks, priorities, deadlines, complexity assessment, artifact linking, and activity feeds. Supports multi-persona collaboration through chat integration and status workflows.

**Implementation Status**: ✅ Complete in mcp-server worktree (13 MCP tools, 0% test coverage)

## Features Documented

### User Stories Addressed
- **US-014**: Pick up task from queue
- **US-015**: View task queue progress
- **US-016**: Create task in queue
- **US-017**: Link artifact to task
- **US-018**: Update task status
- **US-026**: Ask question on task
- **US-030**: Assign task complexity

## Functional Requirements

### FR-001: Task Queue Management (3 tools)
**Tools**: `create_task_queue`, `get_task_queue`, `list_task_queues`
**Database**: task_queues table

### FR-002: Task Lifecycle (6 tools)
**Tools**: `create_task`, `get_task`, `list_tasks`, `update_task_status`, `assign_task_complexity`, `update_task`
**Status Flow**: pending → in_progress → blocked → review → done
**Database**: tasks table
**Note**: Only humans can mark tasks as 'done'

### FR-003: Task Artifact Linking (1 tool)
**Tools**: `add_task_artifact`
**Artifact Types**: artifact, git_branch, file
**Database**: task_artifacts table

### FR-004: Activity Feeds (3 tools)
**Tools**: `add_task_message`, `get_task_queue_feed`, `get_task_feed`
**Polling Pattern**: Returns `next_since` for incremental updates
**Database**: task_events table

## Data Model

**task_queues**: id, name, description, chat_room_id, session_id, status, timestamps
**tasks**: id, queue_id, title, description, acceptance_criteria, priority (0-3), deadline, complexity (1-5), status, created_by, assigned_to, timestamps
**task_events**: id, task_id, queue_id, event_type, persona, data (JSON), created_at
**task_artifacts**: id, task_id, artifact_id, artifact_type, git_branch, description, created_by, created_at

## API Specification

### create_task
```python
task = await create_task(
    queue_id=1,
    title="Implement login",
    priority=2,  # 0=low, 1=normal, 2=high, 3=urgent
    deadline="2025-10-15T17:00:00",
    assigned_to="frontend-dev"
)
```

### update_task_status
```python
await update_task_status(
    task_id=1,
    status="in_progress",
    persona="frontend-dev",
    notes="Starting work"
)
```

### assign_task_complexity
```python
await assign_task_complexity(
    task_id=1,
    complexity=3,  # 1=trivial, 5=very complex
    notes="Estimated 4-6 hours"
)
```

### get_task_feed (polling)
```python
feed = await get_task_feed(
    task_id=1,
    since="2025-10-09T14:30:00"
)
# Use feed["next_since"] for next poll
```

## Web Interface

**Routes**:
- GET /tasks - Queue listing
- GET /tasks/{queue_id} - Queue detail
- GET /tasks/{queue_id}/task/{task_id} - Task detail
- POST /tasks/{queue_id}/task/{task_id}/message - Add message
- POST /tasks/{queue_id}/task/{task_id}/status - Update status

## Dependencies
- **Internal**: Artifacts (C-02), Chat (C-04), Sessions (C-05), Database (C-01)
- **External**: FastAPI, SQLite, FastMCP

## Testing
- **Coverage**: 0% (fully implemented but no tests)
- **Gap**: High priority for test implementation

## Documentation References
- **Category Brief**: `.tmp/mcp-server/categories/06-task-queue.md`
- **Tool Spec**: `.tmp/mcp-server/tools/by-category/task-tools.yaml`
