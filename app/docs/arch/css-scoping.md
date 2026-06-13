# CSS Scoping

Multiple themes coexist in one page. Without scoping, a `.btn` rule from theme A stomps theme B's `.btn`. The engine solves this by prefixing selectors with `html[data-design-theme="slug"]`, so each theme's rules only activate when that attribute matches.

## Section pipeline

`generateCSSSections()` returns an ordered array of `CssSection` objects:

```
vars → scoped-vars → branding → sections → tokens → swatches → spacing →
cards → buttons → semantic → typography → indicators → forms → dividers →
shells → hui → utilities → layout → css-snippets → code-terminal → globals
```

Each section is classified as either **self-scoped** or **auto-scoped**.

## Self-scoped sections

These sections emit their own selectors (usually `:root` or `html[data-design-theme]` wrappers) and are passed through without modification:

| Section | Why it's exempt |
|---------|----------------|
| `vars` | Emits `html[data-design-theme="slug"] { --var: value; }` directly |
| `scoped-vars` | Same — scoped custom properties under the theme selector |
| `globals` | Targets `html`, `body`, `:root` — already theme-scoped internally |
| `css-snippets` | Raw authored CSS from YAML — user controls their own selectors |

The check in `loadCachedCSS()`:

```ts
const SELF_SCOPED = new Set(["vars", "scoped-vars", "globals", "css-snippets"]);
if (SELF_SCOPED.has(s.name)) return `${header}\n${s.css}`;
```

## Auto-scoped sections

Everything else (branding, buttons, cards, typography, etc.) gets run through `scopeCSS(css, themeSelector)`. This prefixes every top-level selector:

```css
/* input */
.btn { ... }
.card, .card-body { ... }

/* output */
html[data-design-theme="cyberpunk"] .btn { ... }
html[data-design-theme="cyberpunk"] .card,
html[data-design-theme="cyberpunk"] .card-body { ... }
```

## How scopeCSS() works

Line-by-line scan with brace-depth tracking:

### Brace depth

`depth` increments on `{`, decrements on `}`. Only lines at `depth === 0` that contain `{` and don't start with `@` or `}` are treated as top-level selectors.

### @keyframes

Detected by `trimmed.startsWith("@keyframes")`. Sets an `inAtRule` flag — all lines are passed through verbatim until depth returns to 0. Keyframe stop names (`from`, `to`, `50%`) must not be prefixed.

### @media

Not special-cased — `@media` lines start with `@` so they pass through at depth 0. The selectors *inside* the media block appear at depth 1+, so they aren't prefixed either. This is correct: the theme attribute selector wraps the inner selectors from the outside.

**Note:** This means selectors inside `@media` blocks are currently *not* scoped. If a generator needs scoped media queries, it should emit the theme selector itself (same pattern as the self-scoped sections).

### Comments

Lines starting with `/*` or `*` are preserved as-is regardless of depth.

### Comma-separated selectors

The selector portion (everything before `{`) is split on `,`. Each fragment gets `${themeSelector} ${selector.trim()}` and they're rejoined with `,\n`.

### Depth floor

`depth` is clamped to 0 minimum after each line to tolerate malformed input.

## Output assembly

### Composite file: `design-system.generated.css`

All themes are concatenated into a single file:

```
/* header: checksum, theme list, source table */

/* ═══ THEME: Cyberpunk (cyberpunk) ═══ */
/* ── VARS ── */
...
/* ── BUTTONS ── */
...

/* ═══ THEME: Sumi-e (sumi-e) ═══ */
/* ── VARS ── */
...
/* ── BUTTONS ── */
...
```

Written to `src/app/design-system.generated.css` and imported via `globals.css`. This is the **SSR path** — all theme CSS is available on first paint, no network round-trips.

### Per-theme files: `public/themes/{slug}.css`

Each theme also gets its own file (e.g., `public/themes/cyberpunk.css`). Same scoped CSS, just one theme per file.

These are loaded by the `ThemeCSS` client component, which injects `<link>` tags and enables/disables them based on `data-design-theme`. This is the **lazy-loading path** — useful when the composite file gets too large.

## When each output is used

| Mode | File | Loaded by | Use case |
|------|------|-----------|----------|
| Composite | `design-system.generated.css` | `@import` in `globals.css` | Default. SSR-safe, zero FOUC, all themes available immediately |
| Lazy | `public/themes/{slug}.css` | `ThemeCSS` component | Opt-in. Swap the `@import` for `<ThemeCSS>` in layout. Only active theme's CSS is enabled |

Both modes use the same scoped CSS. The difference is delivery strategy, not content.

## Caching

The composite file is cached in `.cache/` keyed by a SHA-256 checksum of all theme YAML sources. Cache miss triggers full regeneration. Stale cache entries are purged automatically.
