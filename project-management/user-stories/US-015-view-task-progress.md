# User Story: View Task Queue Progress

**ID**: US-015
**Persona**: P-004 (Project Manager)
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a **project manager**,
I want to **view task queue progress with status breakdowns**,
So that **I can understand team velocity and identify bottlenecks**.

## Context

This user story addresses the **NPL MCP Task Queue system** (`get_task_queue`, `list_tasks`, `get_task_queue_feed`), which provides visibility into work item progress across agents and human team members. Task queues use a status workflow: pending → in_progress → blocked → review → done. This is distinct from Claude Code's built-in TaskList tool, which tracks Claude's own internal work.

## Acceptance Criteria

- [ ] Can retrieve task queue summary using `get_task_queue` with task counts by status (pending, in_progress, blocked, review, done)
- [ ] Queue summary includes total task count, completion percentage, and active task count
- [ ] Can list all tasks in a queue using `list_tasks` with filtering by status
- [ ] Task list returns task ID, title, status, assigned_to, priority, created_at, updated_at
- [ ] Can retrieve activity feed using `get_task_queue_feed` showing recent task status changes, assignments, and comments
- [ ] Activity feed entries include timestamp, actor (agent/human), action type, and affected task
- [ ] Web UI dashboard displays queue overview with visual status breakdown (charts/progress bars)
- [ ] Blocked tasks are visually highlighted with blockedBy dependencies shown
- [ ] Can filter task list by assigned persona to see agent vs. human workload
- [ ] Dashboard auto-refreshes or provides real-time updates via SSE

## Notes

- **Primary view**: This is the main project tracking interface for project managers coordinating agent and human work
- **Blocked task visibility**: Blocked tasks should show dependency chains (what tasks are blocking them) to help managers unblock work
- **Real-time updates**: Web dashboard should use SSE connection to show live task updates as agents and humans change status
- **Filtering capabilities**: Support filtering by status, assigned_to, priority, and date ranges
- **Performance considerations**: For queues with 100+ tasks, implement pagination in `list_tasks`
- **Future enhancements**: Burndown charts, velocity tracking, agent vs. human throughput comparison (see US-033)

## Open Questions

- [ ] **Sprint/milestone groupings**: Should task queues support grouping by sprint or milestone? (Recommend: Add optional `sprint_id` field to tasks for filtering)
- [ ] **Dependency visualization**: How to visualize complex task dependency chains in the UI? (Options: Gantt chart, dependency graph, simple list with indent levels)
- [ ] **Historical metrics**: Should `get_task_queue` include historical completion data for velocity calculation? (Recommend: Add optional `include_metrics` parameter for last 4 weeks of throughput)
- [ ] **Queue-level vs. global view**: Should project managers see a single dashboard for all queues or per-queue views? (Recommend: Both - default global view with drill-down to individual queues)
- [ ] **Agent work patterns**: Should the dashboard show agent work hours/patterns to identify burnout risk? (Consider privacy implications; may belong in separate admin view)

## Related Commands

**Primary Commands:**
- `get_task_queue` (Task Queue Tools) - Get queue summary with status counts
- `list_tasks` (Task Queue Tools) - List all tasks in queue with filtering
- `get_task_queue_feed` (Task Queue Tools) - Get activity feed for queue

**Supporting Commands:**
- `list_task_queues` (Task Queue Tools) - List all queues (for multi-queue dashboard)
- `get_task` (Task Queue Tools) - Get detailed task info when drilling down
- `get_task_feed` (Task Queue Tools) - Get activity feed for specific task
