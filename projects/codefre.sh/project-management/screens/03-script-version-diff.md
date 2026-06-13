# Script Version Diff

| Field | Value |
|-------|-------|
| **ID** | `script-version-diff` |
| **Type** | Primary |
| **Category** | Script Authoring |
| **User Stories** | US-045 |

## Description

Side-by-side or inline diff view comparing two versions of the same script. Shows added/removed/modified nodes, edges, and expectations. Used when reviewing changes before publishing or understanding version history.

## Key Components

- **Version picker** — Two dropdowns for selecting left (older) and right (newer) versions
- **Diff summary** — Counts of added/removed/modified nodes and edges
- **Graph diff overlay** — Visual representation with color-coded additions (green) and removals (red)
- **Detail diff panel** — Per-node textual diff of prompt references, expectations, and config

## Interactions

- Select two versions to compare
- Toggle between graph-overlay view and textual diff
- Click any changed node to see detailed diff

## Navigation

- Accessible from: Graph Editor (version selector), Script List
- Links to: Graph Editor (click a version to open it)
