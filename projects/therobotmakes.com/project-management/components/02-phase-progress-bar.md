# Phase Progress Bar

| Field | Value |
|-------|-------|
| **ID** | `phase-progress-bar` |
| **Category** | Data Display |
| **Used In** | 05-Projects Dashboard, 11-PRD Editor, 24-Agent Development |

## Description

Horizontal 4-segment indicator showing project progress through Sketch/Draft/Ink/Publish phases. Segments show complete (filled), active (pulsing), or locked (greyed + lock icon) state.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Thin bar with no labels (inside cards) |
| **Compact** | Bar with phase labels below |
| **Expanded** | Bar with step count per phase |

## Props / Configuration

- `phases` — Array of {name, status: complete|active|locked, stepsCompleted, stepsTotal}
- `showLabels` — Boolean
- `showStepCount` — Boolean

## Interactions

- Hover locked segment → upgrade tooltip
- Click active segment → navigate to that phase
