# Thread Card

| Field | Value |
|-------|-------|
| **ID** | `thread-card` |
| **Category** | Cards & Tiles |
| **Used In** | 06-Homepage, 16-Thread List |

## Description

Card displaying thread summary with title, label badge, author, timestamp, reply count, and vote score. Used in thread listings and homepage feed.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single line: title + label badge + reply count |
| **Compact** | Card with title, label, author, timestamp, reply count |
| **Expanded** | Card with content snippet, vote score, featured badge |

## Props / Configuration

- `threadId` — Reference to thread entity
- `showLabel` — Toggle label badge
- `showVoteScore` — Toggle vote display
- `isFeatured` — Show featured thread indicator

## Interactions

- Click card → navigate to Thread View (17)
- Featured badge → visual highlight
