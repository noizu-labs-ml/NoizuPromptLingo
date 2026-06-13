# Visual Flow Editor

| Field | Value |
|-------|-------|
| **ID** | `visual-flow-editor` |
| **Category** | Domain-Specific |
| **Used In** | 60-Agent Collaboration Protocol |

## Description

Drag-drop node/edge editor for building agent collaboration protocols, workflows, or dependency graphs

## Size Variants

| Variant | Description |
|---------|-------------|
| **Full_Page** | Full canvas editor with node palette and properties panel |

## Props / Configuration

- `nodes` — array of node definitions
- `edges` — array of connections
- `nodeTypes` — available node palette
- `onSave` — callback
- `executionTrace` — optional overlay

## Interactions

- drag nodes from palette
- connect nodes with edges
- configure per-node properties
- view execution traces overlaid
- test with simulated events
