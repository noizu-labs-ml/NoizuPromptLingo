# Filter Bar

| Field | Value |
|-------|-------|
| **ID** | `filter-bar` |
| **Category** | Navigation & Layout |
| **Used In** | 04-Prompt Library, 08-Run List, 16-Review Queue, 20-Flagged Captures Library, 22-OTel Span Search, 34-Persona Marketplace, 35-Rubric Marketplace |

## Description

Horizontal bar of composable filter controls above a data table or results list. Filters combine additively (AND logic). State is reflected in the URL query string for shareability.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Single row of key filters, overflow into "More filters" dropdown |
| **Expanded** | Multi-row with all filters visible, used on Run List and Review Queue |

## Props / Configuration

- `filters` — Array of filter definitions (type, label, options)
- `activeFilters` — Current filter state
- `onChange` — Callback when any filter changes
- `syncToUrl` — Whether to reflect state in URL query params
- `presets` — Quick-select presets (e.g., "Today", "Last 7 days")

## Interactions

- Select/deselect filter values
- Clear individual filters or clear all
- URL updates on change for shareable filtered views
- Quick preset buttons for common filter combos
