# Bulk Action Toolbar

| Field | Value |
|-------|-------|
| **ID** | `bulk-action-toolbar` |
| **Category** | Data Management |
| **Used In** | S-04 Canon List, S-13 Generation History, S-22 Admin User List |

## Description

Floating toolbar that appears at the bottom of the viewport whenever one or more list items are selected. Displays the selected item count and exposes batch actions applicable to the current screen context. Disappears when selection is cleared.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Icon-only action buttons with tooltips; used on narrow viewports or when action count exceeds 4 |
| **Expanded** | Labeled action buttons with icons; standard desktop presentation |

## Props / Configuration

- `selectedCount` — Number of currently selected items; displayed in the toolbar label
- `actions` — Array of action descriptors: `{ id, label, icon, variant, confirmRequired }`
  - `variant` — `"default"` | `"danger"` — danger actions render in red
  - `confirmRequired` — Boolean; if true a confirmation dialog is shown before executing
- `onAction` — Callback receiving `(actionId, selectedIds[])` when an action button is clicked
- `onClearSelection` — Callback invoked when user clicks the X to deselect all
- `context` — `"canon"` | `"generations"` | `"admin-users"` — determines which actions are available

## Interactions

- Toolbar slides up from the bottom of the screen with a 200ms ease-in animation when `selectedCount` becomes non-zero
- Slides back down and unmounts when selection is cleared
- Select All affordance in the list header drives `selectedCount`; toolbar X button triggers `onClearSelection`
- Danger-variant actions (Delete, Revoke) show a confirmation modal before proceeding; modal lists the count of affected items
- Export action triggers a download of selected items as JSON or CSV (format chosen in a small dropdown)
- Tag action opens an inline tag-selector popover to apply tags to all selected items simultaneously
- Run Check action enqueues a consistency check job for all selected canon entries
- Progress is tracked via a queue job; toolbar shows a spinner during bulk operation and a success/failure count on completion
