# User Story: Add Task Queue Test Suite (0% → 80%)

**ID**: US-0110
**Persona**: P-005 (Dave, DevOps Engineer)
**Priority**: Critical
**Status**: Draft
**PRD Group**: test_coverage
**Created**: 2026-02-02

## As a...
DevOps engineer improving test coverage for task orchestration

## I want to...
Implement comprehensive tests for 13 task queue tools to reach 80% coverage

## So that...
Task management system is reliable for agent work orchestration and user task tracking

## Acceptance Criteria
- [ ] All 13 task tools have 80%+ test coverage
- [ ] Workflow states tested (pending → in_progress → review → done/blocked)
- [ ] Priority and complexity scoring tested with multiple scenarios
- [ ] Artifact linking to tasks tested (create, update, retrieve)
- [ ] Activity feeds and comments tested (creation, filtering, ordering)
- [ ] Concurrent task updates handled and tested
- [ ] Test suite passes in CI/CD pipeline with coverage report validation

## Implementation Notes

**Reference**: `.tmp/mcp-server/categories/06-task-queue.md`

**Tools to Test**:
1. `create_task_queue` - Create queue container with configuration
2. `create_task` - Add task with initial state
3. `get_task` - Retrieve task with full metadata
4. `list_tasks` - Query with filters (status, priority, assignee, complexity)
5. `update_task_status` - Transition states (workflow validation)
6. `assign_task` - Assign to agent or user with notification
7. `add_task_artifact` - Link versioned artifact to task
8. `get_task_artifact` - Retrieve linked artifact
9. `create_task_activity` - Log activity events
10. `add_task_comment` - Add discussion comments
11. `set_task_priority` - Update priority level (P0-P5)
12. `set_task_complexity` - Score effort (1-10, affects estimation)
13. `dismiss_task` - Archive/close task with reason

**Database Tables**:
- task_queues (id, name, owner, status, config, created_at, updated_at)
- tasks (id, queue_id, title, description, status, assigned_to, priority, complexity, created_at, updated_at)
- task_events (id, task_id, type, user_id, content, created_at)
- task_artifacts (id, task_id, artifact_id, version, linked_at)

**Test Categories**:
- Unit: Tool validation, output formatting, scoring algorithms
- Integration: Database CRUD operations, schema relationships
- Workflow: State transitions, validation rules, business logic
- Artifact linking: Create, update, retrieve, cascade deletion
- Activity: Event logging, comment threads, filtering
- Concurrent: Simultaneous updates, race conditions, data consistency
- Performance: Baseline times for queue operations, sorting, filtering

**Current Coverage**: 0% (critical gap)

**Test Framework**: pytest (Python) + coverage.py

**Target Coverage**: 80%+

**Critical Test Scenarios**:
- Workflow validation: Cannot transition pending → done (must go through in_progress)
- Priority levels: Verify sorting and urgency calculations
- Complexity scoring: Test effort estimation impact
- Artifact versioning: Link specific revisions, not just latest
- Concurrent assignment: Handle task claimed by multiple agents
- Activity audit: Complete event trail for regulatory/debugging

## Related Stories
- US-014 (Pick Task from Queue)
- US-015 (View Task Progress)
- US-016 (Create Task)
- US-017 (Link Artifact to Task)
- US-018 (Update Task Status)
- US-026 (Ask Question on Task)
- US-030 (Assign Task Complexity)
- US-032 (Assign Tasks to Agents)
- US-033 (Monitor Sprint Progress)
- US-048 (Real-time Agent Workflow Failure Diagnostics)
- US-051 (Worklog Error Propagation Protocol)
- US-054 (Test Execution Error Detail Capture)
- US-093 (Validate Task Queue Implementation)

## Notes
Task queue is critical for agent orchestration and user work management. Zero test coverage is blocker for all downstream features. Complex workflow state machine requires comprehensive testing of edge cases. Artifact linking particularly important for maintaining context through task lifecycle. Test implementation unblocks US-093 validation and enables production deployment.
