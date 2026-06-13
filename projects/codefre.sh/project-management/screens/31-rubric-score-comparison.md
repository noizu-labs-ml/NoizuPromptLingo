# Rubric Score Comparison

| Field | Value |
|-------|-------|
| **ID** | `rubric-score-comparison` |
| **Type** | Primary |
| **Category** | Rubric & Scoring |
| **User Stories** | US-059, US-060, US-121 |

## Description

Side-by-side view comparing scores from two different rubric versions on the same run. Shows per-step score columns with disagreement highlighting and aggregate delta.

## Key Components

- **Version selector** — Pick two rubric versions that scored this run (US-060)
- **Step score columns** — Side-by-side score, verdict, rationale, judge model per step (US-060)
- **Disagreement highlighting** — Rows where verdicts disagree highlighted (US-060)
- **Aggregate delta** — Run-level score delta between versions (US-060)
- **Disagreement analytics** — Cohen's kappa, confusion matrix (US-121)

## Interactions

- Select two rubric versions to compare
- Scroll through step-by-step comparison
- View aggregate metrics
- Export disagreement data as CSV

## Navigation

- Accessible from: Run Detail (rubric versions chip), Rubric Detail (re-score flow)
- Links to: Run Detail (back), Rubric Detail
