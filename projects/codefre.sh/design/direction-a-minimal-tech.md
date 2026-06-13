# Style Guide: CodeFresh — Direction A: Minimal Tech

> The barely-there testing interface. Eval results *are* the design.

**Style System:** Minimal Tech 100%
**Source Spec:** minimal-tech.md
**Scenario:** AI agent behavioral testing platform for developers and ML engineers

---

## Scenario

CodeFresh is a **behavioral testing framework for AI agents** — closer to Playwright or Cypress than to Datadog. Its primary users are AI/ML engineers who build agents with LangChain, CrewAI, AutoGen, and custom frameworks. They need regression testing for agent behavior across releases.

The interface needs to signal **precision, intelligence, and reliability** — "this tool is as rigorous as your code." The hero surface is a **conversation graph editor** where nodes represent script turns and edges represent expected branches. The results view color-codes nodes by eval outcome: green (pass), amber (warn), red (fail). These semantic colors *are* the visual interest — the rest of the UI steps back.

Minimal Tech is the natural industry fit: the product lives alongside Linear, Vercel, and Stripe in the developer's tool belt. One accent color, dark mode default, data visualization as the primary decorative element, generous whitespace.

**Reference energy:** linear.app (density + animation), raycast.com (keyboard-first), resend.com (single accent restraint)

---

## Color Palette

```css
:root {
  /* Backgrounds */
  --bg-primary: #09090B;
  --bg-surface: #141418;
  --bg-elevated: #1C1C22;
  --bg-code: #111115;

  /* Text */
  --text-primary: #EDEDF0;
  --text-secondary: #8E8E9A;
  --text-tertiary: #56566A;

  /* Borders */
  --border-default: #27272F;
  --border-subtle: #1C1C22;

  /* Accent — Violet (signals AI/intelligence) */
  --accent: #7C3AED;
  --accent-hover: #8B5CF6;
  --accent-muted: rgba(124, 58, 237, 0.12);

  /* Eval Results — THE color system */
  --eval-pass: #22C55E;
  --eval-pass-muted: rgba(34, 197, 94, 0.12);
  --eval-warn: #EAB308;
  --eval-warn-muted: rgba(234, 179, 8, 0.12);
  --eval-fail: #EF4444;
  --eval-fail-muted: rgba(239, 68, 68, 0.12);

  /* Freeball — special state for off-script deviations */
  --eval-freeball: #F97316;
  --eval-freeball-muted: rgba(249, 115, 22, 0.12);

  /* Semantic */
  --info: #60A5FA;
}
```

```
+------------------------------------------+
|  CODEFRESH PALETTE — Direction A          |
+------------------------------------------+
|                                           |
|  ██████  #09090B  Background              |
|  ██████  #141418  Surface                 |
|  ██████  #1C1C22  Elevated                |
|                                           |
|  ██████  #EDEDF0  Text Primary            |
|  ██████  #8E8E9A  Text Secondary          |
|  ██████  #56566A  Text Tertiary           |
|                                           |
|  ██████  #7C3AED  Accent (Violet)         |
|                                           |
|  ██████  #22C55E  Pass                    |
|  ██████  #EAB308  Warn                    |
|  ██████  #EF4444  Fail                    |
|  ██████  #F97316  Freeball                |
|                                           |
+------------------------------------------+
```

**Usage rules:**
- Dark mode is the default and only mode
- Accent (violet) appears ONLY on: primary CTA buttons, active sidebar items, focus rings, and the "Run Evaluation" action
- Eval colors (pass/warn/fail/freeball) are the primary visual interest — they appear on graph nodes, score badges, and result summaries
- Eval-muted variants are used for node backgrounds and row highlights in results tables
- Background should occupy 80%+ of visual field
- No gradients anywhere in the interface

---

## Typography

**Font stack:**
```css
--font-sans: 'Geist', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
--font-mono: 'Geist Mono', 'JetBrains Mono', 'Fira Code', Consolas, monospace;
```

| Level | Size | Weight | Line Height | Use |
|-------|------|--------|-------------|-----|
| Display | 36px | 600 | 1.15 | Dashboard hero metrics only |
| H1 | 28px | 600 | 1.2 | Page titles ("Scripts", "Runs", "Agents") |
| H2 | 22px | 600 | 1.25 | Panel titles, script names |
| H3 | 18px | 600 | 1.3 | Node labels in graph, card headers |
| Body | 14px | 400 | 1.6 | Default text (developer-dense) |
| Body Small | 12px | 400 | 1.5 | Metadata, timestamps, node annotations |
| Code | 13px | 400 | 1.5 | Prompts, agent responses, expectation text, YAML |
| Caption | 11px | 500 | 1.4 | Graph edge labels, score decimals |

**Typography notes:**
- Base body is 14px — developer tool density, not consumer spacing
- Mono font is prominent: conversation prompts, agent responses, expectation definitions, and YAML scripts all render in mono
- Two weights only: 400 and 600, never bold (700)
- Node labels in the graph editor use H3 at 18px for readability at zoom levels

**Font sources:**

| Font | Source | License | Link |
|------|--------|---------|------|
| Geist | Vercel | Free / OFL | [GitHub](https://github.com/vercel/geist-font) |
| Geist Mono | Vercel | Free / OFL | [GitHub](https://github.com/vercel/geist-font) |
| Inter (fallback) | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/Inter) |
| JetBrains Mono (fallback) | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/JetBrains+Mono) |

---

## Spacing & Layout

**Spacing scale:** 4, 8, 12, 16, 24, 32, 48, 64, 96px

**Grid:**

| Breakpoint | Columns | Gutter | Margin | Max Width |
|------------|---------|--------|--------|-----------|
| Mobile (<768px) | 4 | 12px | 16px | 100% |
| Tablet (768-1024px) | 8 | 16px | 24px | 100% |
| Desktop (1024-1440px) | 12 | 24px | 32px | 100% |
| Wide (>1440px) | 12 | 24px | 64px | 1440px |

**Layout pattern:** Collapsible sidebar (260px) + main workspace.

```
+------------------------------------------------------------------+
|  LOGO     Scripts   Runs   Agents   Personas       [Run ▶]       |
+----------+-------------------------------------------------------+
|          |                                                        |
| SIDEBAR  |  MAIN WORKSPACE                                       |
| 260px    |                                                        |
|          |  ┌──────────────────────────────────────────────────┐  |
| Scripts  |  │                                                  │  |
|  ├ flow1 |  │   GRAPH EDITOR / RESULTS VIEWER                 │  |
|  ├ flow2 |  │                                                  │  |
|  └ flow3 |  │   (nodes + edges fill this space)                │  |
|          |  │                                                  │  |
| Agents   |  │                                                  │  |
|  ├ gpt-4 |  └──────────────────────────────────────────────────┘  |
|  └ claude|                                                        |
|          |  ┌─ NODE DETAIL PANEL (slide-in from right) ────────┐  |
| Personas |  │  Prompt, Expectations, Branches, Scores          │  |
|  ├ hostile|  └─────────────────────────────────────────────────┘  |
|  └ novice|                                                        |
+----------+-------------------------------------------------------+
```

---

## Component Styling

### Buttons

```css
/* Primary — Run Evaluation action */
.btn-primary {
  background: var(--accent);
  color: #FFFFFF;
  padding: 8px 16px;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 600;
  font-family: var(--font-sans);
  border: none;
  transition: opacity 150ms ease;
}
.btn-primary:hover { opacity: 0.9; }
.btn-primary:focus-visible { outline: 2px solid var(--accent); outline-offset: 2px; }
.btn-primary:disabled { opacity: 0.4; cursor: not-allowed; }

/* Secondary */
.btn-secondary {
  background: transparent;
  color: var(--text-primary);
  padding: 8px 16px;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 600;
  border: 1px solid var(--border-default);
  transition: background 150ms ease;
}
.btn-secondary:hover { background: var(--bg-elevated); }

/* Ghost */
.btn-ghost {
  background: transparent;
  color: var(--text-secondary);
  padding: 8px 12px;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 400;
  border: none;
  transition: color 150ms ease;
}
.btn-ghost:hover { color: var(--text-primary); }
```

### Graph Nodes

```css
/* Base node in the conversation graph */
.graph-node {
  background: var(--bg-surface);
  border: 1px solid var(--border-default);
  border-radius: 8px;
  padding: 12px 16px;
  min-width: 200px;
  max-width: 320px;
  font-size: 13px;
  transition: border-color 150ms ease;
}
.graph-node:hover { border-color: var(--text-tertiary); }
.graph-node--selected { border-color: var(--accent); box-shadow: 0 0 0 3px var(--accent-muted); }

/* Eval state overlays */
.graph-node--pass { border-color: var(--eval-pass); background: var(--eval-pass-muted); }
.graph-node--warn { border-color: var(--eval-warn); background: var(--eval-warn-muted); }
.graph-node--fail { border-color: var(--eval-fail); background: var(--eval-fail-muted); }
.graph-node--freeball {
  border-color: var(--eval-freeball);
  background: var(--eval-freeball-muted);
  border-style: dashed;
}
```

### Score Badges

```css
.score-badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 600;
  font-family: var(--font-mono);
}
.score-badge--pass { background: var(--eval-pass-muted); color: var(--eval-pass); }
.score-badge--warn { background: var(--eval-warn-muted); color: var(--eval-warn); }
.score-badge--fail { background: var(--eval-fail-muted); color: var(--eval-fail); }
```

### Form Inputs

```css
.input {
  background: var(--bg-surface);
  color: var(--text-primary);
  padding: 8px 12px;
  border: 1px solid var(--border-default);
  border-radius: 6px;
  font-size: 14px;
  font-family: var(--font-sans);
  transition: border-color 150ms ease;
}
.input:focus {
  border-color: var(--accent);
  box-shadow: 0 0 0 3px var(--accent-muted);
  outline: none;
}
.input--error { border-color: var(--eval-fail); }

/* YAML/JSON script input uses mono */
.input--code {
  font-family: var(--font-mono);
  font-size: 13px;
}
```

### Navigation

```css
.sidebar {
  width: 260px;
  background: var(--bg-primary);
  border-right: 1px solid var(--border-default);
  padding: 16px 0;
}
.nav-item {
  padding: 8px 16px;
  color: var(--text-secondary);
  font-size: 13px;
  font-weight: 400;
  transition: color 150ms ease, background 150ms ease;
}
.nav-item:hover { color: var(--text-primary); background: var(--bg-surface); }
.nav-item--active {
  color: var(--accent);
  background: var(--accent-muted);
  font-weight: 600;
}
.nav-group-label {
  padding: 8px 16px;
  font-size: 11px;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--text-tertiary);
}
```

---

## Interaction & Motion

| Element | Effect | Duration | Easing |
|---------|--------|----------|--------|
| Button hover | Opacity fade | 150ms | ease |
| Input focus | Border + shadow | 150ms | ease |
| Nav item hover | Background fade | 150ms | ease |
| Sidebar collapse | Width slide | 200ms | ease-out |
| Node detail panel | SlideX from right | 200ms | ease-out |
| Graph node hover | Border color | 150ms | ease |
| Graph zoom/pan | Transform | Continuous | ease-out |
| Eval result load | Nodes color sequentially | 50ms stagger | ease |
| Toast notification | Slide up + fade | 200ms | ease-out |
| Score counter | Number tick-up | 300ms | ease-out |

**Motion philosophy:** Functional only. The one signature moment: when eval results load, graph nodes transition from neutral to their pass/warn/fail colors in a staggered sequence (50ms per node, following the conversation path). This makes results feel like they're "flowing through" the graph.

All animations respect `prefers-reduced-motion` by collapsing to instant state changes.

---

## Asset Guidelines

**Photography:** None. This is a data interface.

**Iconography:** Lucide icons (18px default, 1.5px stroke weight). Monochrome — uses `currentColor`. Always outlined, never filled.

**Data visualization:** The conversation graph IS the primary visualization. Additional charts (score trends over time, persona comparison bar charts) use accent for primary data, text-tertiary for secondary. No 3D effects. Minimal axis labels. Interactive tooltips on hover.

**Empty states:** Simple line-drawing illustrations in monochrome + accent. "No scripts yet — create your first evaluation" with a single CTA button.

**Logo direction:** Wordmark only. "codefre.sh" in Geist at 600 weight. The period before "sh" can be styled in accent color as a subtle brand element.

---

## Implementation Checklist

- [ ] Single typeface family (Geist) with mono variant (Geist Mono)
- [ ] Two font weights maximum (400, 600)
- [ ] Accent (violet) used only for CTAs, active states, focus rings
- [ ] Eval colors (pass/warn/fail/freeball) are the primary visual system
- [ ] Background is 80%+ of visual field
- [ ] No gradients, no decorative shadows
- [ ] All interactive elements have visible focus states
- [ ] Color contrast meets WCAG AA (text-primary on bg-primary)
- [ ] All animations respect `prefers-reduced-motion`
- [ ] Touch targets >= 44px on mobile
- [ ] Graph nodes are keyboard-navigable
- [ ] Data visualizations readable without color (use shape for secondary channel)
- [ ] Dark mode only

---

*Derived from: minimal-tech.md*
