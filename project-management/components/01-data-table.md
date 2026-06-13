# Data Table

| Field | Value |
|-------|-------|
| **ID** | `data-table` |
| **Category** | Tables & Lists |
| **Used In** | 01-Script List, 04-Prompt Library, 06-Agent List, 08-Run List, 11-Rubric List, 13-Persona List, 16-Review Queue, 18-Dataset List, 19-Dataset Detail, 20-Flagged Captures Library, 22-OTel Span Search, 25-Schedule List, 32-Auto-Flag Rules, 37-API Token Management |

## Description

Sortable, filterable table with rows representing domain entities. Supports column sorting, row click navigation, row-level actions, pagination, and empty states. The foundational listing component used across nearly every primary screen.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Fewer columns, used in side panels or embedded contexts (e.g., entry table in Dataset Detail) |
| **Expanded** | Full column set with filters above, pagination below — the standard list page layout |

## Props / Configuration

- `columns` — Column definitions (key, label, sortable, width)
- `data` — Row data array
- `sortColumn` / `sortDirection` — Current sort state
- `onRowClick` — Navigation handler when row is clicked
- `rowActions` — Per-row action buttons/menu (edit, delete, fork, archive, etc.)
- `emptyState` — Content to show when no rows match
- `pagination` — Page size, current page, total count
- `selectable` — Enable multi-select checkboxes for bulk actions

## Interactions

- Click column header to sort ascending/descending
- Click row to navigate to detail view
- Hover row to reveal row actions
- Select multiple rows for bulk operations
- Infinite scroll or page navigation at bottom
