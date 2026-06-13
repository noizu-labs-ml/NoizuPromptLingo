# Card Grid

| Field | Value |
|-------|-------|
| **ID** | `card-grid` |
| **Category** | Navigation & Layout |
| **Used In** | S01 Universe Dashboard, S09 Generation Studio (Template Selection), S03 Universe Overview |

## Description

Responsive CSS grid container that renders a collection of content cards. Adjusts column count automatically based on viewport width. Supports loading skeletons, empty states, and infinite scroll / pagination controls at the bottom.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Smaller card thumbnails; 4–6 columns on wide viewports; used for template selection |
| **Expanded** | Larger cards; 2–3 columns on wide viewports; used for universe and entry grids |

## Props / Configuration

- `items` — Array of data objects passed to the card render function
- `renderCard` — Render prop / component receiving a single item; expected to return a card component
- `columns` — Override column count: `{ sm: 1, md: 2, lg: 3, xl: 4 }` responsive map
- `gap` — Grid gap in rem units (default: `1.5`)
- `loading` — Boolean; when true renders skeleton placeholder cards
- `skeletonCount` — Number of skeleton cards to show while loading (default: `6`)
- `emptyState` — React node rendered when `items` is empty and `loading` is false
- `onLoadMore` — Callback triggered when the user scrolls near the bottom (infinite scroll) or clicks "Load More"
- `hasMore` — Boolean indicating whether additional pages exist

## Interactions

- Grid reflows automatically on viewport resize without JS intervention (pure CSS grid)
- Skeleton cards fade out and are replaced by real cards when `loading` transitions to false
- "Load More" button appears at the bottom when `hasMore` is true and `onLoadMore` is provided; replaced by an inline spinner while fetching the next page
- Empty state renders a centered illustration + message + optional CTA button
- Individual card hover/focus states are managed by the card component; the grid provides no additional hover behavior
