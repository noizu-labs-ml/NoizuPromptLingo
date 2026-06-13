# Step Progress Indicator

| Field | Value |
|-------|-------|
| **ID** | `step-progress-indicator` |
| **Category** | Navigation & Layout |
| **Used In** | 06-Agent Registration Form, 27-Onboarding Flow |

## Description

Linear step indicator showing the user's position in a multi-step flow, with checkmarks for completed steps and optional labels. Supports optional non-linear navigation to completed steps.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Dot-only presentation for minimal vertical footprint |
| **Expanded** | Numbered steps with labels and checkmarks for completed steps |

## Props / Configuration

- `steps[]` — Ordered array of step objects with id, label, and optional icon
- `currentStep` — Index or ID of the currently active step
- `onStepClick` — Callback when a step node is clicked
- `allowNonLinearNav` — Whether completed steps are clickable for back-navigation
- `showLabels` — Whether step labels are rendered beneath each step node

## Interactions

- Click a completed step to navigate back to it (when `allowNonLinearNav` is enabled)
