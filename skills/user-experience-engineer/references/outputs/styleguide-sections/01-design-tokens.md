# 01 — Design Tokens

> The CSS custom properties that form the atomic foundation of the entire system.

---

## Why This Section Exists

Design tokens are the single source of truth for every visual decision. Colors, fonts, spacing, radii, shadows — all expressed as CSS custom properties that components consume. Tokens come first in the numbered sections because everything else references them. If a color appears in Section 02 or a spacing value in Section 04, it should trace back to a token defined here. Without this section, the system has no shared vocabulary — implementers invent values ad hoc and the design drifts.

## What to Include

### Token Categories

Group tokens by purpose, not by component:

- **Neutrals / Surfaces** — white, off-white, gray scale (50-900), black. The grayscale ladder that backgrounds, borders, and text colors draw from.
- **Primary Colors** — the 2-5 brand colors with light/mid transparency variants for hover states and backgrounds.
- **Semantic Colors** — success, warning, error, info with their background-tint variants. These map meaning to color.
- **Typography** — font family stacks (`--font-sans`, `--font-mono`). Not sizes — those live in the type scale.
- **Spacing** — a progressive scale from `--space-1` through `--space-16`, all multiples of the base unit.
- **Grid** — base unit (`--unit`), column gap (`--col-gap`).
- **Radius** — border-radius values. Often a single value for the whole system.
- **Shadows** — elevation levels if the system uses them.

### Naming Convention

Use a consistent prefix pattern:

```
--color-*     or bare names (--red, --gray-500)
--font-*      for font families
--space-*     for spacing scale
--radius      or --radius-* for multiple levels
--shadow-*    for elevation
--unit        for grid base
```

Pick one scheme and enforce it. The template uses bare color names (`--red`, `--blue`, `--gray-500`) and prefixed categories (`--space-1`, `--font-sans`).

### The CSS-to-Display Sync Rule

The `[data-design-theme]` CSS block defines the actual custom properties. The TokenCard components in the JSX display those values for documentation. These two sources **must stay in sync**. If you add `--purple: #7c3aed` to the CSS, add it to the corresponding TokenCard array. If they diverge, the guide is lying.

## Best Practices

1. **Every token should be used somewhere.** Dead tokens are clutter. If nothing references `--gray-350`, delete it.
2. **Limit the palette.** Constraint breeds coherence. A 12-shade gray scale is usually 4 shades too many.
3. **Use consistent naming.** If neutrals go `--gray-50` through `--gray-900`, don't name one `--darkgray`. Follow the pattern.
4. **No magic numbers.** If a component uses `padding: 13px`, that's a red flag. Either it should be a token or it should snap to the nearest token value.
5. **Transparency variants follow their base.** `--red-light` and `--red-mid` derive from `--red` via rgba. Name them predictably.
6. **Document the base unit.** If spacing is multiples of 8px, say so. The unit is the Rosetta Stone of the system.

## Template Usage

In the styleguide-engine, Section 01 uses a grid of TokenCard components inside a `sg-section`. **Engine facet:** `style-guide.vars.yaml`.

### TokenCard props

| Prop | Type | Notes |
|------|------|-------|
| `title` | string | Card heading (e.g., "Neutrals", "Primary", "Spacing") |
| `type` | string | Controls inline preview: `color`, `font`, `space`, `radius`, `shadow`, `size` |
| `tokens` | [name, value][] | Array of `[varName, cssValue]` pairs |
| `stylize` | boolean | Show inline visual previews (default: true) |

The `type` prop determines how each token row renders its preview:
- `color` — 16px square swatch filled with the color value
- `font` — "Ag" sample rendered in the font
- `space` — small block sized to the spacing value
- `radius` — 24px square with the border-radius applied
- `shadow` — 24px square with the box-shadow applied
- `size` — "A" rendered at the font-size value

### Updating tokens

1. Edit the CSS custom properties inside the `[data-design-theme]` block.
2. Update the corresponding TokenCard `tokens` arrays in the JSX to match.
3. Verify the TokenCard `type` is correct for the category.

Wrap multiple TokenCards in a `<div className="token-grid">` for responsive columns.

## Anti-Patterns

- **Tokens nobody uses.** Every defined token should appear in at least one component or section. Orphan tokens are debt.
- **Inconsistent naming.** `--clr-primary` alongside `--color-accent` alongside `--brand-blue` is three naming schemes pretending to be one.
- **Magic numbers that aren't tokens.** If a spacing value or color appears in CSS but isn't a token, either make it one or replace it with an existing token.
- **CSS and display out of sync.** The worst version of this: the TokenCard says `--red: #ff0000` but the CSS says `--red: #e20613`. Now implementers are building against the wrong values.
- **Too many tokens.** A token system with 200 entries is a token system nobody memorizes. Aim for the smallest set that covers the design.

## Dependencies

- **Referenced by** Section 02 (Color Palette) — colors defined here are visualized there.
- **Referenced by** Section 03 (Typography) — font families defined here are rendered there.
- **Referenced by** Section 04 (Spacing) — spacing scale defined here is diagrammed there.
- **Referenced by** all component sections — every visual value should trace to a token.
- **References** Header/Branding — meta values in the StyleCard should match tokens.
