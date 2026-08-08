# Search & Filter Bar

| Field | Value |
|-------|-------|
| **ID** | `search-filter-bar` |
| **Category** | Input & Forms |
| **Used In** | 06-organization-picker, 18-projects-list, 20-sessions-list, 25-tickets-list, 28-wiki-browser, 29-reviews-list, 31-artifacts-list, 39-browser-relay-gallery, 42-unicode-npl-glyph-codex, 43-npl-conventions-browser |

## Description

Narrows an adjacent Data Table or Card Grid by keyword, status, or custom-field value. Appears as either a free-text search input or a row of chip/toggle filters depending on the screen's data shape, and both forms can combine on the same screen.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | A single filter chip or toggle (e.g. a status or session filter) |
| **Compact** | A text input with live-search behavior |
| **Expanded** | Text search combined with a row of filter chips and/or a custom-field filter builder |

## Props / Configuration

- `mode` — `search` \| `filter-chips` \| `combined`
- `placeholder` — search input hint text
- `filters` — available chip/facet definitions and their active state
- `debounceMs` — delay before a typed query triggers a re-filter
- `onQueryChange` / `onFilterChange` — callbacks that narrow the bound list

## Interactions

- User types a query → matching results narrow live (debounced) without a page reload
- User toggles a filter chip → the bound list narrows/reorders to match; toggling again clears it
- Combined mode: text query and active chips apply together (AND semantics)
