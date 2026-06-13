# Pitch Input

| Field | Value |
|-------|-------|
| **ID** | `pitch-input` |
| **Type** | Primary |
| **Category** | Sketch Phase |
| **User Stories** | INK-005, INK-008 |

## Description

Free-text input where users describe their product idea in 2-3 sentences. Auto-saves as draft. Entry point to the Sketch phase pipeline.

## Key Components

- **Pitch Textarea** — Free-text field (20-500 chars) with character counter (INK-005)
- **Auto-Save Indicator** — "Draft saved" badge confirming no work lost (INK-005)
- **Next Button** — Advances to AI Pitch Refinement (INK-005)
- **Onboarding Tips** — First-run contextual tip overlays with dismiss option (INK-085)

## Interactions

- Text auto-saves on pause (debounced)
- Character counter shows remaining/used
- "Next" enabled only when 20+ chars entered
- For returning users, shows existing draft with "Continue" (INK-008)

## Navigation

- Accessible from: Project Type Selector, Dashboard "Continue" on Sketch:Pitch project
- Links to: Pitch Refinement
