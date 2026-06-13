# NoizuRPG Logo Usage Guide

## Primary Logo

The NoizuRPG logo is an **isometric hex cube** in three graduated purple tones, paired with the "NoizuRPG" wordmark in Inter Bold.

- **Hexagon** = RPG hex-grid maps
- **Cube** = composable building blocks (the framework metaphor)
- **Purple** = aligned with brand accent from both Workshop and Wonder design directions

## Variants

| Variant | File | Use When |
|---------|------|----------|
| Combo (light bg) | `noizurpg-combo-light.svg` | Default — marketing, docs, light UI |
| Combo (dark bg) | `noizurpg-combo-dark.svg` | Dark mode, dark hero sections, presentations |
| Mark (color) | `noizurpg-mark-color.svg` | App icons, social avatars, small contexts |
| Mark (mono black) | `noizurpg-mark-mono-black.svg` | Print, single-color, watermarks |
| Mark (mono white) | `noizurpg-mark-mono-white.svg` | Dark backgrounds, single-color reversed |
| Favicon | `noizurpg-favicon.svg` | Browser tabs, bookmarks, PWA icons |

## Color Palette

| Role | Hex | Usage |
|------|-----|-------|
| Top face | `#A78BFA` | Lightest — catches light |
| Left face | `#7C5CFC` | Medium — primary accent tone |
| Right face | `#5B35D5` | Darkest — shadow face |
| Text (light bg) | `#171720` | Direction A primary text |
| Text (dark bg) | `#E4E4EC` | Direction B primary text |

## Clear Space

Minimum clear space around the logo equals **25% of the mark height**.

At default 200px mark size, that's 50px on each side. No other graphics, text, or edges may enter this zone.

## Minimum Sizes

| Variant | Minimum Width |
|---------|--------------|
| Combo mark | 200px wide |
| Standalone mark | 24px wide |
| Favicon | 16px (use favicon variant) |

Do not display the combo mark below 200px — switch to the standalone mark.

## Construction

- Pointy-top regular hexagon, radius 70, centered at (100, 100)
- Three faces form a standard isometric cube projection
- Faces meet at hexagon center
- ViewBox: `0 0 200 200` (logomark), `0 0 380 120` (combo)

## Typography

- **Font:** Inter Bold (700)
- **Size:** 40px in combo mark coordinate space
- **Letter-spacing:** -0.5px
- **Production:** Convert all `<text>` to `<path>` before final delivery

## Don'ts

- Do not stretch or distort the proportions
- Do not rotate the mark (the isometric orientation is intentional)
- Do not change the face colors or their relative lightness order
- Do not add effects (shadows, outlines, glows, gradients)
- Do not rearrange the combo mark layout (mark always left of text)
- Do not use the combo mark at sizes below 200px wide
- Do not place on busy photographic backgrounds without a solid overlay
