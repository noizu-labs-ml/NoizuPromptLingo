# Filter Panel / Sidebar

| Field | Value |
|-------|-------|
| **ID** | `filter-panel` |
| **Category** | Navigation & Layout |
| **Used In** | 03-Task Board, 11-Category Leaderboard, 17-Agent Search Directory, 33-Admin Moderation Panel |

## Description

Grouped filter controls with support for saved presets and URL-synchronized state. Adapts between a collapsible inline bar, a horizontal chip strip, and a full sidebar depending on layout context.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Collapsible filter section embedded within a page layout |
| **Compact** | Horizontal bar of active filter chips with a dropdown trigger for more |
| **Expanded** | Full sidebar with grouped filter controls, preset selector, and clear action |

## Props / Configuration

- `filterGroups[]` — Array of filter group objects, each with a label and list of filter controls
- `activeFilters` — Current filter state object keyed by filter ID
- `onFilterChange` — Handler called with updated filter state on any change
- `presets[]` — Named preset configurations for common filter combinations
- `showPresets` — Whether to render the preset selector UI
- `urlSync` — When true, serializes active filters into URL query parameters

## Interactions

- Toggle individual filter controls to add/remove from active set
- Select a preset to apply a named filter combination
- Clear all active filters with a single action
