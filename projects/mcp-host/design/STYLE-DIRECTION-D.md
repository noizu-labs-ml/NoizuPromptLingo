# MCP Host — Style Direction D

> **Option D: Bold Expressive (70%) + Nocturne (30%)**
> Unified design system for the MCP Host platform and its three product surfaces.

**Status:** draft
**Last updated:** 2026-05-12

---

## 1. Style Selection

**Primary:** Bold Expressive (70%) — vivid gradients, confident scale, motion-rich presence
**Base:** Nocturne (30%) — dark foundation that grounds energy and prevents visual chaos

### Rationale

MCP is an emerging protocol space with no entrenched visual identity yet. The window to establish instant recognition and memorability is open — and it won't stay open long. Option D seizes that window.

The Bold Expressive foundation creates the kind of visual identity that gets shared: developers screenshot the deployment screen, the gradient badge appears in conference talks, the UI ends up in "cool tools" threads. This is intentional. In a protocol ecosystem, mindshare matters as much as capability, and design is a distribution strategy.

The Nocturne base (30%) is not decorative restraint — it's structural. A pure Bold Expressive execution on light backgrounds would read as energetic but unserious. The dark canvas transforms the gradients from loud to luminous. Color on dark reads as light emission, not paint. It's the difference between a neon sign in daylight and a neon sign at night.

**Competitive positioning:** Compared to the muted, serious-gray aesthetic common in developer infra tooling (think: legacy cloud consoles), Option D occupies adjacent territory to Raycast, Linear, and Framer — tools that won developer love partly through design that respects and excites the audience. Option A's Nocturne + Minimal Tech is the safe choice. Option D is the memorable choice.

**When this direction is correct:** If the goal is brand recognition, developer community buzz, and visual differentiation in the MCP ecosystem, Option D is the strongest signal. If the goal is blending into enterprise procurement conversations, it is not.

---

## 2. Color System

### Dark Foundation (shared across all surfaces)

| Token | Hex | Usage |
|-------|-----|-------|
| `--void` | `#09090B` | Deepest background, page base |
| `--canvas` | `#111111` | Primary section background |
| `--surface` | `#1A1A1A` | Card backgrounds, elevated elements |
| `--surface-raised` | `#222222` | Modals, dropdowns, popovers |
| `--border-subtle` | `#27272A` | Card borders, dividers |
| `--border-default` | `#3F3F46` | Input borders, interactive elements |

### Vivid Accent Gradients

Gradients are intentional in this direction. They are not anti-patterns — they are the brand signal. Each gradient has a semantic role and is applied consistently.

#### Platform Primary — Electric Violet → Hot Pink

| Stop | Hex | Token |
|------|-----|-------|
| Start | `#7C3AED` | `--grad-primary-from` |
| End | `#EC4899` | `--grad-primary-to` |

**Application:** Hero section CTAs, primary action buttons, key UI moments, wordmark gradient fill, active navigation indicators. This gradient = "you're looking at MCP Host."

```css
--gradient-primary: linear-gradient(135deg, #7C3AED 0%, #EC4899 100%);
```

#### Platform Secondary — Cyan → Blue

| Stop | Hex | Token |
|------|-----|-------|
| Start | `#06B6D4` | `--grad-secondary-from` |
| End | `#3B82F6` | `--grad-secondary-to` |

**Application:** Data visualization, charts, interactive element focus states, sparklines, metric callouts. This gradient = "live data, activity, speed."

```css
--gradient-secondary: linear-gradient(135deg, #06B6D4 0%, #3B82F6 100%);
```

### Sub-Product Gradients

Each product surface has its own gradient identity. These are used in product-specific hero sections, navigation lockups, badges, and onboarding flows.

| Product | From | To | Semantic |
|---------|------|----|---------|
| **JustMCP.it** | `#06B6D4` Cyan | `#3B82F6` Blue | Speed, instant deployment |
| **MCP Jumpstart** | `#10B981` Green | `#14B8A6` Teal | Growth, scaffolding, building |
| **SafeMCP** | `#7C3AED` Violet | `#6366F1` Indigo | Authority, control, trust |

```css
--gradient-justmcp:   linear-gradient(135deg, #06B6D4 0%, #3B82F6 100%);
--gradient-jumpstart: linear-gradient(135deg, #10B981 0%, #14B8A6 100%);
--gradient-safemcp:   linear-gradient(135deg, #7C3AED 0%, #6366F1 100%);
```

### Text

| Token | Hex | Usage |
|-------|-----|-------|
| `--text-primary` | `#FAFAFA` | Headlines, body content, primary labels |
| `--text-secondary` | `#A1A1AA` | Supporting text, metadata, descriptions |
| `--text-muted` | `#71717A` | Placeholders, disabled states, timestamps |

### Glow / Ambient

Each gradient color produces a glow variant for hover states and card ambient lighting:

```css
--glow-violet:  rgba(124, 58, 237, 0.35);
--glow-pink:    rgba(236, 72, 153, 0.30);
--glow-cyan:    rgba(6, 182, 212, 0.30);
--glow-blue:    rgba(59, 130, 246, 0.25);
--glow-green:   rgba(16, 185, 129, 0.30);
```

---

## 3. Typography

### Type Stack

| Role | Family | Fallback |
|------|--------|---------|
| Display / UI | Space Grotesk | system-ui, sans-serif |
| Body | Inter | system-ui, sans-serif |
| Code | Berkeley Mono | JetBrains Mono, monospace |

**Space Grotesk rationale:** Geometric skeleton like Grotesk/Futura (technical credibility) but with subtle optical irregularities that give it personality — the "G" is distinctive, the "a" has character. It reads modern without being cold. At large display sizes, it's immediately recognizable. It's the right font when you want a developer audience to notice the typography without being able to say exactly why.

**Berkeley Mono rationale:** Premium feel for code surfaces. If unavailable, JetBrains Mono is an acceptable fallback — legible, wide glyph support, free.

### Weights in Use

| Weight | Usage |
|--------|-------|
| 400 | Body text, descriptions |
| 500 | UI labels, navigation items, card titles |
| 700 | Display headlines, hero text, CTAs, badge text |

Bold is not reserved here. This is Bold Expressive — weight is a primary tool.

### Type Scale

| Step | Size | Line Height | Letter Spacing | Usage |
|------|------|------------|---------------|-------|
| `--text-xs` | 12px | 1.5 | 0 | Badges, timestamps, labels |
| `--text-sm` | 14px | 1.5 | 0 | Body secondary, table cells |
| `--text-base` | 16px | 1.6 | 0 | Primary body text |
| `--text-lg` | 18px | 1.5 | -0.01em | Card titles, feature labels |
| `--text-xl` | 20px | 1.4 | -0.01em | Section headings |
| `--text-2xl` | 24px | 1.3 | -0.02em | Sub-section headings |
| `--text-3xl` | 32px | 1.2 | -0.02em | Page titles |
| `--text-4xl` | 40px | 1.15 | -0.03em | Hero subheadings |
| `--text-5xl` | 56px | 1.1 | -0.03em | Hero display |
| `--text-6xl` | 72px | 1.0 | -0.04em | Oversized hero, landing hero |

**Oversized typography is a feature.** When a headline can be 72px, make it 72px. This is not decorating — it creates visual hierarchy that functions before the user reads a word.

Gradient text is applied to display-size headings (3xl+) only:

```css
.text-gradient {
  background: var(--gradient-primary);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}
```

---

## 4. Spacing System

### Base Unit: 8px

All spacing tokens are multiples of 8px.

| Token | Value | Usage |
|-------|-------|-------|
| `--space-1` | 4px | Tight internal padding (badges, chips) |
| `--space-2` | 8px | Base unit |
| `--space-3` | 12px | Compact component internal padding |
| `--space-4` | 16px | Standard gaps, list item padding |
| `--space-6` | 24px | Card padding (compact), column gaps |
| `--space-8` | 32px | Card padding (standard), section sub-gaps |
| `--space-12` | 48px | Section gaps, group separators |
| `--space-16` | 64px | Section vertical padding (condensed pages) |
| `--space-20` | 80px | Section vertical padding (standard) |
| `--space-24` | 96px | Section vertical padding (generous) |
| `--space-32` | 128px | Hero vertical padding |
| `--space-40` | 160px | Hero maximum vertical padding |

### Dramatic Scale Jumps

The scale is intentionally non-linear. Hero sections use 120–160px vertical spacing. This is not waste — it creates the visual "breath" that makes the hero content feel like a landmark, not a paragraph. The jump from 64px (content sections) to 120–160px (hero) is perceptible and intentional.

### Layout Widths

| Context | Max Width |
|---------|-----------|
| Full-bleed hero, gradient backgrounds | 1440px (edge-to-edge content at this breakpoint) |
| Content sections, text-heavy layouts | 1200px |
| Prose / documentation | 768px |
| Narrow form / modal content | 480px |

---

## 5. Component Styling

### Buttons

**Primary — Gradient Fill**

The primary action button is the most important moment for the gradient. It should feel like a reward for clicking.

```css
.btn-primary {
  background: var(--gradient-primary);
  color: #FAFAFA;
  font-family: 'Space Grotesk', sans-serif;
  font-weight: 700;
  font-size: 15px;
  letter-spacing: -0.01em;
  padding: 12px 24px;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  transition: all 300ms cubic-bezier(0.34, 1.56, 0.64, 1);
}

.btn-primary:hover {
  transform: scale(1.02) translateY(-1px);
  box-shadow: 0 8px 32px var(--glow-violet), 0 4px 12px var(--glow-pink);
}
```

**Secondary — Glass Morphism**

```css
.btn-secondary {
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: #FAFAFA;
  padding: 12px 24px;
  border-radius: 8px;
  font-weight: 500;
  transition: all 250ms ease;
}

.btn-secondary:hover {
  background: rgba(255, 255, 255, 0.08);
  border-color: rgba(255, 255, 255, 0.2);
}
```

**Ghost — Gradient Border on Hover**

```css
.btn-ghost {
  background: transparent;
  border: 1px solid var(--border-default);
  color: var(--text-secondary);
  padding: 11px 23px;
  border-radius: 8px;
  transition: all 250ms ease;
}

.btn-ghost:hover {
  border-color: transparent;
  background: linear-gradient(var(--canvas), var(--canvas)) padding-box,
              var(--gradient-primary) border-box;
  color: var(--text-primary);
}
```

### Cards

Cards use gradient borders and glass backgrounds to suggest depth and luminosity without competing with content.

```css
.card {
  background: rgba(26, 26, 26, 0.8);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border: 1px solid transparent;
  background-clip: padding-box;
  border-radius: 12px;
  padding: 32px;
  position: relative;
}

/* Gradient border via pseudo-element */
.card::before {
  content: '';
  position: absolute;
  inset: -1px;
  border-radius: 13px;
  background: linear-gradient(135deg, rgba(124, 58, 237, 0.3), rgba(236, 72, 153, 0.15), rgba(63, 63, 70, 0.3));
  z-index: -1;
}

.card:hover::before {
  background: linear-gradient(135deg, rgba(124, 58, 237, 0.6), rgba(236, 72, 153, 0.4));
}

.card:hover {
  transform: translateY(-2px);
  box-shadow: 0 16px 48px rgba(0, 0, 0, 0.4), 0 0 32px var(--glow-violet);
}
```

### Inputs

Inputs use dark recessed styling with a gradient focus ring — the focus state is a moment of visual confirmation, not just a browser default.

```css
.input {
  background: rgba(9, 9, 11, 0.8);
  border: 1px solid var(--border-subtle);
  border-radius: 8px;
  padding: 12px 16px;
  color: var(--text-primary);
  font-size: 15px;
  transition: border-color 200ms ease, box-shadow 200ms ease;
  width: 100%;
}

.input:focus {
  outline: none;
  border-color: transparent;
  box-shadow: 0 0 0 1.5px var(--grad-primary-from),
              0 0 0 3px rgba(124, 58, 237, 0.2);
}

.input::placeholder {
  color: var(--text-muted);
}
```

### Navigation — Glass Morphism Sticky Header

```css
.nav {
  position: sticky;
  top: 0;
  z-index: 100;
  background: rgba(9, 9, 11, 0.7);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
  height: 64px;
  display: flex;
  align-items: center;
}
```

### Data Tables

Tables are primary UI surfaces in SafeMCP and Jumpstart — they deserve dramatic treatment.

```css
.table-header {
  background: var(--surface);
  border-bottom: 2px solid transparent;
  background-clip: padding-box;
  position: relative;
}

/* Gradient accent bar under header row */
.table-header::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  right: 0;
  height: 2px;
  background: var(--gradient-primary);
  opacity: 0.8;
}

.table-header th {
  font-family: 'Space Grotesk', sans-serif;
  font-weight: 700;
  font-size: 11px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: var(--text-muted);
  padding: 14px 16px;
}

.table-row:hover {
  background: rgba(124, 58, 237, 0.06);
}
```

### Code Blocks

Syntax highlighting uses the accent palette — keywords get gradient color, strings get the cyan secondary.

```css
.code-block {
  background: #0D0D0F;
  border: 1px solid var(--border-subtle);
  border-radius: 10px;
  padding: 24px;
  font-family: 'Berkeley Mono', 'JetBrains Mono', monospace;
  font-size: 13px;
  line-height: 1.7;
  overflow-x: auto;
}

/* Syntax color roles */
.token.keyword    { color: #A78BFA; }  /* violet-400 */
.token.string     { color: #34D399; }  /* emerald-400 */
.token.comment    { color: #52525B; }  /* zinc-600 */
.token.function   { color: #22D3EE; }  /* cyan-400 */
.token.number     { color: #F472B6; }  /* pink-400 */
.token.operator   { color: #94A3B8; }  /* slate-400 */
```

### Badges

Gradient fills with consistent border-radius. Each sub-product uses its own gradient.

```css
.badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 3px 10px;
  border-radius: 20px;
  font-family: 'Space Grotesk', sans-serif;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.04em;
  text-transform: uppercase;
}

.badge-primary  { background: var(--gradient-primary);  color: #FAFAFA; }
.badge-justmcp  { background: var(--gradient-justmcp);  color: #FAFAFA; }
.badge-jumpstart{ background: var(--gradient-jumpstart); color: #FAFAFA; }
.badge-safemcp  { background: var(--gradient-safemcp);  color: #FAFAFA; }
.badge-subtle   { background: rgba(124,58,237,0.15); border: 1px solid rgba(124,58,237,0.3); color: #A78BFA; }
```

---

## 6. Motion

Motion is a brand expression in Option D. It communicates immediacy, responsiveness, and energy. Timid hover states read as timid product.

### Transition Defaults

| Property | Duration | Easing |
|----------|---------|--------|
| Color, opacity | 200ms | `ease` |
| Transform (hover) | 300ms | `cubic-bezier(0.34, 1.56, 0.64, 1)` (spring) |
| Box-shadow, glow | 300ms | `ease-out` |
| Page section reveal | 500ms | `cubic-bezier(0.16, 1, 0.3, 1)` |
| Gradient background | 400ms | `ease` |

The spring easing (`0.34, 1.56, 0.64, 1`) creates a slight overshoot on hover scale. This is intentional — it gives interactive elements a physical, snappy quality.

### Hover Effects

**Interactive cards and buttons:**
- `transform: scale(1.02) translateY(-2px)`
- Glow expansion: box-shadow with the relevant glow token

**Navigation items:**
- Underline grows from 0 to 100% with gradient color
- Duration: 200ms, `ease-out`

### Scroll-Triggered Reveals

Sections enter with a fade-in-up pattern:

```css
@keyframes reveal-up {
  from {
    opacity: 0;
    transform: translateY(24px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.reveal {
  animation: reveal-up 500ms cubic-bezier(0.16, 1, 0.3, 1) both;
}
```

Stagger: 80ms per item in a group. Apply via `animation-delay`.

### Hero Background

Animated gradient mesh — the hero background itself moves, slowly (15-20s loop). This creates ambient energy without demanding attention.

**Option A — CSS gradient animation:**

```css
@keyframes gradient-drift {
  0%   { background-position: 0% 50%; }
  50%  { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}

.hero-bg {
  background: linear-gradient(
    -45deg,
    #09090B,
    #1a0a2e,
    #0d1a2e,
    #0a1a0f,
    #09090B
  );
  background-size: 400% 400%;
  animation: gradient-drift 20s ease infinite;
}
```

**Option B — Particle field:** Three.js or tsParticles with low-density, slow-moving particles in the gradient colors. Opacity max 0.4 to avoid visual noise.

### Loading States — Branded Skeleton

```css
@keyframes shimmer {
  0%   { background-position: -1000px 0; }
  100% { background-position: 1000px 0; }
}

.skeleton {
  background: linear-gradient(
    90deg,
    var(--surface) 25%,
    rgba(124, 58, 237, 0.15) 50%,
    var(--surface) 75%
  );
  background-size: 2000px 100%;
  animation: shimmer 2s infinite linear;
  border-radius: 6px;
}
```

---

## 7. Brand Identity

### Wordmark

**"MCP Host"** rendered in Space Grotesk 700. The "MCP" receives the primary gradient fill; "Host" renders in `--text-primary` (`#FAFAFA`). This creates a natural word-grouping that emphasizes the protocol identity.

```
[MCP] in gradient violet→pink  +  [Host] in white
```

At small sizes (navigation, favicon-adjacent contexts), gradient text falls back to solid `#7C3AED`.

### Logomark

Abstract geometric form — a stylized "M" or interlocking node diagram (appropriate for a hosting/routing platform). Constructed from geometric primitives with gradient fill. The form should:
- Read clearly at 16px (favicon)
- Scale confidently to 64px+ (hero lockup)
- Work in single color (monochrome contexts)
- Not reference literal servers/clouds (too generic)

Recommended direction: Three nodes with connecting lines — references MCP's tool-chaining concept, reads as a network graph, has visual tension without being complex.

### Sub-Product Lockups

Each product surface uses:
- Product name in Space Grotesk 700
- Product gradient applied to wordmark
- Consistent em-dash separator for descriptive taglines: `JustMCP.it — Deploy in seconds`

| Product | Gradient | Tagline Treatment |
|---------|---------|-------------------|
| JustMCP.it | Cyan→Blue | Speed-focused: "in seconds", "instantly", "one click" |
| MCP Jumpstart | Green→Teal | Build-focused: "scaffold", "template", "start fresh" |
| SafeMCP | Violet→Indigo | Authority-focused: "control", "audit", "enforce" |

### Swag Viability

The brand should work on physical goods. Test: does it look good on a matte black hoodie? Criteria:
- Logomark works as an embroidered patch (5–6 color max, geometric, no gradients required)
- Wordmark works silk-screened in single color
- The overall mark is distinctive enough to be recognizable without color (at events, in low-resolution prints)

---

## 8. Voice & Tone

### Core Positioning

"The MCP hosting platform that developers actually want to use."

Bold Expressive visual identity requires matching verbal identity. The voice is confident, slightly irreverent, and developer-native. It speaks peer-to-peer, not vendor-to-customer.

### Tone Attributes

| Attribute | In Practice |
|-----------|-------------|
| **Confident** | Direct statements, no hedging, no "might" or "could help you" |
| **Irreverent** | Light wit, comfortable with technical humor, not trying to sound enterprise-safe |
| **Precise** | Correct terminology, no vague claims, specifics over generalities |
| **Energetic** | Active verbs, short declarative sentences, momentum in phrasing |

### Example Copy

| Context | Copy |
|---------|------|
| JustMCP.it hero | "Your MCP servers. Deployed before your coffee gets cold." |
| JustMCP.it sub | "Push your config. We handle the rest: hosting, TLS, health checks, scaling." |
| Jumpstart hero | "Scaffold your MCP server in 30 seconds. Templates that actually make sense." |
| SafeMCP hero | "You wrote the policy. SafeMCP enforces it — at the protocol layer, before it runs." |
| Empty state | "Nothing here yet. Let's fix that." |
| Success state | "Deployed. Live. Go ship something else." |
| Error state | "That didn't work. Here's exactly why." |

### What to Avoid

- Passive voice in CTAs ("Get started by clicking...")
- Corporate hedging ("Our platform may help teams to potentially...")
- False informality that reads as trying too hard ("Hey there! 🎉")
- Unexplained jargon in marketing copy (save the protocol detail for docs)

---

## 9. Accessibility

Gradients and high contrast are not mutually exclusive. Option D targets WCAG 2.2 AA across all surfaces.

### Contrast Requirements

| Pair | Target | Method |
|------|--------|--------|
| `#FAFAFA` text on `#111111` background | 16:1 (exceeds AA) | Solid color |
| `#A1A1AA` text on `#111111` background | 5.3:1 (AA) | Solid color |
| Gradient text (display) | ≥ 4.5:1 at darkest gradient point | Verified at both ends |
| Button text on gradient bg | ≥ 4.5:1 | White text only on gradient fills |
| `#71717A` text on `#111111` | 3.9:1 | **Use only for decorative/non-essential text** — never for content |

### Gradient Text Contract

Gradient text (`background-clip: text`) may not be readable by all assistive technologies. Rules:
1. Never use gradient text below 32px
2. Always provide `aria-label` or equivalent when gradient text is in an interactive element
3. Solid color fallback via `@supports not (-webkit-background-clip: text)`

```css
@supports not (-webkit-background-clip: text) {
  .text-gradient {
    color: var(--grad-primary-from);
  }
}
```

### Focus Indicators

Default browser focus outlines are replaced with high-visibility gradient rings:

```css
:focus-visible {
  outline: none;
  box-shadow: 0 0 0 2px var(--canvas),
              0 0 0 4px var(--grad-primary-from);
}
```

This ensures tab-navigation users see a strong, brand-consistent focus indicator.

### Reduced Motion

The most significant concession for accessibility: when `prefers-reduced-motion: reduce` is set, all animated gradients become static and all motion is reduced to opacity-only fades at 150ms.

```css
@media (prefers-reduced-motion: reduce) {
  /* Remove all transform animations */
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 150ms !important;
    transition-property: opacity !important;
  }

  /* Replace gradient text with solid color */
  .text-gradient {
    background: none;
    -webkit-text-fill-color: var(--grad-primary-from);
    color: var(--grad-primary-from);
  }

  /* Replace animated hero bg with static dark */
  .hero-bg {
    background: var(--void);
    animation: none;
  }

  /* Remove hover transforms */
  .card:hover,
  .btn-primary:hover {
    transform: none;
  }
}
```

---

## 10. Anti-Patterns

These are explicitly prohibited in Option D — they undermine the visual identity.

| Anti-Pattern | Why It Fails Here | Correction |
|--------------|-------------------|------------|
| **All-gray palette** | Indistinguishable from every other dev tool. Zero memorability. | Use the defined gradients in their correct moments. |
| **Muted everything** | Safe = forgettable. This direction bets on boldness. | Let color lead in hero sections and key UI moments. |
| **Timid hover states** | Flat hover = dead UI. Users lose spatial awareness. | Use the spring transform + glow on all interactive elements. |
| **Small typography when big would be better** | Hierarchy collapse. Everything reads at the same weight. | Use the full scale. 72px headlines when the section is a landmark. |
| **Gradient as decoration** | Random rainbow gradients with no semantic meaning. | Use only the defined gradient tokens, in their defined roles. |
| **Gradient overuse** | If everything has a gradient, nothing does. | Gradients on: CTAs, hero text, badges, card borders. Not on: body text, table cells, navigation links. |
| **Corporate formality** | Disconnects from the developer audience immediately. | Match the voice: confident peer, not vendor. |
| **Stock photography** | Generic, off-brand, communicates no product truth. | Use: code screenshots, terminal output, architecture diagrams, abstract data-viz. |
| **Inconsistent gradient application** | Each product using random colors breaks platform coherence. | Always use the sub-product gradient tokens, not ad hoc color choices. |
| **Removing glow on dark backgrounds** | Glow on dark is how gradients communicate depth without borders. | Keep the glow tokens in hover states. Opacity controls intensity, not presence. |

---

## Implementation Notes

### CSS Custom Properties Setup

Define all tokens at `:root` in a single design-tokens file:

```css
:root {
  /* Foundation */
  --void:              #09090B;
  --canvas:            #111111;
  --surface:           #1A1A1A;
  --surface-raised:    #222222;
  --border-subtle:     #27272A;
  --border-default:    #3F3F46;

  /* Text */
  --text-primary:      #FAFAFA;
  --text-secondary:    #A1A1AA;
  --text-muted:        #71717A;

  /* Gradients */
  --grad-primary-from: #7C3AED;
  --grad-primary-to:   #EC4899;
  --grad-secondary-from: #06B6D4;
  --grad-secondary-to:   #3B82F6;

  --gradient-primary:   linear-gradient(135deg, var(--grad-primary-from), var(--grad-primary-to));
  --gradient-secondary: linear-gradient(135deg, var(--grad-secondary-from), var(--grad-secondary-to));
  --gradient-justmcp:   linear-gradient(135deg, #06B6D4, #3B82F6);
  --gradient-jumpstart: linear-gradient(135deg, #10B981, #14B8A6);
  --gradient-safemcp:   linear-gradient(135deg, #7C3AED, #6366F1);

  /* Glow */
  --glow-violet: rgba(124, 58, 237, 0.35);
  --glow-pink:   rgba(236, 72, 153, 0.30);
  --glow-cyan:   rgba(6, 182, 212, 0.30);
}
```

### Font Loading

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;700&family=Inter:wght@400;500&display=swap" rel="stylesheet">
```

Berkeley Mono requires a license. For development, JetBrains Mono is a free substitute:

```html
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
```

### Gradient Border Technique

Gradient borders require the pseudo-element approach (not `border-image` with `border-radius`) for reliable cross-browser rendering with rounded corners:

```css
.gradient-border {
  position: relative;
  background: var(--surface);
  border-radius: 12px;
}

.gradient-border::before {
  content: '';
  position: absolute;
  inset: -1px;
  border-radius: 13px; /* 1px larger than parent */
  background: var(--gradient-primary);
  z-index: -1;
  opacity: 0.4;
  transition: opacity 300ms ease;
}

.gradient-border:hover::before {
  opacity: 0.8;
}
```

---

*Option D Style Direction — MCP Host Platform*
*Status: draft | Date: 2026-05-12*
