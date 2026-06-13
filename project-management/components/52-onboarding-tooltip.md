# Onboarding Tooltip

| Field | Value |
|-------|-------|
| **ID** | `onboarding-tooltip` |
| **Category** | Onboarding |
| **Used In** | S-01 First-Run Experience, S-02 Onboarding Tour |

## Description

Guided tour tooltip with a semi-transparent highlight overlay focused on the current target UI element. Displays a step counter, contextual description, and navigation controls (Next, Back, Skip). Part of a sequential tour sequence that walks new users through key features.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Tooltip only, no overlay backdrop — used for in-context hints after initial tour |
| **Expanded** | Full overlay with spotlight cutout, step counter, description, and nav buttons — used during the primary onboarding sequence |

## Props / Configuration

- `stepIndex` — Zero-based index of the current tour step
- `totalSteps` — Total number of steps in the tour sequence
- `title` — Short headline for this step (≤40 chars)
- `description` — Explanatory text for the highlighted element (≤160 chars)
- `targetSelector` — CSS selector or element ref of the UI element to highlight
- `placement` — Tooltip placement relative to target: `"top"` | `"bottom"` | `"left"` | `"right"` | `"auto"`
- `variant` — `"compact"` | `"expanded"` (default: `"expanded"`)
- `allowSkip` — Boolean; shows Skip Tour button when true (default: true)
- `onNext` — Callback advancing to next step
- `onBack` — Callback returning to previous step
- `onSkip` — Callback invoked when user skips the entire tour
- `onComplete` — Callback invoked after the final step's Next is clicked

## Interactions

- Overlay dims the entire viewport except the target element, which is highlighted via a cutout effect
- Tooltip is positioned relative to target with 12px offset; auto-adjusts if it would overflow the viewport
- Step counter renders as "Step N of M" with a progress dots row
- Back button is hidden on the first step; Next button label changes to "Finish" on the final step
- Skip Tour requires no confirmation and marks the tour as completed in user preferences
- Pressing Escape is equivalent to Skip Tour
- Tour progress is persisted so returning users do not see completed tours again
- Clicking outside the tooltip (but not on the highlighted element) does nothing — prevents accidental dismissal
