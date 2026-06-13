# Style Guide: Ipso The Lorem — LoremOps

> Barely-there interface for a developer-facing AI project management tool.

**Style System:** Minimal Tech 100%
**Source Spec:** [minimal-tech.md](../minimal-tech.md)
**Scenario:** Internal SaaS product for developer teams

---

## Scenario

Ipso The Lorem is launching **LoremOps**, an AI-powered project management SaaS that helps engineering teams decompose epics into tasks, estimate effort, and track velocity. The primary audience is senior developers and engineering managers at mid-market tech companies.

The interface needs to signal **technical credibility** and **intelligence** — this is a tool built by developers for developers. It must handle dense data (burndown charts, sprint boards, task lists) without feeling cluttered. The visual language should say: "We respect your time and your screen real estate."

Minimal Tech is the natural fit: single accent, generous whitespace, monochrome foundation, data visualization as the primary decorative element.

---

## Color Palette

```css
:root {
  /* Backgrounds */
  --bg-primary: #0B0B0F;
  --bg-surface: #16161D;
  --bg-elevated: #1E1E28;

  /* Text */
  --text-primary: #EDEDF0;
  --text-secondary: #9494A0;
  --text-tertiary: #5C5C6B;

  /* Borders */
  --border-default: #2A2A36;
  --border-subtle: #1E1E28;

  /* Accent — Indigo (signals intelligence, focus) */
  --accent: #6366F1;
  --accent-hover: #818CF8;
  --accent-muted: rgba(99, 102, 241, 0.12);

  /* Semantic */
  --success: #4ADE80;
  --warning: #FACC15;
  --error: #F87171;
  --info: #60A5FA;
}
```

```
┌─────────────────────────────────────────┐
│  LOREMOPS PALETTE                       │
├─────────────────────────────────────────┤
│                                         │
│  ██████  #0B0B0F  Background            │
│  ██████  #16161D  Surface               │
│  ██████  #1E1E28  Elevated              │
│                                         │
│  ██████  #EDEDF0  Text Primary          │
│  ██████  #9494A0  Text Secondary        │
│  ██████  #5C5C6B  Text Tertiary         │
│                                         │
│  ██████  #6366F1  Accent (Indigo)       │
│                                         │
└─────────────────────────────────────────┘
```

**Usage rules:**
- Dark mode is the default and only mode (developer audience preference)
- Accent (indigo) appears ONLY on: primary CTA buttons, active nav items, focus rings, chart highlight lines
- Semantic colors appear ONLY in their semantic context (never decorative)
- Background should occupy 80%+ of the visual field
- No gradients anywhere in the interface

---

## Typography

**Font stack:**
```css
--font-sans: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
--font-mono: 'JetBrains Mono', 'Fira Code', 'Consolas', monospace;
```

| Level | Size | Weight | Line Height | Use |
|-------|------|--------|-------------|-----|
| Display | 36px | 600 | 1.15 | Page titles (rare) |
| H1 | 28px | 600 | 1.2 | Section headers |
| H2 | 22px | 600 | 1.25 | Card headers, panel titles |
| H3 | 18px | 600 | 1.3 | Group labels |
| Body | 14px | 400 | 1.6 | Default text (developer-dense) |
| Body Small | 12px | 400 | 1.5 | Metadata, timestamps |
| Code | 13px | 400 | 1.5 | Inline code, task IDs |
| Caption | 11px | 500 | 1.4 | Chart labels, table headers |

**Typography notes:**
- Base body is 14px (not 16px) — developer tools run denser than consumer apps
- Mono font used for: task IDs, code snippets, metric values, keyboard shortcuts
- Maximum 2 weights: 400 (regular) and 600 (semibold) — never bold

**Font sources:**

| Font | Source | License | Link |
|------|--------|---------|------|
| Inter | Adobe Fonts | Free / OFL | [Adobe Fonts](https://fonts.adobe.com/fonts/inter) \| [Google Fonts](https://fonts.google.com/specimen/Inter) \| [GitHub](https://github.com/rsms/inter) |
| JetBrains Mono | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/JetBrains+Mono) \| [GitHub](https://github.com/JetBrains/JetBrainsMono) |
| Fira Code (fallback) | Google Fonts | Free / OFL | [Google Fonts](https://fonts.google.com/specimen/Fira+Code) \| [GitHub](https://github.com/tonsky/FiraCode) |

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

**Layout pattern:** Collapsible sidebar (240px) + main content area. Sidebar houses project navigation; main area is the workspace.

---

## Component Styling

### Buttons

```css
/* Primary */
.btn-primary {
  background: var(--accent);
  color: #FFFFFF;
  padding: 8px 16px;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 600;
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
.input--error { border-color: var(--error); }
.input:disabled { opacity: 0.4; cursor: not-allowed; }
```

### Cards

```css
.card {
  background: var(--bg-surface);
  border: 1px solid var(--border-default);
  border-radius: 8px;
  padding: 20px;
}
/* No hover effect on cards — they're containers, not interactive targets */
/* Task cards in board view are the exception: */
.task-card {
  background: var(--bg-surface);
  border: 1px solid var(--border-subtle);
  border-radius: 6px;
  padding: 12px 16px;
  cursor: grab;
  transition: border-color 150ms ease;
}
.task-card:hover { border-color: var(--border-default); }
```

### Navigation

```css
.sidebar {
  width: 240px;
  background: var(--bg-primary);
  border-right: 1px solid var(--border-default);
  padding: 16px 0;
}
.nav-item {
  padding: 8px 16px;
  color: var(--text-secondary);
  font-size: 13px;
  font-weight: 400;
  border-radius: 0;
  transition: color 150ms ease, background 150ms ease;
}
.nav-item:hover { color: var(--text-primary); background: var(--bg-surface); }
.nav-item--active {
  color: var(--accent);
  background: var(--accent-muted);
  font-weight: 600;
}
```

---

## Interaction & Motion

| Element | Effect | Duration | Easing |
|---------|--------|----------|--------|
| Button hover | Opacity fade | 150ms | ease |
| Input focus | Border color + shadow | 150ms | ease |
| Nav item hover | Background fade | 150ms | ease |
| Sidebar collapse | Width slide | 200ms | ease-out |
| Task card drag | Opacity 0.8, slight scale | 150ms | ease |
| Panel slide-in | Transform translateX | 200ms | ease-out |
| Toast notification | Slide up + fade in | 200ms | ease-out |
| Chart data point | Tooltip fade | 100ms | ease |

**Motion philosophy:** Functional only. Every animation provides feedback or orientation — none are decorative. All respect `prefers-reduced-motion` by collapsing to instant state changes.

---

## Asset Guidelines

**Photography:** None. This is a data interface — no stock photos, hero images, or lifestyle shots.

**Iconography:** Lucide icons (20px default, 1.5px stroke weight). Monochrome — uses `currentColor` to inherit text color. Never filled, always outlined.

**Data visualization:** Charts are the primary visual content. Use accent (indigo) for primary data series, text-tertiary for secondary. No 3D effects, no decorative chart elements. Axes and gridlines use border-subtle.

**Illustration:** None unless for empty states (e.g., "no tasks yet"). Keep minimal — line-drawing style, monochrome + accent.

---

## Implementation Checklist

- [ ] Single typeface family (Inter) with mono fallback (JetBrains Mono)
- [ ] Two font weights maximum (400, 600)
- [ ] Accent color (indigo) used only for CTAs, active states, focus rings, chart highlights
- [ ] Background is 80%+ of visual field
- [ ] No gradients, no decorative shadows
- [ ] All interactive elements have visible focus states
- [ ] Color contrast meets WCAG AA: text-primary on bg-primary = 15.2:1
- [ ] All animations respect `prefers-reduced-motion`
- [ ] Touch targets >= 44px on mobile
- [ ] Sidebar is collapsible for narrow viewports
- [ ] Data visualizations readable without color (use shape/pattern as secondary channel)

---

*Derived from: [minimal-tech.md](../minimal-tech.md)*
*Example #1 of 10 — See [README.md](README.md) for full series*
