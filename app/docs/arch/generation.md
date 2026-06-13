# Generation Pipeline

## CSS Generation

`lib/css-gen/index.ts` orchestrates 21 generator functions. Each receives the normalized `StyleGuideConfig` for a single resolved theme and returns a named CSS section.

### Generator Order

| # | Section | Generator | Notes |
|---|---------|-----------|-------|
| 1 | `vars` | `generateVarsCSS` | `:root` custom properties + defaults cascade |
| 2 | `scoped-vars` | `generateScopedVarsCSS` | Selector-scoped variables |
| 3 | `branding` | `generateBrandingCSS` | `.product-branding` class tree |
| 4 | `sections` | `generateSectionCSS` | Section-level styles |
| 5 | `tokens` | `generateTokenCSS` | `.token-*` utility classes |
| 6 | `swatches` | `generateSwatchCSS` | Color swatch display styles |
| 7 | `spacing` | `generateSpacingCSS` | Spacing utility classes |
| 8 | `cards` | `generateCardCSS` | Card component styles (static) |
| 9 | `buttons` | `generateButtonCSS` | Button variants |
| 10 | `semantic` | `generateSemanticCSS` | Semantic class rules (cards, buttons, HUI, forms) |
| 11 | `typography` | `generateTypographyClassCSS` | Type scale classes |
| 12 | `indicators` | `generateIndicatorCSS` | Status indicator styles |
| 13 | `forms` | `generateFormsCSS` | Form element styles |
| 14 | `dividers` | `generateDividerCSS` | Divider/separator styles |
| 15 | `shells` | `generateShellCSS` | Shell/chrome layout styles |
| 16 | `hui` | `generateHUIInteractiveCSS` | Headless UI interactive elements |
| 17 | `utilities` | `generateUtilityCSS` | Utility classes |
| 18 | `layout` | `generateLayoutCSS` | Grid and page layout rules |
| 19 | `css-snippets` | `generateCssSnippetsCSS` | YAML-defined CSS with topo sort |
| 20 | `code-terminal` | `generateCodeTerminalCSS` | Code block + terminal window styles |
| 21 | `globals` | `generateGlobalsCSS` | Global reset and base styles |

Order matters — later generators can reference CSS custom properties defined by earlier ones. Each generator is a pure function: `(config) → string`.

### Defaults Cascade (`defaults.ts`)

The most architecturally significant generator module. Called by `generateVarsCSS` to derive a full token set from minimal input.

**Three-level cascade:**
1. **Seeds** (~15 values): `unit`, `font-size-base`, primary colors, `radius`, font stacks
2. **Level 1** (`buildBaseTokens`): derives spacing scale, font scale, size tokens, gray ramp, color variants
3. **Level 2**: component foundations — transitions, borders, shadows, micro-labels
4. **Level 3**: component property defaults — `card-*`, `btn-*`, `field-*`, `branding-*`, `shell-*`

**YAML overrides win at every level** — pattern: `resolved[v.name] ?? v.value`. Exports `FOUNDATION_KEYS` so `generateVarsCSS` can separate computed vars from YAML-defined ones.

### Semantic Generator (`semantic.ts`)

Per-class code generation for each semantic class. Generates rules for:
- `.card.{class}` + `.card.accent-{class}` variants
- `.btn.{class}`, `.btn-ghost`, `.btn-outline`, `.btn.accent-{class}`, `.btn-selected`
- `.hui.*` interactive components (menu, popover, listbox, dialog, tabs, disclosure, checkbox, switch, radio)
- `fieldset.{class}` and `.field-group.{class}` form containers

Reads `config.flatVars["card-accent-side"]` (default `"top"`) to set accent border direction — enabling per-theme accent styles (e.g., sumi-e uses `"left"`) without duplicating generator logic.

### Code/Terminal Generator (`code-terminal.ts`)

Static output emitting classes for code blocks (`.code-inline`, `.code-window`, `.code-block`, `.code-line`, `.code-line-number`) and terminal windows (`.terminal-window`, `.terminal-title-bar`, `.terminal-dots`, `.terminal-body`, `.terminal-prompt`, `.terminal-command`, `.terminal-output`, `.terminal-success/.error/.warning`). All values reference CSS custom properties — fully theme-driven.

## Checksum Caching

`lib/css-cache.ts` prevents unnecessary regeneration:

1. **Hash**: SHA-256 of all resolved YAML file contents + override manifest
2. **Check**: Look for `.cache/styles-{hash16}.css`
3. **Hit**: Read cached file, sync to `design-system.generated.css` if stale
4. **Miss**: Generate CSS, write cache file, purge old cache files
5. **Sync**: If `design-system.generated.css` content differs, overwrite and touch `globals.css` to trigger Tailwind recompile

## JSX Generation

`lib/jsx-gen/index.ts` assembles React components from YAML-defined snippets:

1. **Group** snippets by `target-section`
2. **Topologically sort** each group via `topo-sort.ts`
3. **Extract imports** from snippet bodies via `collate-imports.ts`
4. **Collate imports** — deduplicate by module specifier, merge named imports, sort into 4 tiers (react → react-* → third-party → local)
5. **Assemble** into `components/generated/{section}.tsx` with `"use client"` directive
6. **Append** any `jsx-load` file contents (verbatim)
7. **Write** only if content changed (avoids unnecessary HMR)

### Import Collation (`collate-imports.ts`)

Fully implemented. Handles all standard import forms (default, named, combined, side-effect, `import type`). Deduplication merges named imports per module (union), preserves `import type` only when all imports for that module are type-only. Output sorted into tiers with blank separators.

## Topological Sort

`lib/topo-sort.ts` handles snippet ordering:
- Items without dependencies come first (original YAML order)
- Depth-first traversal with cycle detection
- Circular dependencies: warning logged, cycle-involved snippets appended in original order
- Sort is per target-section — cross-section dependencies have no effect

## Regeneration

| Method | When to use |
|--------|-------------|
| `regen.sh` | Manual — clears `.cache/`, regenerates CSS, touches `globals.css` |
| `ensureGeneratedCSS()` | Called by `layout.tsx` on every build/dev request — uses checksum to skip if unchanged |
