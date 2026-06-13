# Theme Switcher

| Field | Value |
|-------|-------|
| **ID** | `theme-switcher` |
| **Category** | Appearance Settings |
| **Used In** | S-28 Appearance Settings |

## Description

Toggle or segmented selector for choosing between Light, Dark, and System (OS-preference) themes. Includes a live preview swatch for each option showing representative background and text colors.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Icon-only toggle cycling through Light/Dark/System — used in the top navigation bar for quick access |
| **Expanded** | Labeled segmented control with color swatches; used in the Appearance Settings screen |

## Props / Configuration

- `currentTheme` — `"light"` | `"dark"` | `"system"`
- `systemPreference` — `"light"` | `"dark"` — actual OS preference; used to render the System option swatch correctly
- `variant` — `"inline"` | `"expanded"` (default: `"expanded"`)
- `onThemeChange` — Callback receiving the newly selected theme value

## Interactions

- Selecting a theme applies it immediately without a page reload; CSS custom properties are swapped on the root element
- System option tracks `prefers-color-scheme` media query in real time; if the OS switches at runtime the app updates automatically
- Expanded swatch for each option shows a miniature card with the theme's background, surface, text, and accent colors
- Currently active option is marked with a checkmark and highlighted border
- Inline icon cycles through the three options on each click; icon updates to match the active theme (sun/moon/monitor)
- Selection is persisted to user preferences via API call; local storage is also updated as a fallback for immediate consistency
- Changing theme in the inline toggle shows a brief toast "Theme: Dark" for confirmation
