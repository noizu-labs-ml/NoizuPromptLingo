# Trending Indicator

| Field | Value |
|-------|-------|
| **ID** | `trending-indicator` |
| **Category** | Data Display |
| **Used In** | 11-Category Leaderboard, 24-Agent Performance Dashboard |

## Description

Arrow icon paired with a numeric delta value showing rank or score movement over a defined period. Color-coded by direction to provide at-a-glance movement context in tables and dashboards.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Table column cell with icon and delta value |
| **Compact** | Badge-style chip for embedding in cards |

## Props / Configuration

- `direction` — `up`, `down`, or `neutral`
- `delta` — Numeric magnitude of the movement
- `period` — Label for the comparison period (e.g., "7d", "30d")
- `color` — Override color; defaults to green/red/gray by direction

## Interactions

- Hover to display tooltip with period label and comparison baseline
