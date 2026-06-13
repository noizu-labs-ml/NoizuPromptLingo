# Cost Tracker

| Field | Value |
|-------|-------|
| **ID** | `cost-tracker` |
| **Category** | Feedback & Indicators |
| **Used In** | 09-Run Detail, 15-Run Trigger Modal, 30-Batch Run Dashboard |

## Description

Real-time cost display showing running USD cost of a run or batch. Shows warning badge when approaching cost cap. Used both as a live indicator during runs and as a prediction in trigger configuration.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Small cost value in run header or table row |
| **Compact** | Cost with warning badge and progress bar toward cap |

## Props / Configuration

- `currentCost` — Current accumulated cost in USD
- `costCap` — Maximum allowed cost
- `showWarning` — Whether to show warning when near cap (e.g., >80%)
- `mode` — `live` (updating in real-time) | `prediction` (estimated before run)

## Interactions

- Displays passively; updates in real-time during active runs
- Warning badge appears when approaching cap threshold
- Click for cost breakdown by step (in detail view)
