# 04 — Spacing & Layout

> The spacing scale, container specs, whitespace principles, and layout diagrams that define the system's spatial rhythm.

---

## Why This Section Exists

Spacing is invisible design. You never see it directly — you see its effects: elements that breathe, content that groups logically, interfaces that feel composed rather than crammed. Spacing is also where most inconsistency creeps in, because it's the easiest thing to eyeball and hardest thing to audit. This section makes the invisible visible: a defined scale, documented container specs, stated principles, and annotated layout diagrams that remove guesswork from spatial decisions.

## What to Include

### The Base Unit

Every spacing system needs a base unit — typically 4px or 8px. All spacing values are multiples of this unit. Document it explicitly:

- What the unit is (e.g., `--unit: 8px`)
- Why it was chosen (8px aligns to most icon grids and device pixels)
- The rule: all spacing snaps to multiples of this unit

### Spacing Scale

A progressive set of named spacing values:

| Token | Value | Typical Use |
|-------|-------|-------------|
| `--space-1` | 8px | Tight internal padding, inline gaps |
| `--space-2` | 16px | Standard padding, form field gaps |
| `--space-3` | 24px | Card padding, subsection gaps |
| `--space-4` | 32px | Section internal padding |
| `--space-6` | 48px | Section headers, major component gaps |
| `--space-8` | 64px | Section-to-section spacing |
| `--space-12` | 96px | Major layout divisions |
| `--space-16` | 128px | Hero padding, page-level breathing room |

The scale doesn't need to be linear. Jumps (skipping `--space-7`, `--space-9`) are fine — what matters is that each step has a clear use case.

### Container Specifications

Document the page-level layout decisions:

- **Page max-width** — how wide the content area goes (e.g., 960px, 1200px)
- **Gutter width** — padding between content and viewport edge
- **Content max-width** — reading-width constraint for body text (e.g., 640px)
- **Column gap** — spacing between grid columns
- **Centering strategy** — `margin: 0 auto`, flexbox, or grid-based

### Whitespace Principles

Short, opinionated statements that capture the system's spatial philosophy:

- "Empty space is intentional, not leftover."
- "When in doubt, double the padding."
- "Group related elements with tight spacing; separate unrelated elements with generous spacing."
- "Content max-width protects readability — never let body text run to the viewport edge."

These principles help implementers make consistent decisions in edge cases the scale doesn't explicitly cover.

### Layout Diagram

A schematic showing how the page is structured spatially — viewport, gutters, content area, sections — with annotated measurements. This is the spatial blueprint.

## Best Practices

1. **Everything snaps to the grid.** No `padding: 13px`. No `margin-top: 7px`. If a value doesn't match a token, either the value is wrong or the scale needs a new step.
2. **Document the reasoning, not just the values.** "Section spacing is 96px to create clear visual breaks between major content groups" is more useful than "section spacing: 96px."
3. **Fewer scale steps are better.** A 20-step spacing scale is a 20-step decision problem. 8-12 steps covers nearly every layout need.
4. **Gutters should be consistent.** If the left gutter is 40px on desktop, the right should be 40px too. If they change at breakpoints, document both.
5. **Vertical rhythm matters more than horizontal.** Users scroll vertically. The spacing between sections, headings, and paragraphs determines whether the page feels composed or chaotic.
6. **Test spacing at extremes.** Check both narrow mobile (320px) and wide desktop (1920px). The scale should hold at both ends.

## Template Usage

Section 04 in `assets/styleguide-template.html` has the most available components. Use whichever are relevant to the design — not every system needs all of them.

### SpacingScale props

| Prop | Type | Notes |
|------|------|-------|
| `steps` | {px, label}[] | Array of spacing steps, each rendered as a horizontal bar |

Each step:
- `px` — pixel value (number), used as the bar width
- `label` — name for this step (e.g., "space-1", "xs", "section")

Renders as a bar chart where each step's width visually represents its value.

### SpecTable props

| Prop | Type | Notes |
|------|------|-------|
| `columns` | string[] | Column header labels (e.g., ["Property", "Value", "Rationale"]) |
| `rows` | string[][] | Array of row arrays. Each cell is a string (HTML supported) |

Use for documenting container specs, breakpoints, or any structured property/value/rationale data.

### Principles props

| Prop | Type | Notes |
|------|------|-------|
| `items` | {rule, detail}[] | Array of principle objects, auto-numbered |

Each item:
- `rule` — bold statement (the principle itself)
- `detail` — explanatory text

### SpacingDiagram props

| Prop | Type | Notes |
|------|------|-------|
| `title` | string | Diagram heading (e.g., "Page Layout Schematic") |
| `blocks` | {label, meta, compact?}[] | Content blocks shown inside the layout |

Each block:
- `label` — section name (e.g., "Hero", "Content", "Footer")
- `meta` — spacing annotation (e.g., "py: 144px")
- `compact` — boolean, uses smaller padding hatching if true

The diagram renders a viewport with gutters on each side and content blocks stacked vertically with annotated padding.

### SectionDesc props

| Prop | Type | Notes |
|------|------|-------|
| `children` | node | Paragraph text, max-width constrained for readability |

Use below SectionHeader to introduce the spacing philosophy before the scale and specs.

### Recommended layout

```
SectionHeader number="04" title="Spacing & Layout"
SectionDesc — introductory paragraph about spatial philosophy

Subsection: "Scale"
  SpacingScale — bar chart of all spacing tokens

Subsection: "Container Specs"
  SpecTable — page width, gutters, content width, column gap

Subsection: "Principles"
  Principles — 3-5 spatial design rules

Subsection: "Layout Diagram"  (optional)
  SpacingDiagram — annotated page schematic
```

## Anti-Patterns

- **Spacing values that don't follow the scale.** A component with `padding: 18px` in a system based on 8px units is a bug, not a design decision.
- **No rationale for choices.** "Max-width: 960px" without explaining why invites someone to change it to 1200px next week.
- **Gutters that change arbitrarily.** If the gutter is 40px on the homepage and 24px on the settings page without a documented reason, the system is inconsistent.
- **Skipping the diagram.** The spatial relationship between viewport, gutters, and content is hard to communicate in tables alone. A diagram makes it concrete.
- **Too many scale steps.** If the scale has `--space-1` through `--space-24`, implementers will use adjacent values interchangeably. Keep the steps far enough apart to be visually distinct.
- **No mobile spacing guidance.** If the spacing scale only works at desktop widths, it's incomplete. Document how spacing adapts (or doesn't) at breakpoints.

## Dependencies

- **References** Section 01 (Design Tokens) — spacing tokens (`--space-*`, `--unit`, `--col-gap`) defined there are visualized here.
- **Referenced by** all component and layout sections — every margin, padding, and gap should use a value documented in this scale.
- **Related to** Section 03 (Typography) — line height and vertical spacing interact. Changes to the type scale may require spacing adjustments.
