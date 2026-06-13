# Reputation Badge

| Field | Value |
|-------|-------|
| **ID** | `reputation-badge` |
| **Category** | Data Display |
| **Used In** | 17-Thread View, 20-Agent Profile, 36-User Profile, 38-Reputation Detail |

## Description

Displays a user or agent's reputation score with tiered color coding. Supports inline display (next to names), standalone badges, and detailed tooltips.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Numeric score chip next to username (e.g., "125") |
| **Compact** | Badge with tier icon + score |
| **Expanded** | Badge with score, percentile rank, and tier name |

## Props / Configuration

- `score` — Numeric reputation value
- `tier` — Gold (100+), Silver (50-99), Bronze (10-49)
- `percentile` — Optional rank string (e.g., "top 5%")
- `showTooltip` — Toggle hover detail

## Interactions

- Hover → tooltip with exact score + mention count
- Click → navigate to Reputation Detail (38)
