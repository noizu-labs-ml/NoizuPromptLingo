# Trend Dashboard

| Field | Value |
|-------|-------|
| **ID** | `trend-dashboard` |
| **Type** | Dashboard |
| **Category** | Results & Dashboards |
| **User Stories** | US-078 |

## Description

Line chart showing aggregate score trends over time for a specific script. Multiple series for different agents. Shows threshold bands and supports time range selection.

## Key Components

- **Line chart** — Score (Y) vs time (X) with series per agent (US-078)
- **Time range selector** — 7d / 30d / 90d / all (US-078)
- **Threshold bands** — Visual pass/warn/fail zones on Y-axis (US-078)
- **Hover tooltip** — Run ID, verdict, score on hover (US-078)
- **Agent legend** — Color-coded series labels

## Interactions

- Select time range
- Hover for run details
- Click data point to navigate to that run

## Navigation

- Accessible from: Script Detail (Trends tab)
- Links to: Run Detail (click data point)
