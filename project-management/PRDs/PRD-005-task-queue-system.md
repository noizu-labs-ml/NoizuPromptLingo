# PRD-005: Task Queue System

**Version**: 1.0
**Status**: Documented
**Author**: npl-prd-editor
**Created**: 2026-02-02
**Updated**: 2026-02-02

## Overview

Comprehensive task management with queues, individual tasks, priorities, deadlines, complexity assessment, artifact linking, and activity feeds. Supports multi-persona collaboration through chat integration and status workflows.

**Implementation Status**: ✅ Complete in mcp-server worktree (13 MCP tools, 0% test coverage)

## Goals

1. Enable organized task management through queues
2. Support full task lifecycle from creation to completion
3. Provide real-time collaboration via activity feeds
4. Link code artifacts and branches to tasks
5. Enforce business rules (e.g., human-only "done" status)

## Non-Goals

- Advanced sprint planning features (moved to future PRD)
- Time tracking integration (out of scope)
- External calendar synchronization (deferred)

---

## User Stories

Reference stories from global `project-management/user-stories/` directory.

| ID | Title | Persona | Priority |
|----|-------|---------|----------|
| [US-014](../../user-stories/US-014-pick-task-from-queue.md) | Pick up task from queue | P-001 | high |
| [US-015](../../user-stories/US-015-view-task-progress.md) | View task queue progress | P-004 | high |
| [US-016](../../user-stories/US-016-create-task.md) | Create task in queue | P-003 | high |
| [US-017](../../user-stories/US-017-link-artifact-to-task.md) | Link artifact to task | P-001 | high |
| [US-018](../../user-stories/US-018-update-task-status.md) | Update task status | P-001 | high |
| [US-026](../../user-stories/US-026-ask-question-on-task.md) | Ask question on task | P-001 | medium |
| [US-030](../../user-stories/US-030-assign-task-complexity.md) | Assign task complexity | P-001 | low |

Use MCP tools to load full story details:
- **get-story**: Load story by ID
- **edit-story**: Modify story content
- **update-story**: Update story metadata

---

## Functional Requirements

All functional requirements are detailed in `./functional-requirements/` directory.

See `functional-requirements/index.yaml` for complete list.

Key requirements:
- **[FR-001](./functional-requirements/FR-001-task-queue-management.md)**: Task Queue Management (3 tools)
- **[FR-002](./functional-requirements/FR-002-task-lifecycle.md)**: Task Lifecycle Management (6 tools)
- **[FR-003](./functional-requirements/FR-003-artifact-linking.md)**: Task Artifact Linking (1 tool)
- **[FR-004](./functional-requirements/FR-004-activity-feeds.md)**: Activity Feed System (3 tools)

---

## Non-Functional Requirements

| ID | Requirement | Metric | Target |
|----|-------------|--------|--------|
| NFR-1 | Test coverage | Line coverage | >= 80% |
| NFR-2 | Database performance | Task list query | < 100ms |
| NFR-3 | Feed polling latency | Get new events | < 200ms |
| NFR-4 | Concurrent updates | Task status changes | No race conditions |

---

## Error Handling

| Error Condition | Error Type | User Message |
|-----------------|------------|--------------|
| Invalid priority (outside 0-3) | ValueError | "Priority must be 0 (low), 1 (normal), 2 (high), or 3 (urgent)" |
| Invalid complexity (outside 1-5) | ValueError | "Complexity must be between 1 (trivial) and 5 (very complex)" |
| AI marking task done | PermissionError | "Only human users can mark tasks as done" |
| Invalid task_id | NotFoundError | "Task with ID {id} not found" |
| Invalid queue_id | NotFoundError | "Queue with ID {id} not found" |
| Missing required artifact field | ValueError | "artifact_id required for artifact_type='artifact'" |

---

## Acceptance Tests

All acceptance tests detailed in `./acceptance-tests/` directory.

See `acceptance-tests/index.yaml` for test plan.

**Summary**:
- AT-001: Queue Creation (unit)
- AT-002: Task Creation (unit)
- AT-003: Task Status Transitions (unit)
- AT-004: Task Complexity Assignment (unit)
- AT-005: Artifact Linking (integration)
- AT-006: Activity Feed with Polling (integration)

---

## Success Criteria

1. All 7 user stories implemented with acceptance criteria passing
2. Test coverage >= 80% for all new code (currently 0%)
3. All 6 acceptance tests passing
4. Clear and actionable error messages for validation failures
5. Activity feed polling works reliably with next_since mechanism
6. Business rule enforcement (human-only "done") validated in tests

---

## Out of Scope

- Advanced project planning (Gantt charts, dependencies)
- Time tracking and effort estimation
- External integrations (Jira, GitHub Issues)
- Notification system (email/Slack)

---

## Dependencies

**Internal**:
- C-01: Database System (SQLite)
- C-02: Artifact Management
- C-04: Chat Integration
- C-05: Session Management

**External**:
- FastAPI (web routes)
- FastMCP (MCP tools)
- SQLite (database)

---

## Data Model

**task_queues**: id, name, description, chat_room_id, session_id, status, created_at, updated_at

**tasks**: id, queue_id, title, description, acceptance_criteria, priority (0-3), deadline, complexity (1-5), status, created_by, assigned_to, created_at, updated_at

**task_events**: id, task_id, queue_id, event_type, persona, data (JSON), created_at

**task_artifacts**: id, task_id, artifact_id, artifact_type, git_branch, file_path, description, created_by, created_at

---

## API Specification

See functional requirements for detailed interface definitions:
- FR-001: Queue operations (create, get, list)
- FR-002: Task operations (create, get, list, update status, assign complexity)
- FR-003: Artifact linking (add_task_artifact)
- FR-004: Activity feeds (add message, get feed with polling)

---

## Implementation Notes

**Status Workflow**: pending → in_progress → blocked → review → done

**Priority Levels**: 0=low, 1=normal, 2=high, 3=urgent

**Complexity Scale**: 1=trivial, 2=simple, 3=moderate, 4=complex, 5=very complex

**Human-Only "Done"**: Only human personas can mark tasks as "done"; AI personas are blocked from this transition.

---

## Open Questions

- [ ] Should task deadlines trigger notifications?
- [ ] Should blocked tasks automatically notify assignee?
- [ ] Should queue-level metrics include velocity calculation?
