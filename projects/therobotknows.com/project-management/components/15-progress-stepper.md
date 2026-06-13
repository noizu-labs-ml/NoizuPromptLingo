# Progress Stepper

| Field | Value |
|-------|-------|
| **ID** | `progress-stepper` |
| **Category** | Navigation & Layout |
| **Used In** | S02 Universe Creation Wizard, S00 Onboarding Tour |

## Description

Multi-step wizard progress indicator rendered as a horizontal (or optionally vertical) track of numbered steps with labels. Each step displays one of three states: upcoming, current, or completed. Provides navigational affordance to jump back to completed steps.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Horizontal compact strip with step numbers and short labels; used inside modal wizards |
| **Expanded** | Full horizontal bar with step numbers, labels, and optional sub-labels; used on dedicated wizard pages |

## Props / Configuration

- `steps` — Array of `{ id: string, label: string, sublabel?: string }` step definitions
- `currentStep` — Index (0-based) of the active step
- `completedSteps` — Set of step indices that are completed; defaults to all indices before `currentStep`
- `onStepClick` — Callback with step index when a completed step is clicked; omit to make stepper non-interactive
- `orientation` — `horizontal` (default) | `vertical`
- `showLabels` — Boolean; hide labels on narrow viewports if false (default: `true`)

## Interactions

- Completed steps show a checkmark icon and are clickable if `onStepClick` is provided, allowing non-linear navigation back to earlier steps
- Current step is highlighted with the primary brand color and a filled circle
- Upcoming steps are dimmed and non-interactive
- Clicking a completed step fires `onStepClick` with its index; the host wizard is responsible for updating `currentStep`
- Progress connector line between steps fills progressively as steps are completed
- On narrow viewports in horizontal mode, only the current step label is shown; others collapse to dots
