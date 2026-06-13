# Edge Inspector

| Field | Value |
|-------|-------|
| **ID** | `edge-inspector` |
| **Category** | Domain-Specific |
| **Used In** | 02-Graph Editor |

## Description

Panel for configuring a selected graph edge's match condition. Includes match method selection (regex, contains, semantic, always, custom), match configuration (pattern, threshold), label, and priority. Appears when an edge is clicked in the graph canvas.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Right-side panel or popover showing full edge configuration |

## Props / Configuration

- `edge` — The selected edge object
- `matchMethods` — Available match method options
- `onUpdate` — Callback when edge properties change
- `sourceNode` / `targetNode` — Context about connected nodes

## Interactions

- Select match method from dropdown
- Configure method-specific parameters (regex pattern, similarity threshold, etc.)
- Set edge label and priority
- Delete edge
