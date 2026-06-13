# Adding a CSS Generator

How to add a new generator to the CSS pipeline.

## 1. Create the generator file

Create `src/lib/css-gen/{name}.ts`. Every generator follows the same signature:

```typescript
import type { StyleGuideConfig } from "../types";

export function generate{Name}CSS(config: StyleGuideConfig): string {
  return `/* ═══════════════════════════════════════
   {SECTION TITLE}
   ═══════════════════════════════════════ */
.my-component {
  padding: var(--my-component-padding);
  background: var(--my-component-bg);
  color: var(--my-component-color);
  border: var(--my-component-border);
  transition: all var(--my-component-transition);
}
.my-component:hover {
  background: var(--my-component-hover-bg);
}`;
}
```

Accept `config: StyleGuideConfig` even if unused — prefix with `_` if the linter complains.

## 2. Add default vars

Add your component's vars to `LEVEL_3` in `src/lib/css-gen/defaults.ts`. These are the fallback values that themes can override via YAML:

```typescript
// in LEVEL_3:
"my-component-padding": "var(--space-3)",
"my-component-bg": "var(--surface)",
"my-component-color": "var(--text)",
"my-component-border": "1px solid var(--border)",
"my-component-transition": "var(--transition-base)",
"my-component-hover-bg": "var(--surface-raised)",
```

Follow the naming convention: `{component}-{property}`. See `css-generators.md` for the full prefix table.

## 3. Register in index.ts

In `src/lib/css-gen/index.ts`:

1. Add the import:
   ```typescript
   import { generateMyComponentCSS } from "./my-component";
   ```

2. Add a `{ name, css }` entry to the array returned by `generateCSSSections()`:
   ```typescript
   { name: "my-component", css: generateMyComponentCSS(config) },
   ```

The `name` string is used by the scoping system to decide how to handle the section.

## 4. Ordering

The array order in `generateCSSSections()` is the cascade order in the final CSS. Rules:

- **vars** and **scoped-vars** must come first — everything else references them.
- **globals** must come last — it contains resets and base element styles that override everything.
- **css-snippets** should stay near the end — theme authors expect snippet rules to win over generated rules.
- **utilities** and **layout** go late — utility classes need high specificity position.
- New component generators go in the middle block (after `tokens`/`swatches`/`spacing`, before `utilities`/`layout`).

Place your generator near related sections. Cards, buttons, semantic, typography, indicators, forms, dividers, and shells are all peer-level component generators.

## 5. Scoping

By default, your section will be **auto-scoped** — the engine prefixes every top-level selector with `html[data-design-theme="slug"]`. This is correct for most generators.

Mark a section as **self-scoped** only if it emits its own theme selector (e.g., `html[data-design-theme]` wrappers or `:root` rules). To do this, add the section name to the `SELF_SCOPED` set in `src/lib/css-cache.ts`:

```typescript
const SELF_SCOPED = new Set(["vars", "scoped-vars", "globals", "css-snippets", "my-section"]);
```

When to self-scope:
- Your generator emits `html[data-design-theme="..."]` or `:root` selectors directly
- Your generator includes `@media` blocks with selectors that need theme scoping (auto-scope doesn't prefix inside `@media`)

When to use auto-scope (the default):
- Your generator emits bare class selectors (`.foo { ... }`)
- This is the common case — most generators use auto-scope

See `css-scoping.md` for full details on how `scopeCSS()` works.

## 6. Token usage

All values in generated CSS must be `var(--*)` references. Never hardcode `px`, `rem`, hex colors, `rgba()`, or timing values.

```css
/* wrong */
.my-component { padding: 12px; color: #333; }

/* right */
.my-component { padding: var(--my-component-padding); color: var(--my-component-color); }
```

The only exceptions are structural constants that never change across themes: `0`, `100%`, `none`, `inherit`, `currentColor`, `transparent`, and gradient stop percentages.

## 7. Verify

```bash
./regen.sh
```

This clears the cache, regenerates all CSS, and nudges Tailwind. Then:

1. Check `src/app/design-system.generated.css` — search for your section header comment
2. Verify your rules appear under each theme with correct scoping prefixes
3. Check the dev server renders correctly
4. Run `npx tsc --noEmit` to verify types

## Complete example

`src/lib/css-gen/badges.ts`:

```typescript
import type { StyleGuideConfig } from "../types";

export function generateBadgeCSS(_config: StyleGuideConfig): string {
  return `/* ═══════════════════════════════════════
   BADGES
   ═══════════════════════════════════════ */
.badge {
  display: inline-flex;
  align-items: center;
  padding: var(--badge-padding-y) var(--badge-padding-x);
  font-family: var(--badge-font-family);
  font-size: var(--badge-font-size);
  font-weight: var(--badge-font-weight);
  border-radius: var(--badge-radius);
  background: var(--badge-bg);
  color: var(--badge-color);
  border: var(--badge-border);
}
.badge-sm {
  padding: var(--badge-sm-padding-y) var(--badge-sm-padding-x);
  font-size: var(--badge-sm-font-size);
}`;
}
```

Then in `index.ts`, add it after related indicator sections:

```typescript
{ name: "badges", css: generateBadgeCSS(config) },
```

Auto-scoped. No entry in `SELF_SCOPED` needed.
