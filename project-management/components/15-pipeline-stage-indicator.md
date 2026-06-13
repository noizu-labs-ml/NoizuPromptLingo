# Pipeline Stage Indicator

| Field | Value |
|-------|-------|
| **ID** | `pipeline-stage-indicator` |
| **Category** | Data Display |
| **Used In** | 23-Bug Detail, 27-Pipeline Status, 46-Pre-Deploy Checklist |

## Description

Horizontal multi-step progress showing stages of a pipeline/lifecycle with pass/fail/running per stage

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Compact dots/icons per stage |
| **Compact** | Labeled steps with status colors |
| **Expanded** | Full pipeline with expandable stage detail |

## Props / Configuration

- `stages` — array of {name, status}
- `currentStage` — active stage index
- `expandable` — boolean
- `onStageClick` — handler

## Interactions

- click stage to expand detail
- transition state via buttons
- auto-advance on events
