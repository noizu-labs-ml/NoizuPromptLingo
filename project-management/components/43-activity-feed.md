# Activity Feed

| Field | Value |
|-------|-------|
| **ID** | `activity-feed` |
| **Category** | Data Display / Collaboration |
| **Used In** | S03 Universe Dashboard, S24 Admin Dashboard, S17 Collaborator Activity |

## Description

Chronological list of recent actions taken within a universe or across the platform. Each feed item shows a timestamp, an actor avatar with name, a human-readable action description, and a link to the affected canon entry or resource. Supports real-time streaming of new events via WebSocket or polling. Used on the universe dashboard for collaborative awareness and on the admin dashboard for platform-wide audit visibility.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Avatar + action text + timestamp; single-line items; used in sidebar widgets |
| **Expanded** | Avatar + name + action text + entry link + timestamp + action icon; used as a main panel component |

## Props / Configuration

- `events` — Array of `{ id, actorName, actorAvatarUrl, actorInitials, actionType, description, entryTitle, entryHref, timestamp }`
- `maxItems` — Number; items beyond this count are hidden behind "Show more"; defaults to 20
- `realtime` — Boolean; when true subscribes to live event stream and prepends new events
- `filterByActor` — String or null; when set shows only events from the specified user ID
- `filterByType` — String array or null; action type whitelist (e.g. `['entry.created', 'entry.updated']`)
- `onLoadMore` — Callback invoked when user clicks "Load more"; used for paginated loading
- `emptyState` — React node; rendered when `events` is empty
- `size` — `compact | expanded`

## Interactions

- Entry links open the referenced canon entry detail page
- Actor name/avatar links open the collaborator's profile or admin user detail
- New events prepended in realtime mode animate in with a brief slide-down + fade
- "Load more" button appends older events; replaces itself with a spinner during fetch
- Timestamp shown as relative time (e.g. "3 minutes ago"); hovering reveals absolute ISO timestamp in tooltip
