# Step Progress Indicator

| Field | Value |
|-------|-------|
| **ID** | `step-progress-indicator` |
| **Category** | Feedback & Indicators |
| **Used In** | 08-Onboarding Tutorial, 10-Education Portal (consent flow) |

## Description

Multi-step progress tracker showing current position in a wizard/storyboard flow. Used in onboarding tutorial and consent workflows.

## Size Variants

| Variant | Description |
|---------|-------------|
| Inline | Numbered dots/steps displayed inline |

## Props / Configuration

- `totalSteps` — Total number of steps in the flow
- `currentStep` — Index of the currently active step
- `completedSteps` — Array of completed step indices
- `labels` — Per-step label strings

## Interactions

- View current progress at a glance
- Click completed steps to revisit (if navigation is permitted by flow config)
