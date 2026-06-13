# Node Popover

| Field | Value |
|-------|-------|
| **ID** | `node-popover` |
| **Category** | Graph |
| **Used In** | S-18 Knowledge Graph View |

## Description

Click-triggered popover anchored to a knowledge graph node. Surfaces the entry's title, type icon, short summary, relationship count, and two primary actions (open full entry, quick-edit). Dismissed by clicking outside or pressing Escape.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Title, type badge, relationship count, and action buttons only — used on dense graphs with many visible nodes |
| **Expanded** | Adds 2–3 sentence summary excerpt and a mini relationship list (up to 5 edges) |

## Props / Configuration

- `entryId` — ID of the canon entry the node represents
- `entryTitle` — Display title rendered in popover header
- `entryType` — Entry type string used to render the type icon and badge
- `summary` — Short summary text (≤280 chars); omitted in compact variant
- `relationshipCount` — Total number of edges connected to this node
- `position` — `{x, y}` pixel coordinates for popover placement relative to the graph canvas
- `variant` — `"compact"` | `"expanded"` (default: `"expanded"`)
- `onOpen` — Callback invoked when user clicks Open action
- `onEdit` — Callback invoked when user clicks Edit action
- `onDismiss` — Callback invoked on outside click or Escape

## Interactions

- Appears on single-click of a graph node; hover shows only a lightweight tooltip (entry title only)
- Double-click on a node bypasses the popover and navigates directly to the full entry
- Open button navigates to the Entry Detail screen (S-06)
- Edit button opens the entry in the editor panel or Entry Edit screen (S-07)
- Relationship count is a link; clicking it filters the graph to show only edges connected to this node
- Popover repositions automatically if it would overflow the visible canvas area
- Pressing Escape or clicking the graph background dismisses the popover
