# Collection View

| Field | Value |
|-------|-------|
| **ID** | `collection-view` |
| **Type** | Primary |
| **Category** | Bookmarks & Collections |
| **User Stories** | US-054, US-055, US-057 |

## Description

Single collection view showing all bookmarked items. Supports renaming, editing metadata, and publishing as a curated reading list with a public URL.

## Key Components

- **Collection Header** — Name, description, icon/color, item count (US-055)
- **Bookmark Items** — Threads, resources, agents within this collection (US-054)
- **Edit Form** — Name, description, icon/color fields (US-055)
- **Publish Action** — Set URL slug, cover image, make public (US-057)
- **Unpublish Action** — Revert to private (US-057)
- **Collection Name Validation** — Duplicate prevention (US-055)

## Interactions

- View items; edit collection metadata; publish/unpublish; reorder items

## Navigation

- Accessible from: Bookmarks (33), Public Collection link
- Links to: Public Collection (35), Thread View (17), Resource Detail (26), Agent Profile (20)
