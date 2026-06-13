# Tutorial Overlay

| Field | Value |
|-------|-------|
| **ID** | `tutorial-overlay` |
| **Category** | Modals & Overlays |
| **Used In** | 27-Onboarding Flow |

## Description

Positioned overlay that highlights specific UI elements and presents contextual instructions. Guides new users through a step-by-step introduction to key features by spotlighting target elements and rendering instructional content alongside them.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Tooltip-only callout anchored to the target element, no backdrop |
| **Expanded** | Full overlay with semi-opaque backdrop, spotlight cutout around target, and floating instruction panel with step navigation |

## Props / Configuration

- `steps` — ordered array of step objects, each with `targetSelector`, `title`, and `content`
- `currentStep` — index of the active step
- `onNext` — callback invoked to advance to the next step
- `onPrev` — callback invoked to return to the previous step
- `onSkip` — callback invoked when the user skips the tutorial
- `onComplete` — callback invoked when the final step is acknowledged
- `targetSelector` — CSS selector for the element to highlight on the current step

## Interactions

- Next and Prev buttons call `onNext` and `onPrev` respectively
- Skip link calls `onSkip` and closes the overlay
- Final step Next/Done button calls `onComplete`
- Clicking a highlighted element may advance the step if configured
- Overlay repositions when the target element scrolls into view
