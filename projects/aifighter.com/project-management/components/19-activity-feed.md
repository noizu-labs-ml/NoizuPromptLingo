# Activity Feed

| Field | Value |
|-------|-------|
| **ID** | `activity-feed` |
| **Category** | Tables & Lists |
| **Used In** | 12-Clan Hub, 07-Laboratory (Replay Theater feed) |

## Description

Chronological feed of activity items (match results, builds shared, joins, comments). Supports scrolling with lazy loading.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Condensed feed items with minimal metadata |
| **Expanded** | Detailed items with previews and full metadata |

## Props / Configuration

- `items` — Activity item list
- `filter` — Activity type filter (matches | builds | social | all)
- `sortOrder` — Sort order (newest-first | featured)

## Interactions

- Scroll to lazy-load more items
- Filter feed by activity type
- Click item to navigate to source (replay, build, profile)
