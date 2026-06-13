# Bulk Action Bar

| Field | Value |
|-------|-------|
| **ID** | `bulk-action-bar` |
| **Category** | Navigation & Layout |
| **Used In** | 08-Run List, 16-Review Queue, 20-Flagged Captures Library |

## Description

Contextual action bar that appears when multiple items are selected in a table. Shows selection count and available bulk actions (approve all, dismiss all, tag all, promote all, compare). Disappears when selection is cleared.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Sticky bar above or below the table, visible only when items are selected |

## Props / Configuration

- `selectedCount` — Number of selected items
- `actions` — Available bulk actions with labels and callbacks
- `onClearSelection` — Callback to deselect all

## Interactions

- Appears when 1+ items are selected via checkboxes
- Click action button to apply to all selected items
- Click "Clear" to deselect all and hide bar
- Selection count updates dynamically
