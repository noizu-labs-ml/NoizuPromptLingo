# Goal Alignment Visualization

| Field | Value |
|-------|-------|
| **ID** | `goal-alignment-viz` |
| **Type** | Primary |
| **Category** | Goals & OKRs |
| **User Stories** | US-072 |

## Description

Interactive tree/graph visualization of objectives, key results, and linked work items with orphan detection (work not linked to any goal), status coloring, and click-to-navigate.

## Key Components

- **Interactive graph** — Zoomable tree/network graph of goals and work
- **Color-coded nodes** — Green (on-track), yellow (at-risk), red (off-track)
- **Orphan detection highlights** — Work items not linked to any OKR
- **Filter by team/period** — Scope visualization to specific teams or time periods
- **Click to navigate** — Click any node to open its detail view
- **Hover tooltip** — Quick stats on hover without navigating away

## Interactions

- Zoom/pan on the graph
- Click nodes to navigate to detail views
- Hover for quick summary tooltip
- Filter to focus on specific teams
- Orphan items highlighted for attention
- Toggle between tree and radial layouts

## Navigation

- Accessible from: Goals nav, OKR Hierarchy
- Links to: OKR Hierarchy, Item detail, Orphan work items
