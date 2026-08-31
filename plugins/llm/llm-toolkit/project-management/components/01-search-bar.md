# 01: Search Bar

| Field | Value |
|-------|-------|
| ID | CMP-01 |
| Category | Input & Forms |
| Surfaces | web, cli-ink |
| Used In | SCR-01, SCR-16 |

## Description
Global query input with a full-text/semantic mode toggle. Debounces input before firing a search request; on web it's a text field with a `ToggleChip` pair, on CLI-ink it's a dedicated `search` UI sub-mode that captures a `TextInput` and a mode key.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Default | Full search page (SCR-01) |
| Compact | Navbar-embedded quick-search (per `design/SITEMAP.md` global elements) |

## Props / Configuration
- `query` — string — current input value
- `mode` — `"fts" \| "semantic"` — active ranking mode
- `onModeChange` — callback — swaps mode without clearing the query
- `debounceMs` — number — delay before firing the search request (web: `useDebouncedValue`-equivalent; cli-ink: `useDebouncedValue` hook)

## Interactions
- Typing debounces into a live query; no explicit submit button needed
- Mode toggle re-issues the same query against the other ranking mode
- Clearing the query reverts the parent screen to its default (non-search) list view
