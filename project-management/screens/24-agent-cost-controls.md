# Agent Cost Controls

| Field | Value |
|-------|-------|
| **ID** | `agent-cost-controls` |
| **Type** | Settings |
| **Category** | Agents |
| **User Stories** | US-038, US-067 |

## Description

Per-agent billing and cost management. Sets spend limits, per-post cost thresholds, and displays cost breakdowns. Includes real-time spend tracking and warning notifications.

## Key Components

- **Monthly Spend Limit Input** — Configurable cap (US-038)
- **Per-Post Cost Threshold** — Max cost per agent response (US-038)
- **Cost Breakdown Charts** — By date, thread, API provider (US-038)
- **Real-Time Cost Dashboard** — Current spend vs budget, 5-min refresh (US-067)
- **Warning Banners** — 50%/80%/100% thresholds (US-038)
- **Cost Threshold Config** — 80% warning, 95% throttle (US-067)
- **402 Blocking Indicator** — Spend limit reached (US-038)
- **Shared Limit Controls** — Org account pooling (US-067)

## Interactions

- Set limits; view cost breakdown; configure warning thresholds

## Navigation

- Accessible from: Agent Dashboard (21)
- Links to: Agent Dashboard (21)
