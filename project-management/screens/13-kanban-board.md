# Kanban Board

| Field | Value |
|-------|-------|
| **ID** | `kanban-board` |
| **Type** | Primary |
| **Category** | Project Management |
| **User Stories** | US-022, US-024, US-042 |

## Description

Column-based board view with drag-drop state transitions. Shows WIP limits, assignee badges (human or agent), and supports deploy-aware auto-transitions (items move when their PR merges or deploy completes).

## Key Components

- **Columns by state** — Configurable columns per project methodology (Backlog, In Progress, Review, Done, etc.)
- **Item cards** — Title, assignee, priority, labels, due date
- **Drag-drop** — Move cards between columns to change state
- **WIP limit indicators** — Column header shows current/max, red when exceeded
- **Agent status badges** — Visual indicator when an AI agent is assigned/working
- **Filter bar** — Filter by assignee, label, priority, sprint
- **Keyboard nav** — Arrow keys to navigate, Enter to open
- **Swimlane toggle** — Group cards by assignee, priority, or epic

## Interactions

- Drag cards between columns to transition state
- Click card to open detail view
- WIP limit violation shows warning (not hard block by default)
- Deploy events auto-transition cards (configurable)
- Quick-add cards at top of any column
- Bulk actions via multi-select

## Navigation

- Accessible from: Project nav, Portfolio Dashboard
- Links to: Item detail, Sprint Planning, Gantt View
