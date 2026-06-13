# Cohort Dashboard

| Field | Value |
|-------|-------|
| **ID** | `cohort-dashboard` |
| **Type** | Dashboard |
| **Category** | Results & Dashboards |
| **User Stories** | US-129 |

## Description

Aggregate cross-run metrics view for a cohort of runs (selected by batch_id or manual multi-select). Shows per-agent accuracy, per-persona accuracy, score distribution boxplots, and verdict delta matrix.

## Key Components

- **Per-agent accuracy table** — Agent name, pass rate, mean score, verdict counts
- **Per-persona accuracy table** — Persona name, pass rate, mean score
- **Score distribution boxplots** — Per-agent or per-persona boxplots
- **Verdict delta matrix** — Cross-comparison highlighting regressions
- **CSV export** — Download cohort summary for paper tables
- **Shareable URL** — Encodes cohort membership

## Interactions

- View cohort metrics
- Export as CSV
- Share URL with team
- Drill into individual runs

## Navigation

- Accessible from: Run List (batch filter or multi-select), Batch Run result
- Links to: Run Detail (drill into specific runs)
