# Navigation Flow Diagram

| Field | Value |
|-------|-------|
| **ID** | `navigation-flow-diagram` |
| **Type** | Primary |
| **Category** | Draft Phase |
| **User Stories** | INK-029 |

## Description

Interactive node graph showing screen-to-screen navigation relationships. Highlights entry/exit points and flags orphaned screens with no connections.

## Key Components

- **Node Graph** — Interactive diagram with screens as nodes and transitions as labeled edges (INK-029)
- **Entry/Exit Markers** — Visual indicators for app entry and exit points (INK-029)
- **Orphan Warnings** — Badge on unconnected screens (INK-029)
- **Transition Labels** — Edge labels describing navigation triggers (INK-029)

## Interactions

- Nodes are clickable → opens corresponding wireframe
- Pan and zoom on the canvas
- Orphan warnings highlight disconnected screens
- Drag nodes to rearrange layout

## Navigation

- Accessible from: Wireframe Gallery toolbar
- Links to: Wireframe Editor (click node)
