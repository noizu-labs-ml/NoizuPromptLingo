# Rubric List

| Field | Value |
|-------|-------|
| **ID** | `rubric-list` |
| **Type** | Primary |
| **Category** | Rubric & Scoring |
| **User Stories** | US-033, US-119 |

## Description

Lists all rubrics in the organization with name, judge model, scale type, and version info. Entry point for creating new rubrics and importing from marketplace.

## Key Components

- **Rubric table** — Name, judge model, scale type (continuous/ladder), criteria count, current version
- **New Rubric button** — Opens rubric creation form (US-033)
- **Import from Marketplace** — Opens marketplace browser (US-119)

## Interactions

- Click "New Rubric" to create a rubric
- Click a row to open Rubric Detail
- Browse marketplace to import community rubrics

## Navigation

- Accessible from: Global sidebar navigation
- Links to: Rubric Detail (click row), Rubric Marketplace (import action)
