# Universe Card

| Field | Value |
|-------|-------|
| **ID** | `universe-card` |
| **Category** | Forms |
| **Used In** | S01 Universe Overview Dashboard |

## Description

Dashboard card representing a single universe. Shows a cover image or generated gradient, universe name, entry count, current consistency score with a color-coded indicator, and a quick-action menu. Acts as the primary navigation entry point from the dashboard to a universe workspace.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Smaller thumbnail format for dense dashboard grids (4+ columns) |
| **Expanded** | Larger card with full cover image, visible metadata row, and action buttons (2–3 column grid) |

## Props / Configuration

- `universe` — Universe data object: `{ id, name, coverImageUrl, entryCount, consistencyScore, lastActivityAt, role }`
- `onClick` — Callback fired when the card body is clicked; navigates into the universe workspace
- `onMenuAction` — Callback fired with `{ universeId, action }` for quick-action menu items (`edit`, `duplicate`, `delete`, `share`)
- `showConsistencyScore` — Boolean; controls visibility of the consistency score indicator (default: `true`)
- `showLastActivity` — Boolean; shows relative last-activity timestamp (default: `true`)
- `role` — User's role in this universe (`owner` | `editor` | `viewer`); controls which quick actions appear in the menu

## Interactions

- Clicking the card body navigates to the universe's Canon List or last-visited section
- Hovering reveals an overlay with the quick-action menu trigger (three-dot icon) in the top-right corner
- Quick-action menu opens a dropdown with Edit, Duplicate, Share, and Delete (Delete only visible to owners)
- Consistency score renders as a circular progress ring color-coded by threshold: green (>85%), yellow (60–85%), red (<60%)
- Cover image uses `object-fit: cover`; if no `coverImageUrl` is provided, a deterministic gradient is generated from the universe name
- Entry count badge updates optimistically when entries are added/removed
