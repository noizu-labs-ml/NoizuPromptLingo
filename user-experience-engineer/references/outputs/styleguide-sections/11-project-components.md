# Section 11 — Project Components

> Domain-specific composite components unique to the product — where the design system meets the problem space.

---

## Why This Section Exists

Core components (Section 10) are generic building blocks. A dropdown is a dropdown in any product. Project components are assembled FROM those blocks into interfaces that only make sense in *this* product's context.

A "story backlog" component combines a list, status dots, and cards. An "agent controls" toolbar combines buttons, switches, and status indicators. These compositions don't exist in any component library — they emerge from the domain.

This section documents those compositions so they're built consistently every time they appear.

## What to Include

### Domain-Specific Widgets

Examples of project components (these will differ per product):

- **Code block** — syntax-highlighted terminal display with language badge and copy action
- **Terminal output** — live feed with timestamps, auto-scroll, monospace text on dark background
- **Story backlog** — list of items with status dots (from Section 08), drag handles, priority indicators
- **Acceptance criteria** — checklist with completion stats (e.g., "3/5 done"), checkboxes, inline editing
- **Agent controls** — approve/reject toolbar with confirmation states, status badge, action buttons
- **Geometric brand elements** — decorative shapes that reinforce brand identity in empty states or backgrounds
- **Grid compositions** — multi-panel layouts using the spacing grid for dashboards or split views
- **Phase pipeline** — horizontal progress indicator composed from nav components and status badges

### The Composition Principle

Every project component should be traceable back to primitives defined in earlier sections:

- Buttons from Section 05
- Status indicators from Section 08
- Cards from Section 09
- Headless UI widgets from Section 10

If a project component introduces a new primitive (a slider, a custom chart), that primitive should be documented in Section 10 first, then composed here.

### Full-Page Composites

After the widget grid, add `sg-subsection` entries showing how project components assemble into larger layouts:

- A dashboard with backlog panel + live terminal output + acceptance criteria panel
- A workspace view with agent controls toolbar + code block + status sidebar
- A pipeline view with phase indicator + detail cards + action bar

These composites demonstrate the layout grid in action and prove the components work together at page scale.

## Best Practices

- **Name components by what they DO, not what they look like.** "Story Backlog" not "Scrollable List With Dots." "Agent Controls" not "Button Row With Status."
- **Include context.** Every project component description should state where it appears in the product. "Used on the Sprint Dashboard to display current iteration items."
- **Use realistic data.** Real task names, real status values, real timestamps. Placeholder text hides layout problems that real content reveals.
- **Composites demonstrate the grid.** Full-page composites should show column breaks, gutter alignment, and responsive stacking — proving the spacing system works at scale.
- **Start small, grow organically.** This section may be nearly empty at project kickoff. That's correct. Components get added as the product takes shape, not invented speculatively.

## Template Usage

### Widget Demos

Use the same `WidgetDemo` component from Section 10:

- `title`: component name (e.g., "Story Backlog")
- `badge`: domain category (e.g., "Agile")
- `desc`: what primitives it composes (e.g., "List + StatusDot + Card")
- `children`: the themed preview with realistic content

### Layout Classes

- `widget-grid` — standard 2-column grid for individual component showcases
- `widget-grid--full` — full-width variant for components that need horizontal space (terminals, pipelines, code blocks)

### Full-Page Composites

Add after the widget grid using `sg-subsection`:

```
<div className="sg-subsection">
  <h3>Dashboard Composition</h3>
  <p>Backlog panel + live output + criteria panel in a 3-column grid.</p>
  {/* Full-width composite with realistic data */}
</div>
```

### Growth Pattern

This section often starts with 2-3 components and grows to 8-12 as the product matures. The template should accommodate expansion without restructuring.

## Anti-Patterns

- **Project components that duplicate core components.** If it's generic enough to use in any product, it belongs in Section 10. A "styled dropdown" is a core component. A "sprint status selector" is a project component.
- **Components without context.** "Here's a card with some data in it" — what screen does it appear on? What user action triggers it? What state does it represent? Without context, the component can't be evaluated for correctness.
- **Composites with placeholder data.** "Lorem ipsum" in a dashboard layout hides whether real content fits. Use actual product terminology, realistic string lengths, and representative data volumes.
- **Inventing components speculatively.** Don't design a "notification center" component before the product has notifications. Build what's needed now, document it, expand later.
- **Breaking the composition principle.** A project component that introduces raw HTML buttons instead of using the Button from Section 05 undermines the entire system. Every element should trace back to its source section.

## Dependencies

| Section | What It Provides |
|---|---|
| 04 — Spacing | Grid and layout system for composites |
| 05 — Buttons | Action triggers inside project components |
| 06 — Navigation | Nav elements composed into pipelines and toolbars |
| 08 — Status & Metadata | Status dots, badges, metadata display |
| 09 — Cards | Container pattern for content grouping |
| 10 — Core Components | Headless UI primitives used as building blocks |
