# Fork Graph

| Field | Value |
|-------|-------|
| **ID** | `fork-graph` |
| **Type** | Primary |
| **Category** | Resources |
| **User Stories** | US-029 |

## Description

Tree visualization showing the fork lineage of a resource. Displays original resource and all descendant forks with metadata. Supports lineage traversal up to the original source and down to all forks.

## Key Components

- **Tree Visualization** — Original + forks, max 50 nodes (US-029)
- **Node Metadata Popover** — Owner, version count, last updated on click (US-029)
- **Active/Inactive Distinction** — Inactive = no updates in 30 days (US-029)
- **Lineage Traversal** — Navigate up to source, down to descendants (US-029)
- **Loading Indicator** — For trees exceeding 50 nodes (US-029)
- **Private Fork Login Gate** — Prompt for inaccessible forks (US-029)

## Interactions

- Click node → metadata popover; traverse lineage up/down; zoom/pan tree

## Navigation

- Accessible from: Resource Detail (26)
- Links to: Resource Detail (26) for any fork in the tree
