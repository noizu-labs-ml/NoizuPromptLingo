# Data Table

| Field | Value |
|-------|-------|
| **ID** | `data-table` |
| **Category** | Data Display / Admin |
| **Used In** | S24 Admin User List, S22 API Keys, S23 Billing Records, S25 Policy Table |

## Description

Sortable, filterable table for displaying structured datasets. Composed of a column header row with sort controls, data rows with optional row-level actions (edit, delete, view), a filter/search bar above the table, and pagination controls below. Supports row selection checkboxes for bulk actions. Used extensively in admin screens for user management, billing, API key management, and moderation policy lists.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Reduced row padding and smaller font; used when table must share screen with other panels |
| **Expanded** | Standard row height with full action menus; default for full-width admin pages |

## Props / Configuration

- `columns` — Array of `{ key, label, sortable, width, render }`; `render` is an optional cell renderer function
- `rows` — Array of data objects; each keyed by column keys
- `sortBy` — `{ key, direction: 'asc' | 'desc' }` controlled sort state
- `onSort` — Callback `(key, direction) => void`
- `selectable` — Boolean; enables checkbox column and bulk action toolbar
- `onSelectionChange` — Callback `(selectedIds: string[]) => void`
- `rowActions` — Array of `{ label, icon, onClick, destructive }`; rendered in a per-row actions menu
- `bulkActions` — Array of `{ label, onClick }`; rendered in bulk action toolbar when rows are selected
- `filterComponent` — Optional React node rendered above the table (search input, dropdowns)
- `pagination` — `{ page, pageSize, total, onChange }`; drives pagination controls
- `loading` — Boolean; replaces body with skeleton rows
- `emptyState` — React node; rendered when `rows` is empty

## Interactions

- Clicking a sortable column header cycles: unsorted → ascending → descending → unsorted
- Row checkbox selects that row; header checkbox selects/deselects all visible rows
- Row actions menu opens on the actions button (kebab); destructive actions show a confirmation dialog
- Bulk action toolbar appears at the top of the table when one or more rows are selected
- Pagination controls: prev/next buttons + page number input + page size selector
- Table is horizontally scrollable on small viewports; column headers remain sticky
