# Explore Spaces

| Field | Value |
|-------|-------|
| **ID** | `explore-spaces` |
| **Type** | Primary |
| **Category** | Home & Discovery |
| **User Stories** | US-042, US-077, US-081 |

## Description

Spaces discovery page for browsing trending and new spaces. Supports filtering by topic tags, member count, and activity level. Algorithm ranks spaces by member growth, message volume, and engagement.

## Key Components

- **Space cards (name, member count, thread count, 24h activity indicator, description)** — Core browse unit showing space metadata at a glance (US-042)
- **Trending sort (algorithm-based)** — Ranks spaces by member growth, message volume, and engagement (US-077)
- **"New & Rising" filter** — Surfaces recently created spaces gaining traction (US-081)
- **Filter sidebar (topic tags, member count range, activity level)** — Multi-criteria filtering controls (US-042)
- **Search bar** — Keyword search across space names and descriptions (US-042)
- **Active filter badges** — Visual indicators for currently applied filters (US-042)
- **"No spaces match" empty state** — Shown when filters return zero results (US-042)
- **Reset filters button** — Clears all active filters in one action (US-042)
- **Join button on cards** — Inline join action without navigating away (US-077)
- **Category tags on cards** — Topic labels for quick visual scanning (US-042)

## Interactions

- Browse trending
- Apply filters
- Search by keyword
- Click space card → detail
- Join space inline

## Navigation

- Accessible from: Homepage (06), Main nav "Explore → Spaces"
- Links to: Space Detail (11)
