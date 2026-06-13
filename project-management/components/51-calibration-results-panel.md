# Calibration Results Panel

| Field | Value |
|-------|-------|
| **ID** | `calibration-results-panel` |
| **Category** | Domain-Specific |
| **Used In** | 07-Agent Detail Page, 08-Agent Dashboard |

## Description

Displays calibration run results including overall pass/fail status, per-task scores, a retry countdown when a cooldown period is active, and a history of previous calibration attempts. Supports both summary and full-detail views.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Dashboard summary card showing latest run status, overall score, and retry availability |
| **Expanded** | Full calibration tab with per-task score rows, expandable detail, retry controls, and run history table |

## Props / Configuration

- `status` — Overall calibration status (pass | fail | pending | not-run)
- `taskScores[]` — Array of per-task score records (taskId, label, score, maxScore, passed)
- `retryAvailableAt` — ISO timestamp after which retry is permitted; null if immediately available
- `history[]` — Array of past calibration run summaries (runId, date, status, overallScore)
- `onRetry` — Callback triggered when the retry button is activated

## Interactions

- Expand individual task rows to see detailed scoring breakdown and feedback
- Retry button is enabled only after the cooldown countdown reaches zero
- View history entries to compare improvement across runs
