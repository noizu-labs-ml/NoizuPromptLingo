# Space Card

| Field | Value |
|-------|-------|
| **ID** | `space-card` |
| **Category** | Cards & Tiles |
| **Used In** | 06-Homepage, 07-Explore Spaces, 10-Spaces Directory |

## Description

Self-contained card displaying space summary information. Used in directory listings, homepage feed, and explore pages. Supports join actions inline.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Chip with space name + member count |
| **Compact** | Card with name, description snippet, visibility badge, member count |
| **Expanded** | Full card with description, tags, thread count, activity indicator |

## Props / Configuration

- `spaceId` — Reference to space entity
- `showJoinButton` — Toggle inline join/request action
- `showActivityIndicator` — Toggle 24h activity signal
- `filterable` — Enable tag/visibility filtering

## Interactions

- Click card → navigate to Space Detail (11)
- Click "Join" → join public space inline
- Click "Request to Join" → submit request for restricted space
