# Sprint Planning View

| Field | Value |
|-------|-------|
| **ID** | `sprint-planning` |
| **Type** | Primary |
| **Category** | Project Management |
| **User Stories** | US-023 |

## Description

AI-assisted sprint planning showing velocity analysis, AI-suggested items with rationale, capacity adjustment, and draft sprint plan editing. Agent analyzes backlog priority, team capacity, and historical velocity to propose a sprint.

## Key Components

- **Velocity chart** — Historical velocity (3-6 sprint rolling window)
- **AI-suggested items** — Ranked list of backlog items proposed for the sprint
- **Rationale per item** — Why AI suggests this item (priority, dependency, capacity fit)
- **Capacity adjuster** — Set team availability (PTO, holidays, part-time allocations)
- **Add/remove items** — Manual override to add/remove from proposed sprint
- **Finalize sprint action** — Commit the sprint plan and start the sprint
- **Risk flags** — Items flagged as high-risk or dependency-blocked

## Interactions

- Review AI suggestions and accept/reject individually
- Adjust capacity to see AI re-suggest
- Manually add items from backlog
- Reorder within sprint for priority sequencing
- Finalize locks the sprint and starts the clock

## Navigation

- Accessible from: Project nav (sprint section), Kanban Board header
- Links to: Kanban Board (active sprint), Backlog Grooming, Sprint Retro
