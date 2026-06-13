# Eval Rubric Builder

| Field | Value |
|-------|-------|
| **ID** | `eval-rubric-builder` |
| **Type** | Settings |
| **Category** | Agent Evaluation |
| **User Stories** | US-097 |

## Description

Define automated evaluation rubrics with weighted dimensions (accuracy, tone, completeness, etc.), scoring methods, version history, and test mode against historical agent outputs.

## Key Components

- **Dimension list** — Evaluation dimensions with descriptions
- **Weight config** — Relative weight per dimension (must sum to 100%)
- **Scoring method selector** — Manual, automated (regex/LLM), or hybrid
- **Version history** — Track rubric changes over time
- **Test mode runner** — Run rubric against historical outputs to validate
- **Historical output selector** — Pick outputs to test rubric against

## Interactions

- Add/remove evaluation dimensions
- Set weights and scoring methods per dimension
- Test rubric against real outputs before activating
- Version rubrics for A/B comparison
- Clone existing rubrics as starting points

## Navigation

- Accessible from: Eval nav, Settings
- Links to: Eval Dashboard, A/B Test Manager, Agent settings
