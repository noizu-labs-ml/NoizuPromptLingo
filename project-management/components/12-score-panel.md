# Score Panel

| Field | Value |
|-------|-------|
| **ID** | `score-panel` |
| **Category** | Data Display |
| **Used In** | 09-Run Detail, 12-Rubric Detail, 27-Cohort Dashboard, 30-Batch Run Dashboard, 31-Rubric Score Comparison |

## Description

Displays scoring results for expectations: per-step scores with verdict, rationale, scoring method, and judge model. Supports both individual step scores and aggregate summaries with weighted calculations.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single score value with verdict badge in a table cell |
| **Compact** | Per-step score row: expectation label, score, verdict, rationale truncated |
| **Expanded** | Full score card with all criteria, rationale, confidence, judge model |

## Props / Configuration

- `scores` — Array of score objects (expectation, value, verdict, rationale, scoring_method, judge_model)
- `aggregateScore` — Weighted aggregate across all expectations
- `showRationale` — Whether to display judge rationale text
- `showConfidence` — Whether to display confidence bands
- `deltaMode` — Show score deltas instead of absolute values (for comparison views)

## Interactions

- Expand individual scores to see full rationale
- In comparison mode, highlight disagreements between versions
- Click judge model to see configuration
