# Search Input

| Field | Value |
|-------|-------|
| **ID** | `search-input` |
| **Category** | Input & Forms |
| **Used In** | 06-Quick Capture Modal, 11-Archive, 21-Template Library, 40-ADR Index, 43-Knowledge Search, 44-Checklist Library, 63-Prompt Tagging |

## Description

Search field with instant results, keyboard navigation through results, and recent search history

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Compact search icon that expands |
| **Compact** | Search bar with instant dropdown results |
| **Expanded** | Full search with filters and result list |
| **Full_Page** | Dedicated search page with faceted results |

## Props / Configuration

- `placeholder` — string
- `onSearch` — callback
- `debounceMs` — number
- `showRecent` — boolean
- `resultRenderer` — component
- `filters` — optional filter config

## Interactions

- type for instant results
- keyboard up/down through results
- Enter to select
- Escape to close
- recent searches on empty focus
