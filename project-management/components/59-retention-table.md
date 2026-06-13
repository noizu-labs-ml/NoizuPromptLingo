# Retention Table

| Field | Value |
|-------|-------|
| **ID** | `retention-table` |
| **Category** | Admin / Analytics |
| **Used In** | S-21 Admin Analytics |

## Description

Cohort-based retention table showing week-over-week or day-over-day user retention percentages. Each row represents a signup cohort; columns represent subsequent periods. Cells are color-coded from red (low retention) through amber to green (high retention).

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Condensed cell size with abbreviated column headers; fits more cohorts in a smaller viewport height |
| **Expanded** | Standard cell size with full period labels, cohort size annotation, and hover tooltips |

## Props / Configuration

- `cohorts` — Array of cohort rows: `{ cohortLabel, cohortSize, retentionByPeriod: number[] }`
  - `cohortLabel` — Display label for the cohort row (e.g., "Week of May 12")
  - `cohortSize` — Total users in the cohort; displayed in the first column
  - `retentionByPeriod` — Array of floats 0–1 representing retention rate at each period offset
- `periodLabels` — Array of column header strings (e.g., `["Week 0", "Week 1", ..., "Week 12"]`)
- `granularity` — `"day"` | `"week"` | `"month"`
- `colorScale` — `"red-green"` | `"blue"` (default: `"red-green"`)
- `variant` — `"compact"` | `"expanded"` (default: `"expanded"`)
- `highlightThreshold` — Float; cells at or above this retention rate receive a bold label (default: 0.4)

## Interactions

- Hovering a cell shows a tooltip with cohort label, period label, absolute user count retained, and percentage
- Clicking a cell opens a drill-down panel listing the retained users for that cohort/period combination (admin only)
- Column headers are sortable by clicking to re-order cohorts by retention at that period offset
- First column (Week 0 / Day 0) always shows 100% as the baseline and is rendered in a distinct grey style
- Color scale is applied per-column (relative to that period's max) so early periods don't visually dominate
- A summary row at the bottom shows average retention across all cohorts per period
- Export button downloads the table as CSV
