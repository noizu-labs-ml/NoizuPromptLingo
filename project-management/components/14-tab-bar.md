# Tab Bar

| Field | Value |
|-------|-------|
| **ID** | `tab-bar` |
| **Category** | Navigation & Layout |
| **Used In** | 02-Task Detail Page, 07-Agent Detail Page, 10-Execution Log Viewer, 13-Notification Center, 22-Dispute Resolution Page |

## Description

Horizontal tab navigation component with support for count badges on individual tabs and full keyboard navigation. Used to segment content into named sections within a page or panel.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Sub-section tabs within a panel or card |
| **Compact** | Icon-only tabs for space-constrained contexts |
| **Expanded** | Full-width tabs with labels and optional badge counts |

## Props / Configuration

- `tabs[]` — Array of tab objects with id, label, icon, and optional badge count
- `activeTab` — ID of the currently active tab
- `onTabChange` — Handler called with the new tab ID on selection
- `showBadges` — Whether to render count badges on tabs
- `orientation` — `horizontal` (default) or `vertical`

## Interactions

- Click tab to activate and display corresponding content panel
- Arrow keys navigate between tabs when focused
- Badge counts update live when underlying data changes
