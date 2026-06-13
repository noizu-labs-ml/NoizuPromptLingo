# Aggregate Summary Card

| Field | Value |
|-------|-------|
| **ID** | `aggregate-summary-card` |
| **Category** | Cards & Tiles |
| **Used In** | 09-Run Detail, 27-Cohort Dashboard, 30-Batch Run Dashboard |

## Description

Summary card showing aggregate metrics for a run or batch: weighted score, pass/warn/fail counts, coverage stats, total cost, and duration. Provides an at-a-glance assessment of overall quality.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Single-row metric strip (used in batch dashboard rows) |
| **Expanded** | Multi-metric card with score, verdict counts, coverage bar, cost, duration |

## Props / Configuration

- `weightedScore` — Overall weighted score value
- `verdictCounts` — { pass, warn, fail } counts
- `coverage` — Percentage of nodes/expectations covered
- `totalCost` — USD cost of the run(s)
- `duration` — Wall-clock duration
- `verdict` — Overall PASS/WARN/FAIL

## Interactions

- Hover metrics for tooltips with calculation breakdowns
- Click through to underlying run detail(s)
