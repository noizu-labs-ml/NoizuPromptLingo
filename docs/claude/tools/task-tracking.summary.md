# Task Tracking Summary

| Tool | Purpose | Required Params | Key Optional |
|------|---------|-----------------|--------------|
| **TaskCreate** | Create structured task lists | `subject`, `description` | `activeForm` |
| **TaskUpdate** | Update task status/details | `taskId` | `status`, `addBlocks`, `addBlockedBy` |
| **TaskList** | View all tasks | none | — |
| **TaskGet** | Get specific task details | `taskId` | — |

**Status flow:** pending → in_progress → completed (or deleted)

**Key rules:**
- ONLY mark completed when FULLY done (code + tests passing)
- Keep `in_progress` if tests fail or blocked
- Use for complex work (3+ steps), not trivial tasks
- Set up dependencies with `addBlocks`/`addBlockedBy`
- Always provide `activeForm` (shown in spinner during work)

---

**For expanded view:** [task-tracking.md](task-tracking.md) — Completion criteria tables, dependency examples, staleness warnings, and when to use TaskGet before updates.