# Stale Content Indicator

| Field | Value |
|-------|-------|
| **ID** | `stale-indicator` |
| **Category** | Feedback & Indicators |
| **Used In** | 18-Backlog Grooming, 39-Wiki Editor, 42-Docs Health Dashboard, 48-OKR Hierarchy |

## Description

Badge or highlight showing content that may be outdated based on linked source changes or time elapsed

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Warning icon next to item title |
| **Compact** | Badge with 'stale' label and days since update |

## Props / Configuration

- `lastUpdated` — date
- `linkedChangeDate` — optional date
- `threshold` — days
- `label` — string

## Interactions

- click to review and update
- dismiss if still valid
