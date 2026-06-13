# Edge Label

| Field | Value |
|-------|-------|
| **ID** | `edge-label` |
| **Category** | Graph |
| **Used In** | S-18 Knowledge Graph View |

## Description

Relationship label rendered mid-edge on graph connections. Displays the relationship type string and a directional arrow indicating source-to-target orientation. Clickable to open an edge detail popover with full relationship metadata.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single-line label with type text and arrow glyph; scales with zoom level |
| **Compact** | Arrow glyph only when zoom < 50%; type text suppressed to reduce clutter |

## Props / Configuration

- `edgeId` — Unique ID of the relationship edge
- `label` — Relationship type string (e.g., "ally of", "created by", "located in")
- `direction` — `"forward"` | `"backward"` | `"bidirectional"` — controls arrow rendering
- `sourceNode` — ID of the source entry node
- `targetNode` — ID of the target entry node
- `zoomLevel` — Current graph zoom scalar; used to switch to compact variant below threshold
- `isSelected` — Boolean; highlights label when the edge or either adjacent node is selected
- `onClickLabel` — Callback invoked when user clicks the label; receives `edgeId`

## Interactions

- Clicking the label opens an edge detail popover showing source entry, target entry, relationship type, and description
- Edge detail popover includes an Edit Relationship button navigating to the relationship edit form
- Label text is truncated with ellipsis beyond 24 characters; full text shown in tooltip on hover
- When graph zoom drops below 50%, label collapses to arrow-only mode to prevent overlap
- Selected state (bold label, highlighted edge color) is triggered when either connected node is active
- Label is not draggable; it follows the edge path automatically as nodes are repositioned
