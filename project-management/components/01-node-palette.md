# Node Palette

| Field | Value |
|-------|-------|
| **ID** | `node-palette` |
| **Category** | Input & Forms |
| **Used In** | 01-Fighter Studio |

## Description

Searchable, filterable panel listing all available node types organized by category tabs (Perception/Decision/Action/Utility). Supports real-time search, tag-based filtering, pinned favorites, and recent nodes.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Collapsed sidebar showing icon-only node list |
| **Expanded** | Full sidebar with category tabs, search bar, and labeled node entries |

## Props / Configuration

- `categories` — Node category tabs (Perception/Decision/Action/Utility)
- `searchQuery` — Filter text for real-time search
- `pinnedNodes` — List of favorited nodes pinned to top
- `recentNodes` — Recently used nodes shown in a quick-access section

## Interactions

- Type to search in real-time across all node types
- Click category tabs to filter by node category
- Drag node onto canvas to instantiate
- Pin/unpin nodes to favorites
- Escape to clear search query
