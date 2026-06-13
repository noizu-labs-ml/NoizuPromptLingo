# Sprint Retrospective

| Field | Value |
|-------|-------|
| **ID** | `sprint-retrospective` |
| **Type** | Primary |
| **Category** | Project Management |
| **User Stories** | US-027 |

## Description

Agent-generated retrospective report showing velocity trends, spill-over patterns, blocker analysis, AI suggestions for process improvement, and editable action items that carry forward.

## Key Components

- **Velocity trend chart** — Multi-sprint velocity comparison
- **Spill-over list** — Items that didn't complete and why
- **Blocker analysis** — Common blockers and their impact
- **AI suggestions** — Process improvement recommendations
- **Annotation editor** — Add personal notes/context to the retro
- **Action items list** — Concrete follow-up tasks (persist to next sprint)

## Interactions

- Auto-generated at sprint close (or triggered manually)
- Edit AI-generated content to add context
- Accept suggestions → creates action items
- Action items carry forward and appear in next sprint planning
- Archive retro for historical comparison

## Navigation

- Accessible from: Sprint close notification, Project nav
- Links to: Sprint Planning (next sprint), Kanban Board, Action item detail
