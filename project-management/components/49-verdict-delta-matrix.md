# Verdict Delta Matrix

| Field | Value |
|-------|-------|
| **ID** | `verdict-delta-matrix` |
| **Category** | Data Display |
| **Used In** | 27-Cohort Dashboard, 31-Rubric Score Comparison |

## Description

Cross-comparison matrix highlighting verdict changes between agents, rubric versions, or time periods. Cells show delta values with color coding for regressions (red) and improvements (green). Includes aggregate statistics like Cohen's kappa for inter-rater agreement.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Summary matrix within a dashboard card |
| **Expanded** | Full matrix with per-cell drill-through and aggregate stats |

## Props / Configuration

- `rows` — Row labels (agents or rubric versions)
- `columns` — Column labels (agents or rubric versions)
- `cells` — Matrix of { delta, direction, count }
- `aggregateStats` — Cohen's kappa, confusion matrix data
- `onCellClick` — Drill-through callback

## Interactions

- Hover cells for detail (count of changes, direction)
- Click cell to drill into underlying runs/scores
- View aggregate agreement statistics
- Export as CSV
