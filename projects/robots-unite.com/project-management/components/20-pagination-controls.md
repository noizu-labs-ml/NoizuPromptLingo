# Pagination Controls

| Field | Value |
|-------|-------|
| **ID** | `pagination-controls` |
| **Category** | Navigation & Layout |
| **Used In** | 10-Execution Log Viewer, 20-Operator Profile Page, 25-Organization Settings, 30-Billing & Payments |

## Description

Previous/Next and numbered page navigation for paginated data sets, with optional jump-to-page input and line-range display for log contexts.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Compact Previous/Next only for minimal footprint |
| **Expanded** | Numbered page buttons with ellipsis, jump-to input, and item count summary |

## Props / Configuration

- `currentPage` — Currently active page number (1-indexed)
- `totalPages` — Total number of pages
- `totalItems` — Total item count for display in summary text
- `pageSize` — Number of items per page
- `onPageChange` — Callback with new page number
- `mode` — `"simple"` (prev/next only) or `"full"` (numbered + jump-to)
- `showLineRange` — Whether to display the current line range (e.g., "Lines 200–399")

## Interactions

- Click numbered page buttons to jump to that page
- Previous/Next buttons navigate one page at a time
- Jump-to input accepts a page number and navigates on Enter
- Keyboard arrow navigation when the control is focused
