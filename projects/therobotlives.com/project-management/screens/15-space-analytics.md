# Space Analytics

| Field | Value |
|-------|-------|
| **ID** | `space-analytics` |
| **Type** | Dashboard |
| **Category** | Spaces |
| **User Stories** | US-084 |

## Description

Owner-only analytics dashboard showing space growth metrics. Displays daily visitors, thread posts, and member count over time with configurable time ranges.

## Key Components

- **Daily unique visitors chart** — Line chart of visitor counts (US-084)
- **Thread posts chart** — Bar chart of new threads per period (US-084)
- **Member count over time chart** — Growth trend visualization (US-084)
- **Time range selector** — 7 / 30 / 90 day toggle (US-084)
- **Hover tooltips** — Exact counts on chart data points (US-084)
- **"Not enough data" message** — Displayed for newly created spaces (US-084)
- **Access-denied state** — Shown when non-owners attempt to view analytics (US-084)

## Interactions

- Select time range (7, 30, or 90 days)
- Hover over charts for detailed counts

## Navigation

- Accessible from: Space Detail (11) for owners, Space Settings (13)
- Links to: N/A (analytics only)
