# Theme System Architecture

## Overview

The theme system currently consists of **5 standalone HTML/CSS directories** — each a self-contained design exploration with component showcase pages. A future React-based theme system is planned but not yet implemented.

## Current State: Static HTML Themes

### Directory Structure

```
therobotmakes.com/
├── blueprint/                # Minimal tech, grid-based
│   ├── style.css             #   Theme stylesheet
│   ├── head.html             #   Shared HTML head
│   ├── nav.html              #   Shared navigation
│   ├── buttons.html          #   Component showcases...
│   ├── cards.html
│   ├── typography.html
│   └── ... (15 files total)
├── brush/                    # Organic, ink-brush aesthetic
│   ├── style.css
│   ├── head.html
│   ├── header.html
│   ├── screen-*.html         #   Full page mockups (landing, dashboard, etc.)
│   └── ... (19 files total)
├── cyberpunk/                # High contrast, neon accents (same structure as blueprint)
├── sumi-e/                   # Japanese traditional, ink effects
├── swiss/                    # Swiss design, geometric precision
├── template/                 # Shared styleguide infrastructure
│   ├── hui.css               #   Base UI CSS
│   ├── sg.css                #   Styleguide layout CSS
│   └── sg.js                 #   Theme switching + navigation JS
├── styleguide-components.css # Shared component styles
├── styleguide-components.js  # Shared component JS
└── styleguide-{theme}.html   # Single-file theme previews (v1 and v2)
```

### Component Coverage per Theme

| Theme | Component Pages | Screen Mockups | Notes |
|-------|----------------|----------------|-------|
| Blueprint | 13 (buttons, cards, code-blocks, color-palette, design-tokens, effects, input-fields, navigation, spacing, status-indicators, typography, agent-dashboard) | 0 | Grid-based, minimal |
| Brush | 8 (buttons, forms, ink-palette, persona-cards, project-cards, spacing, typography, user-story-cards) | 7 (landing, dashboard, agent, deploy, personas, pitch, demo-preview) | Most complete with full page mockups |
| Cyberpunk | 13 | 0 | Same structure as blueprint |
| Sumi-e | 13+ | 0 | Same structure as blueprint |
| Swiss | 13+ | 0 | Same structure as blueprint |

### Shared Template Assets

The `template/` directory provides shared infrastructure:

- **hui.css** — Base UI reset and foundational styles
- **sg.css** — Styleguide-specific layout (sidebar nav, section grid, showcases)
- **sg.js** — Theme switching logic, navigation, and interactive showcases

Each theme's HTML pages reference these shared assets via relative paths.

### Root-Level Styleguide Files

Self-contained single HTML files for quick sharing:

| File | Purpose |
|------|---------|
| `styleguide-blueprint.html`, `.v2.html` | Blueprint theme preview |
| `styleguide-brush.html` | Brush theme preview |
| `styleguide-cyberpunk.html`, `.v2.html` | Cyberpunk theme preview |
| `styleguide-sumi-e.html`, `.v2.html` | Sumi-e theme preview |
| `styleguide-swiss.html`, `.v2.html` | Swiss theme preview |
| `styleguide-reference.html` | Reference/comparison styleguide |
| `styleguide-template.html` | Template styleguide |

## Planned: React Theme System

### Target Structure (Not Yet Implemented)

```
web/
├── src/styles/
│   ├── theme-blueprint.css
│   ├── theme-brush.css
│   ├── theme-cyberpunk.css
│   ├── theme-sumi-e.css
│   └── theme-swiss.css
├── components/themes/
│   ├── blueprint/             # 14 themed components each
│   ├── brush/
│   ├── cyberpunk/
│   ├── sumi-e/
│   └── swiss/
└── app/style-guide/
    └── {theme}/page.tsx       # Per-theme overview pages
```

### Planned Component API Contract

All theme components will export identical props interfaces. Theme switching will update a `data-theme` attribute on `<html>`, cascading CSS variables to all components via a `ThemeProvider` at the app root.

### Planned Design Tokens

| Token | Blueprint | Brush | Cyberpunk | Sumi-e | Swiss |
|-------|-----------|-------|-----------|--------|-------|
| Font Primary | Inter | Playfair Display | JetBrains Mono | Noto Serif JP | Space Grotesk |
| Font Mono | JetBrains Mono | Source Code Pro | Cascadia Code | IBM Plex Mono | JetBrains Mono |
| Spacing Unit | 4px | 6px | 2px | 8px | 4px |
| Border Radius | 2px | 8px | 0px | 2px | 4px |
| Animation Speed | 200ms | 400ms | 150ms | 600ms | 300ms |
