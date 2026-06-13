# Story Curation

| Field | Value |
|-------|-------|
| **ID** | `story-curation` |
| **Type** | Primary |
| **Category** | Sketch Phase |
| **User Stories** | INK-013, INK-014, INK-015, INK-016 |

## Description

AI generates user stories grouped by persona with acceptance criteria. Users curate, reorder, add custom stories, and request more per persona. Drag-and-drop for priority.

## Key Components

- **Story Cards by Persona** — Collapsible persona sections with "As a / I want / So that" cards, AC checkboxes, priority badges (INK-013)
- **Curation Controls** — Accept/Reject/Edit per story card (INK-014)
- **Summary Bar** — Accepted/Rejected/Pending counts (INK-014)
- **Drag-and-Drop Reorder** — Handles on cards for priority ordering (INK-014)
- **Add Story Button** — Per-persona + top-level inline story form (INK-015)
- **Generate More Button** — Per-persona with optional focus area input (INK-016)

## Interactions

- Persona sections collapsible with expand/collapse all
- Drag-and-drop reorders within and across persona groups
- Accept/Reject/Edit mirrors persona curation pattern
- Summary bar updates in real-time
- "Generate More" with focus area constraint appends new story cards

## Navigation

- Accessible from: Persona Curation completion
- Links to: PRD View (when minimum stories accepted)
