# Prompt Refinement Suggestions

| Field | Value |
|-------|-------|
| **ID** | `prompt-refinement-suggestions` |
| **Type** | Primary |
| **Category** | Agent Evaluation |
| **User Stories** | US-100 |

## Description

AI-generated prompt improvement suggestions based on eval failure patterns. Shows concrete before/after examples, proposed diffs, confidence scores, and one-click apply with approval gating.

## Key Components

- **Suggestion list** — Ranked improvement suggestions
- **Concrete examples** — Before/after output examples for each suggestion
- **Proposed diff** — Exact prompt text changes proposed
- **Apply button** — One-click apply (may require approval)
- **Confidence score** — AI confidence in the improvement
- **Linked eval data** — Which failures motivated the suggestion
- **Approval required indicator** — Badge when change needs approval

## Interactions

- Review suggestions ranked by expected impact
- View concrete examples to validate suggestion quality
- Apply with one click (routes through approval if configured)
- Dismiss with reason (improves future suggestions)
- View linked eval data for context

## Navigation

- Accessible from: Eval Dashboard, Prompt Timeline
- Links to: Prompt Timeline, Eval Dashboard, A/B Test Manager
