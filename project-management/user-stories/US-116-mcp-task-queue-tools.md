# User Story: MCP Task Queue Tools

**ID**: US-116
**Legacy ID**: US-046-060
**Persona**: P-001 (AI Agent)
**PRD Group**: mcp_tools
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T20:00:00Z
**Related PRD**: PRD-010

## Story

As a **task coordinator**,
I want **to manage task queues with complexity scoring and artifact linking via MCP tools**,
So that **work can be organized and tracked through MCP workflows**.

## Acceptance Criteria

- [ ] Can create tasks with priority and complexity scoring
- [ ] Can pick up tasks from queue
- [ ] Can update task status through workflow states
- [ ] Can link artifacts to tasks
- [ ] Can ask questions on tasks
- [ ] Can view queue progress metrics

## Notes

- Story points: 13
- Related personas: task-coordinator, developer
- Consolidates stories US-046 through US-060 scope

## Dependencies

- PRD-005 Task Queue System
- PRD-010 MCP Tools Implementation

## Related Commands

- `create_task` - Create task
- `pick_task` - Pick up task from queue
- `update_task_status` - Update task status
- `link_artifact` - Link artifact to task
- `ask_question` - Ask question on task
