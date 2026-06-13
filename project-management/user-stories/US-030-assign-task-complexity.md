# User Story: Assign Task Complexity

**ID**: US-030
**Persona**: P-001 (AI Agent)
**Priority**: Low
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As an **AI agent**,
I want to **assign complexity scores to tasks**,
So that **the team can estimate effort and plan work accordingly**.

## Acceptance Criteria

- [ ] Can assign numeric complexity score (1-5 scale)
- [ ] Complexity score automatically mapped to standard labels
- [ ] Can include optional notes explaining complexity reasoning
- [ ] Persona identifier recorded with complexity assignment
- [ ] Complexity score and label returned in task details via `get_task`
- [ ] Complexity assignment recorded in task feed as event with timestamp
- [ ] Invalid complexity scores (< 1 or > 5) are rejected with error
- [ ] Reassigning complexity overwrites previous value (not append)
- [ ] Task must exist before complexity can be assigned

## Technical Details

### Complexity Scale Definition

| Score | Label | Typical Characteristics |
|-------|-------|------------------------|
| 1 | Trivial | < 15 min, no dependencies, straightforward change |
| 2 | Easy | 15-60 min, minimal dependencies, well-understood pattern |
| 3 | Moderate | 1-4 hours, some dependencies, requires planning |
| 4 | Hard | 4-8 hours, multiple dependencies, cross-cutting changes |
| 5 | Complex | > 8 hours, extensive dependencies, architectural impact |

### API Parameters

`assign_task_complexity` accepts:
- `task_id` (required): Task to assign complexity to
- `complexity` (required): Integer 1-5
- `notes` (optional): Explanation of reasoning
- `persona` (required): Identifier of who assigned complexity

### Response Format

```json
{
  "status": "ok",
  "result": {
    "task_id": 21,
    "complexity": 3,
    "complexity_label": "moderate"
  }
}
```

## Notes

- Helps with sprint planning and velocity tracking
- AI agents can auto-estimate based on task description and historical patterns
- Complexity is distinct from priority (high priority tasks may be low complexity)
- Reassessment is allowed as task understanding improves

## Dependencies

- Task must exist (US-016: Create Task)
- Task queue system operational

## Open Questions

- Should complexity affect priority automatically, or remain independent?
- How to validate AI-generated estimates against actual time spent?
- Should complexity history be tracked for better future estimates?
- Should there be complexity thresholds that trigger task split recommendations?

## Related Commands

- `assign_task_complexity` (Task Queue Tools) - Assign complexity score to a task
- `get_task` (Task Queue Tools) - Retrieve task details including complexity
- `get_task_feed` (Task Queue Tools) - View complexity assignment events
