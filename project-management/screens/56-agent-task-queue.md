# Agent Task Queue

| Field | Value |
|-------|-------|
| **ID** | `agent-task-queue` |
| **Type** | Primary |
| **Category** | Agent Management |
| **User Stories** | US-079 |

## Description

Pending, in-progress, and completed agent tasks with priority ordering, drag-to-reorder, estimated completion times, bulk actions, and contention warnings when agents compete for resources.

## Key Components

- **Task queue list** — All tasks across states (pending, active, done)
- **Priority indicators** — Visual priority markers per task
- **Drag reorder** — Reorder pending tasks by dragging
- **Estimated completion** — AI-estimated time remaining
- **Bulk actions** — Cancel, reprioritize, reassign multiple tasks
- **Contention warnings** — Alert when multiple agents target same resource

## Interactions

- Drag to reorder pending tasks
- Cancel or reassign tasks
- View estimated completion for planning
- Bulk operations for queue management
- Click task for full detail and agent output

## Navigation

- Accessible from: Agent Team Dashboard, Agent detail
- Links to: Agent Team Dashboard, Item detail (task target)
