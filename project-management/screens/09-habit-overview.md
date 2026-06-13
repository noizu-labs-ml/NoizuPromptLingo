# Habit Overview

| Field | Value |
|-------|-------|
| **ID** | `habit-overview` |
| **Type** | Primary |
| **Category** | Personal Productivity |
| **User Stories** | US-012, US-014 |

## Description

Overview of all active habits showing current-week completion status, streak counts, heatmap visualizations (GitHub-style), and streak-break alerts. Supports grace periods for flexibility.

## Key Components

- **Habit list** — All active habits with today's completion status
- **Weekly completion grid** — 7-day row per habit showing done/missed
- **Streak counter** — Current streak days per habit
- **Heatmap visualization** — Color-coded calendar grid (12-week history)
- **Grace period config** — Allow N miss-days before streak breaks
- **Longest streak badge** — Personal best highlight per habit

## Interactions

- Tap/click to mark habit complete for today
- Click habit name to view full history and edit schedule
- Streak-break alerts appear as notifications
- Configure grace period per habit
- Add new habits via create button

## Navigation

- Accessible from: Main nav (habits icon), Today Dashboard (habit section)
- Links to: Habit detail/edit, Today Dashboard, Weekly Review
