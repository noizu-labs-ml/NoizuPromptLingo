# Buttons

> The simplest interaction primitive — one action, one click.

---

## Why This Section Exists

Buttons are the first interactive element to define because they reduce interaction to its atomic form: a single user intent mapped to a single system response. Every other interactive pattern (forms, modals, flows) builds on top of button conventions. If button hierarchy, sizing, and states aren't resolved here, inconsistency cascades through every screen.

## What to Include

### Variants (priority tiers)

- **Primary / Default** — filled background, high contrast. The main action in any context.
- **Secondary / Outline** — border only, no fill. Supports the primary without competing.
- **Ghost / Text** — no border, no fill. For low-priority or repeated actions (cancel, dismiss, "learn more").
- **Danger / Destructive** — red fill or red text. Irreversible or high-consequence actions only.

### Sizes

- **Small (sm)** — compact UI, inline actions, table rows.
- **Default** — standard interactive contexts.
- **Large (lg)** — hero CTAs, onboarding flows, mobile touch targets.

### States (show all for every variant)

- **Default** — resting appearance.
- **Hover** — subtle background shift or elevation change. Cursor pointer.
- **Focus** — visible focus ring (2px offset, accent color). Non-negotiable for accessibility.
- **Active / Pressed** — slight scale-down or color darken. Confirms the click registered.
- **Disabled** — reduced opacity (0.5). Cursor not-allowed.

### The Hierarchy Principle

One primary action per context. If two buttons feel equally important, the information architecture is wrong — resolve the priority upstream, not with styling.

Secondaries support ("Cancel," "Save Draft"). Ghosts handle tertiary actions. Danger is a variant of primary, not a separate tier — it replaces primary when the action is destructive.

## Best Practices

- **Consistent padding ratios** across sizes. If default is `10px 20px`, small should be `6px 14px` and large should be `14px 28px`. The ratio stays constant; the base scales.
- **Focus rings are not optional.** 2px solid, accent color, 2px offset from the button edge. Users navigating by keyboard must see where they are.
- **Match border-radius to the system.** If the design language is sharp (no radius on cards, inputs), buttons should be sharp too. Don't mix.
- **Verb labels, not nouns.** "Deploy" not "Deployment." "Save" not "Save Button." The button is the verb.
- **Minimum touch target** of 44x44px on mobile regardless of visual size.

## Template Usage

Use the `Btn` component with props: `variant` (primary, outline, ghost, danger), `size` (sm, default, lg), and `label` (string).

Wrap related buttons in a `ButtonRow` container for consistent spacing and alignment.

In the style tag, define `.btn-primary`, `.btn-outline`, `.btn-ghost`, `.btn-danger` CSS classes. Size modifiers go on the same element: `.btn-sm`, `.btn-lg`.

Group the demo by priority tier: primary row first, then outline/ghost row, then danger row. This visually reinforces the hierarchy.

## Anti-Patterns

- **Too many variants.** If you have 8 button styles, something is wrong. Audit the actual use cases — most can collapse into 3-4.
- **No focus states.** This is an accessibility failure, not a style choice.
- **Disabled buttons with no explanation.** A grayed-out button without a tooltip or adjacent text explaining *why* it's disabled is a dead end. Tell the user what's missing.
- **Using color alone to distinguish variants.** Outline vs. ghost should differ structurally (border vs. no border), not just by hue.
- **"Click Here" labels.** If the button needs the word "click," the surrounding context isn't doing its job.

## Dependencies

- **02 — Color Palette**: Primary, accent, and danger colors define button fills and focus ring color.
- **03 — Typography**: Font family, weight, and size for button labels.
- **04 — Spacing / Layout**: Padding scale and gap values for `ButtonRow`.
