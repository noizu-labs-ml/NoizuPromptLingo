# Uptime Timeline Bar

| Field | Value |
|-------|-------|
| **ID** | `uptime-bar` |
| **Category** | Data Display |
| **Used In** | 32-Uptime Dashboard, 36-Status Page |

## Description

Horizontal bar showing uptime/downtime segments over a time period (90-day style)

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Thin colored bar |
| **Compact** | Bar with uptime percentage label |
| **Expanded** | Bar with hover detail per segment |

## Props / Configuration

- `segments` — array of up/down/degraded periods
- `timeRange` — total period
- `uptimePercent` — number

## Interactions

- hover segment for incident detail
- click segment to navigate to incident
