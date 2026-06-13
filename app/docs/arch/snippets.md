# Snippets

Snippets inject custom CSS and JSX into the generated style guide without modifying generator source files. They are defined in YAML, accumulated across config files, deduplicated by slug, sorted by declared dependencies, and injected into their target sections.

## YAML schema

### CSS snippet

```yaml
css-snippets-defaults:          # optional, applies to all snippets in this file
  target-section: cards

css-snippets:
  - slug: card-glow              # unique ID, used for dedup and dependency edges
    name: Card Glow Effect        # human label (optional)
    title: "Glow variant"         # short subtitle (optional)
    description: "Adds a glow."   # shown in the showcase (optional)
    target-section: cards         # groups output in the CSS and the UI
    dependencies: [card-base]     # slugs that must appear before this one
    body: |                       # raw CSS, emitted verbatim
      .card.glow {
        box-shadow: 0 0 20px color-mix(in srgb, var(--brand-blue) 40%, transparent);
      }
```

### JSX snippet

```yaml
jsx-snippets-defaults:
  target-section: demo

jsx-snippets:
  - slug: counter-demo
    name: Counter Demo
    title: "Simple counter"
    description: "A basic counter component."
    target-section: demo
    imports: ["import { useState } from \"react\""]   # explicit imports (optional)
    dependencies: [demo-imports]                       # slugs that must appear first
    body: |
      export function CounterDemo() {
        const [count, setCount] = useState(0);
        return <button onClick={() => setCount(c => c + 1)}>Count: {count}</button>;
      }
```

### css-load / jsx-load

Load an external file directly into the pipeline instead of inlining the body in YAML:

```yaml
css-load:
  - path: ./extras/scanlines.css
    target-section: effects
    force: false                  # required if target-section matches a built-in name

jsx-load:
  - path: ./extras/fancy-demo.tsx
    target-section: demo
```

`path` is resolved relative to the theme directory. For `css-load`, the `force` flag must be `true` to write into a built-in section (vars, cards, buttons, etc.) — otherwise the load is rejected with an error.

---

## Accumulation model

Snippets are **accumulated, not replaced**. Each `style-guide.*.yaml` file in a theme can declare its own `css-snippets` / `jsx-snippets` arrays. The loader (`src/config/loader.ts`) collects them all into flat arrays:

```
style-guide.css-snippets.yaml   →  [card-glow]
style-guide.effects.yaml        →  [scanline, neon-border]
                                 ────────────────────────
                         config.cssSnippets = [card-glow, scanline, neon-border]
```

**File-level defaults** (`css-snippets-defaults`, `jsx-snippets-defaults`) are applied before accumulation. If a snippet omits `target-section` and the file declares a default, the default fills it in.

Base-theme fallback applies here too: if a child theme doesn't define a `style-guide.css-snippets.yaml`, the base theme's snippets are inherited. If the child does define the file, only its snippets are used for that file — but snippets from *other* base-theme files still accumulate.

---

## Deduplication

Snippets are keyed by `slug`. The topo-sorter (`src/lib/topo-sort.ts`) uses slugs for dependency resolution. If two snippets share a slug, they will both appear — there is no automatic dedup at the loader level. Use unique slugs.

---

## Ordering: topological sort

Within each `target-section` group, snippets are topologically sorted by their `dependencies` array:

```
dependencies: [card-base]   →  card-base is emitted before this snippet
dependencies: []             →  no constraint, appears in original YAML order
```

Cycles are detected and warned; cycled snippets fall back to YAML order. The sort is stable — snippets without dependency relationships preserve their declaration order.

---

## CSS snippet pipeline

`generateCssSnippetsCSS()` in `src/lib/css-gen/css-snippets.ts`:

1. Groups snippets by `target-section`
2. Topo-sorts each group
3. Emits a comment header per snippet (`/** target-section: title */`)
4. Emits the `body` verbatim
5. Appends `css-load` file contents after snippet groups

The output lands in the CSS pipeline at position 18 (after `layout`, before `globals`), wrapped in `/* -- {section} -- */` banners.

Built-in section names that conflict with `css-load` targets: `vars`, `scoped-vars`, `branding`, `sections`, `tokens`, `swatches`, `spacing`, `cards`, `buttons`, `semantic`, `typography`, `indicators`, `forms`, `dividers`, `shells`, `hui`, `utilities`, `layout`, `globals`.

---

## JSX snippet pipeline

`generateJsxFiles()` in `src/lib/jsx-gen/index.ts`:

1. Groups snippets by `target-section`
2. For each section, topo-sorts the group
3. **Extracts imports** from each snippet's `body` and `imports` array
4. **Collates imports** — merges named imports for the same module, deduplicates, sorts by tier (react > react-* > third-party > local)
5. Strips extracted imports from snippet bodies
6. Writes `src/components/generated/{section}.tsx` — only if content changed

Output file structure:

```tsx
// Auto-generated from YAML jsx-snippets — do not edit manually
"use client";

import { useState } from "react";        // collated from all snippets

// @demo-imports
// Demo Imports: Shared imports
// ...

// @counter-demo
// Counter Demo: Simple counter
export function CounterDemo() { ... }
```

### Component export contract

Each JSX snippet that exports a function becomes a named export from the generated file. The `SnippetShowcase` component discovers exports by regex-matching `export function {Name}` in the snippet body, then looks up `generatedModules[section][Name]` to render a live preview.

Import-only snippets (no `export function` or `export default`) are shown as metadata-only entries in the showcase UI.

---

## How snippets appear in the rendered style guide

The `SnippetsSection` component (registered as `"snippets"` in the section registry) renders a `SnippetShowcase` when `config.cssSnippets` or `config.jsxSnippets` is non-empty.

**CSS snippets** are shown grouped by `target-section` with:
- Slug as monospace label (`.card-glow`)
- Title and target badge
- Description text
- Live preview — auto-detected from the first class selector in the body
- Expandable code view of the raw CSS

**JSX snippets** are shown grouped by `target-section` with:
- Slug as monospace label (`@counter-demo`)
- Title and target badge
- Live rendered component (if the export was found in the generated module)
- Expandable code view of the JSX body

---

## Practical examples

### Adding a custom CSS effect to a theme

1. Open the theme's `style-guide.css-snippets.yaml` (or any `style-guide.*.yaml` file)
2. Add the snippet:

```yaml
css-snippets:
  - slug: pulse-border
    title: "Pulsing border glow"
    target-section: effects
    body: |
      @keyframes pulse-border {
        0%, 100% { box-shadow: 0 0 0 0 var(--brand-blue); }
        50% { box-shadow: 0 0 12px 2px var(--brand-blue); }
      }
      .pulse-border {
        animation: pulse-border 2s ease-in-out infinite;
      }
```

3. The CSS is injected into the generated stylesheet automatically. No generator code changes needed.

### Adding a JSX demo component

1. Open or create `style-guide.jsx-snippets.yaml` in the theme directory
2. Add the snippet:

```yaml
jsx-snippets:
  - slug: toggle-demo
    title: "Toggle switch demo"
    target-section: demo
    body: |
      import { useState } from "react";

      export function ToggleDemo() {
        const [on, setOn] = useState(false);
        return (
          <label className="field-switch">
            <input type="checkbox" checked={on} onChange={() => setOn(!on)} />
            <span className="field-switch-track" />
          </label>
        );
      }
```

3. Run `regen.sh` — the engine writes `src/components/generated/demo.tsx`
4. Register the generated module in `SnippetShowcase.tsx` if the section is new (the `demo` section is pre-registered)
5. The component renders live in the Snippets section of the style guide

---

## JSX snippet rendering contract

### Assembly pipeline

`generateJsxFiles()` in `src/lib/jsx-gen/index.ts` produces one `.tsx` file per `target-section`:

1. Snippets are grouped by `target-section`
2. Each group is topologically sorted via `topoSort()` (same sorter as CSS snippets)
3. **Import extraction** — `extractImports()` pulls all `import` lines out of each snippet `body` and combines them with the snippet's explicit `imports[]` array
4. **Import collation** — `collateImports()` merges named imports for the same module, deduplicates, and sorts by tier: `react` → `react-*` → third-party → local (`.`/`/` prefixed). Blank lines separate tiers. Conflicting default imports warn and keep the first encountered.
5. Stripped bodies are emitted in topo order, each preceded by a comment header (`// @slug`, title, description, deps)
6. `jsx-load` file contents are appended verbatim after snippet bodies
7. The file is written to `src/components/generated/{section}.tsx` — **only if content changed** (avoids unnecessary HMR/rebuilds)

### Output file shape

```tsx
// Auto-generated from YAML jsx-snippets — do not edit manually
"use client";

import { useState } from "react";    // collated

// @slug
// Name: Title
export function ComponentName() { ... }
```

Every generated file is a `"use client"` module. Snippets that contain `export function Foo` become **named exports**. Import-only snippets (no export) contribute their imports to the collated block but produce no body in the output.

There is no default export. The generated file is a bag of named exports.

### How the style guide renders components

`SnippetShowcase` (`src/components/SnippetShowcase.tsx`) uses `require()` to statically load known generated modules into a lookup table:

```ts
const demo = require("@/components/generated/demo");
generatedModules["demo"] = demo;
```

For each JSX snippet, it regex-matches `export function {Name}` in the snippet body, then looks up `generatedModules[section][Name]`. If found, the component is rendered live inline (wrapped in `<Suspense>`). If not found, a placeholder is shown.

Import-only snippets (no `export function` or `export default`) appear as metadata-only entries in the UI — slug and title, no preview.

**New sections must be registered manually** — add a `require()` + `generatedModules[section]` assignment in `SnippetShowcase.tsx`. The `demo` section is pre-registered.

### Available React APIs inside snippet bodies

Snippets run as standard `"use client"` React components. Available:

- All React client hooks (`useState`, `useEffect`, `useRef`, `useMemo`, etc.)
- `Suspense`, `Fragment`, and other React built-ins (via import)
- Any CSS classes/variables from the generated design system (they're in the same DOM)
- Inline styles

### Limitations

- **No server components** — every generated file is `"use client"`
- **No external package imports** — only `react` and local project paths are available at runtime. The collator will happily merge third-party imports, but they must actually be installed in the project
- **No dynamic imports** — the showcase uses synchronous `require()`, not `import()`
- **One component per snippet** — the export-discovery regex matches only the first `export function` per snippet body
- **Section registration is manual** — new `target-section` values require a `require()` line in `SnippetShowcase.tsx`
- **No JSX fragment default exports** — the showcase only discovers `export function` and `export default`; bare JSX fragments won't render
