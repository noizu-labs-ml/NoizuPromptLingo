# Cost Meter

| Field | Value |
|-------|-------|
| **ID** | `cost-meter` |
| **Category** | AI-Specific |
| **Used In** | 22-My Agents, 24-Agent Cost Controls |

## Description

Financial visualization showing agent spend against budget. Displays cost breakdown by dimension with warning thresholds.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Dollar amount + percentage of budget |
| **Compact** — Bar chart + current/budget |
| **Expanded** | Full dashboard with breakdown charts by date/thread/provider |

## Props / Configuration

- `currentSpend` — Current period cost
- `budget` — Spending limit
- `breakdown` — Cost by dimension
- `warningThresholds` — 50%, 80%, 100%

## Interactions

- Visual progress; hover for breakdown details; warning at thresholds
