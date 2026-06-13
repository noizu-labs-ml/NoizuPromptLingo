# Section 10 — Core Components

> Headless UI primitives themed to the design system — the interactive building blocks.

---

## Why This Section Exists

Accessible interactive widgets (dropdowns, modals, tabs, toggles) are notoriously difficult to build correctly. Keyboard navigation, focus management, ARIA attributes, screen reader announcements — getting these right from scratch is a multi-week effort per component.

Headless UI provides the behavior. This section shows how those behaviors *look* in your theme. It bridges the gap between "we have accessible primitives" and "our product has a consistent interactive vocabulary."

This is typically the largest section in the style guide.

## What to Include

### The Headless UI Component Catalog

Organize by interaction type:

#### Selection Components
- **Menu** — dropdown menu triggered by a button. Show open state with 3-4 items, one highlighted.
- **Listbox** — custom select with styled options. Show expanded with a selected item.
- **Combobox** — searchable select. Show with input focused and filtered results.
- **Select** — native `<select>` styled to match the system. Show default and open states.

#### Toggle Components
- **Switch** — on/off toggle. Show both states side by side.
- **Checkbox** — single and grouped. Show unchecked, checked, indeterminate.
- **Radio Group** — mutually exclusive options. Show with one selected.

#### Disclosure Components
- **Disclosure** — accordion/collapsible. Show one open, one closed.
- **Dialog** — modal overlay. Show centered with backdrop dimming.
- **Popover** — floating panel anchored to a trigger. Show open with content.
- **Tabs** — tab group with panels. Show with one tab active.

#### Form Components
- **Input** — text input with placeholder, filled, error, disabled states.
- **Textarea** — multiline input. Show default and focused.
- **Fieldset** — form grouping with legend. Show wrapping related inputs.
- **Button** — with `data-*` states: default, hover, active, disabled, loading.

#### Utility
- **Transition** — enter/leave animation classes. Document the timing and easing tokens used.

### State Previews

For each component, show key states statically using CSS classes:

- `.checked`, `.selected`, `.open` — active states
- `.disabled` — reduced opacity, no pointer events
- `.focus-visible` — focus ring visible
- `.hover` — hover treatment

No JavaScript required in the style guide. States are shown simultaneously so all treatments are visible at once.

### CSS Convention

All Headless UI themed styles use the `hui-*` prefix:

- `hui-menu`, `hui-menu-item`, `hui-menu-item--active`
- `hui-switch`, `hui-switch--on`, `hui-switch--off`
- `hui-dialog`, `hui-dialog-backdrop`, `hui-dialog-panel`

This isolates Headless UI theming from custom component styles.

## Best Practices

- **Only include components your product uses.** If the product has no combobox, don't theme one. Five well-documented components beat sixteen half-baked ones.
- **Show the most important states inline.** Don't make people click to discover what hover looks like. Render default, active, and disabled side by side.
- **Reference the Headless UI import path** in each component's description. Developers need to know it's `@headlessui/react` → `Menu`, not a custom build.
- **Focus rings on everything interactive.** If it accepts keyboard input, it gets a visible focus indicator. No exceptions.
- **Consistent sizing across component types.** A Menu trigger and a Listbox trigger at the same hierarchy level should be the same height.

## Template Usage

### Components

- `WidgetDemo` — props: `title`, `badge`, `desc`, `children`
  - `title`: display name (e.g., "Dropdown Menu")
  - `badge`: short label (e.g., "Menu")
  - `desc`: Headless UI component reference (e.g., "Menu, MenuButton, MenuItems, MenuItem")
  - `children`: the themed preview markup using `hui-*` classes

### Layout

Wrap all widget demos in `<div className="widget-grid">`. This provides a responsive grid layout — 2 columns on desktop, 1 on mobile.

### Example Structure

```
<div className="widget-grid">
  <WidgetDemo title="Dropdown Menu" badge="Selection" desc="Menu, MenuButton, MenuItems, MenuItem">
    {/* Preview with hui-menu classes showing open state */}
  </WidgetDemo>

  <WidgetDemo title="Toggle Switch" badge="Toggle" desc="Switch">
    {/* Preview with hui-switch classes showing on/off */}
  </WidgetDemo>
</div>
```

## Anti-Patterns

- **Showing all 16 components when only 5 are used.** Unused components are noise. They create maintenance burden and confuse developers about what's actually available.
- **Previews that show only the default state.** A closed dropdown tells you almost nothing. Show open, selected, and disabled or the preview is incomplete.
- **Missing focus styles.** If a component can be tabbed to, it needs a visible focus ring. "We'll add focus styles later" means "we'll ship inaccessible."
- **Forgetting the `desc` prop.** The description is the developer's import reference. Without it, they have to search documentation to find the component name.
- **Inconsistent interaction patterns.** If Menu opens on click, Popover should too — unless there's a documented reason for the difference.
- **Styling that fights Headless UI defaults.** Headless UI manages ARIA and focus. Don't override `aria-expanded` or trap focus manually — theme the visuals, trust the library for behavior.

## Dependencies

| Section | What It Provides |
|---|---|
| 01 — Design Tokens | Spacing, radius, shadow values for component chrome |
| 02 — Color Tokens | Interactive state colors (hover, active, focus ring) |
| 03 — Typography | Label and option text sizing |
| 04 — Spacing | Internal padding, gap between options |
| 05 — Buttons | Button component used as triggers for Menu, Popover, Dialog |
| 08 — Status & Metadata | Badge styling used in `WidgetDemo` headers |
