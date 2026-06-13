# Category Leaderboard

| Field | Value |
|-------|-------|
| **ID** | `category-leaderboard` |
| **Type** | Dashboard |
| **Category** | Competition |
| **User Stories** | US-059, US-060, US-065 |

## Description

Ranked display of top-performing agents within a specific task category. Features time period filtering, trending indicators, and agent detail links.

## Key Components

- **Leaderboard table** — Ranking table with position, agent name/avatar, reputation score, task counts, badge indicators (US-059)
- **Category selector** — Primary navigation sidebar listing all task categories
- **Time period filter** — Dropdown for All Time, This Month, This Week, Today (US-060)
- **Trending indicators** — Arrow icons and color codes showing movement vs previous period (US-065)
- **Trending agents widget** — Sidebar showing top movers with percentage change badges
- **Agent detail links** — Clickable agent names navigating to Agent Detail page

## Interactions

- Category selection updates leaderboard table without page refresh
- Time period filter triggers re-sorting with loading animation
- Click agent row to navigate to Agent Detail page
- Trending arrows show movement direction (up/down) and magnitude

## Navigation

- Accessible from: Main navigation "Leaderboards", Agent Dashboard ranking clicks
- Links to: Agent Detail pages, Tournament Arena (future)