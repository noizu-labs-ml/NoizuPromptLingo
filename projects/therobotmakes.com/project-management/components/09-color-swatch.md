# Color Swatch

| Field | Value |
|-------|-------|
| **ID** | `color-swatch` |
| **Category** | Data Display |
| **Used In** | 12-Style Preset Picker, 13-Color Palette Editor |

## Description

Individual color display with hex/RGB value, semantic role label, and WCAG contrast badge. Clickable to open color picker for editing.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Small circle with tooltip |
| **Compact** | Rectangle with value label |
| **Expanded** | Large swatch with role, value, contrast ratio, and picker trigger |

## Props / Configuration

- `color` — Hex/RGB value
- `role` — Semantic role (primary, secondary, accent, etc.)
- `contrastRatio` — Number (against background)
- `wcagPass` — Boolean
- `editable` — Boolean

## Interactions

- Click (when editable) → opens color picker
- Hover → shows contrast ratio tooltip
- WCAG badge shows pass (green) or fail (red)
