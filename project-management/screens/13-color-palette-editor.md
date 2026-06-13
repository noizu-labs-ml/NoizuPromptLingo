# Color Palette Editor

| Field | Value |
|-------|-------|
| **ID** | `color-palette-editor` |
| **Type** | Primary |
| **Category** | Draft Phase |
| **User Stories** | INK-023 |

## Description

AI generates a semantic color palette (primary, secondary, accent, neutral, success, warning, error) from the selected preset. Users can tweak individual colors with WCAG contrast validation.

## Key Components

- **Color Swatch Grid** — Semantic color roles with generated values (INK-023)
- **WCAG Contrast Badges** — Pass/fail indicators per color combination (INK-023)
- **Color Picker** — Per-swatch picker for manual adjustment (INK-023)
- **Token Export** — CSS custom properties / design token preview (INK-023)

## Interactions

- Click any swatch to open color picker
- WCAG badges update in real-time as colors change
- "Regenerate" produces new palette preserving accepted swatches
- "Accept" advances to Typography Scale

## Navigation

- Accessible from: Style Preset Picker
- Links to: Typography Scale
