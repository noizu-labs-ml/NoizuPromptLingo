# Filter Panel

| Field | Value |
|-------|-------|
| **ID** | `filter-panel` |
| **Category** | Navigation & Layout |
| **Used In** | S04 Canon List, S07 Global Search Results, S10 Consistency Dashboard, S09 Generation History |

## Description

Collapsible sidebar panel providing multi-dimensional filtering controls for list and grid views. Sections within the panel can be independently expanded or collapsed. Applied filters are reflected as removable chips in the parent view's filter summary bar.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full sidebar visible alongside content; sections open by default |
| **Compact** | Collapsed to a toggle button; expands as an overlay drawer on mobile |

## Props / Configuration

- `filters` — Current filter state object (`types`, `tags`, `dateRange`, `status`, `author`)
- `onChange` — Callback fired with the updated filter object on any change
- `availableTypes` — Array of entry type options with label and count
- `availableTags` — Array of tag options with label and count
- `availableStatuses` — Array of status options (e.g., `draft`, `canon`, `deprecated`)
- `collapsed` — Boolean controlling sidebar open/closed state
- `onToggleCollapse` — Callback to toggle the panel
- `showAuthorFilter` — Boolean; show collaborator author filter (only on shared universes)

## Interactions

- Type toggles are checkbox buttons; multiple selections narrow the result set with AND logic unless `orMode` is enabled
- Tag multi-select uses the `tag-selector` component internally with type-ahead search
- Date range picker opens a calendar popover for start/end selection
- Status filters are radio or multi-checkbox depending on context
- "Clear All" button resets all filters to their default (unfiltered) state
- Each active filter renders a removable chip in the parent's filter summary bar; clicking the chip removes that individual filter
- Filter counts next to each option update live as other filters change
