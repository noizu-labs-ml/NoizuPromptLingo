# Pitch Refinement

| Field | Value |
|-------|-------|
| **ID** | `pitch-refinement` |
| **Type** | Primary |
| **Category** | Sketch Phase |
| **User Stories** | INK-006, INK-007 |

## Description

AI takes the user's raw pitch and produces a structured refinement. Users can accept, edit, regenerate, or provide feedback for iteration. Preserves iteration history.

## Key Components

- **Side-by-Side Comparison** — Original pitch vs. AI-refined version (INK-006)
- **Action Buttons** — Accept / Edit / Regenerate controls (INK-006)
- **Feedback Input** — Textarea for directing the next iteration (INK-007)
- **Iteration History** — Collapsible list of prior versions with revert option (INK-007)

## Interactions

- "Accept" locks the refined pitch and advances to Personas
- "Edit" opens inline editing of the AI output
- "Regenerate" produces a new refinement
- Feedback + regenerate produces a targeted iteration
- History items are clickable to revert

## Navigation

- Accessible from: Pitch Input "Next" action
- Links to: Persona Generation (on accept)
