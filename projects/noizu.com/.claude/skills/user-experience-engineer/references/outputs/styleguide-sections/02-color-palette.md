# 02 — Color Palette

> The full color system rendered visually, with usage rules for every swatch.

---

## Why This Section Exists

Section 01 defines color tokens as name/value pairs. This section shows those colors *in context* — as visual swatches with relationships, contrast information, and usage guidance. Tokens answer "what value is `--red`?" This section answers "when do I use red, and what does it mean?" A color without a defined job creates inconsistency. Every color in the system needs a clear reason to exist and a documented role.

## What to Include

### Subsection Structure

Organize colors into three groups, each as a subsection with its own heading:

**Primaries** — The 3-5 most important colors that define the brand's visual identity. These are the colors someone would name if asked "what colors is this product?" Each primary gets:
- A large swatch (inline mode) showing the color at scale with text overlaid
- A one-line usage rule (e.g., "Red — accent, CTAs, destructive actions")

**Neutral Scale** — The grayscale ladder from white through black. These are the workhorses: backgrounds, surfaces, borders, text colors. Show the full progression so implementers can see the steps and relationships between shades.

**Semantic Colors** — Success (green), warning (amber/orange), error (red), info (blue). These carry meaning independent of brand. Each needs its foreground color and its background tint variant. Document what states or messages each maps to.

### Usage Rules

Every primary and semantic color needs a one-line usage rule documented alongside or below its swatch. These rules are constraints — they tell implementers not just what the color looks like but when to reach for it:

- "Red — accent color, call-to-action buttons, destructive/danger states"
- "Blue — links, informational states, secondary actions"
- "Yellow — highlights, selection state, warning accents"
- "Success — confirmations, valid states, positive feedback"

### Contrast and Accessibility

Note WCAG AA minimum contrast ratios:
- **4.5:1** for normal text (under 18px or under 14px bold)
- **3:1** for large text (18px+ or 14px+ bold) and UI components

If a primary color is used for text on a light background, the combination needs to pass. If it doesn't, document which background it requires or flag it as decoration-only.

## Best Practices

1. **Fewer colors = stronger system.** If two colors serve the same role, one should go. A 5-color primary palette is almost always 2 colors too many.
2. **Every color needs a clear job.** If you can't write a one-line usage rule for a color, it doesn't belong in the system.
3. **Test on real backgrounds.** A color that looks distinct on white may disappear on `--gray-50`. Test combinations that actually occur in the UI.
4. **Semantic colors are not brand colors.** Success green and brand green should be different values — or you'll have situations where "everything looks successful."
5. **Include transparency variants.** Primaries often need light (8% opacity) and mid (15% opacity) variants for hover states and tinted backgrounds. Show these alongside the base.

## Template Usage

In `assets/styleguide-template.html`, Section 02 uses ColorGrid and NotesList components.

### ColorGrid props

| Prop | Type | Notes |
|------|------|-------|
| `colors` | {name, hex, color?}[] | Array of swatch data objects |
| `inline` | boolean | `true` for primary blocks (text overlaid on color), `false` for standard swatches |

Each color object:
- `name` — label displayed on or below the swatch
- `hex` — CSS color value (hex, rgb, or any valid CSS color)
- `color` — text color for inline mode contrast (e.g., `"#fff"` on dark backgrounds, `"#000"` on light)

### NotesList props

| Prop | Type | Notes |
|------|------|-------|
| `notes` | {swatch?, label, text}[] | Array of note objects |

Each note object:
- `swatch` — optional CSS color for a small inline dot
- `label` — bold text (e.g., "Red ---")
- `text` — usage description

### Recommended layout

```
Subsection: "Primaries"
  ColorGrid inline={true} — 3-5 primary blocks
  NotesList — usage rule for each primary

Subsection: "Neutral Scale"
  ColorGrid inline={false} — full gray progression

Subsection: "Semantic"
  ColorGrid inline={false} — success, warning, error, info
  NotesList — what states each maps to
```

## Anti-Patterns

- **Too many shades of the same hue.** If you have `--blue`, `--blue-dark`, `--blue-darker`, `--blue-darkest`, the scale is too fine. Three variants (base, light tint, dark variant) usually suffice.
- **Colors without defined purpose.** A swatch grid with no usage notes is a paint store, not a design system.
- **No usage guidance.** Showing the color without saying when to use it forces implementers to guess. They will guess differently.
- **Skipping contrast documentation.** If the guide doesn't address contrast, implementers will create inaccessible combinations and discover them in an audit.
- **Duplicating token display.** This section should show relationships and rules. If it's just the same swatches from Section 01 in a grid, it's redundant.

## Dependencies

- **References** Section 01 (Design Tokens) — every color shown here must be defined as a token there.
- **References** Header/Branding — the StyleCard color bar should use the same primaries shown here.
- **Referenced by** Section 05+ (Component sections) — buttons, alerts, badges, and other components draw from these defined colors.
