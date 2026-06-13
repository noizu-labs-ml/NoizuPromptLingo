# Batch Run Dashboard

| Field | Value |
|-------|-------|
| **ID** | `batch-run-dashboard` |
| **Type** | Dashboard |
| **Category** | Run Execution |
| **User Stories** | US-070 |

## Description

Compact table view showing per-agent verdict results for a batch run (one script against N agents). Provides a quick overview of which agents passed/failed.

## Key Components

- **Agent verdict table** — Agent name/version, verdict badge, aggregate score, duration, cost
- **Batch header** — Script name + version, trigger time, total cost
- **Cost summary** — Total cost across all batch runs

## Interactions

- View per-agent verdicts at a glance
- Click any agent row to open that run's detail

## Navigation

- Accessible from: Run List (filter by batch_id)
- Links to: Run Detail (click agent row)
