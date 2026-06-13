# Styleguide Engine

## Why this exists

Skills that produce visual output (landing pages, product pages, brand identity) face a problem: generating complete CSS design systems means outputting hundreds of lines of hand-authored CSS, HTML templates, and component markup. For an LLM skill, this is:

- **Context-expensive** — hundreds of tokens spent on boilerplate CSS that follows predictable patterns
- **Error-prone** — inconsistent spacing, mismatched colors, broken component relationships
- **Non-composable** — each output is a one-off; changing the brand means regenerating everything

The styleguide engine solves this by inverting the work. Instead of a skill outputting CSS, it outputs **~12 YAML seed values**. The engine expands those seeds into a complete, internally-consistent design system.

## The leverage ratio

```
12 seed values (colors, fonts, spacing unit)
  → 300+ CSS custom properties (full gray ramp, spacing scale, component tokens)
    → 22 CSS generators (cards, buttons, forms, indicators, shells, typography, ...)
      → complete themed style guide (static HTML with live components, theme switching)
```

A skill doesn't write CSS. It writes intent.

## Intended skill workflow

```
1. Skill decides brand identity
   ├── colors (5 primaries + 4 semantics)
   ├── typography (1-2 font families)
   ├── spacing feel (tight/normal/spacious → unit value)
   └── personality (tone, audience, keywords)

2. Skill writes YAML files
   ├── style-guide.meta.yaml     → name, slug, description
   ├── style-guide.vars.yaml     → ~12 seed tokens
   └── branding.yaml             → intent, tone, audience, logo

3. Engine does the rest
   ├── defaults.ts computes 300+ tokens from seeds
   ├── 22 generators produce scoped CSS
   ├── per-theme CSS files written to public/themes/
   └── style guide renders with live component previews
```

### What skills write (small, declarative)

```yaml
vars:
  groups:
    - name: Seeds
      vars:
        white: "#1a1a2e"
        black: "#e8e8f0"
        red: "#ff6b6b"
        blue: "#4da6ff"
        yellow: "#ffd93d"
        success: "#4ade80"
        warning: "#fbbf24"
        error: "#f87171"
        info: "#60a5fa"
        font-sans: "'Inter', sans-serif"
        radius: "4px"
```

### What skills don't write

- CSS rules, selectors, or media queries
- HTML component templates
- Color ramps, spacing scales, or font size scales
- Card, button, form, indicator, shell, or layout styles
- Dark mode overrides (computed from seeds)
- Responsive breakpoints

All of that is derived by the engine's cascade and generators.

## Customization depth

Skills choose how deep to go:

| Depth | Effort | What you control |
|-------|--------|-----------------|
| **Seeds only** | ~12 values | Colors, fonts, spacing unit — everything else cascades |
| **Component overrides** | ~30-50 values | Override specific card/button/form tokens |
| **Full theme** | ~270 values | Every token, every component, every detail |
| **Custom sections** | YAML + TSX | Theme-unique page sections with custom rendering |
| **CSS snippets** | YAML with raw CSS | Inject arbitrary CSS into specific sections |

Most skills should stay at seeds-only. The cascade handles the rest.

## How it works

```
YAML config files (19 types)
  ↓ glob: style-guide.*.yaml per theme-* directory
  ↓ merged via Object.assign (later keys win)
  ↓ base-theme inheritance for missing files
  ↓
normalizer.ts
  ↓ kebab-case → camelCase
  ↓ flatten var groups → Record<string, string>
  ↓
defaults.ts — resolveDefaults(flatVars)
  ↓ Pass 1: buildBaseTokens() — seeds → full token set
  ↓ Pass 2: Layer component foundations
  ↓ Pass 3: Layer component properties
  ↓ Pass 4: YAML overrides win (always)
  ↓
22 CSS generators — produce scoped component CSS
  ↓ every value uses var(--*) references
  ↓ auto-scoped with html[data-design-theme="slug"]
  ↓
Output:
  ├── src/app/design-system.generated.css (all themes, composite)
  ├── public/themes/{slug}.css (per-theme, lazy-loadable)
  └── rendered style guide (Next.js static export)
```

## Docs

### For theme authors

| Doc | What it covers |
|-----|----------------|
| [Creating Themes](./guides/creating-themes.md) | Multi-theme system: scaffolding, inheritance, custom sections |
| [YAML Config Reference](./reference/yaml-config.md) | All 19 config files, schemas, examples |
| [Token Reference](./reference/token-reference.md) | All ~300 auto-generated CSS custom properties, grouped by category |
| [Variable Cascade](./reference/cascade.md) | Four-pass resolver, seed values, how defaults propagate |
| [Branding & Intro](./guides/branding.md) | Logo, intro hero, font loading, per-theme brand identity |
| [Variants](./guides/variants.md) | Override/variant file system for alternate section configs |
| [Troubleshooting](./troubleshooting/troubleshooting.md) | Common issues: missing tokens, wrong values, theme switching, CSS regen |

### For engine developers

| Doc | What it covers |
|-----|----------------|
| [CSS Generators](./reference/css-generators.md) | The 22 generators, pipeline order, naming conventions |
| [Adding Generators](./arch/adding-generators.md) | How to add a new CSS generator to the pipeline |
| [CSS Scoping](./arch/css-scoping.md) | Multi-theme scoping model, self-scoped vs auto-scoped sections |
| [Snippets](./arch/snippets.md) | CSS/JSX snippet assembly, dependencies, rendering contract |
| [Custom Sections](./arch/custom-sections.md) | Adding shared/theme-unique page sections, per-theme rendering |

## Key files

| Path | Role |
|------|------|
| `src/config/theme-*/*.yaml` | Theme definitions (YAML source, multiple themes) |
| `src/config/loader.ts` | Glob, merge, normalize YAML files |
| `src/config/branding-loader.ts` | Brand metadata loader |
| `src/lib/types.ts` | All TypeScript interfaces |
| `src/lib/normalizer.ts` | YAML → typed config transform |
| `src/lib/css-gen/defaults.ts` | Multi-pass cascade resolver |
| `src/lib/css-gen/vars.ts` | Emits resolved CSS custom properties |
| `src/lib/css-gen/index.ts` | Orchestrates all 22 generators |
| `src/lib/css-gen/*.ts` | Individual component CSS generators |
| `src/lib/css-cache.ts` | Cache, scoping, and output file assembly |
| `src/app/page.tsx` | Main page: loads config, renders sections |
| `scripts/create-theme.sh` | Scaffold a new theme from seeds |
