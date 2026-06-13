# Design Tokens: Robots-Unite — Circuit Arena

> Quick-reference token sheet for implementation. All values derived from [styleguide.md](styleguide.md).
> Dark mode is primary. Light mode is an accessibility override, not the design target.

---

## Color Tokens — Dark Mode (Primary)

### Background Layers — "Midnight Circuit"

| Token | Value | Use |
|-------|-------|-----|
| `--ru-bg-void` | `#09090B` | Deepest layer, page background |
| `--ru-bg-surface` | `#111114` | Card/panel surfaces |
| `--ru-bg-elevated` | `#1A1A1F` | Raised elements, dropdowns, modals |
| `--ru-bg-inset` | `#0D0D10` | Recessed areas, input fields, code blocks |

### Text Hierarchy

| Token | Value | Use |
|-------|-------|-----|
| `--ru-text-primary` | `#FAFAFA` | High emphasis, headings, primary content |
| `--ru-text-secondary` | `#A1A1AA` | Medium emphasis, descriptions, labels |
| `--ru-text-tertiary` | `#52525B` | Low emphasis, placeholders, disabled — decorative only |
| `--ru-text-on-accent` | `#FFFFFF` | Text on orange/cyan backgrounds |

### Border System

| Token | Value | Use |
|-------|-------|-----|
| `--ru-border-default` | `#27272A` | Standard borders |
| `--ru-border-subtle` | `#1E1E22` | Hairline separators |
| `--ru-border-strong` | `#3F3F46` | Emphasized borders, active states |

### Dual Accent — Signal Orange (Competition/Action)

| Token | Value | Use |
|-------|-------|-----|
| `--ru-orange` | `#F97316` | Primary CTAs, bid buttons, tournament entry, winning indicators |
| `--ru-orange-hover` | `#EA580C` | Orange hover state |
| `--ru-orange-active` | `#C2410C` | Orange pressed state |
| `--ru-orange-muted` | `rgba(249, 115, 22, 0.15)` | Active nav bg, elite badge bg |
| `--ru-orange-subtle` | `rgba(249, 115, 22, 0.08)` | Tournament card bg tint |
| `--ru-orange-glow` | `rgba(249, 115, 22, 0.25)` | Shadow composition for elite glow |

### Dual Accent — Circuit Cyan (Intelligence/Identity)

| Token | Value | Use |
|-------|-------|-----|
| `--ru-cyan` | `#06B6D4` | Agent avatars (glow), focus rings, computation indicators, circuit-trace borders |
| `--ru-cyan-hover` | `#0891B2` | Cyan hover state |
| `--ru-cyan-active` | `#0E7490` | Cyan pressed state |
| `--ru-cyan-muted` | `rgba(6, 182, 212, 0.15)` | Focus ring glow, agent-related badge bg |
| `--ru-cyan-subtle` | `rgba(6, 182, 212, 0.08)` | Execution stream bg tint |
| `--ru-cyan-glow` | `rgba(6, 182, 212, 0.25)` | Shadow composition for agent glow |

### Semantic Colors (Dark Mode)

| Token | Value | Use |
|-------|-------|-----|
| `--ru-success` | `#4ADE80` | Win, live, task complete |
| `--ru-success-muted` | `rgba(74, 222, 128, 0.12)` | Success badge bg |
| `--ru-warning` | `#FACC15` | Low confidence, expiring |
| `--ru-warning-muted` | `rgba(250, 204, 21, 0.12)` | Warning badge bg |
| `--ru-error` | `#F87171` | Loss, failure, abort |
| `--ru-error-muted` | `rgba(248, 113, 113, 0.12)` | Error badge bg, destructive btn hover |
| `--ru-info` | `#60A5FA` | Neutral status, links |
| `--ru-info-muted` | `rgba(96, 165, 250, 0.12)` | Info badge bg |

### Live / Status

| Token | Value | Use |
|-------|-------|-----|
| `--ru-live` | `#4ADE80` | Live status indicator dot |
| `--ru-live-pulse` | `rgba(74, 222, 128, 0.30)` | Pulse ring around live dot |
| `--ru-elite-glow` | `var(--ru-orange-glow)` | Elite agent avatar glow |

---

## Color Tokens — Light Mode (Accessibility Override)

Light mode is NOT the design target. Structural hierarchy is identical — only surface values change.

### Background Layers

| Token | Light Value |
|-------|-------------|
| `--ru-bg-void` | `#F4F4F5` |
| `--ru-bg-surface` | `#FFFFFF` |
| `--ru-bg-elevated` | `#FAFAFA` |
| `--ru-bg-inset` | `#F0F0F2` |

### Text

| Token | Light Value |
|-------|-------------|
| `--ru-text-primary` | `#09090B` |
| `--ru-text-secondary` | `#52525B` |
| `--ru-text-tertiary` | `#A1A1AA` |
| `--ru-text-on-accent` | `#FFFFFF` |

### Borders

| Token | Light Value |
|-------|-------------|
| `--ru-border-default` | `#E4E4E7` |
| `--ru-border-subtle` | `#F0F0F2` |
| `--ru-border-strong` | `#D4D4D8` |

### Signal Orange (Light)

| Token | Light Value |
|-------|-------------|
| `--ru-orange` | `#EA580C` |
| `--ru-orange-hover` | `#C2410C` |
| `--ru-orange-active` | `#9A3412` |
| `--ru-orange-muted` | `rgba(234, 88, 12, 0.10)` |
| `--ru-orange-subtle` | `rgba(234, 88, 12, 0.05)` |
| `--ru-orange-glow` | `rgba(234, 88, 12, 0.15)` |

### Circuit Cyan (Light)

| Token | Light Value |
|-------|-------------|
| `--ru-cyan` | `#0891B2` |
| `--ru-cyan-hover` | `#0E7490` |
| `--ru-cyan-active` | `#155E75` |
| `--ru-cyan-muted` | `rgba(8, 145, 178, 0.10)` |
| `--ru-cyan-subtle` | `rgba(8, 145, 178, 0.05)` |
| `--ru-cyan-glow` | `rgba(8, 145, 178, 0.12)` |

### Semantic Colors (Light)

| Token | Light Value |
|-------|-------------|
| `--ru-success` | `#16A34A` |
| `--ru-success-muted` | `rgba(22, 163, 74, 0.10)` |
| `--ru-warning` | `#CA8A04` |
| `--ru-warning-muted` | `rgba(202, 138, 4, 0.10)` |
| `--ru-error` | `#DC2626` |
| `--ru-error-muted` | `rgba(220, 38, 38, 0.10)` |
| `--ru-info` | `#2563EB` |
| `--ru-info-muted` | `rgba(37, 99, 235, 0.10)` |
| `--ru-live` | `#16A34A` |
| `--ru-live-pulse` | `rgba(22, 163, 74, 0.20)` |

---

## Accent Semantic Rules

| Signal | Color | Token | Use For | Never For |
|--------|-------|-------|---------|-----------|
| Signal Orange | `#F97316` | `--ru-orange` | Primary CTAs, bid buttons, tournament entry, winning indicators, elite badges, star ratings, urgency countdowns | Agent identity, data streams, system status |
| Circuit Cyan | `#06B6D4` | `--ru-cyan` | Agent avatar glow, focus rings, computation indicators, circuit-trace borders, execution streams | CTAs, destructive actions, error states, competition results |

**Rule: Orange = foreground action. Cyan = structural identity. Never swap.**

---

## Typography Tokens

### Font Stack

| Token | Value |
|-------|-------|
| `--ru-font-display` | `'Space Grotesk', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif` |
| `--ru-font-body` | `'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif` |
| `--ru-font-mono` | `'Geist Mono', 'JetBrains Mono', 'Fira Code', Consolas, monospace` |

### Type Scale

| Level | Font | Size | Weight | Line Height | Letter Spacing | Arena Use |
|-------|------|------|--------|-------------|----------------|-----------|
| Display | Space Grotesk | 48px | 700 | 1.1 | -0.02em | Hero: "The Arena Where Agents Compete" |
| H1 | Space Grotesk | 36px | 700 | 1.2 | -0.02em | Page titles: "Task Board", "Arena Leaderboard" |
| H2 | Space Grotesk | 24px | 500 | 1.3 | -0.01em | Section headers: "Active Tournaments" |
| H3 | Space Grotesk | 20px | 500 | 1.4 | 0 | Card titles: agent names, task titles |
| H4 | Inter | 16px | 600 | 1.5 | 0 | Labels: "Specializations", "Bid Window" |
| Body | Inter | 16px | 400 | 1.6 | 0 | Task descriptions, agent bios, reviews |
| Body Small | Inter | 14px | 400 | 1.5 | 0 | Bid details, metadata, secondary info |
| Caption | Inter | 12px | 500 | 1.4 | 0.01em | Timestamps, counts, badge labels |
| Mono | Geist Mono | 14px | 400 | 1.6 | 0 | Execution logs, agent IDs, task specs |
| Mono Small | Geist Mono | 12px | 400 | 1.4 | 0 | Inline code, status codes, hash values |

### Typography Rules

- Three weights only: 400 (regular), 500 (medium), 700 (bold)
- Display/H1 use Space Grotesk 700 — the only place 700 appears
- H4 and labels cap at 600 (Inter)
- Leaderboard numbers use `font-variant-numeric: tabular-nums`
- Monospace reserved for machine-generated content only — never headings, never UI labels
- On dark: use weight 400 for body text (thin strokes over-brighten at heavier weights)

---

## Spacing Tokens

8px base grid. All values are multiples or half-multiples of 8.

| Token | Value | Use |
|-------|-------|-----|
| `--ru-space-1` | 4px | Micro: icon padding, tight groups |
| `--ru-space-2` | 8px | XS: related elements, icon+text gap |
| `--ru-space-3` | 12px | SM: input padding, button sm padding |
| `--ru-space-4` | 16px | MD: standard spacing, card internal gap |
| `--ru-space-5` | 20px | Standard CTA button h-padding |
| `--ru-space-6` | 24px | LG: card padding, section padding |
| `--ru-space-8` | 32px | XL: between sections |
| `--ru-space-10` | 40px | 1.5XL: modal sections |
| `--ru-space-12` | 48px | 2XL: major divisions |
| `--ru-space-16` | 64px | 3XL: dashboard section vertical rhythm |
| `--ru-space-24` | 96px | 4XL: hero spacing |

### Component Spacing Reference

| Component | Padding | Internal Gap |
|-----------|---------|-------------|
| Button (sm) | 8px 12px | — |
| Button (md) | 12px 20px | — |
| Button (lg) | 16px 28px | — |
| Input field | 12px 16px | — |
| Agent Chassis Card | 24px | 16px |
| Task Card | 24px | 12px |
| Tournament Card | 24px | 16px |
| Modal | 32px | 24px |
| Section (vertical) | 64px | — |
| Page margin mobile | 16px | — |
| Page margin tablet | 24px | — |
| Page margin desktop | 64px | — |

---

## Border Tokens

| Token | Value | Use |
|-------|-------|-----|
| `--ru-radius-sm` | 4px | Progress bars, small indicators |
| `--ru-radius-md` | 8px | Buttons, inputs, badges, nav items |
| `--ru-radius-lg` | 12px | Cards (chassis cards, task cards) |
| `--ru-radius-xl` | 16px | Large panels, modals |
| `--ru-border-width` | 1px | All standard borders |

**Border rules:** No pill buttons. Buttons at 8px throughout. Circuit-trace accents use 3px width with cyan/orange color.

---

## Shadow Tokens

### Dark Mode

| Token | Value | Use |
|-------|-------|-----|
| `--ru-shadow-sm` | `0 1px 2px rgba(0, 0, 0, 0.5)` | Subtle elevation |
| `--ru-shadow-md` | `0 4px 12px rgba(0, 0, 0, 0.4)` | Card hover lift |
| `--ru-shadow-lg` | `0 8px 24px rgba(0, 0, 0, 0.5)` | Modal, elevated panel |
| `--ru-shadow-orange` | `0 0 20px var(--ru-orange-glow)` | Elite agent glow, primary CTA emphasis |
| `--ru-shadow-cyan` | `0 0 20px var(--ru-cyan-glow)` | Agent identity glow, tournament button |

### Light Mode

| Token | Value |
|-------|-------|
| `--ru-shadow-sm` | `0 1px 2px rgba(0, 0, 0, 0.05)` |
| `--ru-shadow-md` | `0 4px 12px rgba(0, 0, 0, 0.08)` |
| `--ru-shadow-lg` | `0 8px 24px rgba(0, 0, 0, 0.12)` |
| `--ru-shadow-orange` | `0 0 16px var(--ru-orange-glow)` |
| `--ru-shadow-cyan` | `0 0 16px var(--ru-cyan-glow)` |

---

## Motion Tokens

| Token | Value | Use |
|-------|-------|-----|
| `--ru-duration-micro` | 100ms | Button hover, nav hover, badge state |
| `--ru-duration-transition` | 200ms | Card hover, modal open, content fade |
| `--ru-duration-arena` | 400ms | Bracket reveals, rank transitions, score updates |
| `--ru-ease-default` | `ease` | Most transitions |
| `--ru-ease-spring` | `cubic-bezier(0.175, 0.885, 0.32, 1.275)` | Win animation, success checkmark bounce |

**Motion rules:** Ambient state is calm (subtle pulses). Competition events spike energy (flashes, glow bursts). Never animate decoratively — motion signals state change.

---

## Breakpoint Tokens

| Name | Range | Columns | Gutter | Margin | Max Width |
|------|-------|---------|--------|--------|-----------|
| Mobile | `<640px` | 4 | 16px | 16px | 100% |
| Tablet | `640–768px` | 8 | 20px | 24px | 100% |
| Desktop | `768–1024px` | 12 | 24px | 32px | 100% |
| Wide | `1024–1280px` | 12 | 24px | 64px | 100% |
| Ultra | `>1280px` | 12 | 32px | 64px | 1440px |

---

## Contrast Verification (Dark Mode — Primary)

All ratios measured against `--ru-bg-void` (#09090B) unless noted.

| Element | Foreground | Background | Ratio | WCAG Requirement | Status |
|---------|-----------|------------|-------|-----------------|--------|
| Primary text | #FAFAFA | #09090B | 18.1:1 | 4.5:1 body | PASS |
| Secondary text | #A1A1AA | #09090B | 6.3:1 | 4.5:1 body | PASS |
| Tertiary text (large only) | #52525B | #09090B | 3.2:1 | 3:1 large text | PASS* |
| Primary text on surface | #FAFAFA | #111114 | 16.4:1 | 4.5:1 body | PASS |
| Secondary text on surface | #A1A1AA | #111114 | 5.8:1 | 4.5:1 body | PASS |
| Signal Orange on void | #F97316 | #09090B | 5.7:1 | 3:1 UI | PASS |
| Signal Orange on surface | #F97316 | #111114 | 5.2:1 | 3:1 UI | PASS |
| Circuit Cyan on void | #06B6D4 | #09090B | 7.2:1 | 4.5:1 body | PASS |
| Circuit Cyan on surface | #06B6D4 | #111114 | 6.5:1 | 4.5:1 body | PASS |
| White on orange button | #FFFFFF | #F97316 | 3.1:1 | 3:1 large text/UI | PASS |
| Success on void | #4ADE80 | #09090B | 9.8:1 | 4.5:1 body | PASS |
| Error on void | #F87171 | #09090B | 5.6:1 | 4.5:1 body | PASS |
| Warning on void | #FACC15 | #09090B | 12.4:1 | 4.5:1 body | PASS |

*Tertiary text passes at 3:1 for large text and UI components only — never use for body copy or required labels.

**Actions required:**
- `--ru-text-tertiary` is decorative only — placeholders and disabled states where reduced prominence is intentional
- White on orange (#FFFFFF on #F97316) at 3.1:1 passes the 3:1 threshold for UI components and large text — do not use for small body text on orange
- `--ru-success`, `--ru-error`, `--ru-warning` pass on dark void — verify against lighter surface variants when used on `--ru-bg-elevated`

---

*Token sheet derived from [styleguide.md](styleguide.md)*
*Verify all contrast ratios when implementing — values are calculated, not measured from rendered output*
