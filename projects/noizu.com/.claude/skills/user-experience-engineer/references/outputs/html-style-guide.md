# HTML Style Guide Output

> Single-file, self-contained HTML pages that render a style guide visually — live color swatches with contrast ratios, real web fonts at every scale level, interactive component states, spacing diagrams, grid overlays. Open in a browser, see the design system. No build tools, no server, no dependencies beyond font CDN links.

---

## Table of Contents

- [1. When to Use HTML Style Guides](#1-when-to-use-html-style-guides)
- [2. Font Loading](#2-font-loading)
  - [2.1 Google Fonts (Recommended Default)](#21-google-fonts-recommended-default)
  - [2.2 Self-Hosted Fonts](#22-self-hosted-fonts)
  - [2.3 Adobe Fonts](#23-adobe-fonts)
  - [2.4 System Font Fallbacks](#24-system-font-fallbacks)
  - [2.5 Font Loading Performance](#25-font-loading-performance)
  - [2.6 Common Font Loading Recipes](#26-common-font-loading-recipes)
- [3. Conversion Process: Markdown to HTML](#3-conversion-process-markdown-to-html)
  - [3.1 Prerequisites](#31-prerequisites)
  - [3.2 Step 1 — Scaffold from Base Template](#32-step-1--scaffold-from-base-template)
  - [3.3 Step 2 — Load Fonts](#33-step-2--load-fonts)
  - [3.4 Step 3 — Inject Design Tokens](#34-step-3--inject-design-tokens)
  - [3.5 Step 4 — Build Color Palette Section](#35-step-4--build-color-palette-section)
  - [3.6 Step 5 — Build Typography Section](#36-step-5--build-typography-section)
  - [3.7 Step 6 — Build Spacing & Layout Section](#37-step-6--build-spacing--layout-section)
  - [3.8 Step 7 — Build Component Section](#38-step-7--build-component-section)
  - [3.9 Step 8 — Build Motion, Assets, Checklist Sections](#39-step-8--build-motion-assets-checklist-sections)
  - [3.10 Validation](#310-validation)
- [4. File Structure](#4-file-structure)
  - [4.1 CSS Organization for Complex Themes](#41-css-organization-for-complex-themes)
- [5. Base Template](#5-base-template)
- [6. Section Reference](#6-section-reference)
  - [6.1 Header & Scenario](#61-header--scenario)
  - [6.2 Color Palette](#62-color-palette)
  - [6.3 Typography Scale](#63-typography-scale)
  - [6.4 Spacing & Layout](#64-spacing--layout)
  - [6.5 Components](#65-components)
  - [6.6 Interaction & Motion](#66-interaction--motion)
  - [6.7 Icons & Assets](#67-icons--assets)
  - [6.8 Implementation Checklist](#68-implementation-checklist)
- [7. Handling Style Variations](#7-handling-style-variations)
  - [7.1 Dark Mode Only](#71-dark-mode-only)
  - [7.2 Light Mode Only](#72-light-mode-only)
  - [7.3 Dual Mode with Toggle](#73-dual-mode-with-toggle)
  - [7.4 Mixed Styles (80/20)](#74-mixed-styles-8020)
  - [7.5 Self-Referential vs Neutral Shell](#75-self-referential-vs-neutral-shell)
  - [7.6 Theme Namespacing for Parallel Rendering](#76-theme-namespacing-for-parallel-rendering)
- [8. Multi-Direction Comparison](#8-multi-direction-comparison)
- [9. Accessibility of the Guide Itself](#9-accessibility-of-the-guide-itself)
- [10. Print Styles](#10-print-styles)
- [References](#references)

---

## 1. When to Use HTML Style Guides

| Use Case | Why HTML |
|----------|----------|
| **Stakeholder review** | Non-designers see real colors, real fonts — no imagination required |
| **Design direction comparison** | Open 3 tabs, compare side-by-side in browser |
| **Developer handoff** | Devs inspect elements, copy CSS values, test interaction states |
| **Living documentation** | Single file in repo, updates with the project, git-diffable |
| **Offline reference** | No server needed — works on a plane, a phone, a client's laptop |
| **Client presentations** | More credible than Markdown, less overhead than a Figma prototype |

### When NOT to use

| Situation | Better Alternative |
|-----------|-------------------|
| Working draft stage, iterating fast | Markdown style guide (`process/style-guide-construction.md`) |
| Figma-centric team or handoff | `outputs/figma-spec.md` |
| Need interactive prototype | `outputs/p5js.md` or `outputs/nextjs.md` |
| Need to test flows, not just look | `outputs/landing-pages.md` |

### Relationship to Markdown Style Guides

The Markdown guide is the **source of truth**. The HTML guide is a **rendered view** of the same content. Always construct the Markdown guide first (via `process/style-guide-construction.md`), then convert to HTML using the process in Section 3.

```
style-guide-construction.md → Markdown Style Guide (source) → HTML Style Guide (view)
```

If the design changes, update the Markdown guide first, then regenerate the HTML.

---

## 2. Font Loading

Font loading is the single biggest difference between a Markdown style guide (which describes fonts) and an HTML style guide (which renders them). Get this right and the guide is credible. Get it wrong and everything looks like Times New Roman on first load.

### 2.1 Google Fonts (Recommended Default)

Most style guides reference fonts available on Google Fonts. This is the simplest, most reliable approach.

```html
<head>
  <!-- Step 1: Preconnect (reduces DNS + TLS overhead by ~100ms) -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

  <!-- Step 2: Load fonts with specific weights -->
  <!-- Only request the weights your guide actually uses -->
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@400&display=swap" rel="stylesheet">
</head>
```

**Key rules:**
- Always include `display=swap` — shows fallback immediately, swaps when loaded
- Only request weights you need — each weight adds ~15-25KB
- Use `preconnect` — saves ~100ms on first load
- List all families in a single `<link>` tag — fewer HTTP requests

### 2.2 Self-Hosted Fonts

For fonts not on Google Fonts (Geist, Sohne, commercial fonts), or for offline use:

```html
<style>
  /* Self-hosted font-face declarations */
  @font-face {
    font-family: 'Geist';
    src: url('./fonts/geist-regular.woff2') format('woff2');
    font-weight: 400;
    font-style: normal;
    font-display: swap;
  }
  @font-face {
    font-family: 'Geist';
    src: url('./fonts/geist-semibold.woff2') format('woff2');
    font-weight: 600;
    font-style: normal;
    font-display: swap;
  }
  @font-face {
    font-family: 'Geist Mono';
    src: url('./fonts/geist-mono-regular.woff2') format('woff2');
    font-weight: 400;
    font-style: normal;
    font-display: swap;
  }
</style>
```

**When self-hosting, the file structure changes:**

```
design/
├── direction-a-minimal-tech.html
└── fonts/
    ├── geist-regular.woff2
    ├── geist-semibold.woff2
    └── geist-mono-regular.woff2
```

**When to self-host:**
- Font is not on Google Fonts (Geist, Sohne, etc.)
- Guide must work fully offline
- Font license requires self-hosting
- You need a specific version that Google Fonts doesn't offer

### 2.3 Adobe Fonts

Adobe Fonts (Typekit) requires a project ID and a `<link>` to their CSS:

```html
<link rel="stylesheet" href="https://use.typekit.net/YOUR_PROJECT_ID.css">
```

**Caveat:** Adobe Fonts requires a Creative Cloud subscription and doesn't work offline. For style guides that need to be portable, prefer Google Fonts or self-hosting. Reference the Adobe Fonts link in a comment so devs know the canonical source:

```html
<!-- Font: Source Serif 4
     Adobe Fonts: https://fonts.adobe.com/fonts/source-serif
     Google Fonts (free fallback): loaded below -->
<link href="https://fonts.googleapis.com/css2?family=Source+Serif+4:wght@400;600&display=swap" rel="stylesheet">
```

### 2.4 System Font Fallbacks

Every `font-family` declaration needs a fallback stack. If the web font fails to load (offline, CDN down, slow connection), the guide should still be recognizable:

```css
/* Sans-serif stacks */
--font-sans: 'Geist', 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;

/* Serif stacks */
--font-serif: 'Source Serif 4', 'Georgia', 'Times New Roman', serif;

/* Monospace stacks */
--font-mono: 'Geist Mono', 'JetBrains Mono', 'Fira Code', 'Consolas', 'Monaco', 'Courier New', monospace;
```

**Fallback hierarchy:**
1. Primary web font (the one the guide specifies)
2. Secondary web font (a loaded alternative, if the guide specifies one)
3. Platform-specific system font (-apple-system, Segoe UI)
4. Generic system keyword (system-ui, sans-serif, serif, monospace)

### 2.5 Font Loading Performance

For style guides (single-page, loaded once), performance is less critical than for production sites. But avoid obvious mistakes:

| Do | Don't |
|----|-------|
| Request only needed weights | Load the entire variable font axis |
| Use `display=swap` | Use `display=block` (causes invisible text) |
| Preconnect to font CDN | Skip preconnect (adds 100ms+) |
| Use woff2 format only | Include woff/ttf/eot for legacy browsers |
| Single `<link>` tag for all families | Separate `<link>` per family |

### 2.6 Common Font Loading Recipes

Copy-paste these into your `<head>` based on which fonts your Markdown guide specifies.

**Geist + Geist Mono (Vercel stack):**
```html
<!-- Not on Google Fonts — use CDN from GitHub releases or self-host -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/geist@1/dist/fonts/geist-sans/style.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/geist@1/dist/fonts/geist-mono/style.min.css">
```

**Inter + JetBrains Mono (standard dev tool stack):**
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@400&display=swap" rel="stylesheet">
```

**Source Serif 4 + Inter + JetBrains Mono (editorial mix stack):**
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@400&family=Source+Serif+4:wght@400;600&display=swap" rel="stylesheet">
```

**Space Mono + Space Grotesk (brutalist stack):**
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=Space+Grotesk:wght@400;500;700&display=swap" rel="stylesheet">
```

**IBM Plex Sans + IBM Plex Mono (corporate stack):**
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600&family=IBM+Plex+Mono:wght@400&display=swap" rel="stylesheet">
```

**Playfair Display + Source Serif 4 (editorial luxury stack):**
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Source+Serif+4:wght@400&display=swap" rel="stylesheet">
```

---

## 3. Conversion Process: Markdown to HTML

This mirrors the 8-step construction in `process/style-guide-construction.md`, but adapted for HTML output.

### 3.1 Prerequisites

Before converting:

- [ ] Markdown style guide is complete and reviewed
- [ ] All fonts identified with loading strategy chosen (Section 2)
- [ ] Color values extracted and verified (hex values, not just CSS variable names)
- [ ] Base Template saved as your starting HTML file

### 3.2 Step 1 — Scaffold from Base Template

1. Copy `assets/styleguide-template.html` to your target file (e.g., `direction-a-minimal-tech.html`). If the template file is unavailable, fall back to the inline Base Template in Section 5.
2. Update `<title>` with project name and direction
3. Update the `<header>` block with:
   - Project name and direction name
   - One-line tagline from the Markdown guide
   - Style system metadata (pure or mix)
   - Key specs (font, accent, radius, mode)
4. Write the scenario paragraph — adapt from the Markdown guide's "Scenario" section

### 3.3 Step 2 — Load Fonts

1. Identify every font family in the Markdown guide's font stack
2. Look up each font in the Common Font Loading Recipes (Section 2.6)
3. If the font isn't listed, find it on Google Fonts or prepare self-hosted files
4. Replace the placeholder `<link>` tags in the `<head>` with your actual font links
5. Update the `--font-sans`, `--font-mono`, and `--font-serif` (if applicable) CSS custom properties to match

**Verification:** Open the HTML file in a browser. Open DevTools → Elements → Computed Styles. Check that `font-family` on body text shows your web font, not a system fallback. If you see the fallback font, the loading failed — check the `<link>` URL.

### 3.4 Step 3 — Inject Design Tokens

1. Copy the entire `:root { ... }` CSS block from the Markdown guide
2. **Scope tokens under `[data-theme="{name}"]`** instead of `:root` — e.g., `[data-theme="blueprint"] { --bg-primary: #0D1B2A; }`. Variable names stay unprefixed. The `data-theme` attribute selector provides isolation so multiple guides can run in parallel without collisions.
3. Replace the placeholder `[data-theme]` block in the template's `<style>` with the scoped tokens
4. Add any additional tokens the Markdown guide uses (e.g., `--eval-pass`, `--eval-freeball`) inside the same `[data-theme]` block
5. Ensure font stack variables (`--font-sans`, etc.) reference the fonts you loaded in Step 2
6. **Scope all CSS rules under `[data-theme="{name}"]`** — every selector in the guide must be written as `[data-theme="{name}"] .classname`. See [Section 7.6](#76-theme-namespacing-for-parallel-rendering) for the full pattern.

**Verification:** The page background, text colors, and accent color should now match the Markdown guide's palette. If running multiple guides in the same page, each should render independently without style bleed.

### 3.5 Step 4 — Build Color Palette Section

For each color in the Markdown guide's palette:

1. Create a `<div class="swatch">` block
2. Set the `.swatch-color` background to the literal hex value (not the CSS variable — hardcode it so the swatch is self-documenting)
3. Add the CSS variable name as `.swatch-name`
4. Add the hex value as `.swatch-value`
5. Group swatches by semantic role: Backgrounds, Text, Borders, Accent, Semantic, Domain-specific

**Contrast ratios:** For text colors, add a contrast badge showing the ratio against the primary background. Calculate using: https://webaim.org/resources/contrastchecker/

```html
<div class="swatch-contrast" style="font-size: 11px; color: var(--text-tertiary); margin-top: 4px;">
  vs bg-primary: 15.2:1 AAA
</div>
```

**Accent muted preview:** For `rgba()` accent colors, show them both standalone and overlaid on the primary background:

```html
<div class="swatch-color" style="background: var(--bg-primary);">
  <div style="background: rgba(124, 58, 237, 0.12); width: 100%; height: 100%; display: flex; align-items: center; justify-content: center;">
    <span style="color: var(--accent); font-size: 12px; font-family: var(--font-mono);">accent-muted on bg</span>
  </div>
</div>
```

### 3.6 Step 5 — Build Typography Section

For each row in the Markdown guide's type scale table:

1. Create a `<div class="type-row">` block
2. In `.type-meta`, show: level name, size, weight, line-height, and font family label
3. In `.type-sample`, render actual text at the specified size/weight/line-height using inline styles
4. Use domain-relevant sample text (not "Lorem ipsum")

**Multi-family guides:** If the guide uses multiple font families (e.g., sans for UI + serif for prose + mono for code), add a subsection heading before each family group:

```html
<h3 class="component-label" style="margin-top: var(--space-12);">Sans-Serif — UI & Navigation</h3>
<!-- sans type rows -->

<h3 class="component-label" style="margin-top: var(--space-12);">Serif — Prose & Transcripts</h3>
<!-- serif type rows -->

<h3 class="component-label" style="margin-top: var(--space-12);">Monospace — Code & Data</h3>
<!-- mono type rows -->
```

**Font source table:** After the type samples, add a table showing where to get each font:

```html
<table class="motion-table" style="margin-top: var(--space-8);">
  <thead>
    <tr><th>Font</th><th>Source</th><th>License</th><th>Link</th></tr>
  </thead>
  <tbody>
    <tr>
      <td>Geist</td>
      <td>Vercel</td>
      <td>OFL</td>
      <td><a href="https://github.com/vercel/geist-font" style="color: var(--accent);">GitHub</a></td>
    </tr>
    <!-- ... -->
  </tbody>
</table>
```

### 3.7 Step 6 — Build Spacing & Layout Section

1. For each value in the spacing scale, create a `<div class="spacing-row">` with a proportional bar
2. Add the grid specification as a styled table (breakpoint / columns / gutter / margin / max-width)
3. Optionally include the layout pattern diagram from the Markdown guide in a `<pre>` block styled with the mono font

**Grid overlay (optional but impressive):** Add a toggleable grid overlay that shows the column structure:

```html
<button onclick="document.getElementById('grid-overlay').classList.toggle('visible')"
  style="/* button styles */">
  Toggle Grid
</button>
<div id="grid-overlay" style="
  display: none;
  position: fixed; inset: 0; z-index: 99; pointer-events: none;
  max-width: 1440px; margin: 0 auto; padding: 0 64px;
">
  <div style="display: grid; grid-template-columns: repeat(12, 1fr); gap: 24px; height: 100%;">
    <!-- 12 column indicators -->
  </div>
</div>
<style>
  #grid-overlay.visible { display: block; }
  #grid-overlay > div > div {
    background: rgba(124, 58, 237, 0.05);
    border-left: 1px solid rgba(124, 58, 237, 0.1);
    border-right: 1px solid rgba(124, 58, 237, 0.1);
  }
</style>
```

### 3.8 Step 7 — Build Component Section

This is the most labor-intensive step. For each component in the Markdown guide:

**Approach A: Headless UI components (preferred)**

Use [Headless UI](https://headlessui.com/) for interactive components. Headless UI provides fully accessible, unstyled behavior primitives — you supply the CSS via your design tokens. This gives you correct ARIA attributes, keyboard navigation, and focus management for free.

1. Load Headless UI via CDN or import in your framework
2. Use Headless UI components for: Menu, Listbox, Combobox, Dialog, Popover, Disclosure, Tab, Switch, RadioGroup
3. Style entirely with your theme's CSS custom properties — Headless UI applies no visual styles
4. All states (open/closed, selected, active, disabled) are exposed as data attributes you can target in CSS

For static HTML style guides (no framework), use Headless UI's markup patterns as reference and implement the same ARIA attributes and keyboard handling manually.

**Approach B: Class-based (simpler components)**

1. Copy the component CSS from the Markdown guide into the `<style>` block
2. Use the exact class names from the guide on the HTML elements
3. Hover/focus states work automatically via CSS `:hover` and `:focus` selectors

**Approach C: Inline styles (fastest, throwaway)**

1. Apply CSS properties directly as inline `style` attributes
2. Use `onmouseover`/`onmouseout` for hover states
3. Use `onfocus`/`onblur` for focus states

**Required components (minimum):**

| Component | States to Show |
|-----------|---------------|
| **Buttons** | Primary, Secondary, Ghost — each in default, hover (live), disabled |
| **Form inputs** | Default, focused (click to see), error, disabled |
| **Cards** | Default card, clickable card (if applicable), feature card |
| **Navigation** | Active item, hover state, collapsed vs expanded (if sidebar) |

**Optional domain-specific components:**

Show components unique to the product being designed. These make the guide feel real, not generic:

- Score badges / status indicators
- Graph nodes (for CodeFresh)
- Conversation transcript blocks (for chat tools)
- Pricing cards (for SaaS)
- Alert / notification banners

**Component background:** Show components on a `var(--bg-surface)` background with a border, so they're visually separated from the guide chrome. This simulates how they'll look in the actual product.

**Component grid (required):** Every style guide must include a visual grid showing all Headless UI components rendered in the guide's theme. This grid serves as both a visual inventory and a proof that the design tokens work across all component types.

```html
<!-- Component Grid — shows every component in this theme's tokens -->
<h3 class="section-subhead">Component Grid</h3>
<div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: var(--space-6);">

  <!-- Each cell: component name + live rendered example -->
  <div style="background: var(--bg-surface); border: 1px solid var(--border-default); border-radius: var(--radius-lg); padding: var(--space-6);">
    <div style="font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-tertiary); margin-bottom: var(--space-4);">Listbox / Select</div>
    <!-- Rendered Listbox component here -->
  </div>

  <div style="background: var(--bg-surface); border: 1px solid var(--border-default); border-radius: var(--radius-lg); padding: var(--space-6);">
    <div style="font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-tertiary); margin-bottom: var(--space-4);">Dialog / Modal</div>
    <!-- Rendered Dialog trigger + preview here -->
  </div>

  <div style="background: var(--bg-surface); border: 1px solid var(--border-default); border-radius: var(--radius-lg); padding: var(--space-6);">
    <div style="font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-tertiary); margin-bottom: var(--space-4);">Tabs</div>
    <!-- Rendered Tab group here -->
  </div>

  <!-- ... one cell per Headless UI component type ... -->
</div>
```

Include at minimum: Buttons, Inputs, Cards, Listbox, Menu, Dialog, Disclosure, Tabs, Switch, and any domain-specific components. Each grid cell should show the component in its default state with a label — interactive states (hover, focus, open) activate on user interaction.

### 3.9 Step 8 — Build Motion, Assets, Checklist Sections

**Motion table:** Convert the Markdown guide's interaction table to an HTML `<table>` using the `.motion-table` class. Add a live demo element above the table — a simple box that demonstrates the guide's primary easing and duration:

```html
<div style="display: flex; gap: var(--space-4); margin-bottom: var(--space-8);">
  <div style="width: 64px; height: 64px; background: var(--accent-muted); border: 1px solid var(--accent); border-radius: var(--radius-md); transition: transform 150ms ease, background 150ms ease; cursor: pointer;"
    onmouseover="this.style.transform='scale(1.05)'; this.style.background='var(--accent)'"
    onmouseout="this.style.transform='scale(1)'; this.style.background='var(--accent-muted)'">
  </div>
  <span style="align-self: center; font-size: 13px; color: var(--text-tertiary);">Hover to preview 150ms ease transition</span>
</div>
```

**Assets:** Text section — icon library name, stroke weight, usage notes. If the guide uses Lucide, optionally load a few example icons via CDN:

```html
<script src="https://unpkg.com/lucide@latest/dist/umd/lucide.min.js"></script>
<script>lucide.createIcons();</script>

<div style="display: flex; gap: var(--space-6); color: var(--text-secondary);">
  <i data-lucide="play" style="width: 20px; height: 20px;"></i>
  <i data-lucide="git-branch" style="width: 20px; height: 20px;"></i>
  <i data-lucide="check-circle" style="width: 20px; height: 20px;"></i>
  <i data-lucide="alert-triangle" style="width: 20px; height: 20px;"></i>
</div>
```

**Checklist:** Render as a `<ul class="checklist">` — empty visual checkboxes, not interactive. Copy items directly from the Markdown guide.

### 3.10 Validation

After conversion, verify:

- [ ] **Fonts render correctly** — DevTools shows web font, not system fallback
- [ ] **All colors match** — compare swatches side-by-side with Markdown hex values
- [ ] **Type scale is accurate** — each level renders at the specified size/weight/line-height
- [ ] **Hover states work** — buttons, inputs, cards respond to mouse interaction
- [ ] **Focus states work** — tab through the page, focus rings appear on interactive elements
- [ ] **Responsive** — resize browser to mobile width, content reflows without horizontal scroll
- [ ] **Print** — Ctrl+P shows a clean print preview (Section 10)
- [ ] **Offline** — disconnect from internet, reload — if using self-hosted fonts, everything renders; if using Google Fonts, fallbacks appear cleanly

---

## 4. File Structure

HTML style guides are **single self-contained files**. All CSS is inlined. The only external dependencies are font CDN links (which degrade gracefully to system fonts) and the StyleGuide UMD bundle (`sg.js` + `sg.css`) loaded from `https://noizu.github.io/react-assets/dist/`.

```
project/
└── design/
    ├── direction-a-minimal-tech.md         # Source Markdown (source of truth)
    ├── direction-a-minimal-tech.html       # Rendered HTML style guide
    ├── direction-b-minimal-editorial.md
    ├── direction-b-minimal-editorial.html
    ├── direction-c-neo-brutalist.md
    ├── direction-c-neo-brutalist.html
    ├── compare.html                        # Optional: side-by-side iframe comparison
    └── README.md                           # Comparison index
```

**Self-hosting exception:** If using self-hosted fonts, add a `fonts/` directory alongside the HTML files. This is the only case where the HTML file references local files.

### 4.1 CSS Organization for Complex Themes

When your `<style>` block grows large (roughly 200+ lines of theme CSS), extract it into a `theme/` subfolder and import it. This keeps the HTML file readable and makes CSS easier to maintain.

```
project/
└── design/
    ├── my-product-sg.html                  # Style guide HTML (imports CSS)
    └── theme/
        ├── tokens.css                      # Design tokens (custom properties)
        ├── buttons.css                     # Button variants
        ├── cards.css                       # Card variants
        ├── inputs.css                      # Form field styles
        ├── components.css                  # Headless UI component styles
        └── overrides.css                   # StyleGuide CDN class overrides
```

In the HTML file, replace the large `<style>` block with imports:

```html
<style>
  @import './theme/tokens.css';
  @import './theme/buttons.css';
  @import './theme/cards.css';
  @import './theme/inputs.css';
  @import './theme/components.css';
  @import './theme/overrides.css';
</style>
```

**When to extract:** Use your judgment — a 50-line theme stays inline; a 400-line theme with button variants, card styles, and Headless UI component CSS should be split. The goal is to keep any single file under ~200 lines of CSS.

**What stays inline:** The `[data-design-theme]` token block can stay inline since it's the identity of the theme. Everything that _consumes_ those tokens (component classes, overrides) is what gets extracted.

**Note:** `@import` from a `<style>` tag requires serving via HTTP (not `file://`). For local development, use `python -m http.server` or any static server. Alternatively, use `<link rel="stylesheet">` tags in `<head>` instead of `@import`.

---

## 5. Base Template

This is the inline fallback scaffold. The default workflow uses `assets/styleguide-template.html` (see Section 3.2). This inline version is provided as a reference if the template file is unavailable.

The template includes:
- Sticky section navigation
- Header with metadata
- All 7 sections with structural markup
- Print-friendly media query
- Responsive mobile layout
- Reduced-motion support
- Semantic HTML (nav, header, section, main)
- Accessible focus styles

```html
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Style Guide: [PROJECT NAME] — [DIRECTION NAME]</title>
  <meta name="description" content="Visual style guide for [PROJECT NAME] — [DIRECTION NAME]. [Style system description].">

  <!-- =============================================
       FONTS — Replace with your guide's fonts
       See Section 2.6 for copy-paste recipes
       ============================================= -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@400&display=swap" rel="stylesheet">

  <style>
    /* =============================================
       DESIGN TOKENS — SCOPED VIA data-theme
       Replace this block with tokens from the Markdown
       style guide's CSS section. Variable names stay
       UNPREFIXED. Scope under [data-theme="{name}"]
       instead of :root so multiple guides can run in
       parallel without variable collisions.
       ============================================= */
    [data-theme="minimal-tech"] {
      --bg-primary: #09090B;
      --bg-surface: #141418;
      --bg-elevated: #1C1C22;

      --text-primary: #EDEDF0;
      --text-secondary: #8E8E9A;
      --text-tertiary: #56566A;

      --border-default: #27272F;
      --border-subtle: #1C1C22;

      --accent: #7C3AED;
      --accent-hover: #8B5CF6;
      --accent-muted: rgba(124, 58, 237, 0.12);

      --success: #22C55E;
      --warning: #EAB308;
      --error: #EF4444;
      --info: #60A5FA;

      --font-sans: 'Inter', -apple-system, BlinkMacSystemFont, system-ui, sans-serif;
      --font-mono: 'JetBrains Mono', 'Fira Code', 'Consolas', monospace;

      --space-1: 4px;
      --space-2: 8px;
      --space-3: 12px;
      --space-4: 16px;
      --space-6: 24px;
      --space-8: 32px;
      --space-12: 48px;
      --space-16: 64px;
      --space-24: 96px;

      --radius-sm: 4px;
      --radius-md: 6px;
      --radius-lg: 8px;
    }

    /* =============================================
       PRODUCT COMPONENT CSS — THEME-SCOPED
       Components use unprefixed variables. The
       [data-theme] selector on <body> activates the
       right token values. Only scope selectors under
       [data-theme="{name}"] when a theme needs
       structural changes beyond what tokens cover.
       ============================================= */

    /* Pattern 1 — Variables do all the work (preferred):
    .btn-primary { background: var(--accent); color: #fff; ... }
    .card { background: var(--bg-surface); border: 1px solid var(--border-default); ... }

       Pattern 2 — Theme needs structural overrides:
    [data-theme="brutalist"] .card {
      border: 3px solid black;
      border-radius: 0;
      box-shadow: 4px 4px 0 black;
    }
    */

    /* =============================================
       GUIDE LAYOUT — THEME-SCOPED VIA data-theme
       The [data-theme] attribute on <body> activates
       tokens and scopes structural overrides.
       Components use unprefixed var() references.
       Structural resets (*, html) remain global.
       ============================================= */

    *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

    html { scroll-behavior: smooth; }
    @media (prefers-reduced-motion: reduce) {
      html { scroll-behavior: auto; }
    }

    body[data-theme] {
      font-family: var(--font-sans);
      font-size: 15px;
      background: var(--bg-primary);
      color: var(--text-primary);
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
      -moz-osx-font-smoothing: grayscale;
    }

    a { color: var(--accent); text-decoration: none; }
    a:hover { text-decoration: underline; }

    :focus-visible {
      outline: 2px solid var(--accent);
      outline-offset: 2px;
    }

    .guide {
      max-width: 1080px;
      margin: 0 auto;
      padding: var(--space-8);
    }

    /* --- Sticky Navigation --- */
    .guide-nav {
      position: sticky;
      top: 0;
      z-index: 50;
      background: var(--bg-primary);
      border-bottom: 1px solid var(--border-default);
      padding: var(--space-3) var(--space-8);
      margin: 0 calc(-1 * var(--space-8));
      display: flex;
      gap: var(--space-6);
      overflow-x: auto;
      font-size: 13px;
      -webkit-overflow-scrolling: touch;
    }
    .guide-nav a {
      color: var(--text-secondary);
      text-decoration: none;
      white-space: nowrap;
      transition: color 150ms;
      padding: var(--space-1) 0;
    }
    .guide-nav a:hover { color: var(--text-primary); }

    /* --- Header --- */
    .guide-header {
      padding: var(--space-24) 0 var(--space-16);
    }
    .guide-header h1 {
      font-size: 36px;
      font-weight: 600;
      line-height: 1.15;
      margin-bottom: var(--space-4);
    }
    .guide-header .tagline {
      font-size: 18px;
      color: var(--text-secondary);
      max-width: 55ch;
      line-height: 1.5;
      margin-bottom: var(--space-6);
    }
    .guide-header .scenario {
      font-size: 14px;
      color: var(--text-secondary);
      max-width: 70ch;
      line-height: 1.7;
      margin-bottom: var(--space-8);
      padding: var(--space-6);
      background: var(--bg-surface);
      border: 1px solid var(--border-default);
      border-radius: var(--radius-lg);
    }
    .guide-meta {
      display: flex;
      flex-wrap: wrap;
      gap: var(--space-4) var(--space-8);
      font-size: 13px;
    }
    .guide-meta dt {
      color: var(--text-tertiary);
      font-weight: 500;
    }
    .guide-meta dd {
      font-family: var(--font-mono);
      color: var(--text-secondary);
    }

    /* --- Sections --- */
    .guide-section {
      padding: var(--space-16) 0;
      border-bottom: 1px solid var(--border-default);
    }
    .guide-section:last-child { border-bottom: none; }
    .section-number {
      font-family: var(--font-mono);
      font-size: 12px;
      font-weight: 600;
      color: var(--accent);
      margin-bottom: var(--space-2);
    }
    .section-heading {
      font-size: 28px;
      font-weight: 600;
      line-height: 1.2;
      margin-bottom: var(--space-2);
    }
    .section-desc {
      color: var(--text-secondary);
      font-size: 15px;
      max-width: 65ch;
      line-height: 1.6;
      margin-bottom: var(--space-8);
    }
    .section-subhead {
      font-size: 16px;
      font-weight: 600;
      color: var(--text-secondary);
      margin: var(--space-8) 0 var(--space-4);
    }

    /* --- Swatch Grid --- */
    .swatch-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
      gap: var(--space-4);
    }
    .swatch {
      border: 1px solid var(--border-default);
      border-radius: var(--radius-lg);
      overflow: hidden;
    }
    .swatch-color {
      height: 72px;
      display: flex;
      align-items: flex-end;
      justify-content: space-between;
      padding: var(--space-2) var(--space-3);
    }
    .swatch-aa {
      font-size: 10px;
      font-family: var(--font-mono);
      padding: 1px 4px;
      border-radius: 2px;
      background: rgba(0,0,0,0.3);
      color: rgba(255,255,255,0.8);
    }
    .swatch-label {
      padding: var(--space-3);
      background: var(--bg-surface);
    }
    .swatch-name {
      font-size: 13px;
      font-weight: 600;
      margin-bottom: 2px;
    }
    .swatch-value {
      font-family: var(--font-mono);
      font-size: 12px;
      color: var(--text-secondary);
    }
    .swatch-var {
      font-family: var(--font-mono);
      font-size: 11px;
      color: var(--text-tertiary);
      margin-top: 2px;
    }

    /* --- Type Scale --- */
    .type-scale { margin-bottom: var(--space-8); }
    .type-row {
      display: flex;
      align-items: baseline;
      gap: var(--space-8);
      padding: var(--space-4) 0;
      border-bottom: 1px solid var(--border-subtle);
    }
    .type-row:last-child { border-bottom: none; }
    .type-meta {
      flex: 0 0 180px;
      font-family: var(--font-mono);
      font-size: 12px;
      color: var(--text-tertiary);
      line-height: 1.5;
    }
    .type-meta strong {
      color: var(--text-secondary);
      font-weight: 600;
      display: block;
      margin-bottom: 2px;
    }
    .type-sample {
      flex: 1;
      min-width: 0;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    /* --- Spacing Visualization --- */
    .spacing-scale { margin-bottom: var(--space-8); }
    .spacing-row {
      display: flex;
      align-items: center;
      gap: var(--space-4);
      padding: var(--space-2) 0;
    }
    .spacing-label {
      flex: 0 0 80px;
      font-family: var(--font-mono);
      font-size: 12px;
      color: var(--text-tertiary);
      text-align: right;
    }
    .spacing-bar {
      height: 28px;
      background: var(--accent-muted);
      border-left: 3px solid var(--accent);
      border-radius: 0 var(--radius-sm) var(--radius-sm) 0;
      display: flex;
      align-items: center;
    }
    .spacing-name {
      font-family: var(--font-mono);
      font-size: 11px;
      color: var(--text-secondary);
      margin-left: var(--space-3);
      white-space: nowrap;
    }

    /* --- Grid Spec Table --- */
    .grid-table {
      width: 100%;
      border-collapse: collapse;
      font-size: 13px;
      margin-top: var(--space-6);
    }
    .grid-table th {
      text-align: left;
      font-size: 11px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      color: var(--text-tertiary);
      padding: var(--space-3) var(--space-4);
      border-bottom: 1px solid var(--border-default);
    }
    .grid-table td {
      padding: var(--space-3) var(--space-4);
      border-bottom: 1px solid var(--border-subtle);
      color: var(--text-secondary);
      font-family: var(--font-mono);
      font-size: 12px;
    }
    .grid-table td:first-child {
      color: var(--text-primary);
      font-family: var(--font-sans);
      font-weight: 500;
    }

    /* --- Component Showcase --- */
    .component-group { margin-bottom: var(--space-12); }
    .component-label {
      font-size: 14px;
      font-weight: 600;
      margin-bottom: var(--space-4);
      color: var(--text-secondary);
    }
    .component-row {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      gap: var(--space-6);
      padding: var(--space-8);
      background: var(--bg-surface);
      border: 1px solid var(--border-default);
      border-radius: var(--radius-lg);
    }
    .component-stack {
      display: flex;
      flex-direction: column;
      gap: var(--space-3);
    }
    .state-label {
      font-family: var(--font-mono);
      font-size: 11px;
      color: var(--text-tertiary);
    }

    /* --- Motion Table --- */
    .motion-table {
      width: 100%;
      border-collapse: collapse;
      font-size: 14px;
    }
    .motion-table th {
      text-align: left;
      font-size: 11px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      color: var(--text-tertiary);
      padding: var(--space-3) var(--space-4);
      border-bottom: 1px solid var(--border-default);
    }
    .motion-table td {
      padding: var(--space-3) var(--space-4);
      border-bottom: 1px solid var(--border-subtle);
      color: var(--text-secondary);
    }
    .motion-table td:first-child { color: var(--text-primary); font-weight: 500; }
    .motion-table code {
      font-family: var(--font-mono);
      font-size: 12px;
      background: var(--bg-elevated);
      padding: 2px 6px;
      border-radius: var(--radius-sm);
    }

    /* --- Motion Demo --- */
    .motion-demo {
      display: flex;
      align-items: center;
      gap: var(--space-4);
      padding: var(--space-6);
      background: var(--bg-surface);
      border: 1px solid var(--border-default);
      border-radius: var(--radius-lg);
      margin-bottom: var(--space-8);
    }
    .motion-demo-box {
      width: 56px;
      height: 56px;
      background: var(--accent-muted);
      border: 1px solid var(--accent);
      border-radius: var(--radius-md);
      cursor: pointer;
      transition: transform 150ms ease, background 150ms ease;
    }
    .motion-demo-box:hover {
      transform: scale(1.08);
      background: var(--accent);
    }

    /* --- Checklist --- */
    .checklist {
      list-style: none;
      display: grid;
      gap: var(--space-3);
    }
    .checklist li {
      display: flex;
      align-items: flex-start;
      gap: var(--space-3);
      font-size: 14px;
      color: var(--text-secondary);
      line-height: 1.5;
    }
    .checklist li::before {
      content: '';
      flex-shrink: 0;
      width: 18px;
      height: 18px;
      margin-top: 3px;
      border: 2px solid var(--border-default);
      border-radius: var(--radius-sm);
    }

    /* --- Layout Diagram --- */
    .layout-diagram {
      font-family: var(--font-mono);
      font-size: 12px;
      line-height: 1.4;
      color: var(--text-secondary);
      background: var(--bg-surface);
      border: 1px solid var(--border-default);
      border-radius: var(--radius-lg);
      padding: var(--space-6);
      overflow-x: auto;
      white-space: pre;
      margin-top: var(--space-6);
    }

    /* --- Icon Grid --- */
    .icon-grid {
      display: flex;
      flex-wrap: wrap;
      gap: var(--space-6);
      padding: var(--space-6);
      background: var(--bg-surface);
      border: 1px solid var(--border-default);
      border-radius: var(--radius-lg);
    }
    .icon-item {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: var(--space-2);
      color: var(--text-secondary);
    }
    .icon-item span {
      font-size: 11px;
      font-family: var(--font-mono);
      color: var(--text-tertiary);
    }

    /* --- Footer --- */
    .guide-footer {
      padding: var(--space-12) 0;
      font-size: 12px;
      color: var(--text-tertiary);
      text-align: center;
    }

    /* =============================================
       RESPONSIVE
       ============================================= */
    @media (max-width: 768px) {
      .guide { padding: var(--space-4); }
      .guide-nav {
        margin: 0 calc(-1 * var(--space-4));
        padding: var(--space-3) var(--space-4);
      }
      .guide-header h1 { font-size: 28px; }
      .guide-header .tagline { font-size: 16px; }
      .section-heading { font-size: 22px; }
      .swatch-grid { grid-template-columns: repeat(2, 1fr); }
      .type-row {
        flex-direction: column;
        gap: var(--space-2);
      }
      .type-meta { flex: none; }
      .component-row {
        flex-direction: column;
        align-items: stretch;
      }
    }

    /* =============================================
       PRINT
       ============================================= */
    @media print {
      .guide-nav { display: none; }
      body { background: white; color: black; }
      .guide-section { page-break-inside: avoid; }
      .swatch-color { border: 1px solid #ccc; print-color-adjust: exact; -webkit-print-color-adjust: exact; }
      .component-row { background: #f5f5f5; print-color-adjust: exact; -webkit-print-color-adjust: exact; }
      a { color: black; }
      a[href]::after { content: " (" attr(href) ")"; font-size: 0.8em; color: #666; }
    }
  </style>
</head>
<body data-theme="minimal-tech">
<!-- =============================================
     THEME ATTRIBUTE: Set data-theme="{name}" on <body>.
     This activates the matching [data-theme="{name}"]
     CSS block, scoping all design tokens so multiple
     guides can coexist without collisions.
     Replace "minimal-tech" with your theme slug
     (e.g., "blueprint", "cyberpunk", "sumi-e").
     ============================================= -->

<main class="guide">

  <!-- ===== NAVIGATION ===== -->
  <nav class="guide-nav" aria-label="Style guide sections">
    <a href="#scenario">Scenario</a>
    <a href="#colors">Colors</a>
    <a href="#typography">Typography</a>
    <a href="#spacing">Spacing & Layout</a>
    <a href="#components">Components</a>
    <a href="#motion">Motion</a>
    <a href="#assets">Assets</a>
    <a href="#checklist">Checklist</a>
  </nav>

  <!-- ===== HEADER ===== -->
  <header class="guide-header">
    <h1>[Project Name] — [Direction Name]</h1>
    <p class="tagline">[One-line description from the Markdown style guide]</p>
    <dl class="guide-meta">
      <div><dt>Style System</dt><dd>[e.g., Minimal Tech 100%]</dd></div>
      <div><dt>Primary Font</dt><dd>[e.g., Geist]</dd></div>
      <div><dt>Mono Font</dt><dd>[e.g., Geist Mono]</dd></div>
      <div><dt>Accent</dt><dd>[e.g., Violet #7C3AED]</dd></div>
      <div><dt>Border Radius</dt><dd>[e.g., 6px]</dd></div>
      <div><dt>Mode</dt><dd>[e.g., Dark only]</dd></div>
    </dl>
  </header>

  <!-- ===== 01 SCENARIO ===== -->
  <section class="guide-section" id="scenario">
    <div class="section-number">01</div>
    <h2 class="section-heading">Scenario</h2>
    <div class="guide-header scenario">
      [Paste the scenario paragraphs from the Markdown guide here.
       Explain what this guide serves, what signals it sends, and
       why this style was chosen. 2-3 paragraphs.]
    </div>
  </section>

  <!-- ===== 02 COLORS ===== -->
  <section class="guide-section" id="colors">
    <div class="section-number">02</div>
    <h2 class="section-heading">Color Palette</h2>
    <p class="section-desc">
      [Usage rules summary — paste 3-5 bullets from the Markdown guide.]
    </p>

    <h3 class="section-subhead">Backgrounds</h3>
    <div class="swatch-grid">
      <!--
        For each color:
        1. Set style="background: #HEX;" on .swatch-color
        2. Put the human name in .swatch-name
        3. Put the hex value in .swatch-value
        4. Put the CSS variable name in .swatch-var
        5. Optionally add contrast ratio in .swatch-aa
      -->
      <div class="swatch">
        <div class="swatch-color" style="background: #09090B;"></div>
        <div class="swatch-label">
          <div class="swatch-name">Background</div>
          <div class="swatch-value">#09090B</div>
          <div class="swatch-var">--bg-primary</div>
        </div>
      </div>
      <div class="swatch">
        <div class="swatch-color" style="background: #141418;"></div>
        <div class="swatch-label">
          <div class="swatch-name">Surface</div>
          <div class="swatch-value">#141418</div>
          <div class="swatch-var">--bg-surface</div>
        </div>
      </div>
      <div class="swatch">
        <div class="swatch-color" style="background: #1C1C22;"></div>
        <div class="swatch-label">
          <div class="swatch-name">Elevated</div>
          <div class="swatch-value">#1C1C22</div>
          <div class="swatch-var">--bg-elevated</div>
        </div>
      </div>
    </div>

    <h3 class="section-subhead">Text</h3>
    <div class="swatch-grid">
      <div class="swatch">
        <div class="swatch-color" style="background: #EDEDF0;">
          <span class="swatch-aa">vs bg: 15.2:1</span>
        </div>
        <div class="swatch-label">
          <div class="swatch-name">Text Primary</div>
          <div class="swatch-value">#EDEDF0</div>
          <div class="swatch-var">--text-primary</div>
        </div>
      </div>
      <div class="swatch">
        <div class="swatch-color" style="background: #8E8E9A;">
          <span class="swatch-aa">vs bg: 6.2:1</span>
        </div>
        <div class="swatch-label">
          <div class="swatch-name">Text Secondary</div>
          <div class="swatch-value">#8E8E9A</div>
          <div class="swatch-var">--text-secondary</div>
        </div>
      </div>
      <div class="swatch">
        <div class="swatch-color" style="background: #56566A;">
          <span class="swatch-aa">vs bg: 3.4:1</span>
        </div>
        <div class="swatch-label">
          <div class="swatch-name">Text Tertiary</div>
          <div class="swatch-value">#56566A</div>
          <div class="swatch-var">--text-tertiary</div>
        </div>
      </div>
    </div>

    <h3 class="section-subhead">Accent</h3>
    <div class="swatch-grid">
      <!-- accent, accent-hover, accent-muted -->
    </div>

    <h3 class="section-subhead">Semantic</h3>
    <div class="swatch-grid">
      <!-- success, warning, error, info -->
    </div>

    <h3 class="section-subhead">Domain-Specific</h3>
    <div class="swatch-grid">
      <!-- eval-pass, eval-warn, eval-fail, eval-freeball, etc. -->
    </div>
  </section>

  <!-- ===== 03 TYPOGRAPHY ===== -->
  <section class="guide-section" id="typography">
    <div class="section-number">03</div>
    <h2 class="section-heading">Typography</h2>
    <p class="section-desc">
      [Typography notes from the Markdown guide — key rules and constraints.]
    </p>

    <h3 class="section-subhead">Sans-Serif — UI & Navigation</h3>
    <div class="type-scale">
      <div class="type-row">
        <div class="type-meta">
          <strong>Display</strong>
          36px / 600 / 1.15
        </div>
        <div class="type-sample" style="font-size: 36px; font-weight: 600; line-height: 1.15;">
          Behavioral Testing
        </div>
      </div>
      <div class="type-row">
        <div class="type-meta">
          <strong>H1</strong>
          28px / 600 / 1.2
        </div>
        <div class="type-sample" style="font-size: 28px; font-weight: 600; line-height: 1.2;">
          Evaluation Scripts
        </div>
      </div>
      <div class="type-row">
        <div class="type-meta">
          <strong>H2</strong>
          22px / 600 / 1.25
        </div>
        <div class="type-sample" style="font-size: 22px; font-weight: 600; line-height: 1.25;">
          Onboarding Flow Results
        </div>
      </div>
      <div class="type-row">
        <div class="type-meta">
          <strong>H3</strong>
          18px / 600 / 1.3
        </div>
        <div class="type-sample" style="font-size: 18px; font-weight: 600; line-height: 1.3;">
          Node: Ask Clarifying Questions
        </div>
      </div>
      <div class="type-row">
        <div class="type-meta">
          <strong>Body</strong>
          14px / 400 / 1.6
        </div>
        <div class="type-sample" style="font-size: 14px; font-weight: 400; line-height: 1.6;">
          The script runner agent takes over when the evaluated agent deviates from all expected branches, improvising follow-up prompts that explore the deviation path.
        </div>
      </div>
      <div class="type-row">
        <div class="type-meta">
          <strong>Body Small</strong>
          12px / 400 / 1.5
        </div>
        <div class="type-sample" style="font-size: 12px; font-weight: 400; line-height: 1.5;">
          Last run: 2h ago &middot; 12 nodes &middot; 3 personas &middot; Score: 0.87
        </div>
      </div>
      <div class="type-row">
        <div class="type-meta">
          <strong>Caption</strong>
          11px / 500 / 1.4
        </div>
        <div class="type-sample" style="font-size: 11px; font-weight: 500; line-height: 1.4; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-tertiary);">
          EVALUATION RESULTS
        </div>
      </div>
    </div>

    <h3 class="section-subhead">Monospace — Code & Data</h3>
    <div class="type-scale">
      <div class="type-row">
        <div class="type-meta">
          <strong>Code</strong>
          13px / 400 / 1.5
        </div>
        <div class="type-sample" style="font-family: var(--font-mono); font-size: 13px; font-weight: 400; line-height: 1.5;">
          const result = await agent.evaluate(script, { persona: 'hostile' });
        </div>
      </div>
      <div class="type-row">
        <div class="type-meta">
          <strong>Score</strong>
          12px / 600 / 1.4
        </div>
        <div class="type-sample" style="font-family: var(--font-mono); font-size: 12px; font-weight: 600; line-height: 1.4;">
          0.92 &middot; PASS &middot; 14/15 expectations met
        </div>
      </div>
    </div>

    <!-- Font source table -->
    <h3 class="section-subhead">Font Sources</h3>
    <table class="grid-table">
      <thead>
        <tr><th>Font</th><th>Source</th><th>License</th><th>Link</th></tr>
      </thead>
      <tbody>
        <tr>
          <td>Inter</td>
          <td style="font-family: var(--font-mono); font-size: 12px;">Google Fonts</td>
          <td style="font-family: var(--font-mono); font-size: 12px;">OFL</td>
          <td><a href="https://fonts.google.com/specimen/Inter">fonts.google.com</a></td>
        </tr>
        <!-- Add rows for each font -->
      </tbody>
    </table>
  </section>

  <!-- ===== 04 SPACING & LAYOUT ===== -->
  <section class="guide-section" id="spacing">
    <div class="section-number">04</div>
    <h2 class="section-heading">Spacing & Layout</h2>
    <p class="section-desc">
      [Spacing philosophy from the Markdown guide. e.g., "Base unit: 8px. All spacing derives from the scale below."]
    </p>

    <h3 class="section-subhead">Spacing Scale</h3>
    <div class="spacing-scale">
      <div class="spacing-row">
        <div class="spacing-label">4px</div>
        <div class="spacing-bar" style="width: 4px;"><span class="spacing-name">Micro</span></div>
      </div>
      <div class="spacing-row">
        <div class="spacing-label">8px</div>
        <div class="spacing-bar" style="width: 16px;"><span class="spacing-name">XS</span></div>
      </div>
      <div class="spacing-row">
        <div class="spacing-label">12px</div>
        <div class="spacing-bar" style="width: 24px;"><span class="spacing-name">SM</span></div>
      </div>
      <div class="spacing-row">
        <div class="spacing-label">16px</div>
        <div class="spacing-bar" style="width: 40px;"><span class="spacing-name">MD</span></div>
      </div>
      <div class="spacing-row">
        <div class="spacing-label">24px</div>
        <div class="spacing-bar" style="width: 64px;"><span class="spacing-name">LG</span></div>
      </div>
      <div class="spacing-row">
        <div class="spacing-label">32px</div>
        <div class="spacing-bar" style="width: 96px;"><span class="spacing-name">XL</span></div>
      </div>
      <div class="spacing-row">
        <div class="spacing-label">48px</div>
        <div class="spacing-bar" style="width: 144px;"><span class="spacing-name">2XL</span></div>
      </div>
      <div class="spacing-row">
        <div class="spacing-label">64px</div>
        <div class="spacing-bar" style="width: 192px;"><span class="spacing-name">3XL</span></div>
      </div>
      <div class="spacing-row">
        <div class="spacing-label">96px</div>
        <div class="spacing-bar" style="width: 288px;"><span class="spacing-name">4XL</span></div>
      </div>
    </div>

    <h3 class="section-subhead">Grid Specification</h3>
    <table class="grid-table">
      <thead>
        <tr><th>Breakpoint</th><th>Columns</th><th>Gutter</th><th>Margin</th><th>Max Width</th></tr>
      </thead>
      <tbody>
        <tr><td>Mobile (&lt;768px)</td><td>4</td><td>12px</td><td>16px</td><td>100%</td></tr>
        <tr><td>Tablet (768-1024px)</td><td>8</td><td>16px</td><td>24px</td><td>100%</td></tr>
        <tr><td>Desktop (1024-1440px)</td><td>12</td><td>24px</td><td>32px</td><td>100%</td></tr>
        <tr><td>Wide (&gt;1440px)</td><td>12</td><td>24px</td><td>64px</td><td>1440px</td></tr>
      </tbody>
    </table>

    <h3 class="section-subhead">Layout Pattern</h3>
    <pre class="layout-diagram">[Paste the ASCII layout diagram from the Markdown guide here]</pre>
  </section>

  <!-- ===== 05 COMPONENTS ===== -->
  <section class="guide-section" id="components">
    <div class="section-number">05</div>
    <h2 class="section-heading">Components</h2>
    <p class="section-desc">
      Live, interactive examples. Hover to see state changes. Click inputs to see focus states.
    </p>

    <!-- BUTTONS -->
    <div class="component-group">
      <h3 class="component-label">Buttons</h3>
      <div class="component-row">
        <!--
          APPROACH: Paste your guide's button CSS into the <style> block above,
          then use the class names directly here. Hover/focus states work via CSS.
          If you haven't pasted the CSS, use inline styles as a fallback.
        -->
        <div class="component-stack">
          <span class="state-label">Primary</span>
          <button style="background: var(--accent); color: #fff; border: none; padding: 8px 16px; border-radius: var(--radius-md); font-family: var(--font-sans); font-size: 13px; font-weight: 600; cursor: pointer; transition: opacity 150ms;" onmouseover="this.style.opacity='0.9'" onmouseout="this.style.opacity='1'">Run Evaluation</button>
        </div>
        <div class="component-stack">
          <span class="state-label">Secondary</span>
          <button style="background: transparent; color: var(--text-primary); border: 1px solid var(--border-default); padding: 8px 16px; border-radius: var(--radius-md); font-family: var(--font-sans); font-size: 13px; font-weight: 600; cursor: pointer; transition: background 150ms;" onmouseover="this.style.background='var(--bg-elevated)'" onmouseout="this.style.background='transparent'">Export Script</button>
        </div>
        <div class="component-stack">
          <span class="state-label">Ghost</span>
          <button style="background: transparent; color: var(--text-secondary); border: none; padding: 8px 12px; border-radius: var(--radius-md); font-family: var(--font-sans); font-size: 13px; cursor: pointer; transition: color 150ms;" onmouseover="this.style.color='var(--text-primary)'" onmouseout="this.style.color='var(--text-secondary)'">Cancel</button>
        </div>
        <div class="component-stack">
          <span class="state-label">Disabled</span>
          <button style="background: var(--accent); color: #fff; border: none; padding: 8px 16px; border-radius: var(--radius-md); font-family: var(--font-sans); font-size: 13px; font-weight: 600; opacity: 0.4; cursor: not-allowed;" disabled>Run Evaluation</button>
        </div>
      </div>
    </div>

    <!-- INPUTS -->
    <div class="component-group">
      <h3 class="component-label">Form Inputs</h3>
      <div class="component-row" style="flex-direction: column; align-items: stretch;">
        <div class="component-stack" style="max-width: 400px;">
          <span class="state-label">Default (click to see focus)</span>
          <input type="text" placeholder="Script name..." style="display: block; width: 100%; background: var(--bg-primary); color: var(--text-primary); border: 1px solid var(--border-default); border-radius: var(--radius-md); padding: 8px 12px; font-family: var(--font-sans); font-size: 14px; outline: none; transition: border-color 150ms, box-shadow 150ms;" onfocus="this.style.borderColor='var(--accent)'; this.style.boxShadow='0 0 0 3px var(--accent-muted)'" onblur="this.style.borderColor='var(--border-default)'; this.style.boxShadow='none'">
        </div>
        <div class="component-stack" style="max-width: 400px;">
          <span class="state-label">Error</span>
          <input type="text" value="invalid-agent-url" style="display: block; width: 100%; background: var(--bg-primary); color: var(--text-primary); border: 1px solid var(--error); border-radius: var(--radius-md); padding: 8px 12px; font-family: var(--font-sans); font-size: 14px; outline: none;">
          <span style="font-size: 12px; color: var(--error); margin-top: 4px; display: block;">Invalid agent endpoint URL</span>
        </div>
        <div class="component-stack" style="max-width: 400px;">
          <span class="state-label">Code Input (monospace)</span>
          <input type="text" value='{"persona": "hostile", "threshold": 0.85}' style="display: block; width: 100%; background: var(--bg-primary); color: var(--text-primary); border: 1px solid var(--border-default); border-radius: var(--radius-md); padding: 8px 12px; font-family: var(--font-mono); font-size: 13px; outline: none; transition: border-color 150ms, box-shadow 150ms;" onfocus="this.style.borderColor='var(--accent)'; this.style.boxShadow='0 0 0 3px var(--accent-muted)'" onblur="this.style.borderColor='var(--border-default)'; this.style.boxShadow='none'">
        </div>
      </div>
    </div>

    <!-- CARDS -->
    <div class="component-group">
      <h3 class="component-label">Cards</h3>
      <div class="component-row">
        <div style="background: var(--bg-surface); border: 1px solid var(--border-default); border-radius: var(--radius-lg); padding: 20px; width: 280px;">
          <div style="font-size: 14px; font-weight: 600; margin-bottom: 8px;">Onboarding Flow</div>
          <div style="font-size: 12px; color: var(--text-secondary); margin-bottom: 12px;">12 nodes &middot; 3 personas &middot; Last run: 2h ago</div>
          <div style="display: flex; gap: 8px;">
            <span style="font-family: var(--font-mono); font-size: 12px; padding: 2px 8px; border-radius: var(--radius-sm); background: rgba(34,197,94,0.12); color: var(--success); font-weight: 600;">0.92</span>
            <span style="font-family: var(--font-mono); font-size: 12px; padding: 2px 8px; border-radius: var(--radius-sm); background: rgba(234,179,8,0.12); color: var(--warning); font-weight: 600;">2 warns</span>
          </div>
        </div>
        <!-- Add more card variants as needed -->
      </div>
    </div>

    <!-- DOMAIN-SPECIFIC: Add components unique to your product -->

  </section>

  <!-- ===== 06 MOTION ===== -->
  <section class="guide-section" id="motion">
    <div class="section-number">06</div>
    <h2 class="section-heading">Interaction & Motion</h2>
    <p class="section-desc">
      [Motion philosophy from the Markdown guide.]
    </p>

    <div class="motion-demo">
      <div class="motion-demo-box"></div>
      <span style="font-size: 13px; color: var(--text-tertiary);">Hover to preview the default transition (150ms ease)</span>
    </div>

    <table class="motion-table">
      <thead>
        <tr><th>Element</th><th>Effect</th><th>Duration</th><th>Easing</th></tr>
      </thead>
      <tbody>
        <!-- Paste rows from Markdown guide's motion table -->
        <tr>
          <td>Button hover</td>
          <td>Opacity fade</td>
          <td><code>150ms</code></td>
          <td><code>ease</code></td>
        </tr>
        <tr>
          <td>Input focus</td>
          <td>Border color + ring shadow</td>
          <td><code>150ms</code></td>
          <td><code>ease</code></td>
        </tr>
        <tr>
          <td>Nav item hover</td>
          <td>Background fade</td>
          <td><code>150ms</code></td>
          <td><code>ease</code></td>
        </tr>
        <!-- ... more rows ... -->
      </tbody>
    </table>
  </section>

  <!-- ===== 07 ASSETS ===== -->
  <section class="guide-section" id="assets">
    <div class="section-number">07</div>
    <h2 class="section-heading">Icons & Assets</h2>
    <p class="section-desc">
      [Asset guidelines from the Markdown guide — icon library, stroke weight, usage rules.]
    </p>

    <!-- If using Lucide or another CDN-available icon set, show examples:
    <div class="icon-grid">
      <div class="icon-item">
        <i data-lucide="play"></i>
        <span>play</span>
      </div>
    </div>
    -->
  </section>

  <!-- ===== 08 CHECKLIST ===== -->
  <section class="guide-section" id="checklist">
    <div class="section-number">08</div>
    <h2 class="section-heading">Implementation Checklist</h2>

    <ul class="checklist">
      <!-- Copy items directly from the Markdown guide -->
      <li>Single typeface family with mono variant</li>
      <li>Two font weights maximum (400, 600)</li>
      <li>Accent color used only for CTAs, active states, focus rings</li>
      <li>Background is 80%+ of visual field</li>
      <li>No gradients, no decorative shadows</li>
      <li>All interactive elements have visible focus states</li>
      <li>Color contrast meets WCAG AA</li>
      <li>All animations respect prefers-reduced-motion</li>
      <li>Touch targets >= 44px on mobile</li>
    </ul>
  </section>

  <footer class="guide-footer">
    <p>Derived from: [source spec name(s)] &middot; Generated: [date]</p>
  </footer>

</main>

<script>
  // Theme toggle — use if the guide supports dark + light
  function toggleTheme() {
    const html = document.documentElement;
    html.dataset.theme = html.dataset.theme === 'dark' ? 'light' : 'dark';
  }

  // Optional: Lucide icons (uncomment if using)
  // Loaded via: <script src="https://unpkg.com/lucide@latest/dist/umd/lucide.min.js">
  // lucide.createIcons();
</script>

</body>
</html>
```

---

## 6. Section Reference

Detailed construction guidance for each section. Read alongside Section 3 (the conversion process).

> **Template-based workflow:** Always use `assets/styleguide-template.html` as the starting point for HTML style guides. Section-by-section content guidance is in [`outputs/styleguide-sections/`](styleguide-sections/README.md) — each file documents what to include, why it matters, best practices, available components, and anti-patterns.

### 6.1 Header & Scenario

**Source:** Top-level metadata and "Scenario" section from the Markdown guide.

| Field | Where to Find | Notes |
|-------|--------------|-------|
| Project name | Markdown guide title | e.g., "CodeFresh" |
| Direction name | Markdown guide subtitle | e.g., "Direction A: Minimal Tech" |
| Tagline | Markdown guide's `>` blockquote | One-liner under the title |
| Style System | Markdown guide metadata | e.g., "Minimal Tech 100%" or "MT 80% + Editorial 20%" |
| Fonts | Typography section | Primary + mono at minimum |
| Accent | Color palette section | Name + hex |
| Scenario | Scenario section | 2-3 paragraphs explaining context, signals, rationale |

### 6.2 Color Palette

**Source:** `:root` CSS custom properties block from the Markdown guide.

**Grouping rules:**

1. Group by semantic role, not by lightness/darkness
2. Add sub-headings (`<h3 class="section-subhead">`) between groups
3. Standard groups: Backgrounds, Text, Borders, Accent, Semantic
4. Add a "Domain-Specific" group for product-unique colors

**Contrast ratios:** Calculate the contrast ratio of each text color against `--bg-primary`. Display as a badge on the swatch. Use https://webaim.org/resources/contrastchecker/ or compute programmatically.

| Ratio | WCAG Level | Display |
|-------|-----------|---------|
| >= 7:1 | AAA | `AAA 7.2:1` |
| >= 4.5:1 | AA | `AA 4.8:1` |
| >= 3:1 | AA (large text) | `AA-lg 3.2:1` |
| < 3:1 | Fail | `FAIL 2.1:1` (in red) |

**Muted/alpha colors:** For `rgba()` values, show two swatches — the color standalone and the color overlaid on the primary background. The overlay is more useful because it shows what the color actually looks like in context.

### 6.3 Typography Scale

**Source:** Type scale table from the Markdown guide.

**Sample text rules:**
- Display/H1: Short product-relevant phrase (3-6 words)
- H2/H3: Feature or section name from the product
- Body: 1-2 sentences describing a product concept (shows line-height + wrapping)
- Code/Mono: A realistic code snippet from the product domain
- Caption/Small: Metadata text (timestamps, counts, labels)

**Multi-family handling:** If the Markdown guide specifies multiple font families (sans + serif, sans + mono, etc.), create separate subsections with headings. Never mix families in the same type-row — it obscures which font is being demonstrated.

**Font source table:** Always include. Developers need to know where to get the fonts and what license applies.

### 6.4 Spacing & Layout

**Source:** Spacing scale and grid specification from the Markdown guide.

**Spacing bars:** Use a proportional visualization — the bar width should be a visual multiple of the value. For small values (4px, 8px), multiply by 3-4x so they're visible. For large values (64px, 96px), multiply by 3x.

Suggested multiplier: `width = value * 3` (so 4px → 12px bar, 96px → 288px bar).

**Grid specification:** Render as a table with breakpoint, columns, gutter, margin, max-width columns.

**Layout diagram:** Use a `<pre>` block styled with the mono font. Copy the ASCII layout diagram directly from the Markdown guide. This shows the structural arrangement (sidebar + main, etc.) without needing a visual mockup.

### 6.5 Components

**Source:** Component CSS snippets from the Markdown guide + [Headless UI](https://headlessui.com/) for behavior.

**Three rendering approaches:**

| Approach | When to Use | Pros | Cons |
|----------|-------------|------|------|
| **Headless UI** | Interactive components (menus, dialogs, tabs, listboxes) | Full a11y, keyboard nav, focus management for free; you only write CSS | Requires framework (React/Vue) or manual ARIA for static HTML |
| **Class-based** | Simple components (buttons, cards, badges) | Hover/focus work via CSS, closer to production | No built-in a11y behavior |
| **Inline + JS** | Quick generation, throwaway guide | No CSS modification needed, faster | Verbose HTML, hover requires `onmouseover` |

**Headless UI component mapping:**

| Style Guide Component | Headless UI Component | Why |
|-----------------------|----------------------|-----|
| Dropdown / select | `Listbox` or `Combobox` | Keyboard nav, ARIA listbox role |
| Navigation menu | `Menu` | Focus trapping, arrow key nav |
| Modal / dialog | `Dialog` | Focus trap, Escape to close, scroll lock |
| Accordion / collapsible | `Disclosure` | Expand/collapse with ARIA |
| Tabs | `Tab` | Arrow key switching, ARIA tablist |
| Toggle / switch | `Switch` | ARIA switch role |
| Tooltip / popover | `Popover` | Positioning, focus management |
| Radio group | `RadioGroup` | Arrow key selection, ARIA |

**State coverage requirements:**

| Component | Required States |
|-----------|----------------|
| Buttons | Default, hover, focus, disabled (for each variant: primary, secondary, ghost) |
| Inputs | Default, focus, error, disabled, placeholder |
| Cards | Default, hover (if clickable) |
| Navigation | Default, hover, active |

### 6.6 Interaction & Motion

**Source:** Interaction specification table from the Markdown guide.

Include a live demo element above the table — a simple colored box that responds to hover with the guide's default transition timing. This proves the timing feels right without needing to build actual components.

### 6.7 Icons & Assets

**Source:** Asset guidelines section from the Markdown guide.

For icon libraries available via CDN (Lucide, Phosphor, Heroicons), load a small sample and render 6-10 representative icons in a grid. For libraries that require npm/bundler, describe the library and show a placeholder.

### 6.8 Implementation Checklist

**Source:** Implementation checklist from the Markdown guide.

Copy items verbatim. The HTML rendering adds visual weight (styled checkbox indicators) that makes the checklist feel more authoritative than a Markdown list.

---

## 7. Handling Style Variations

### 7.1 Dark Mode Only

The base template defaults to dark mode. No changes needed — just ensure the `:root` tokens are all dark-mode values.

### 7.2 Light Mode Only

Replace the `:root` tokens with light-mode values:

```css
:root {
  --bg-primary: #FFFFFF;
  --bg-surface: #F5F5F5;
  --bg-elevated: #EBEBEB;
  --text-primary: #171717;
  --text-secondary: #525252;
  --text-tertiary: #A3A3A3;
  --border-default: #E5E5E5;
  --border-subtle: #F0F0F0;
  /* ... */
}
```

### 7.3 Dual Mode with Toggle

Define both palettes using `data-theme` selectors:

```css
[data-theme="dark"] {
  --bg-primary: #09090B;
  --text-primary: #EDEDF0;
  /* ... */
}
[data-theme="light"] {
  --bg-primary: #FFFFFF;
  --text-primary: #171717;
  /* ... */
}
```

Add a toggle button in the nav:

```html
<nav class="guide-nav">
  <a href="#colors">Colors</a>
  <!-- ... -->
  <button onclick="toggleTheme()" style="
    margin-left: auto;
    background: var(--bg-elevated);
    color: var(--text-secondary);
    border: 1px solid var(--border-default);
    border-radius: var(--radius-md);
    padding: 4px 12px;
    font-family: var(--font-mono);
    font-size: 12px;
    cursor: pointer;
  ">Toggle Mode</button>
</nav>
```

**Color section for dual mode:** Show both palettes side by side, or duplicate the swatch grid with light/dark variants.

### 7.4 Mixed Styles (80/20)

For guides that mix two style systems:

1. **Clearly label what carries the 20%** — add a visual marker (border-left accent, or a tag) on elements that use the minority style
2. **Show mixed typography** — if the 20% introduces a new font family (e.g., serif for prose), create a separate subsection in the typography scale
3. **Include a "Mixing Notes" section** after the checklist — render the same table from the Markdown guide showing what carries the 20% and why

```html
<section class="guide-section" id="mixing">
  <div class="section-number">09</div>
  <h2 class="section-heading">Mixing Notes</h2>
  <p class="section-desc">
    This guide mixes [Primary 80%] with [Secondary 20%]. The following elements carry the 20% accent:
  </p>
  <table class="motion-table">
    <thead>
      <tr><th>Element</th><th>What Changed</th><th>Why</th></tr>
    </thead>
    <tbody>
      <!-- From Markdown guide's mixing notes -->
    </tbody>
  </table>
</section>
```

### 7.5 Self-Referential vs Neutral Shell

| Approach | Description | Best For |
|----------|-------------|----------|
| **Neutral shell** | Guide layout stays in a consistent dark theme. Only components/swatches show the actual style. | Comparing multiple directions side-by-side |
| **Self-referential** | Guide layout itself uses the documented style. The guide IS the first implementation. | Single direction, immersive feel |

The base template uses a neutral shell. To make it self-referential, the guide's design tokens already flow through the `:root` variables — the layout CSS references them. So a self-referential guide happens automatically when the tokens match the documented style (which they do if you followed Section 3).

For a truly neutral shell (e.g., dark guide layout documenting a light-mode style), you'd need separate variables for the guide chrome vs the documented style. This is more complex and usually not worth the effort.

### 7.6 Theme Namespacing for Parallel Rendering

When generating multiple style guides that may be loaded simultaneously (side-by-side iframes, a unified comparison page, or a multi-theme demo), **every guide must be namespaced via `data-theme`** to prevent CSS collisions.

**Two rules:**

1. **Set `data-theme="{name}"` on the `<body>` tag**
2. **Scope all design tokens under `[data-theme="{name}"]`**

Variable names stay **unprefixed**. Components reference generic `var(--accent)`, `var(--bg-primary)`, etc. The `data-theme` attribute selector activates the right values.

**Rule 1 — Body attribute:**

```html
<body data-theme="blueprint">   <!-- not just <body> -->
```

**Rule 2 — Token scoping:**

```css
/* WRONG — will collide with other guides */
:root {
  --bg-primary: #09090B;
  --accent: #7C3AED;
}

/* RIGHT — scoped, collision-proof, unprefixed vars */
[data-theme="blueprint"] {
  --bg-primary: #0D1B2A;
  --accent: #4FC3F7;
  --font-sans: 'IBM Plex Sans', sans-serif;
}

[data-theme="cyberpunk"] {
  --bg-primary: #0A0A0A;
  --accent: #FF0080;
  --font-sans: 'Space Grotesk', sans-serif;
}
```

**Components stay generic — tokens do the work:**

```css
/* Component references unprefixed vars — works in any theme */
.card {
  background: var(--bg-surface);
  border: var(--border-default);
  border-radius: var(--radius-md);
}

.btn-primary {
  background: var(--accent);
  color: #fff;
}
```

#### When themes diverge structurally

If themes only differ in color/spacing values, components stay untouched (Pattern 1 below). Only reach for selector scoping when a theme genuinely changes *structure*, not just *values*.

**Pattern 1 — Variables do all the work (ideal, covers 90% of cases):**

```css
[data-theme="minimal-tech"] {
  --card-bg:      #141418;
  --card-border:  1px solid #27272F;
  --card-radius:  6px;
  --card-shadow:  none;
}

[data-theme="editorial"] {
  --card-bg:      #FAFAF8;
  --card-border:  1px solid #E5E5E5;
  --card-radius:  8px;
  --card-shadow:  0 1px 3px rgba(0,0,0,0.1);
}

/* Component stays generic */
.card {
  background:    var(--card-bg);
  border:        var(--card-border);
  border-radius: var(--card-radius);
  box-shadow:    var(--card-shadow);
}
```

**Pattern 2 — Structural overrides (only when layout/effects differ):**

```css
/* Base card — shared structure */
.card { padding: 1rem; border-radius: var(--radius-md); }

/* Theme adds structural differences beyond what tokens cover */
[data-theme="cyberpunk"] .card {
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255,255,255,0.08);
}

[data-theme="brutalist"] .card {
  border: 3px solid black;
  border-radius: 0;
  box-shadow: 4px 4px 0 black;
}
```

**Pattern 3 — Component-level token layers (scales well for large systems):**

```css
/* 1. Primitives (never used directly in components) */
:root {
  --color-gray-100: #f5f5f5;
  --color-gray-900: #1a1a1a;
}

/* 2. Semantic tokens (theme-scoped) */
[data-theme="light"] {
  --surface-card:   var(--color-gray-100);
  --border-subtle:  1px solid #e5e5e5;
}
[data-theme="dark"] {
  --surface-card:   var(--color-gray-900);
  --border-subtle:  1px solid #333;
}

/* 3. Component tokens (optional, for fine control) */
:root {
  --card-bg:      var(--surface-card);
  --card-border:  var(--border-subtle);
}

/* Component only reads its own tokens */
.card {
  background: var(--card-bg);
  border:     var(--card-border);
}

/* Context override without touching the theme */
.sidebar .card { --card-bg: var(--surface-raised); }
```

**Anti-pattern — avoid theme-specific class names:**

```css
/* WRONG — leaks theme logic into HTML */
.card-dark { background: #1e1e1e; }

/* RIGHT — theme drives tokens, component stays generic */
[data-theme="dark"] { --card-bg: #1e1e1e; }
.card { background: var(--card-bg); }
```

**General rule:** push as much as possible into variables (Pattern 1/3), drop to selector scoping (Pattern 2) only when a theme genuinely changes *structure* not just *values*.

#### Parallel comparison page

When using the comparison page (Section 8), each iframe loads a guide with its own `data-theme` value. Because tokens are scoped to `[data-theme]`, there is zero cross-contamination — even when all guides share the same structural class names.

```
┌─ iframe: blueprint.html ──────────────┐  ┌─ iframe: cyberpunk.html ───────────────┐
│ <body data-theme="blueprint">         │  │ <body data-theme="cyberpunk">          │
│   [data-theme="blueprint"] { ... }    │  │   [data-theme="cyberpunk"] { ... }     │
│   --accent: #4FC3F7                   │  │   --accent: #FF0080                    │
│   .card { background: var(--bg-...) } │  │   .card { background: var(--bg-...) }  │
└───────────────────────────────────────┘  └────────────────────────────────────────┘
```

---

## 8. Multi-Direction Comparison

When generating HTML guides for multiple design directions:

**Same structure.** Every direction covers the same 8 sections in the same order. This makes tab-switching comparisons meaningful.

**Same sample content.** Use identical text samples ("Behavioral Testing", "Evaluation Scripts", "Run Evaluation"), component labels, and checklist language. Differences should come from the style, not the content.

**Naming convention:**
```
direction-a-minimal-tech.html
direction-b-minimal-editorial.html
direction-c-neo-brutalist.html
```

**Comparison page (optional but powerful):**

A single HTML file that loads all directions in iframes for side-by-side comparison:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Style Guide Comparison — [Project Name]</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { background: #000; font-family: system-ui; }
    .tabs {
      display: flex;
      background: #111;
      border-bottom: 1px solid #333;
    }
    .tab {
      padding: 12px 24px;
      color: #888;
      font-size: 13px;
      cursor: pointer;
      border: none;
      background: none;
    }
    .tab.active { color: #fff; border-bottom: 2px solid #7C3AED; }
    .frames { position: relative; height: calc(100vh - 45px); }
    .frames iframe {
      position: absolute;
      inset: 0;
      width: 100%;
      height: 100%;
      border: none;
      display: none;
    }
    .frames iframe.active { display: block; }
  </style>
</head>
<body>
  <nav class="tabs">
    <button class="tab active" onclick="show(0)">A: Minimal Tech</button>
    <button class="tab" onclick="show(1)">B: Minimal + Editorial</button>
    <button class="tab" onclick="show(2)">C: Neo-Brutalist</button>
  </nav>
  <div class="frames">
    <iframe src="direction-a-minimal-tech.html" class="active"></iframe>
    <iframe src="direction-b-minimal-editorial.html"></iframe>
    <iframe src="direction-c-neo-brutalist.html"></iframe>
  </div>
  <script>
    function show(i) {
      document.querySelectorAll('.tab').forEach((t, j) => t.classList.toggle('active', j === i));
      document.querySelectorAll('.frames iframe').forEach((f, j) => f.classList.toggle('active', j === i));
    }
  </script>
</body>
</html>
```

---

## 9. Accessibility of the Guide Itself

The style guide page should meet WCAG AA, even if it's documenting a style system that pushes accessibility boundaries (e.g., Bold Expressive):

- [ ] All text in the guide chrome meets 4.5:1 contrast against its background
- [ ] All interactive elements (inputs, buttons, nav links) have visible focus indicators
- [ ] Semantic HTML: `<nav>`, `<main>`, `<section>`, `<header>`, `<footer>`
- [ ] `aria-label` on the nav element
- [ ] Keyboard-navigable: Tab through all interactive elements
- [ ] `prefers-reduced-motion` respected: `scroll-behavior: auto` when reduced motion is preferred
- [ ] Print styles: clean output when Ctrl+P (Section 10)
- [ ] Page title is descriptive: "Style Guide: [Project] — [Direction]"

---

## 10. Print Styles

The base template includes a `@media print` block that:

- Hides the sticky navigation
- Forces white background with black text
- Preserves swatch and component background colors via `print-color-adjust: exact`
- Prevents page breaks inside sections
- Appends URLs after links

**Test by:** Ctrl+P (or Cmd+P) in browser. The output should be a clean, readable document suitable for sharing as a PDF.

For guides that need to be distributed as PDF, print from Chrome for the best fidelity. Firefox and Safari handle `print-color-adjust` differently.

---

## References

- `../process/style-guide-construction.md` — Markdown style guide construction (upstream process)
- `html-css.md` — HTML/CSS implementation patterns (borrow component CSS)
- `../styles/` — Source style specifications (palette, type, component rules)
- `../styles/examples/` — 10 worked Markdown examples that can be converted
- `../patterns/components.md` — Component patterns and state definitions
- `../patterns/accessibility.md` — Accessibility patterns for components

---

*Version: 0.1.0*
*Last updated: 2026-03-13*
