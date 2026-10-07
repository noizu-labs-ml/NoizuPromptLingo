# Review: MCP Task Queue Tools

- **Story**: `project-management/user-stories/US-116-mcp-task-queue-tools.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The Python server implements most of the surface in `src/npl_mcp/tasks/tasks.py` + launcher tools (Tasks.Create/CreateInQueue/Get/List/UpdateStatus/AssignComplexity/AddArtifact/ListArtifacts, TaskQueue.Create/Get/List/Feed): queue-scoped creation with priority and complexity (tasks.py:322-370), status workflow over `pending|in_progress|blocked|review|done` (tasks.py:22), artifact/branch linking (tasks.py:401-462), and queue status counts as basic metrics (tasks.py:278-288). Two structural holes: there is no pick/claim operation anywhere (no `pick_task`/claim function in either codebase), and `npl_task_events` has no writer in `src/` (grep finds only SELECTs in `task_feed`/`queue_feed`, tasks.py:465-553), so both feed tools read a table that nothing populates. Questions-on-tasks are not implemented in Python but the Elixir backend (noted: Elixir backend at /Users/keithbrings/Work/Space/Noizu/projects/NoizuPromptLingo/backend) covers the domain with its Tickets system — `Ticket.Comment` (domains/tickets/tools/ticket_comment.ex), queue tools with `status_counts` (queue_get.ex:32), `Ticket.Attach` for artifact linking, and `Ticket.Update` for workflow — though it likewise has no claim/pick operation.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Create tasks with priority and complexity scoring | Met | `task_create_in_queue(queue_id, ..., priority, complexity, complexity_notes)` src/npl_mcp/tasks/tasks.py:322-370; `task_assign_complexity` tasks.py:373-398; Elixir backend `Ticket.Create` |
| Pick up tasks from queue | Not Met | No pick/claim/assign-to-self operation in `src/npl_mcp/tasks/tasks.py` or in the Elixir backend `domains/tickets/tools/` (grep for pick/claim finds nothing); callers can only assign via create/update fields |
| Update task status through workflow states | Met | `task_update_status` with VALID_STATUSES validation + notes append, tasks.py:166-219; Elixir backend `Ticket.Update` |
| Link artifacts to tasks | Met | `task_add_artifact` (artifact or git_branch) tasks.py:401-432 + `task_list_artifacts` tasks.py:435-462; Elixir backend `Ticket.Attach` ("Attach an artifact, URL, or git branch to a ticket", ticket_attach.ex) |
| Ask questions on tasks | Partially Met | Python has no question/comment capability; Met on the Elixir backend via `Ticket.Comment` (domains/tickets/tools/ticket_comment.ex) — no dedicated Q&A semantics (e.g., open/resolved questions) in either |
| View queue progress metrics | Partially Met | `task_queue_get` returns `task_counts` grouped by status (tasks.py:278-288); Elixir `Queue.Get` returns `status_counts` (queue_get.ex:32). No throughput/aging/progress-over-time metrics; task/queue feeds return nothing because `npl_task_events` has no writer |

## Gaps / Risks

- No task claiming: two agents polling the same queue have no atomic way to take ownership of a task — assignment is a manual UPDATE, so races and double-work are possible.
- Feeds are dead code on the Python side: `npl_task_events` is never inserted into, so `Tasks.Feed`/`TaskQueue.Feed` always return empty lists. Status transitions in `task_update_status` do not emit events either.
- No authz scoping on Python task/queue access (any integer id is addressable); Elixir tickets are org/project-scoped.
- `task_add_artifact` does not verify the task or artifact id exists (unchecked INSERT).
- Complexity is free-form int with no scoring rubric or validation range.

## BDD Scenario

```gherkin
Feature: Manage task queues with complexity scoring and artifact links

  Scenario: Create a queue, add a scored task, work it to done (Python surface)
    Given the MCP server is connected
    When the agent calls ToolCall("TaskQueue.Create", {"name": "release-42"})
    Then a queue row is created
    When the agent calls ToolCall("Tasks.CreateInQueue", {"queue_id": <qid>, "title": "bump helm tag", "priority": 2, "complexity": 5})
    Then the task is stored in the queue with priority 2 and complexity 5
    When the agent calls ToolCall("Tasks.UpdateStatus", {"task_id": <tid>, "status": "in_progress", "notes": "started"})
    Then the task status becomes "in_progress" and the note is appended
    When the agent calls ToolCall("Tasks.AddArtifact", {"task_id": <tid>, "artifact_type": "git_branch", "git_branch": "release/42"})
    Then the branch link is stored and visible via Tasks.ListArtifacts
    When the agent calls ToolCall("TaskQueue.Get", {"queue_id": <qid>})
    Then task_counts by status are returned

  Scenario: Ask a question on a ticket (Elixir backend surface)
    Given a ticket exists on the Elixir backend
    When an agent calls Ticket.Comment with a question body
    Then the comment is stored on the ticket and visible to watchers
    # Missing today: no operation atomically claims ("picks") a queued task.
```
