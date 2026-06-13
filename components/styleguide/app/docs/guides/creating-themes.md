# Creating Themes

The engine supports multiple themes via convention-based auto-discovery. Each theme is a directory named `theme-{slug}` under `src/config/`. The system scans for `theme-*` dirs at startup, reads their `style-guide.meta.yaml`, and registers them automatically.

## Quick start: new theme

```
src/config/theme-myapp/
  style-guide.meta.yaml
  style-guide.vars.yaml
  branding.yaml
```

That's it. The base theme (`theme-style-guide`) fills in everything else via inheritance.

## Meta file (required)

```yaml
# style-guide.meta.yaml
name: "My App"
slug: "myapp"
title: "My App — Style Guide"
description: "Design system for My App."
```

`slug` must match the directory suffix: `theme-myapp` → `slug: myapp`.

## Base theme inheritance

Every theme inherits from `theme-style-guide` by default. Missing section files fall back to the base theme automatically.

To inherit from a different theme:

```yaml
# style-guide.meta.yaml
name: "Variant"
slug: "variant"
title: "Variant Style Guide"
description: "A variant of Cyberpunk."
base-theme: theme-cyberpunk
```

### Merge rules

When a theme provides a file that the base also has:

| Key type | Behavior |
|----------|----------|
| `scoped-vars`, `css-snippets`, `jsx-snippets`, `css-load`, `jsx-load` | **Accumulated** — entries from both theme and base are merged |
| Everything else (`vars`, `color-modes`, `globals`, `semantic-classes`, etc.) | **Replaced** — theme's file wins entirely |

If a theme omits a section file entirely, the base theme's file is used as-is.

## Minimal theme (~12 seeds)

Set seed values and let the builder compute everything else.

```yaml
# style-guide.vars.yaml
vars:
  groups:
    - name: Theme Seeds
      vars:
        # Surface endpoints — gray ramp computed automatically
        white: "#1a1a2e"
        black: "#e8e8f0"

        # Primaries — light/mid variants computed automatically
        red: "#ff6b6b"
        blue: "#4da6ff"
        yellow: "#ffd93d"

        # Semantics — *-bg variants computed automatically
        success: "#4ade80"
        warning: "#fbbf24"
        error: "#f87171"
        info: "#60a5fa"

        # Typography
        font-sans: "'Inter', -apple-system, sans-serif"

        # Spacing (optional — 8px default works for most themes)
        # unit: "10px"

        # Border radius (optional — 2px default)
        radius: "4px"
```

This produces:
- Full gray ramp (gray-50 through gray-900) — interpolated from white/black
- All spacing tokens (space-half through space-16) — computed from unit
- All font sizes (xs through display) — computed from font-size-base
- Color variants (red-light, red-mid, success-bg, etc.) — computed from primaries/semantics
- All component styling (cards, buttons, forms, shells, indicators) — cascaded via var() refs

## What you get for free

With just the seeds above, the cascade provides defaults for:

| System | What cascades | Override prefix |
|--------|--------------|-----------------|
| Cards | Padding, borders, colors, typography, shadows | `card-*` |
| Buttons | Sizes (sm/lg/xl), outline, colors, transitions | `btn-*` |
| Forms | Field height, borders, focus rings, validation states, checkbox/radio/switch | `field-*`, `control-*`, `switch-*` |
| Indicators | Badges, alerts, toasts, progress bars, status dots, tags | `badge-*`, `alert-*`, `toast-*`, etc. |
| Shell chrome | Navbar, sidebar, aside, footer dimensions and colors | `shell-*` |
| Typography | Micro labels, font weights, line heights | `micro-label-*`, `font-weight-*` |
| Layout | Transitions, borders, z-indices | `transition-*`, `border-*`, `z-*` |

## Customizing components

Override specific component vars when the defaults don't fit:

```yaml
vars:
  groups:
    - name: Theme Seeds
      vars:
        white: "#1a1a2e"
        black: "#e8e8f0"
        # ...

    - name: Card Overrides
      vars:
        card-padding: "var(--space-4)"           # more spacious cards
        card-rounded-radius: "8px"               # rounder corners
        card-border-color: "var(--gray-700)"     # subtler border

    - name: Button Overrides
      vars:
        btn-background: "var(--blue)"            # blue primary button
        btn-color: "var(--white)"
        btn-border-color: "var(--blue)"
        btn-hover-background: "color-mix(in srgb, var(--blue) 85%, black)"
```

## CSS scoping

All generated CSS is automatically scoped per-theme using the attribute selector:

```css
html[data-design-theme="myapp"] .card { ... }
html[data-design-theme="myapp"] .btn { ... }
```

Self-scoped sections (`vars`, `scoped-vars`, `globals`, `css-snippets`) handle their own scoping and are emitted as-is.

Per-theme CSS files are written to `public/themes/{slug}.css` for optional lazy-loading via the `<ThemeCSS>` component.

## Theme-specific CSS snippets

Add a `style-guide.css-snippets.yaml` to your theme directory. Snippets are **accumulated** — your theme's snippets merge with the base theme's snippets.

```yaml
# src/config/theme-myapp/style-guide.css-snippets.yaml
css-snippets-defaults:
  target-section: ui-elements

css-snippets:
  - name: "Glow effect"
    target-section: ui-elements
    css: |
      html[data-design-theme="myapp"] .card:hover {
        box-shadow: 0 0 20px rgba(0, 255, 255, 0.3);
      }
```

Note: snippets must self-scope with `html[data-design-theme="yourslug"]` since they're emitted verbatim.

## Per-theme page sections

Each theme can define which sections appear and in what order via `style-guide.page-sections.yaml`. Falls back to the base theme's page sections if omitted.

```yaml
# src/config/theme-myapp/style-guide.page-sections.yaml
page-sections:
  - group: Visual Foundation
    sections:
      - id: typography
        title: Typography
        desc: "Type system and scale."
      - id: color
        title: Color
        desc: "Full palette."
      # omit sections you don't need

  - group: Custom
    sections:
      - id: my-custom-section
        title: "My Custom Section"
        desc: "Something unique to this theme."
```

### Theme-unique sections

To add a section that only appears in one theme:

1. Create a React component in `src/components/sections/`
2. Register it in `src/components/sections/index.ts`:
   ```ts
   import { MyCustomSection } from "./my-custom-section";

   export const sectionRegistry: Record<string, ...> = {
     // ... existing entries
     "my-custom-section": MyCustomSection,
   };
   ```
3. Add the ID to that theme's `style-guide.page-sections.yaml` only

Other themes won't render it because it's not in their page-sections list.

### Branching per-theme in components

Components can read the active theme and branch behavior:

```tsx
import { useThemeConfig } from "@/components/ThemeConfigContext";

function MySection() {
  const { activeSlug, config, branding } = useThemeConfig();

  if (activeSlug === "sumi-e") {
    return <SumiEVariant config={config} />;
  }
  return <DefaultVariant config={config} />;
}
```

`useThemeConfig()` returns the active theme's full config, branding, and slug. It re-renders when the user switches themes.

## Theme switching and persistence

When more than one theme is discovered, the LayoutBar automatically shows a theme picker. No configuration needed.

Switching sets `data-design-theme` on `<html>` and swaps the active CSS stylesheet. The choice persists to `localStorage` under key `sg-theme`.

On page load, an inline script reads the stored preference before first paint to prevent flash-of-wrong-theme.

## Dark mode

Dark mode is automatic. The toggle adds `.dark` to `<html>`, which activates the dark overrides from `style-guide.color-modes.yaml`.

### Defining color modes

```yaml
# style-guide.color-modes.yaml
color-modes:
  light:
    surface: "var(--white)"
    surface-alt: "var(--slate-50)"
    text: "var(--black)"
    text-secondary: "var(--gray-600)"
    border: "var(--slate-200)"
    # ...
  dark:
    surface: "var(--slate-900)"
    surface-alt: "var(--slate-800)"
    text: "var(--slate-100)"
    text-secondary: "var(--slate-300)"
    border: "var(--slate-700)"
    # ...
```

Component defaults use semantic tokens (`var(--surface)`, `var(--text)`, etc.), so they flip automatically. You only need to define the 10 semantic mappings for each mode.

### Tailwind integration

The `@theme` block in `globals.css` maps semantic tokens to Tailwind utilities:

- `bg-surface`, `bg-surface-alt`, `bg-surface-inverse`
- `text-text`, `text-text-secondary`, `text-text-muted`
- `border-border`, `border-border-strong`
- `bg-slate-50` through `bg-slate-950`

Since the underlying vars flip with `.dark`, Tailwind utilities work in both modes without needing `dark:` prefixes for most cases.

### Toggle persistence

The color mode toggle persists to `localStorage` under key `color-mode`. An inline script in `<head>` reads the stored preference before first paint to prevent flash-of-wrong-theme. Falls back to `prefers-color-scheme: dark` when no stored preference exists.

## Override precedence

The cascade resolves in this order (later wins):

```
1. buildBaseTokens(seeds)    — computed from ~12 seeds
2. LEVEL_2 (foundations)     — micro-label, transitions, borders, etc.
3. LEVEL_3 (component vars)  — card-*, btn-*, field-*, shell-*, etc.
4. YAML vars                 — your explicit overrides (always wins)
```

This means:
- Set `unit: "10px"` → all spacing rescales → all components using `var(--space-*)` update
- Set `space-3: "20px"` → overrides just that step, other spacing unchanged
- Set `card-padding: "20px"` → overrides only card padding, not the spacing scale

## Full theme (exhaustive control)

For complete control, define every var group. Use the current `style-guide.vars.yaml` as a template — it defines ~270 vars across 20 groups.

Copy from:
```
src/config/theme-style-guide/style-guide.vars.yaml
```

You can also look at the "generated.css" tab in the Theme Config section of the rendered style guide to see every var and its resolved value.

## Required files

At minimum, a theme needs:

| File | Required | Notes |
|------|----------|-------|
| `style-guide.meta.yaml` | Yes | `name`, `slug`, `title`, `description` |
| `style-guide.vars.yaml` | Yes | At least seed values |
| `branding.yaml` | Yes | Brand metadata for the branding section |
| All others | No | Falls back to base theme |

Everything else is inherited. Add files only to override or extend.

## Semantic classes

Semantic classes define contextual modifiers. They're independent of the var cascade — each class has its own accent color, background, and optional typography overrides.

```yaml
semantic-classes:
  - name: danger
    class: danger
    group: States
    title: Danger
    description: "Destructive or error states"
    accent-style: bottom-bar
    vars:
      accent: "var(--error)"
      background: "var(--error-bg)"
      color: "var(--error)"
```

The engine generates `.card.danger`, `.btn.danger`, `.text-danger`, and accent/outline variants for each class.

## Auto-discovery

`listThemes()` in `src/config/loader.ts` scans `src/config/` for directories matching `theme-*`. Any directory with a valid `style-guide.meta.yaml` becomes a theme. No registration step.

Current themes:
```
src/config/theme-style-guide/    # base theme (always present)
src/config/theme-cyberpunk/      # NEON PROTOCOL
src/config/theme-sumi-e/         # Sumi-e ink wash
```

## Testing a theme

1. Create your theme directory under `src/config/theme-{slug}/`
2. Add at minimum: `style-guide.meta.yaml`, `style-guide.vars.yaml`, `branding.yaml`
3. Run `./regen.sh` to rebuild CSS
4. Run the dev server: `npx next dev`
5. Open the style guide — theme picker appears automatically
6. Check the "Theme Config" section — the "generated.css" tab shows all resolved vars
7. Verify components render correctly across sections

## Rebuilding CSS

After any YAML changes, run:

```bash
./regen.sh
```

This clears the cache, regenerates CSS for all themes, and nudges Tailwind. Never use `npx next build` — it interferes with the dev server.

## Debugging

- **Missing var?** Check the "generated.css" tab — search for the var name. If absent, add it to YAML or check that it's in `defaults.ts`.
- **Wrong color in gray ramp?** The builder interpolates linearly between `white` and `black`. For non-linear ramps, override individual `gray-*` values in YAML.
- **Component looks wrong?** Find the component's var prefix (e.g., `card-*`) in the generated CSS. Check which vars it references and trace back through the cascade.
- **Theme not appearing?** Verify the directory name starts with `theme-` and contains a valid `style-guide.meta.yaml` with at least `slug` and `name`.
- **CSS not scoped?** Check that `slug` in meta.yaml matches. Generated CSS uses `html[data-design-theme="{slug}"]` as the scope selector.
- **Base theme fallback not working?** Ensure `base-theme` in meta.yaml points to a valid `theme-*` directory name (not just the slug).
- **Type error after changes?** Run `npx tsc --noEmit`. Never use `npx next build` (it interferes with the dev server).
