# Fork Graph Visualization

| Field | Value |
|-------|-------|
| **ID** | `fork-graph-visualization` |
| **Category** | Domain-Specific |
| **Used In** | 28-Fork Graph |

## Description

Tree/lineage diagram showing resource fork history. Displays original resource and descendant forks with metadata on click. Supports active/inactive visual distinction and lineage traversal.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** — Mini tree with key nodes |
| **Expanded** | Full interactive tree with zoom/pan |
| **Full Page** | Full-page tree with metadata panel |

## Props / Configuration

- `rootResourceId` — Original resource
- `maxNodes` — Display cap (default 50)
- `showInactive` — Toggle inactive fork display

## Interactions

- Click node → metadata popover; traverse up/down lineage
- Zoom/pan tree; private fork → login prompt
