# Empty State

| Field | Value |
|-------|-------|
| **ID** | `empty-state` |
| **Category** | Feedback / Onboarding |
| **Used In** | S01 First Universe Setup, S05 Empty Canon List, S10 No Search Results, S18 No Issues Found |

## Description

Placeholder component rendered when a section or list has no data to display. Composed of an illustration (SVG or Lottie), a headline, a supporting description, and an optional primary CTA button. Variant illustrations and copy are context-specific — e.g., an empty canon shows a blank notebook, no search results shows a magnifying glass with a question mark.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | No illustration; icon + single-line message; used inside small panels and table bodies |
| **Compact** | Small illustration + headline + description; used in sidebar panels and modals |
| **Full Page** | Large illustration centered in the main content area; headline, description, and CTA |

## Props / Configuration

- `illustration` — `string` key mapping to a named SVG asset, or a React node for custom graphics
- `headline` — Primary message string; e.g. "No entries yet"
- `description` — Supporting copy; explains what the section will contain or how to add data
- `ctaLabel` — Optional button label; e.g. "Create your first entry"
- `onCta` — Callback invoked when CTA button is clicked
- `ctaHref` — Optional URL; renders CTA as a link instead of a button
- `size` — `inline | compact | full-page`

## Interactions

- CTA button or link is the sole interactive element; all other content is decorative
- Illustration respects `prefers-reduced-motion`; Lottie animations pause when motion is reduced
- In "No search results" context, CTA reads "Clear search" and resets the active filters
- Empty state is announced to screen readers via an `aria-live="polite"` region when it appears after a data load
