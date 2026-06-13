# Branding

Each theme has a `branding.yaml` that defines brand identity and the intro/cover hero section. The loader is `src/config/branding-loader.ts`.

## Top-level fields

| Field | Required | Type | Purpose |
|-------|----------|------|---------|
| `name` | Yes | string | Brand name (used as fallback display text) |
| `logo-text` | Yes | string | Text rendered in the header logo |
| `font-url` | No | string | Google Fonts URL — injected as `<link rel="stylesheet">` in `<head>` |
| `intent` | Yes | string | Design system purpose statement |
| `perception` | Yes | string | How users should feel |
| `audience` | Yes | string | Who this is for |
| `tone` | Yes | string | Voice and writing style |
| `keywords` | Yes | string[] | Brand vocabulary — used for content generation context |

## `logo-style` (optional)

Controls how `<ThemeLogo>` renders the header logo (`src/components/ThemeLogo.tsx`).

| Field | Type | Purpose |
|-------|------|---------|
| `font` | string | CSS font-family for the logo text |
| `color` | string | Text color |
| `glow` | string | CSS `text-shadow` value (neon effects, etc.) |
| `background` | string | Background color behind the logo |
| `html` | string | **Raw HTML override** — when set, replaces the entire logo with `dangerouslySetInnerHTML`. All other logo-style fields are ignored. |

When `html` is absent, `ThemeLogo` renders `logo-text` styled with `font`, `color`, `glow`, and `background`. When `html` is present, it renders the raw HTML inside a `<div class="theme-logo">`.

## `intro` (optional)

Controls the hero/cover section rendered by `<IntroHero>` (`src/components/IntroHero.tsx`). If omitted, no intro section renders.

| Field | Required | Type | Purpose |
|-------|----------|------|---------|
| `title` | Yes | string | Main heading text. Also sets `data-text` attribute for CSS pseudo-element effects. |
| `title-html` | No | string | Raw HTML override for the title. When set, replaces `title` via `dangerouslySetInnerHTML`. |
| `subtitle` | No | string | Subheading below the title |
| `quote` | No | string | Pull quote below subtitle |
| `glyph` | No | string | Large decorative character (emoji, kanji, symbol) |
| `version` | No | string | Version string (e.g. `v0.1.0`) |
| `date` | No | string | Date string |
| `repo` | No | string | Repository identifier |
| `colors` | No | string[] | Color swatches for the intro color bar |
| `hide-meta` | No | boolean | Hides the version/date/repo line |
| `hide-colors` | No | boolean | Hides the color swatch bar |

### Render order

```
┌─────────────────────────────┐
│  .sg-intro-hero             │
│                             │
│  <h1> title or title-html   │
│  <div> glyph                │
│  <div> subtitle             │
│  <div> quote                │
│  <div> version · date · repo│  ← hidden when hide-meta: true
│  <div> ████ ████ ████ ████  │  ← hidden when hide-colors: true
│                             │
└─────────────────────────────┘
```

Meta line joins version, date, and repo with ` · ` separators, skipping any that are absent.

## Font loading

`font-url` is a Google Fonts CSS URL. At build time, `layout.tsx` collects all unique `font-url` values across every theme's branding and emits them as `<link>` tags in `<head>`:

```tsx
const fontUrls = [...new Set(
  Object.values(allBrandings).map((b) => b["font-url"]).filter(Boolean)
)];
// → <link href={url} rel="stylesheet" /> for each
```

All theme fonts load on initial page load regardless of which theme is active. This prevents font flash when switching themes.

## Theme-aware rendering

Both `ThemeLogo` and `IntroHero` observe the `data-design-theme` attribute on `<html>` via a `MutationObserver`. When the user switches themes, both components re-render with the new theme's branding. The brandings record (keyed by theme slug) is passed as a prop from the server layout.

## Per-theme differences

### Base theme (`theme-style-guide`)

Minimal branding — no `logo-style`, no `intro` block. Just identity fields and a font URL.

```yaml
name: noizu.ink
logo-text: NOIZU.INK
font-url: "https://fonts.googleapis.com/css2?family=Space+Grotesk..."
intent: "Cyberpunk design system for agent-driven development tools..."
keywords: [Neon, Void, Signal, Protocol, Glow, Cyberpunk]
```

### Cyberpunk (`theme-cyberpunk`)

Adds `logo-style` with neon glow and a full `intro` block with color swatches.

```yaml
logo-style:
  font: "var(--font-display)"
  color: "#00fff0"
  glow: "0 0 8px rgba(0,255,240,0.8), 0 0 30px rgba(0,255,240,0.3)"

intro:
  title: "noizu.ink — NEON PROTOCOL"
  subtitle: "CYBERPUNK STYLE GUIDE • DEV PRAWN EDITION"
  version: "v0.1.0"
  date: "2026-03-14"
  repo: "neon-protocol/styleguide"
  colors: ["var(--teal)", "var(--fuchsia)", "var(--lime)", "var(--brand-blue)"]
```

### Sumi-e (`theme-sumi-e`)

Uses `html` override for both the logo and title. Adds a glyph, a quote, and hides the meta/color bars.

```yaml
logo-style:
  font: "var(--font-display)"
  color: "var(--sumi, #1a1a1a)"
  html: '<div class="sumi-logo-seal">墨</div><div class="sumi-logo-text">...</div>'

intro:
  title: "noizu.ink"
  title-html: '<span style="...">noizu</span><span style="...">.ink</span>'
  glyph: "墨"
  subtitle: "SUMI-E STYLE GUIDE · THE BRUSH KNOWS"
  quote: "\u201CIn the ink, the whole world..."
  hide-meta: true
  hide-colors: true
```

Key pattern: cyberpunk shows everything (meta, colors, glow); sumi-e hides chrome and uses raw HTML for typographic control.

## CSS classes

Style the intro section by targeting these classes in your theme's CSS snippets:

| Class | Element |
|-------|---------|
| `.sg-intro-hero` | Outer container |
| `.sg-intro-title` | `<h1>` — has `data-text` attr for pseudo-elements |
| `.sg-intro-glyph` | Decorative character |
| `.sg-intro-subtitle` | Subheading |
| `.sg-intro-quote` | Pull quote |
| `.sg-intro-meta` | Version/date/repo line |
| `.sg-intro-color-bar` | Color swatch row (children are `<span>` with inline `background`) |
| `.theme-logo` | Logo container in the header |
