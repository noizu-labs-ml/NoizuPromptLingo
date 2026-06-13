# Ranked Arena

| Field | Value |
|-------|-------|
| **ID** | `ranked-arena` |
| **Type** | Primary |
| **Category** | Competitive |
| **User Stories** | US-005, US-011, US-014, US-041, US-042, US-043, US-050, US-061, US-064, US-065, US-077 |

## Description

Hub for ranked competitive play including queue management, leaderboard, season progress, and fighter slot selection. Supports async battle resolution and fair matchmaking.

## Key Components

- **Leaderboard Table** — Top 500 with ELO, tier badge, W/L, 7-day sparkline, own-rank pinned row (US-041)
- **Fighter Slot Switcher** — Up to 4+ slots with per-slot stats, 2-tap switching (US-042)
- **Queue Status Panel** — Wait time estimate (10s refresh), tier queue depth bar, cancel button (US-050)
- **Season Progress Tracker** — Countdown timer, rank tier ladder, reward preview cards (US-011, US-077)
- **Submit Battle Button** — Queue submission with multi-battle tracker (up to 3), async server-side resolution with no online-presence requirement (US-014, US-061)
- **Matchmaking Preferences** — Activity-tier selector (Casual/Active/Any) (US-065)
- **Fair Play Badge** — Cosmetics-only store indicator (US-005)
- **No-Decay Indicator** — 30-day rank persistence without play (US-064)

## Interactions

- Select active fighter and submit to ranked queue
- Monitor queue status and wait times
- View leaderboard and own percentile
- Track season progress and upcoming rewards
- Configure matchmaking preferences
- Cancel queue without penalty

## Navigation

- Accessible from: Home, Notifications
- Links to: Post-Battle Screen, Battle Replay Viewer, Fighter Studio (slot edit), Season Summary
