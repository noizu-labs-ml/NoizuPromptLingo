# Review: Ask a Question on a Task

- **Story**: `project-management/user-stories/US-026-ask-question-on-task.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The task-message/discussion path is a stub. `add_task_message` is listed in the static stub catalog (`src/npl_mcp/meta_tools/stub_catalog.py:673`) and returns a stub status via ToolCall (`src/npl_mcp/launcher.py:434-437`) — no message is persisted. The read side exists: `task_feed` (`src/npl_mcp/tasks/tasks.py:465`) reads from the `npl_task_events` table, **but nothing in the codebase ever inserts into `npl_task_events`** — `task_update_status` and all other task functions record no events — so the feed is permanently empty. Mentions/notification generation on task questions (which the story implies, mirroring chat notifications) has no task-side dispatch; notifications exist only for chat and tickets in the Elixir backend (`backend/lib/noizu_prompt_lingua/domains/notifications/dispatch.ex:65,248`). Confidence: high (write path verified absent).

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Agent can post a question/message on a task | Not Met | `add_task_message` stub (`stub_catalog.py:673`; `launcher.py:434-437`) |
| Question visible to assignees/watchers in a task feed | Not Met | `task_feed` reads `npl_task_events` (`tasks.py:465`) but no code inserts events — feed is always empty |
| Mentioned watchers are notified | Not Met | no task-message notification dispatch (only chat `dispatch.ex:65`, ticket_assigned `:248`) |
| Q&A thread persisted with task context | Not Met | no persistence layer for task messages |

## Gaps / Risks

- Fix is two-part: implement `add_task_message` (persist to `npl_task_events`) and emit task events from status changes so the existing feed becomes meaningful.
- Cross-codebase risk: task events are Python-side while notifications are Elixir-side; decide whether task-message notifications dispatch via the Elixir Notifications domain or a Python write path.

## BDD Scenario

```gherkin
Feature: Ask a question on a task
  Scenario: Agent asks assignee a clarifying question
    Given an assigned task with watchers
    When the agent calls add_task_message with a question
    Then a stub status is returned and nothing is stored
    And the task feed for the task remains empty
    And no watcher is notified
```
