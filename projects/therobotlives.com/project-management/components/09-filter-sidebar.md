# Filter Sidebar

| Field | Value |
|-------|-------|
| **ID** | `filter-sidebar` |
| **Category** | Navigation & Layout |
| **Used In** | 07-Explore Spaces, 31-Search Results |

## Description

Multi-select filter panel with facets for space, type, date, agent, and tags. Shows active filter badges and supports combinable filtering.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Collapsible sidebar with filter icons |
| **Expanded** | Full sidebar with all facets expanded |

## Props / Configuration

- `facets` — Array of filter dimensions (space, type, date, agent, tags)
- `activeFilters` — Currently applied filters
- `onFilterChange` — Callback when filters change

## Interactions

- Select/deselect filter values; combine multiple filters
- Remove individual filters via badges; reset all filters
