# Data Table

| Field | Value |
|-------|-------|
| **ID** | `data-table` |
| **Category** | Tables & Lists |
| **Used In** | 11-Category Leaderboard, 19-Tournament Results Page, 25-Organization Settings, 29-Security & API Keys, 30-Billing & Payments, 33-Admin Moderation Panel |

## Description

Sortable, filterable table component with row-level actions, status badge cells, pagination, and optional bulk selection. Serves as the primary data grid across administrative, financial, and leaderboard contexts.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Compact settings-style list with minimal column count and no pagination |
| **Expanded** | Full-page sortable grid with column headers, filters, pagination, and row actions |

## Props / Configuration

- `columns` — array of column definition objects (`key`, `label`, `sortable`, `width`, `renderCell`)
- `rows` — array of row data objects
- `sortable` — boolean enabling column header sort controls
- `filterable` — boolean enabling filter controls above the table
- `onSort` — callback invoked with column key and direction on sort change
- `onFilter` — callback invoked with filter state on filter change
- `rowActions` — array of action definition objects rendered per row (label, icon, onClick)
- `onRowClick` — callback invoked with the row data when a row is clicked
- `pagination` — object with `page`, `pageSize`, `total`, and `onPageChange`

## Interactions

- Click column header to sort ascending; click again to sort descending
- Inline row action buttons trigger the corresponding `rowActions` callback
- Clicking a row calls `onRowClick` with the row data
- Filter controls update displayed rows by calling `onFilter`
- Bulk select checkbox in header toggles all visible rows; per-row checkboxes for individual selection
- Pagination controls navigate pages via `pagination.onPageChange`
