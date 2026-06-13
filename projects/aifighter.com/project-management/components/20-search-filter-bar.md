# Search Filter Bar

| Field | Value |
|-------|-------|
| **ID** | `search-filter-bar` |
| **Category** | Input & Forms |
| **Used In** | 01-Fighter Studio (node palette), 05-Template Gallery, 07-Laboratory, 12-Clan Hub, 13-Patch Notes, 19-Node Glossary |

## Description

Combined search input and filter controls used across multiple screens. Supports real-time search, category tabs/chips, and tag-based filtering.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Search input only, no filter controls |
| **Expanded** | Search input with filter chips and category tabs |

## Props / Configuration

- `placeholder` — Search hint text
- `categories` — Filter category list for tab/chip rendering
- `tags` — Active filter tags (controlled)
- `onSearch` — Callback fired on input change
- `clearOnEscape` — Clear search input on Escape key press

## Interactions

- Type to search in real-time
- Click category tabs to filter by category
- Toggle filter tags to narrow results
- Press Escape to clear search input (if `clearOnEscape` enabled)
