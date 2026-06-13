# File Tree

| Field | Value |
|-------|-------|
| **ID** | `file-tree` |
| **Category** | Navigation & Layout |
| **Used In** | 23-Scaffold Generation, 24-Agent Development, 25-Agent Dashboard |

## Description

Hierarchical directory/file navigator with expand/collapse, change indicators (A/M/D in green/yellow/red), and click-to-open behavior. Used in scaffold preview, code editor, and agent dashboard.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Sidebar panel (fixed width, scrollable) |
| **Expanded** | Full panel with file metadata (size, last modified) |

## Props / Configuration

- `tree` — Nested file/directory structure
- `changeIndicators` — Map of path → A|M|D
- `selectedPath` — Currently selected file
- `readOnly` — Boolean
- `onSelect` — Callback when file clicked

## Interactions

- Click directory → expand/collapse
- Click file → select (triggers onSelect callback)
- Change indicators (A=green, M=yellow, D=red) show git-like status
- Context menu on right-click (when not readOnly)
