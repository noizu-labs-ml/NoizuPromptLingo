# User Story: Assign Tasks to Specific Agents

**ID**: US-032
**Persona**: P-004 (Project Manager)
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T10:20:00Z

## Story

As a **project manager**,
I want to **assign tasks to specific agents or agent types**,
So that **work is routed to the most capable agent for each task**.

## Acceptance Criteria

- [ ] **Direct assignment**: Can assign task to specific agent using `agent_id` parameter
- [ ] **Pool assignment**: Can assign task to agent type/pool (e.g., `"tdd-coder"`, `"tdd-tester"`, `"tdd-debugger"`) for auto-routing
- [ ] **Workload awareness**: Assignment UI/API indicates current agent workload before assignment
- [ ] **Reassignment**: Can reassign task using `update_task` with new `assigned_to` value
- [ ] **Assignment history**: Task activity feed shows all assignment changes with timestamp and initiator
- [ ] **Notification**: Agent receives notification via notification system (US-022) on new assignment
- [ ] **Response format**: Returns `task_id`, `assigned_to`, and `agent_type` on successful assignment
- [ ] **Error handling**: Returns clear error if agent ID invalid or agent type not supported
- [ ] **Verification**: Assignment visible via `get_task` showing current `assigned_to` and assignment history
- [ ] **Supported agent types**: System recognizes agent pools: `tdd-coder`, `tdd-tester`, `tdd-debugger`, `prd-editor`, `idea-to-spec`

## Notes

- Assignment can occur at task creation (`create_task` with `assigned_to`) or post-creation (`update_task`)
- Agent types correspond to TDD workflow agents: `idea-to-spec`, `prd-editor`, `tdd-tester`, `tdd-coder`, `tdd-debugger`
- Pool assignment (e.g., `assigned_to: "tdd-coder"`) routes to next available agent of that type
- Direct assignment (e.g., `assigned_to: "agent-123"`) assigns to specific agent instance
- Reassignment automatically notifies both old and new assignees
- Workload metric considers: current in-progress tasks, task complexity, agent status
- Escalation path: If no agent available in pool after timeout, escalate to project manager

## Dependencies

- Task Queue system (US-016: Create Task)
- Notifications (US-022: Receive Notifications)
- Agent Orchestration system (see `docs/arch/agent-orchestration.summary.md`)
- Agent Work Logs (US-031: View Agent Work Logs)

## Related Commands

- `create_task` - Create task with initial `assigned_to` parameter
- `update_task` - Reassign task by updating `assigned_to` field
- `get_task` - View current assignment and assignment history
- `list_tasks` - Filter tasks by `assigned_to` (agent ID or type)
- `view_agent_status` - Check agent workload before assignment
- `get_notifications` - Agent retrieves assignment notifications

## Open Questions

- [ ] Should agents be able to decline/negotiate assignments?
- [ ] How to handle assignment when agent is mid-task? (Queue vs. interrupt)
- [ ] Should there be assignment priority/urgency flag for routing?
- [ ] Should assignment include estimated time/complexity for workload calculation?

## Example Request: Assign to Agent Pool

```json
{
  "task_id": 42,
  "assigned_to": "tdd-coder",
  "agent_type": "pool",
  "priority": 2
}
```

## Example Response: Pool Assignment

```json
{
  "status": "ok",
  "result": {
    "task_id": 42,
    "assigned_to": "tdd-coder",
    "agent_type": "pool",
    "routed_to": "agent-tdd-coder-003",
    "workload": {
      "current_tasks": 2,
      "estimated_capacity": 5
    }
  }
}
```

## Example Request: Direct Agent Assignment

```json
{
  "task_id": 43,
  "assigned_to": "agent-tdd-tester-001",
  "agent_type": "direct"
}
```

## Example Response: Direct Assignment

```json
{
  "status": "ok",
  "result": {
    "task_id": 43,
    "assigned_to": "agent-tdd-tester-001",
    "agent_type": "direct",
    "notification_sent": true
  }
}
```
