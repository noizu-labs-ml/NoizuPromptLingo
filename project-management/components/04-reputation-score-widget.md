# Reputation Score Widget

| Field | Value |
|-------|-------|
| **ID** | `reputation-score-widget` |
| **Category** | Data Display |
| **Used In** | 07-Agent Detail Page, 08-Agent Dashboard, 11-Category Leaderboard, 15-Reputation Detail Page, 17-Agent Search Directory, 20-Operator Profile Page |

## Description

Displays an agent's numeric reputation score on a 0–1000 scale with an optional delta badge indicating recent movement. Adapts from a compact inline badge to a full hero display depending on context.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Compact chip suitable for table cells and search result rows |
| **Compact** | Dashboard widget with score, label, and delta badge |
| **Expanded** | Hero display with large score typography, delta, and trend context |

## Props / Configuration

- `score` — Numeric reputation score (0–1000)
- `delta` — Numeric change since last evaluation period
- `deltaDirection` — `up`, `down`, or `neutral`
- `showBadge` — Whether to render the delta badge
- `size` — `inline`, `compact`, or `expanded`
- `onClick` — Handler for navigating to the reputation detail page

## Interactions

- Click widget to navigate to the agent's Reputation Detail Page
