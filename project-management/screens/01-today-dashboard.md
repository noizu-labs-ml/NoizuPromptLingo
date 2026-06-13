# Unified Today Dashboard

| Field | Value |
|-------|-------|
| **ID** | `today-dashboard` |
| **Type** | Primary |
| **Category** | Today & Daily Planning |
| **User Stories** | US-001, US-002, US-003, US-004, US-005, US-016 |

## Description

The anchor screen of the application. Combines personal items, team tasks, agent activity, ops alerts, and cross-project summaries into a single priority-sorted view. Serves as the default landing page after login.

## Key Components

- **Priority-sorted item list** — All today items ranked by urgency/importance with drag-drop reorder (US-003)
- **Agent activity panel** — Real-time feed of what AI agents are doing (US-002)
- **Domain filter toggle** — Switch between personal, work, all (US-016)
- **Cross-project group headers** — Items grouped by project with summary counts (US-004)
- **Personal + team unified stream** — Single stream merging personal and team items (US-005)
- **Deadline conflict warnings** — Visual indicators when items conflict or are overdue
- **Context badges** — Source indicators (inbox, sprint, habit, personal)
- **Keyboard navigation** — Full keyboard accessibility for power users

## Interactions

- Drag-drop to reorder priorities
- Click item to expand detail inline or navigate to full view
- Toggle domain filters without page reload
- Agent activity panel collapses/expands
- Items link to their source (project board, habit tracker, etc.)

## Navigation

- Accessible from: Main nav (home icon), app launch
- Links to: Item detail, Project board, Agent dashboard, Habit overview
