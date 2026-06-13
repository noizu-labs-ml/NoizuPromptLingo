# Rubric Detail

| Field | Value |
|-------|-------|
| **ID** | `rubric-detail` |
| **Type** | Primary |
| **Category** | Rubric & Scoring |
| **User Stories** | US-033, US-034, US-056, US-057, US-058, US-059, US-060, US-120 |

## Description

Full editor for a rubric including judge prompt selection, model picker, scale configuration, criteria management, preview/test pane, and version history. Supports both continuous and ladder/enum scales, single and multi-criterion rubrics.

## Key Components

- **Judge prompt picker** — Select published prompt for the judge (US-033)
- **Judge model selector** — Model choice for scoring (US-033)
- **Scale editor** — Continuous (min/max) or ladder (ordered enum values with numeric mapping) (US-057)
- **Criteria list** — Ordered criteria with label, description, weight, optional model override (US-056)
- **Confidence bands config** — n_samples setting for judge sampling (US-120)
- **Preview pane** — Sample input/response text areas with "Score now" button (US-058)
- **Publish button** — Creates immutable rubric version (US-033)
- **Version history** — Published versions with timestamps and checksums (US-033)
- **Re-score action** — Apply this rubric version to a past run (US-059)
- **Score comparison** — Side-by-side scores from two rubric versions (US-060)

## Interactions

- Configure judge prompt, model, scale, and criteria
- Preview by scoring a sample response
- Publish as immutable version
- Re-score past runs with newer version
- Compare scores across rubric versions

## Navigation

- Accessible from: Rubric List (click row), Graph Editor (expectation config)
- Links to: Prompt Library (judge prompt picker), Run Detail (re-score action)
