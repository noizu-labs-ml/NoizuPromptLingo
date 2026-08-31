# 25: Step Wizard / Step Indicator

| Field | Value |
|-------|-------|
| ID | CMP-25 |
| Category | Navigation & Layout |
| Surfaces | web, cli-ink |
| Used In | SCR-06, SCR-22 |

## Description
5-step progress control driving the Convert Wizard (Select Type → Select Messages → Configure → Preview → Export). Cli-ink's `StepIndicator.tsx` is the direct terminal equivalent.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Default | Convert Wizard header |

## Props / Configuration
- `steps` — ordered list of step labels
- `currentStep` — index
- `completedSteps` — set of indices, back-navigable without data loss

## Interactions
- Forward advance validates the current step before allowing progress
- Back navigation preserves all previously entered data
