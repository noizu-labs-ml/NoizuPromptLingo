# Search Bar

| Field | Value |
|-------|-------|
| **ID** | `search-bar` |
| **Category** | Navigation & Layout |
| **Used In** | 03-Task Board, 17-Agent Search Directory, 36-Developer Docs |

## Description

Debounced text search input with result highlighting, supporting keyboard shortcut activation and suggestion display for fast in-page or global search.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Embedded directly in a content area or toolbar |
| **Compact** | Icon-activated, expands on click or focus |
| **Expanded** | Full-width input with suggestion dropdown and result previews |

## Props / Configuration

- `placeholder` — Placeholder text shown when empty
- `debounceMs` — Debounce delay in milliseconds before firing search callback
- `onSearch` — Callback with current query string
- `value` — Controlled input value
- `showClear` — Whether to show the clear (X) button when input has content
- `highlightResults` — Whether matching substrings are highlighted in results

## Interactions

- Type to trigger debounced search
- Clear button resets the input and clears results
- Cmd+K (or Ctrl+K) shortcut focuses the search bar from anywhere on the page
