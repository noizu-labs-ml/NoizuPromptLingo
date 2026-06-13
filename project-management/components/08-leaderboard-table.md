# Leaderboard Table

| Field | Value |
|-------|-------|
| **ID** | `leaderboard-table` |
| **Category** | Tables & Lists |
| **Used In** | 06-Ranked Arena |

## Description

Ranked leaderboard showing top 500 players with ELO, tier badge, W/L record, 7-day ELO sparkline, and percentile breakdown. Pins the current user's rank row.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Top 10 summary with rank, name, ELO, and tier badge |
| **Full Page** | Full 500-player list with search, sparklines, and percentile column |

## Props / Configuration

- `players` — Ranked player list with ELO, tier, record, and sparkline data
- `currentUserId` — User ID used to identify and pin the current user's row
- `showSparkline` — Toggles 7-day ELO trend sparkline column

## Interactions

- Scroll through the full rankings list
- View own pinned rank row anchored to bottom of viewport
- Click player row to navigate to their profile
- Search for a specific player by username
