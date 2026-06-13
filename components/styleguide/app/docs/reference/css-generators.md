# CSS Generators

The engine produces CSS through 17 generator functions, each returning a CSS template literal string. All style values use `var(--*)` references — zero hardcoded px, color, or timing values in the output.

## Pipeline order

`generateCSS(config)` in `src/lib/css-gen/index.ts` concatenates generators in this order:

| # | Function | File | Output classes |
|---|----------|------|---------------|
| 1 | `generateVarsCSS` | `vars.ts` | `html[data-design-theme="..."] { --var: value; }` |
| 2 | `generateBrandingCSS` | `branding.ts` | `.product-branding-*` |
| 3 | `generateSectionCSS` | `sections.ts` | `.sg-section-*`, `.sg-group-*`, `.sg-subsection`, `.sg-principle-*`, `.sg-demo-box`, `.sg-description` |
| 4 | `generateTokenCSS` | `tokens.ts` | `.token-card`, `.token-row`, `.token-preview-*` |
| 5 | `generateSpacingCSS` | `spacing.ts` | `.spacing-*`, `.spacing-diagram-*` |
| 6 | `generateCardCSS` | `cards.ts` | `.card`, `.card-header`, `.card-body`, `.card-footer`, `.card-filled`, `.card-tag`, modifiers |
| 7 | `generateButtonCSS` | `buttons.ts` | `.btn`, `.btn-sm/lg/xl`, `.btn-outline`, modifiers |
| 8 | `generateSemanticCSS` | `semantic.ts` | `.card.{class}`, `.btn.{class}`, accent variants, selected animation |
| 9 | `generateTypographyClassCSS` | `typography.ts` | `.type-sans-400`, `.type-mono-700`, etc. |
| 10 | `generateIndicatorCSS` | `indicators.ts` | `.badge`, `.alert`, `.toast`, `.progress`, `.status-dot`, `.tag` |
| 11 | `generateFormsCSS` | `forms.ts` | `.field-*`, `.field-checkbox`, `.field-switch`, `.field-radio`, validation states |
| 12 | `generateDividerCSS` | `dividers.ts` | `.hr`, `.hr.section/subsection/item/accent`, `.vr`, glow/overline variants |
| 13 | `generateShellCSS` | `shells.ts` | `.shell-navbar`, `.shell-sidebar`, `.shell-aside`, `.shell-footer`, `.screen-frame` |
| 14 | `generateHUIInteractiveCSS` | `hui-interactive.ts` | Headless UI interactive components |
| 15 | `generateUtilityCSS` | `utilities.ts` | `.text-{class}` semantic text utilities |
| 16 | `generateLayoutCSS` | `layout.ts` | `.layout-*` page layout scoping |
| 17 | `generateGlobalsCSS` | `globals.ts` | Raw CSS resets (pass-through from YAML `globals` key) |

## Generator pattern

Every generator follows the same pattern:

```typescript
import type { StyleGuideConfig } from "../types";

export function generateExampleCSS(_config: StyleGuideConfig): string {
  return `/* COMMENT */
.example {
  padding: var(--example-padding);
  background: var(--example-background);
  font-size: var(--example-font-size);
  transition: all var(--example-transition);
}
.example:hover {
  background: var(--example-hover-background);
}`;
}
```

**Rules:**
- Return a CSS template literal string
- ALL values must be `var(--*)` references (no raw px, hex, rgba, or numeric values)
- The corresponding vars are defined in `defaults.ts` (Level 3) and optionally overridden in YAML
- Accept `config: StyleGuideConfig` even if unused (convention for future extensibility)

## Special generators

### vars.ts — Variable emission

Unlike other generators, `vars.ts` calls `resolveDefaults()` from `defaults.ts` and emits all resolved variables:

```css
html[data-design-theme="style-guide"] {
  /* Surfaces */
  --white: #ffffff;
  --gray-50: #f5f5f5;
  ...

  /* Foundations (cascade defaults) */
  --micro-label-font-size: var(--font-size-xs);
  --transition-base: 0.15s;
  ...

  /* Semantic vars */
  --semantic-danger-accent: #c41a1a;
  ...
}
```

YAML-defined vars appear in their original groups. Foundation vars (from the cascade) appear in a separate "Foundations" section.

### semantic.ts — Dynamic class generation

Iterates `config.semanticClasses` to generate rules for each class applied to cards and buttons:

```css
/* For each semantic class (e.g., "danger"): */
.card.danger {
  border-color: var(--semantic-danger-accent);
  background: var(--semantic-danger-background);
}
.btn.danger {
  background: var(--semantic-danger-accent);
  color: var(--on-semantic-color);
}
.btn.danger:hover {
  background: color-mix(in srgb, var(--semantic-danger-accent) 85%, black);
}
```

Also generates accent variants (`.accent-danger`), outline combinations, and a `btn-selected` animation keyframe.

### globals.ts — Pass-through

Simply returns `config.globals` — a raw CSS string defined in the YAML. Used for resets and base element styles.

## Var naming conventions

| Prefix | Scope | Example |
|--------|-------|---------|
| (none) | Base tokens | `--white`, `--space-3`, `--font-size-sm` |
| `micro-label-*` | Foundation pattern | `--micro-label-font-size` |
| `font-weight-*` | Foundation constant | `--font-weight-semibold` |
| `card-*` | Card component | `--card-padding`, `--card-border-color` |
| `btn-*` | Button component | `--btn-font-size`, `--btn-hover-background` |
| `field-*` | Form field | `--field-height`, `--field-border-color` |
| `control-*` | Checkbox/radio/switch | `--control-size`, `--control-checked-color` |
| `switch-*` | Toggle switch | `--switch-width`, `--switch-thumb-size` |
| `badge-*`, `alert-*`, `toast-*`, `progress-*`, `tag-*` | Status indicators | `--badge-radius`, `--toast-bg` |
| `shell-*` | App shell chrome | `--shell-navbar-height`, `--shell-sidebar-width` |
| `screen-*` | Screen frame (macOS chrome) | `--screen-dot-close`, `--screen-frame-radius` |
| `hui-*` | Headless UI interactive | `--hui-field-height`, `--hui-panel-shadow` |
| `sg-*` | Styleguide-specific | `--sg-description-max-width`, `--sg-bar-height` |
| `branding-*` | Brand identity | `--branding-name-font-size` |
| `hr-*` | Dividers | `--hr-height`, `--hr-overline-length` |
| `token-*` | Token preview display | `--token-card-padding` |
| `toggle-*` | Collapse toggle | `--toggle-icon-size` |
| `semantic-{name}-*` | Per-semantic-class | `--semantic-danger-accent` |
| `layout-{name}-*` | Per-layout | `--layout-standard-max-width` |

## Adding a new generator

1. Create `src/lib/css-gen/my-component.ts` following the generator pattern above
2. Add default vars to `LEVEL_3` in `defaults.ts`
3. Wire it into `index.ts`:
   ```typescript
   import { generateMyComponentCSS } from "./my-component";
   // Add to the array in generateCSS():
   generateMyComponentCSS(config),
   ```
4. Run `npx tsc --noEmit` to verify types
