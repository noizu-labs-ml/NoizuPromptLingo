# User Story: Update Task Status

**ID**: US-018
**Persona**: P-001 (AI Agent)
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As an **AI agent**,
I want to **update task status as I progress through work**,
So that **team members can track progress in real-time**.

## Acceptance Criteria

- [ ] Can update status: pending -> in_progress -> completed
- [ ] Can set status to "deleted" to permanently remove task
- [ ] Status transitions are linear (no backwards movement)
- [ ] Invalid state transitions rejected (e.g., completed -> in_progress)
- [ ] When blocked, task remains "in_progress" with dependencies tracked via addBlockedBy
- [ ] Status change recorded with timestamp
- [ ] Must fetch latest task state before updating (staleness check)
- [ ] Can update task metadata along with status
- [ ] Can set up dependency relationships (blocks/blockedBy)
- [ ] Only mark "completed" when fully done (tests passing, all requirements met)

## Technical Details

### Valid Status Transitions

| From | To | Valid? |
|------|-----|--------|
| pending | in_progress | ✅ Yes |
| pending | completed | ✅ Yes (rare, for trivial tasks) |
| pending | deleted | ✅ Yes |
| in_progress | completed | ✅ Yes |
| in_progress | deleted | ✅ Yes |
| in_progress | pending | ❌ No (backwards) |
| completed | in_progress | ❌ No (backwards) |
| completed | pending | ❌ No (backwards) |
| completed | deleted | ✅ Yes |

### Blocking Mechanism

When a task is blocked:
1. Status remains "in_progress" (NOT a separate "blocked" status)
2. Use `addBlockedBy: ["task-id-1", "task-id-2"]` to track dependencies
3. Task becomes unblocked automatically when blocking tasks complete
4. Use TaskList to see blockedBy status for all tasks

### Completion Criteria by Task Type

| Task Type | Must Have Before Marking Completed |
|-----------|-----------------------------------|
| Implementation | Code written + all tests passing |
| Documentation | Written + reviewed + formatting validated |
| Bug fix | Fixed + edge cases tested + root cause documented |
| Refactoring | Old code removed + new code written + tests passing + performance verified |

## Notes

- Status flow is linear: pending -> in_progress -> completed
- No backwards transitions allowed (e.g., cannot move completed back to in_progress)
- "deleted" is a special status that permanently removes a task
- Blocking is NOT a status - blocked tasks remain "in_progress" with dependencies managed via addBlockedBy parameter
- Always use TaskGet before TaskUpdate to avoid stale data overwrites
- Tasks should only be marked "completed" when ALL criteria are met:
  - Code fully implemented
  - All tests passing
  - Documentation updated if needed
  - No unresolved errors or blockers

## Open Questions

- Should there be a separate "cancelled" status distinct from "deleted"?
- Should status transitions trigger notifications to watchers?
- Should there be an audit log of all status changes?
- How to handle concurrent updates beyond staleness warnings?

## Related Commands

- `TaskUpdate` (Task Tracking Tools) - Update task status, details, or dependencies
- `TaskGet` (Task Tracking Tools) - Fetch latest task state before updating
- `TaskList` (Task Tracking Tools) - View all tasks and check for newly unblocked work
