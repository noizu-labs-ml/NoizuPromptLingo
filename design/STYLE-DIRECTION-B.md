# MCP Host — Style Direction B

> Option B: Pure Minimal Tech — Clean SaaS, light-mode-first, restraint as the product.

**Status:** draft
**Last updated:** 2026-05-12

---

## Style Selection

**Primary:** Pure Minimal Tech (100%) — light-native, whitespace-driven hierarchy
**Accent:** Single Electric Blue (#2563EB) — one accent, used sparingly and intentionally

### Rationale

Where Option A (Nocturne) wraps the developer in atmosphere, Option B gets out of the way entirely. The thesis: infrastructure that disappears is infrastructure you trust. Vercel, Linear, and Resend have proven that the minimal SaaS aesthetic isn't neutral — it is itself a strong signal. It says: the interface isn't the product. The product is the product.

For an MCP hosting platform, this maps directly to the value proposition. JustMCP.it deploys in one click — the UI should feel like it takes zero effort. MCP Jumpstart scaffolds boilerplate — the interface should feel like a clean whiteboard. SafeMCP enforces security policy — the audit surface should feel like a well-lit operating room, not a bunker.

The light-mode-first approach also addresses a practical reality: security and compliance stakeholders (who sign off on SafeMCP) live in Notion, Google Docs, and Jira. A dark-native tool creates a context mismatch in the room where decisions get made.

**What this direction rejects:** Decoration, atmosphere, brand personality expressed through UI chrome. The brand lives in the copy, the icon treatment, and the product decisions — not in glows, gradients, or section illustrations.

---

## Color System

### Philosophy

Two rules. First: backgrounds are white or near-white. Borders are barely visible. Text is dark. The Electric Blue accent appears at most three times per screen. Second: never use color to decorate — only to communicate state.

### Light Mode (Primary)

#### Background Scale

| Token | Hex | Usage |
|-------|-----|-------|
| `--bg-base` | `#FFFFFF` | Page background, primary surface |
| `--bg-subtle` | `#FAFAFA` | Alternating rows, sidebar backgrounds |
| `--bg-muted` | `#F5F5F5` | Code blocks, recessed sections, input backgrounds |

#### Border Scale

| Token | Hex | Usage |
|-------|-----|-------|
| `--border-faint` | `#F0F0F0` | Barely-there dividers — use for rows, not containers |
| `--border-default` | `#E5E5E5` | Card borders, input borders, table borders |
| `--border-strong` | `#D4D4D4` | Active input borders, hover borders |

Rule: borders are visible only enough to define containment. If you can describe the border as "obvious", it is too heavy.

#### Text Scale

| Token | Hex | Usage |
|-------|-----|-------|
| `--text-primary` | `#171717` | Headlines, labels, active navigation items |
| `--text-secondary` | `#525252` | Body text, descriptions, sublabels |
| `--text-tertiary` | `#A3A3A3` | Placeholder text, timestamps, metadata |
| `--text-disabled` | `#D4D4D4` | Disabled states only |

#### Electric Blue Accent

One accent. Everywhere the same accent. No surface gets its own accent color.

| Token | Hex | Usage |
|-------|-----|-------|
| `--accent` | `#2563EB` | Primary CTA buttons, active nav indicator, focus rings, links |
| `--accent-hover` | `#1D4ED8` | Hover state on accent elements |
| `--accent-subtle` | `#EFF6FF` | Accent tint for selected rows, badge backgrounds, hover on ghost buttons |
| `--accent-border` | `#BFDBFE` | Subtle accent border for info callouts |

Usage ceiling: the accent should appear at most 3 times per viewport. Primary button, active nav item, and one link — that is the full budget.

#### Semantic Colors

| Token | Hex | Background Tint | Usage |
|-------|-----|-----------------|-------|
| `--success` | `#16A34A` | `#F0FDF4` | Healthy status, deploy success, passing checks |
| `--warning` | `#D97706` | `#FFFBEB` | Policy warnings, deprecation notices |
| `--error` | `#DC2626` | `#FEF2F2` | Failures, policy denials, auth errors |
| `--info` | `#2563EB` | `#EFF6FF` | Informational states (shares accent token intentionally) |

Status badge pattern: semantic color text on semantic background tint. Never a filled solid badge — that reads as marketing, not data.

### Dark Mode Variant

Dark mode is a first-class variant, not an afterthought — but light mode is the design origin. All dark tokens are derived by inverting the light hierarchy.

| Light Token | Dark Equivalent | Hex |
|-------------|-----------------|-----|
| `--bg-base` | Dark page bg | `#0A0A0A` |
| `--bg-subtle` | Dark alt surface | `#111111` |
| `--bg-muted` | Dark recessed | `#1A1A1A` |
| `--border-default` | Dark border | `#262626` |
| `--border-strong` | Dark active border | `#404040` |
| `--text-primary` | Dark primary text | `#FAFAFA` |
| `--text-secondary` | Dark body text | `#A3A3A3` |
| `--text-tertiary` | Dark metadata | `#525252` |
| `--accent` | Dark accent | `#3B82F6` (lightened 1 step for contrast) |

Dark mode does not introduce new personality. It is the same restraint, inverted.

### Sub-Product Color Treatment

All three surfaces use the same Electric Blue accent (`#2563EB`). No surface gets its own accent color. Differentiation is carried entirely by iconography.

| Surface | Accent | Differentiation |
|---------|--------|-----------------|
| **JustMCP.it** | `#2563EB` | Rocket/deploy icon in product mark |
| **MCP Jumpstart** | `#2563EB` | Scaffold/frame icon in product mark |
| **SafeMCP** | `#2563EB` | Shield/lock icon in product mark |

This is not a limitation — it is a signal that these are one coherent platform, not three separate products that happen to share a homepage.

---

## Typography

### Font Stack

| Role | Font | Fallback |
|------|------|----------|
| **All UI text** | Inter | system-ui, -apple-system, sans-serif |
| **Code / monospace** | JetBrains Mono | Berkeley Mono, Fira Code, monospace |

No display typeface. No decorative font. Inter at two weights. This is the full typographic palette.

### Weights

Two weights only. No exceptions.

| Weight | Value | Usage |
|--------|-------|-------|
| Regular | 400 | All body text, descriptions, metadata, table rows |
| Semibold | 600 | Headlines, labels, navigation items, button text, table headers |

The temptation to reach for 500 (medium) will arise. Resist it. The contrast between 400 and 600 creates clear hierarchy without introducing a third decision surface.

### Type Scale

| Token | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|--------|-------------|----------------|-------|
| `--type-display` | 48px | 600 | 1.1 | -0.02em | Hero headlines only — one per page |
| `--type-h1` | 36px | 600 | 1.2 | -0.015em | Page titles |
| `--type-h2` | 24px | 600 | 1.3 | -0.01em | Section headings |
| `--type-h3` | 20px | 600 | 1.4 | -0.005em | Subsection headings, card titles |
| `--type-body-lg` | 18px | 400 | 1.6 | 0 | Lead paragraphs, feature descriptions |
| `--type-body` | 16px | 400 | 1.6 | 0 | Standard body text |
| `--type-body-sm` | 14px | 400 | 1.5 | 0 | Secondary body, form help text |
| `--type-label` | 14px | 600 | 1.2 | +0.01em | Form labels, table headers |
| `--type-caption` | 12px | 400 | 1.4 | +0.02em | Timestamps, metadata, version numbers |
| `--type-mono` | 14px | 400 | 1.6 | 0 | Code inline, tool names, API keys |
| `--type-mono-sm` | 12px | 400 | 1.5 | 0 | Code in dense tables, terminal output |

### Letter Spacing Rules

- Negative tracking (`-0.02em` to `-0.005em`) on large display text — prevents headlines from reading too wide
- Zero tracking on body text — Inter's default spacing is calibrated for legibility
- Positive tracking (`+0.01em` to `+0.02em`) on small uppercase labels and captions — prevents crowding at small sizes
- All-caps labels: always pair with `letter-spacing: +0.08em` minimum

---

## Spacing System

### Base Unit: 8px

All spacing values are multiples or half-multiples of 8px. No arbitrary values.

| Token | Value | Usage |
|-------|-------|-------|
| `--space-0-5` | 4px | Inline icon-to-text gap, tight badge padding |
| `--space-1` | 8px | Form field label-to-input gap, list item gap |
| `--space-1-5` | 12px | Button padding (vertical), input padding (vertical) |
| `--space-2` | 16px | Component internal padding, horizontal button padding |
| `--space-3` | 24px | Card padding, gutter between columns |
| `--space-4` | 32px | Between cards in a row, sidebar section spacing |
| `--space-6` | 48px | Between major page sections |
| `--space-8` | 64px | Section vertical spacing, hero padding |
| `--space-12` | 96px | Hero-to-content breaks, major landmark spacing |
| `--space-16` | 128px | Max top/bottom page padding on marketing pages |

### Layout Grid

| Property | Value |
|----------|-------|
| Max-width | 1280px |
| Columns | 12 |
| Gutter | 24px |
| Margin (< 1280px) | 24px |
| Margin (< 768px) | 16px |

Application shell (logged-in views) uses a fixed left sidebar. Content area max-width remains 1280px minus sidebar width. Sidebar does not collapse on desktop — stability of layout is a feature.

### Whitespace as a Design Element

The minimal aesthetic does not mean "no white space" — it means white space is load-bearing. Sections breathe. Cards do not crowd each other. Empty space is intentional.

Rule: if adding whitespace feels wasteful, the layout is correctly sparse. If adding content feels natural, add it — then add 50% more whitespace around it.

---

## Component Styling

### Buttons

No shadows. No gradients. No border-radius above 6px. Hover is opacity, never color shift.

```
Primary:
  background: --accent (#2563EB)
  color: #FFFFFF
  border: none
  border-radius: 6px
  padding: 10px 18px
  font: --type-label (14px/600)
  hover: opacity 0.85, transition 150ms ease
  active: opacity 0.75, scale 0.98

Secondary:
  background: transparent
  color: --text-primary
  border: 1px solid --border-default
  border-radius: 6px
  hover: background --bg-subtle, border --border-strong, 150ms

Ghost:
  background: transparent
  color: --text-secondary
  border: none
  hover: background --bg-subtle, color --text-primary, 150ms

Destructive:
  background: transparent
  color: --error
  border: 1px solid --border-default
  hover: background #FEF2F2, border --error, 150ms
```

Rule: primary button appears once per view. If you have two primary buttons, one of them is wrong.

### Cards

Border OR shadow. Never both. In this direction: border only.

```
Card:
  background: --bg-base
  border: 1px solid --border-default
  border-radius: 8px
  padding: 24px
  transition: border-color 150ms ease

Interactive card (hover):
  border-color: --border-strong
  cursor: pointer

Selected/active card:
  border-color: --accent
  background: --accent-subtle
```

No drop shadows on cards. If a card needs elevation, use `--bg-base` on `--bg-subtle` background — the color contrast defines the layer.

Exception: modals and dropdown menus may use a single shadow (`box-shadow: 0 4px 16px rgba(0,0,0,0.08)`) because they float above the document flow and need spatial separation. This is a functional shadow, not a decorative one.

### Inputs

```
Input:
  background: --bg-base
  border: 1px solid --border-default
  border-radius: 6px
  padding: 10px 14px
  font: --type-body (16px/400)
  color: --text-primary
  placeholder: --text-tertiary

Focus:
  border-color: --accent
  box-shadow: 0 0 0 3px --accent-subtle (3px focus ring, not a glow)
  outline: none

Error:
  border-color: --error
  box-shadow: 0 0 0 3px #FEF2F2

Disabled:
  background: --bg-muted
  color: --text-disabled
  cursor: not-allowed
```

The focus ring (`box-shadow: 0 0 0 3px`) is the only shadow permitted on inputs. It communicates state, not depth.

### Navigation (Top Bar)

```
Topbar:
  background: --bg-base
  border-bottom: 1px solid --border-default
  height: 56px
  padding: 0 24px
  position: sticky
  top: 0
  z-index: 100

Logo lockup: left-aligned
Nav items: center or right-aligned, horizontal
Active nav item: --text-primary + 2px --accent underline
Inactive nav item: --text-secondary, hover --text-primary, 150ms
```

No backdrop blur. No transparency. The navbar is a clean white bar with a single bottom border. It does not draw attention to itself.

Sidebar (application shell):

```
Sidebar:
  background: --bg-subtle
  border-right: 1px solid --border-default
  width: 240px
  padding: 16px 12px

Section headers: --type-caption, --text-tertiary, letter-spacing +0.08em, uppercase
Nav items: 36px height, 8px border-radius, 12px horizontal padding
Active item: --accent-subtle background, --accent text, --accent left-border (2px)
Inactive item: transparent background, --text-secondary text
```

### Data Tables

```
Table:
  width: 100%
  border-collapse: collapse

Header row:
  background: --bg-subtle
  font: --type-label (14px/600)
  color: --text-secondary
  border-bottom: 1px solid --border-default
  padding: 10px 16px

Body row:
  background: --bg-base
  font: --type-body-sm (14px/400)
  color: --text-primary
  border-bottom: 1px solid --border-faint
  padding: 12px 16px

Row hover:
  background: --bg-subtle
  transition: 100ms

Status badges within table:
  semantic color text on semantic background tint
  border-radius: 4px
  padding: 2px 8px
  font: --type-caption (12px/400)
```

No alternating row colors (zebra striping) — the faint bottom border provides sufficient row separation without adding visual noise.

### Code Blocks

```
Code block:
  background: --bg-muted (#F5F5F5)
  border: 1px solid --border-default
  border-radius: 6px
  padding: 16px 20px
  font: --type-mono (JetBrains Mono, 14px/400)
  color: --text-primary
  overflow-x: auto

Inline code:
  background: --bg-muted
  border: 1px solid --border-faint
  border-radius: 4px
  padding: 2px 6px
  font: --type-mono-sm (12px)
  color: --text-primary

Copy button (top-right of code block):
  icon only, --text-tertiary
  hover: --text-secondary
  success state: --success color, 2 seconds, revert
```

Syntax highlighting palette for light mode: muted, low-saturation colors. No neon. No rainbow. Keywords in `--text-primary`/600, strings in `#16A34A`, comments in `--text-tertiary`, literals in `#7C3AED` (desaturated violet). The code block is information, not decoration.

### Status Indicators

```
Dot indicator (small, inline):
  8px circle
  success: --success
  warning: --warning
  error: --error
  pending: --text-tertiary, pulse animation 2s

Status badge (text + dot):
  dot + label in --type-caption
  no background fill on the badge itself
  color: semantic token
```

---

## Motion

Less is more. Motion communicates state changes. Motion does not entertain.

| Pattern | Duration | Easing | Notes |
|---------|----------|--------|-------|
| Hover state (button, row, nav) | 150ms | ease | The default for all hover |
| Panel slide (sidebar, drawer) | 250ms | ease-out | Enters fast, settles |
| Modal appear | 200ms | ease-out | Fade + scale from 0.96 |
| Toast notification | 300ms in, 200ms out | ease-out | Slides from top-right |
| Page transition | 150ms | ease | Opacity fade only — no slide |
| Status pulse (pending dot) | 2000ms | ease-in-out, infinite | Subtle scale pulse: 1 → 1.2 → 1 |

**Skeleton loaders, not spinners.** When content is loading, render a skeleton that approximates the layout of the arriving content — same dimensions, `--bg-muted` fill, `--bg-subtle` shimmer. Spinners are for operations (saving, submitting). Skeletons are for page loads and data fetching.

```
Skeleton shimmer:
  background: linear-gradient(90deg, --bg-muted 25%, --bg-subtle 50%, --bg-muted 75%)
  background-size: 200% 100%
  animation: shimmer 1.5s infinite linear
  border-radius: matches the element it replaces
```

All animations respect `prefers-reduced-motion: reduce`. Under reduced motion: instant transitions, no pulse animations, no shimmer (static `--bg-muted` for skeletons).

---

## Brand Identity

### Platform Mark: MCP Host

The platform wordmark is the brand. There is no separate logomark. "MCP Host" set in Inter Semibold (600), tracked slightly tighter than default (`letter-spacing: -0.01em`), in `--text-primary`.

If a logomark is required (favicon, app icon, social):
- A clean geometric "M" constructed on a square grid
- Filled with `--accent` (#2563EB) on white
- No rounded edges on the letterform — geometric, not friendly
- Must read legibly at 16×16px as a silhouette

Construction rules for logomark:
- 24×24 grid
- Stroke width: 2px equivalent at target size
- Single color: `--accent` on transparent/white
- No drop shadow, no border, no outer ring

### Sub-Product Lockups

Each sub-product is a clean text lockup: product name in Inter 600, `--text-primary`. The platform mark (reduced) appears before the name. Differentiation is entirely through the icon that follows or precedes the name.

| Surface | Lockup | Icon Treatment |
|---------|--------|----------------|
| **JustMCP.it** | [platform-mark] JustMCP [deploy-icon] | Minimal upward-arrow icon, `--accent` fill |
| **MCP Jumpstart** | [platform-mark] MCP Jumpstart [scaffold-icon] | Minimal grid/frame icon, `--accent` fill |
| **SafeMCP** | [platform-mark] SafeMCP [shield-icon] | Minimal shield-check icon, `--accent` fill |

Icon constraints:
- 16×16 at default scale
- Single color: `--accent`
- Stroke-based preferred over filled — lighter visual weight
- No decorative details — recognizable as a silhouette at 12px

No taglines in the logo lockup. The product name is enough. Taglines live in body copy.

### Voice & Tone

The interface copy matches the visual approach: minimal, direct, technical. No warmth theater. No apologetic hedging. No filler phrases.

| Principle | Do | Don't |
|-----------|-----|-------|
| **Direct** | "Deploy failed. Check logs." | "Oops! Something went wrong with your deployment." |
| **Precise** | "3 policies active, 1 in simulation mode" | "Your policies are mostly set up!" |
| **Imperative** | "Add a server" | "Get started by adding your first server" |
| **Specific** | "Last deployed 4 minutes ago by keith@noizu.com" | "Recently deployed" |
| **Undecorated** | Empty state: "No servers yet. Add one." | "You haven't added any servers yet! Click below to get started 🚀" |

Error messages state what happened and what to do. No apologizing. No emoji.

```
Good: "Connection refused. Verify the server URL and retry."
Bad: "We couldn't connect to your server. Please double-check your settings and try again."
```

Headlines ≤ 8 words. Sentences ≤ 20 words. No filler openers ("In order to", "Please note that", "It's important to").

---

## Accessibility

### Contrast Targets (WCAG 2.2 AA)

| Combination | Ratio | Requirement |
|-------------|-------|-------------|
| `--text-primary` on `--bg-base` (`#171717` on `#FFFFFF`) | 16.1:1 | Exceeds AA |
| `--text-secondary` on `--bg-base` (`#525252` on `#FFFFFF`) | 7.1:1 | Exceeds AA |
| `--text-tertiary` on `--bg-base` (`#A3A3A3` on `#FFFFFF`) | 2.9:1 | Fails AA — use only for non-essential metadata |
| `--accent` on `--bg-base` (`#2563EB` on `#FFFFFF`) | 5.9:1 | Passes AA |
| `#FFFFFF` on `--accent` (`#FFFFFF` on `#2563EB`) | 5.9:1 | Passes AA — white text on accent buttons is valid |
| `--success` on `--bg-base` (`#16A34A` on `#FFFFFF`) | 5.0:1 | Passes AA |
| `--error` on `--bg-base` (`#DC2626` on `#FFFFFF`) | 5.9:1 | Passes AA |
| `--warning` on `--bg-base` (`#D97706` on `#FFFFFF`) | 3.5:1 | Passes AA for large text/UI components |

Note: `--text-tertiary` (#A3A3A3) fails 4.5:1 for body text. Its use is restricted to captions, timestamps, and metadata at 12px — never for meaningful content.

### Focus Indicators

All interactive elements must have a visible focus indicator when navigated by keyboard.

```
Default focus ring:
  box-shadow: 0 0 0 3px --accent-subtle
  border-color: --accent
  outline: none (replaced by box-shadow)

Focus ring contrast: --accent-subtle (#EFF6FF) creates a visible halo
Minimum focus ring area: 3px all sides
```

Focus indicators must be visible in both light and dark mode. The accent-subtle tint that works in light mode becomes too faint in dark mode — dark mode uses `rgba(59, 130, 246, 0.3)` instead.

### Touch Targets

- All interactive elements: minimum 44×44px hit area
- Inline links in body text: exception permitted (enforce in navigation and forms)
- Icon-only buttons: add `aria-label` and ensure 44×44 touch area with padding

### Screen Reader Requirements

- All icon-only buttons have `aria-label`
- Status badges have semantic meaning communicated via text (not just color)
- Data tables use `<th scope="col">` headers
- Loading states communicate via `aria-busy` and live regions
- Error messages associated with inputs via `aria-describedby`

---

## Anti-Patterns

These are not preferences — they are rules. Each one was added because someone will be tempted to break it.

### No Decorative Filler

Empty states: one short sentence and a primary action. No illustration. No mascot. No "it's quiet in here" copy. The product is not your friend — it is your tool.

### No Multiple Accents

The Electric Blue accent is the only accent. If a surface or component "needs" its own color, the design is wrong. Fix the design. Sub-products are differentiated by iconography, not by giving SafeMCP a purple accent.

### No Shadows Everywhere

The only permitted shadows:
1. Floating modals and dropdowns: `box-shadow: 0 4px 16px rgba(0,0,0,0.08)`
2. Focus rings: `box-shadow: 0 0 0 3px --accent-subtle`

Cards do not have shadows. Buttons do not have shadows. Navigation does not have shadows. If you find yourself adding a shadow to make something "pop", use whitespace instead.

### No Gradients on UI Elements

Gradients on buttons, cards, backgrounds, and headings are forbidden. The only permitted gradient is the skeleton loader shimmer, which is functional. Marketing hero sections may use a single, very subtle gradient (`#FFFFFF` to `#FAFAFA`) for depth — this is the maximum.

### No Illustrations or Mascots

This platform is infrastructure. Infrastructure does not have a mascot. Illustrations add personality that was not asked for. The interface communicates capability through clarity — not through a cartoon robot holding a wrench.

### No Rounded Corners Above 8px

- UI controls (buttons, inputs, badges): 6px
- Cards and containers: 8px
- Nothing above 8px

Higher border-radius signals approachability and friendliness — this is a technical platform for developers and security engineers. Geometric precision is the correct signal.

### No Placeholder Content in Production

"Lorem ipsum", "Coming soon", "This feature is under development" — none of these should appear in a shipped interface. Ship fewer features, fully realized, rather than many features half-built. An empty state is preferable to a placeholder state.

### No Color for Decoration

Color communicates state. Color is not used for visual variety, section differentiation, or aesthetic interest. If a section "needs" color, ask what state it is communicating. If the answer is "none", remove the color.

---

*Option B contrasts with Option A (Nocturne) in every dimension: light where A is dark, airy where A is atmospheric, single-accent where A is multi-accent, restrained where A is expressive. Neither is correct by default — the choice is a product decision about who the primary user is and what signal the platform sends in the room where decisions are made.*
