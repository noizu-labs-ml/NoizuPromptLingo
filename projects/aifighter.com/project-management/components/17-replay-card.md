# Replay Card

| Field | Value |
|-------|-------|
| **ID** | `replay-card` |
| **Category** | Cards & Tiles |
| **Used In** | 07-Laboratory (Replay Theater), 18-Public Profile, 25-Tournament Bracket |

## Description

Card representing a battle replay with fighter thumbnails, archetypes, match duration, view count, and upvote button. Links to full replay viewer.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | One-line entry with outcome badge and minimal metadata |
| **Compact** | Card with thumbnails and key info (duration, views, upvote) |

## Props / Configuration

- `replay` — Replay metadata object (fighters, outcome, duration, timestamp)
- `showUpvote` — Enable community voting button
- `showViewCount` — Display view count alongside card
- `featured` — Apply highlight/featured styling

## Interactions

- Click to open full replay viewer
- Upvote replay
- Share replay link
