# Persona Curation

| Field | Value |
|-------|-------|
| **ID** | `persona-curation` |
| **Type** | Primary |
| **Category** | Sketch Phase |
| **User Stories** | INK-009, INK-010, INK-011, INK-012 |

## Description

AI generates 3-5 persona suggestions based on the refined pitch. Users curate (accept/reject/edit), add custom personas, and request more. Running tally tracks progress.

## Key Components

- **Persona Card Grid** — AI-generated persona cards (name, role, goal, frustration, behavior) with reasoning blurb (INK-009)
- **Curation Controls** — Accept/Reject/Edit per card with undo on rejected (INK-010)
- **Running Tally** — "3 of 5 accepted" progress summary (INK-010)
- **Add Custom Persona Button** — Inline form for manual persona entry, tagged "Custom" (INK-011)
- **Suggest More Button** — Request additional AI suggestions with optional hint/constraint (INK-012)

## Interactions

- Accept moves card to "Accepted" section
- Reject fades card with "Undo" option
- Edit opens inline form pre-filled with AI content
- "Add Custom" opens blank inline form
- "Suggest More" with optional hint appends new cards
- Minimum 2 accepted personas required to advance

## Navigation

- Accessible from: Pitch Refinement "Accept"
- Links to: Story Generation (when minimum personas accepted)
