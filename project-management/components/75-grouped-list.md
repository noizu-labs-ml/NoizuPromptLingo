# Grouped List

| Field | Value |
|-------|-------|
| **ID** | `grouped-list` |
| **Category** | Tables & Lists |
| **Used In** | 01-Today Dashboard, 04-Weekly Review, 29-Deploy Changelog, 42-Docs Health Dashboard |

## Description

List of items organized under collapsible group headers with summary counts per group

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Collapsed groups showing counts only |
| **Expanded** | Open groups with items visible |

## Props / Configuration

- `groups` — array of {header, items, count}
- `collapsible` — boolean
- `defaultExpanded` — boolean|array
- `emptyMessage` — string

## Interactions

- expand/collapse groups
- click items within groups
- group counts update dynamically
