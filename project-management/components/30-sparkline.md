# Sparkline

| Field | Value |
|-------|-------|
| **ID** | `sparkline` |
| **Category** | Data Display |
| **Used In** | 06-Ranked Arena (leaderboard), 24-Fighter Win-Rate Analytics |

## Description

Compact inline chart showing 7-day ELO trend or win rate trend. Used in leaderboard rows and analytics tables.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Fits within a table cell, no axis labels |

## Props / Configuration

- `dataPoints` — Array of 7 or more data values
- `color` — Theme color for the line/fill
- `showTrend` — Display up/down trend indicator arrow

## Interactions

- Hover for data point tooltip (desktop)
- Static display (mobile)
