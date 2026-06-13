# Gantt / Timeline View

| Field | Value |
|-------|-------|
| **ID** | `gantt-view` |
| **Type** | Primary |
| **Category** | Project Management |
| **User Stories** | US-029 |

## Description

Waterfall/Gantt chart with milestone markers, dependency connectors, critical path highlighting, and drag-to-adjust dates. Primarily used for client-facing timeline communication and deadline tracking.

## Key Components

- **Timeline bars** — Horizontal bars showing item/epic duration
- **Milestone diamonds** — Key deliverable markers on timeline
- **Dependency lines** — Arrows connecting dependent items
- **Critical path highlight** — Longest dependency chain highlighted in red
- **Drag-adjust dates** — Drag bar edges to change start/end dates
- **Export PDF action** — Generate shareable PDF of the timeline

## Interactions

- Drag bar edges to adjust dates (with dependency validation)
- Click milestone to view detail
- Zoom in/out on timeline (day/week/month granularity)
- Critical path auto-calculated and highlighted
- Export for client communication

## Navigation

- Accessible from: Project nav, Portfolio Dashboard
- Links to: Item detail, Milestone detail, Client Report Generator
