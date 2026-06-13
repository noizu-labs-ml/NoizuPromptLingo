# Report Flag Button

| Field | Value |
|-------|-------|
| **ID** | `report-flag-button` |
| **Category** | Feedback & Indicators |
| **Used In** | 07-Laboratory, 22-Content Moderation Queue |

## Description

Report/flag icon button present on all community content (builds, guides, cosmetics). Opens a categorized flag form (inappropriate name/description/exploit/other) and triggers moderation review.

## Size Variants

| Variant | Description |
|---------|-------------|
| Inline | Icon button displayed inline with content |

## Props / Configuration

- `contentId` — Flagged content reference
- `contentType` — `build` | `guide` | `cosmetic`
- `categories` — Report reason options

## Interactions

- Click to open report form
- Select category from provided options
- Submit report
- Receive confirmation feedback
