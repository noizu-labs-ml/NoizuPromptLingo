# Style Guide Section Reference

> Content guidance for each section of an HTML style guide. Documents *what* to include, *why* it matters, and best practices — independent of any specific visual style.

For the *construction process*, see [`process/style-guide-construction.md`](../../process/style-guide-construction.md).
For the *HTML rendering process*, see [`outputs/html-style-guide.md`](../html-style-guide.md).
For a worked example, see `styleguide-reference.html` in the fivetillplan project.

---

## Reading Order

Sections are numbered to reflect the order they should appear in a finished style guide. This order is deliberate — each section builds on the ones before it.

| # | File | Section | Why This Position |
|---|------|---------|-------------------|
| 00 | [00-header-branding.md](00-header-branding.md) | Header & Product Branding | Sets identity context before any design decisions |
| 01 | [01-design-tokens.md](01-design-tokens.md) | Design Tokens | Primitive values that everything else references |
| 02 | [02-color-palette.md](02-color-palette.md) | Color Palette | First visual layer — applied tokens |
| 03 | [03-typography.md](03-typography.md) | Typography | Second visual layer — how text renders |
| 04 | [04-spacing.md](04-spacing.md) | Spacing, Gutters & Whitespace | Structural layer — how elements relate spatially |
| 05 | [05-buttons.md](05-buttons.md) | Buttons | Simplest interactive element, establishes interaction language |
| 06 | [06-inputs.md](06-inputs.md) | Input Fields | Form primitives — builds on button patterns |
| 07 | [07-navigation.md](07-navigation.md) | Navigation | Wayfinding — uses tokens, type, and spacing together |
| 08 | [08-status-indicators.md](08-status-indicators.md) | Status Indicators | Data display primitives — semantic color in action |
| 09 | [09-cards.md](09-cards.md) | Cards | First compound component — containers for content |
| 10 | [10-core-components.md](10-core-components.md) | Core Component Reference | Headless UI widgets themed to the system |
| 11 | [11-project-components.md](11-project-components.md) | Project Components | Domain-specific compositions from core parts |
| 12 | [12-screens.md](12-screens.md) | Screens | Full-page compositions showing everything together |

## Architecture: Atoms → Molecules → Organisms → Pages

The section order follows atomic design principles:

```
Tokens (subatomic) → Colors, Type, Spacing (atoms)
  → Buttons, Inputs, Status (molecules)
    → Cards, Nav, Components (organisms)
      → Project Components (templates)
        → Screens (pages)
```

Each section should be self-contained enough to read alone, but the cumulative effect builds a complete system. A reader scanning top-to-bottom goes from "what are the raw values?" to "what does a finished screen look like?"

## When to Use These References

| Situation | Action |
|-----------|--------|
| Building a new style guide from scratch | Read all sections in order |
| Adding a section to an existing guide | Read that section's file + its dependencies |
| Reviewing a style guide for completeness | Use the table above as a checklist |
| Deciding whether a section is needed | Read the "Why This Section Exists" block in each file |
