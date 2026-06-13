# Status Indicators

> Ambient information — users glance at them, they don't study them.

---

## Why This Section Exists

Status indicators communicate system state at a glance. They answer "what's happening right now?" without requiring the user to click, hover, or read a paragraph. Because they're peripheral — seen in sidebars, table rows, dashboards, notification areas — they must be instantly parseable. If a user has to stop and think about what a status dot means, the indicator has failed.

## What to Include

### The Status Vocabulary

Every product has its own set, but most map to a common core:

| Status | Typical Labels | Semantic Color | Behavior |
|--------|---------------|----------------|----------|
| Queued / Pending | "Waiting," "Queued," "Scheduled" | Neutral gray or blue | Static |
| Active / Building | "In Progress," "Running," "Building" | Blue or accent | Pulse animation |
| Reviewing / Warning | "Needs Review," "Attention," "Warning" | Yellow / amber | Static |
| Done / Success | "Complete," "Deployed," "Live" | Green | Static |
| Error / Failed | "Failed," "Error," "Rejected" | Red | Static |

Adapt the labels and count to your product. A CI/CD tool might need "queued, building, testing, deploying, live, failed." A content platform might need "draft, review, scheduled, published, archived."

### Visual Encoding

Three channels encode status. Use at least two per indicator:

- **Color** — semantic palette from section 02. Green is always success. Red is always error. Don't subvert these associations.
- **Shape** — squares or rounded rectangles for data-dense contexts (tables, lists). Circles for decorative or dashboard contexts. Pick one convention and hold it.
- **Animation** — pulse animation for the "active" state only. Subtle: opacity oscillation between 1.0 and 0.6, 2-second cycle. Everything else is static. If multiple statuses animate, the UI becomes noisy.

### Anatomy of a Status Indicator

Each status needs:

1. **Visual indicator** — the colored shape (dot, badge, or chip).
2. **Label** — text name of the status. Always present; never rely on color alone (accessibility).
3. **Description** (optional) — a short line of context. "Deployed 3m ago" or "Waiting for approval." Useful in detail views, unnecessary in dense tables.

## Best Practices

- **Limit to 5-7 statuses.** If you need more, your state model is too complex for visual indicators. Collapse states or use a different pattern (timeline, log view).
- **Semantic colors are non-negotiable.** Green = success. Red = error. Yellow = warning. Blue = active/info. Gray = neutral/pending. Users bring these associations from every other product they've used. Don't fight them.
- **Animate only the active state.** One pulsing dot draws the eye to what's in progress. Five pulsing dots create anxiety. Animation is an attention budget — spend it on the one state that changes.
- **Never rely on color alone.** Color-blind users need shape, label, or icon as a secondary channel. A red dot labeled "Failed" works. A red dot alone doesn't.
- **Consistent size.** Status indicators in a list should all be the same size. Don't make "error" bigger than "success" — that's editorializing, not indicating.

## Template Usage

Use `StatusGrid` as a flex container wrapping individual `StatusIndicator` components.

`StatusIndicator` props: `className` (maps to a status CSS class), `label` (string), `desc` (string, optional).

Define CSS classes per status: `.status-indicator.queued`, `.status-indicator.active`, `.status-indicator.warning`, `.status-indicator.success`, `.status-indicator.error`. Each class sets the indicator's background color.

Add a `.status-indicator.active` animation:

```css
.status-indicator.active .indicator-dot {
  animation: pulse 2s ease-in-out infinite;
}
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.6; }
}
```

Shape (square vs. circle) and size are design decisions — set them in the base `.status-indicator` class via `border-radius` and `width`/`height`.

## When to Skip

Simple content sites, static portfolios, or single-action tools without async processes don't need status indicators. If nothing in the product runs in the background, queues, or fails, this section doesn't apply.

## Anti-Patterns

- **Too many status levels.** More than 7 statuses means the state model needs simplification, not more colors.
- **Colors that don't match semantic meaning.** Green for "pending" and gray for "success" will confuse every user on first encounter and most users on the tenth.
- **Animations on every status.** Only active/in-progress should pulse. Animating success, error, and pending creates visual noise and buries the signal.
- **Status dots without labels.** A colored dot in a table column means nothing to a new user or a color-blind user. Always pair with text.
- **Inconsistent placement.** If status appears left-of-label in one view and right-of-label in another, users have to re-learn the pattern each time. Pick a position and hold it.

## Dependencies

- **02 — Color Palette**: Semantic colors (green, red, yellow, blue, gray) must be defined in the palette before status indicators can reference them.
- **03 — Typography**: Label and description font, size, and color.
- **04 — Spacing / Layout**: Grid gap for `StatusGrid`, internal padding for indicator chips.
- **07 — Navigation**: Active states in navigation and active status indicators should use consistent visual language (same blue, same pulse if applicable).
