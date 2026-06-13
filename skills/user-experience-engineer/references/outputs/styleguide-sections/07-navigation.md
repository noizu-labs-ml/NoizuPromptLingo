# Navigation

> Users need to know where they are, where they've been, and where they can go.

---

## Why This Section Exists

Navigation is spatial memory made visible. Without it, users lose context — they don't know how far along they are, what they've completed, or what's ahead. This section defines the wayfinding patterns that orient users within multi-step flows, multi-section tools, or any product with more than one screen.

## What to Include

### Pattern 1: Phase Tabs

Horizontal segments showing workflow stages. Each tab is a discrete phase (e.g., "Configure," "Review," "Deploy"). Users can see all phases at once and understand their position in the overall flow.

Show all states in a single demo row so the visual difference between them is immediately obvious:

- **Default (inactive)** — muted text, no fill. Available but not current.
- **Active (current)** — highest contrast. Filled background (black or primary), inverted text. Unmistakable.
- **Completed** — distinct from active. Checkmark icon or success color. Signals "done" without looking like "current."
- **Locked / Disabled** — reduced opacity, no pointer cursor. The phase exists but isn't available yet.

### Pattern 2: Step Progress

A thin horizontal bar showing linear progress through a sequence. Simpler than phase tabs — no labels per step, just a visual ratio of done-to-remaining.

Show with a fraction label ("3 / 7") and an optional stage name ("Uploading assets..."). The bar itself should use the primary or accent color for the filled portion and a muted background for the remainder.

### State Vocabulary

Across all navigation patterns, these states should be visually distinct and never ambiguous:

| State | Meaning | Visual Treatment |
|-------|---------|-----------------|
| Default | Available, not current | Low contrast, no fill |
| Active | Current position | Highest contrast, filled |
| Completed | Previously finished | Distinct from active (checkmark, muted fill, success color) |
| Locked | Not yet available | Reduced opacity (0.4-0.5), cursor not-allowed |

## Best Practices

- **Active state is the highest contrast element.** If active doesn't stand out immediately in a row of tabs, it's not working. Filled black (or primary) with inverted text is the safe default.
- **Completed must not look like active.** This is the most common navigation bug. A green checkmark or a lighter fill distinguishes "done" from "here." Test by glancing at the row for one second — can you instantly identify the current step?
- **Locked states need both visual and interaction cues.** Reduced opacity plus `cursor: not-allowed`. Optionally, a tooltip explaining what unlocks the phase.
- **Show all states in one demo.** Don't show four separate screenshots — show one row with default, active, completed, and locked tabs side by side. The comparison is the point.
- **Label everything.** Progress bars without labels are decoration. "Step 3 of 7" or "Reviewing" gives the bar meaning.

## Template Usage

`PhaseTabs` accepts a `tabs` array of objects: `{ label: string, state?: string, style?: object }`. States map to CSS classes: `.phase-default`, `.phase-active`, `.phase-completed`, `.phase-locked`.

`StepProgress` accepts props: `total` (number), `done` (number), `current` (number), `label` (string). It renders a thin bar with the filled portion calculated as `(done / total) * 100%`.

These are starting points. Replace with breadcrumbs, sidebar nav, tab bars, or whatever patterns the product actually needs. The point of this section is to establish the state vocabulary (default, active, completed, locked) and ensure those states are visually consistent across whatever navigation pattern you use.

## When to Skip

If the product is a single-page tool with no multi-step flows, no sections, and no sub-pages, this section may not apply. A landing page or a single-screen calculator doesn't need navigation patterns. Include this section only when the product has genuine wayfinding needs.

## Anti-Patterns

- **Navigation that doesn't show current position.** If the user can't instantly see where they are, the navigation is failing its primary job.
- **Completed state that looks like active.** Both are "positive" states, so designers often make them too similar. They must be visually distinct.
- **Progress bars without labels.** A bar at 43% means nothing without context. What is 43% of? What step are we on?
- **Too many phases.** If the tab row has 10+ items, the flow is too complex for horizontal tabs. Consider a vertical stepper or a different IA.
- **Clickable locked states.** If a phase is locked, clicking it should do nothing (or show a tooltip). Don't navigate to an empty or broken state.

## Dependencies

- **02 — Color Palette**: Active fill color, completed/success color, locked opacity values.
- **03 — Typography**: Tab label font, progress label font, checkmark icon.
- **04 — Spacing / Layout**: Tab gap, bar height, overall navigation container width.
- **05 — Buttons**: Active/disabled state treatments should feel consistent between buttons and navigation tabs.
