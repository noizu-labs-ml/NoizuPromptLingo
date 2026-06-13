# Graph Theme Picker

| Field | Value |
|-------|-------|
| **ID** | `graph-theme-picker` |
| **Category** | Input & Forms |
| **Used In** | 01-Fighter Studio, 21-Cosmetic Shop |

## Description

Visual picker for selecting graph color themes (8+ at launch). Shows live preview on canvas before applying. Themes affect edge glow, node fill, pulse, and background.

## Size Variants

| Variant | Description |
|---------|-------------|
| Compact | Theme swatch grid |
| Expanded | Grid with live canvas preview |

## Props / Configuration

- `themes` — Available theme list
- `selectedTheme` — Currently active theme ID
- `previewEnabled` — Show live preview on canvas before applying
- `unlockedThemes` — Array of purchased or earned theme IDs

## Interactions

- Browse theme swatch grid
- Preview theme live on canvas
- Apply selected theme
- Navigate to shop for locked themes
