# MCP Host — Style Direction C

> **Option C: Corporate Enterprise (80%) + Minimal Tech (20%)**
> Unified design system for the MCP Host platform and its three product surfaces.

**Status:** draft
**Last updated:** 2026-05-12

---

## Style Selection

**Primary:** Corporate Enterprise (80%) — institutional credibility, structured hierarchy, trust-forward weight
**Accent:** Minimal Tech (20%) — geometric restraint, clean grid discipline, purposeful whitespace

### Rationale

Enterprise buyers do not purchase on vibes. They purchase on signals: Does this platform look like it will be here in five years? Does it look like a team that takes compliance seriously? Does it look like the security infrastructure at the companies I trust?

The Corporate Enterprise aesthetic answers those questions before the sales call begins. AWS Console, Stripe Dashboard, 1Password, Okta — these products have converged on a visual language for one reason: it works. Light backgrounds convey auditability (you can see everything). Serif display type conveys institution and establishment. Structured data tables with clear hierarchy convey operational maturity.

The Minimal Tech accent prevents this direction from becoming stiff or legacy-feeling. It keeps the grid clean, the whitespace intentional, and the iconography precise — signaling that while this platform is enterprise-grade, it was not designed in 2008.

**Who this is for:** Platform engineers evaluating MCP infrastructure for their organization. Security teams approving third-party tooling. CTOs signing six-figure contracts. They need to see trust before they see features.

---

## Color System

### Light-First Philosophy

This direction is light-mode primary. Dark mode is a supported variant, not the default. Enterprise dashboards default to light — it communicates transparency and operational visibility. Dark mode is available as a user preference, not a brand statement.

### Background Stack

| Token | Hex | Usage |
|-------|-----|-------|
| `--bg-page` | `#FFFFFF` | Primary page background |
| `--bg-subtle` | `#F8FAFC` | Section backgrounds, sidebar |
| `--bg-muted` | `#F1F5F9` | Table zebra rows, input backgrounds |
| `--bg-emphasis` | `#E2E8F0` | Hover states, selected rows |

### Borders

| Token | Hex | Usage |
|-------|-----|-------|
| `--border-light` | `#E2E8F0` | Subtle dividers, card interiors |
| `--border-default` | `#CBD5E1` | Card borders, input borders |
| `--border-strong` | `#94A3B8` | Emphasized borders, table headers |

Blue-tinted grays throughout — never warm or neutral gray. The cool undertone reinforces the platform's technical, institutional character.

### Text Hierarchy (Slate Scale)

| Token | Hex | Usage |
|-------|-----|-------|
| `--text-max` | `#0F172A` | Headlines, critical labels |
| `--text-primary` | `#1E293B` | Body text, navigation items |
| `--text-secondary` | `#475569` | Descriptions, subtext, captions |
| `--text-muted` | `#94A3B8` | Placeholders, metadata, timestamps |
| `--text-disabled` | `#CBD5E1` | Disabled form fields |

### Platform Primary: Navy + Trust Blue

| Token | Hex | Usage |
|-------|-----|-------|
| `--navy` | `#1E3A5F` | Brand anchor, nav backgrounds, logomark |
| `--navy-dark` | `#152D4A` | Hover on navy elements |
| `--navy-light` | `#2D4F7C` | Active states on navy backgrounds |
| `--trust-blue` | `#2563EB` | Primary CTA, links, focus indicators |
| `--trust-blue-hover` | `#1D4ED8` | Hover on primary actions |
| `--trust-blue-muted` | `#EFF6FF` | Background tint on blue-adjacent elements |
| `--trust-blue-border` | `#BFDBFE` | Subtle blue borders, focus halos |

Navy is the structural anchor — it appears in the top navigation bar, the platform logomark, and section anchors. Trust Blue is the action color — it appears on buttons, links, and focus rings. They are distinct in role; never interchangeable.

### Sub-Product Accent Colors

Each surface receives a secondary accent used in product-specific badging, iconography, and section identification. All interactive elements (buttons, links, focus indicators) remain Trust Blue across all surfaces — only decorative and identifying elements use the sub-product accent.

| Surface | Accent Name | Hex | Signal |
|---------|-------------|-----|--------|
| **JustMCP.it** | Operational Teal | `#0D9488` | Deployment speed, reliability, "it just works" |
| **MCP Jumpstart** | Builder Indigo | `#4F46E5` | Construction, scaffolding, developer tooling |
| **SafeMCP** | Authority Navy | `#1E3A5F` | Security depth, control, institutional trust |

SafeMCP shares the platform Navy — deliberately. It is the security control plane; it earns the primary platform color because it is the platform's most serious surface.

### Semantic Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `--success` | `#059669` | Health checks passing, successful deploys |
| `--success-bg` | `#ECFDF5` | Success state backgrounds |
| `--warning` | `#D97706` | Policy warnings, deprecation notices |
| `--warning-bg` | `#FFFBEB` | Warning state backgrounds |
| `--error` | `#DC2626` | Auth failures, policy denials, critical errors |
| `--error-bg` | `#FEF2F2` | Error state backgrounds |
| `--info` | `#2563EB` | Informational states (reuses Trust Blue) |
| `--info-bg` | `#EFF6FF` | Info state backgrounds |

---

## Typography

### Font Stack

| Role | Font | Fallback | Rationale |
|------|------|----------|-----------|
| **Display / H1 / H2** | Source Serif Pro | Georgia, "Times New Roman", serif | Serif headings are the Corporate Enterprise signature: they signal establishment, longevity, and institutional authority |
| **H3 / H4 / Body** | Inter | system-ui, -apple-system, sans-serif | Clean, legible, universally trusted for UI interfaces |
| **Code / Monospace** | JetBrains Mono | "Fira Code", Consolas, monospace | Developer-grade; communicates technical precision |

The serif/sans split is intentional and load-bearing. It mirrors the visual language of Bloomberg Terminal, Refinitiv, and enterprise financial software — contexts where typeface selection signals institutional maturity. Do not substitute a sans-serif display font for the serif; it removes the primary trust signal.

### Weights

Three weights only:

| Weight | Value | Usage |
|--------|-------|-------|
| Regular | 400 | Body text, descriptions, table rows |
| Medium | 500 | Labels, navigation, UI controls |
| Semibold | 600 | Headings (H3–H4 in Inter), emphasis |

Serif headings (Source Serif Pro) use 400 and 600. The contrast between regular serif weight and its optical density at display sizes creates the institutional gravitas — no need for 700+.

### Type Scale

| Token | Font | Size | Weight | Line-height | Letter-spacing | Usage |
|-------|------|------|--------|-------------|----------------|-------|
| `--display` | Source Serif Pro | 52px | 600 | 1.1 | -0.02em | Hero headlines |
| `--h1` | Source Serif Pro | 40px | 600 | 1.2 | -0.015em | Page titles |
| `--h2` | Source Serif Pro | 30px | 600 | 1.25 | -0.01em | Section headings |
| `--h3` | Inter | 22px | 600 | 1.3 | -0.005em | Subsection headings |
| `--h4` | Inter | 18px | 600 | 1.35 | 0 | Component headings |
| `--body-lg` | Inter | 18px | 400 | 1.6 | 0 | Lead paragraphs |
| `--body` | Inter | 16px | 400 | 1.6 | 0 | Standard body text |
| `--body-sm` | Inter | 14px | 400 | 1.5 | +0.01em | Secondary body, table cells |
| `--caption` | Inter | 12px | 500 | 1.4 | +0.02em | Labels, timestamps, metadata |
| `--label` | Inter | 12px | 600 | 1.3 | +0.05em | Form labels, badge text |
| `--mono` | JetBrains Mono | 14px | 400 | 1.5 | 0 | Code, API keys, tool names |
| `--mono-sm` | JetBrains Mono | 12px | 400 | 1.4 | 0 | Inline code, small terminals |

---

## Spacing System

### Base Unit: 8px

| Token | Value | Usage |
|-------|-------|-------|
| `--space-1` | 4px | Tight inline gaps, icon padding |
| `--space-2` | 8px | Icon-to-label, tight form gaps |
| `--space-3` | 12px | Input internal gaps |
| `--space-4` | 16px | Component padding (compact) |
| `--space-5` | 20px | Component padding (default) |
| `--space-6` | 24px | Card padding, list gaps |
| `--space-8` | 32px | Section internal padding |
| `--space-10` | 40px | Between major components |
| `--space-12` | 48px | Between sections (mobile) |
| `--space-16` | 64px | Between sections (desktop) |
| `--space-20` | 80px | Hero padding top/bottom |
| `--space-24` | 96px | Page-level section breaks |

Spacing is slightly tighter than the Nocturne direction. Enterprise dashboards are information-dense; excessive whitespace wastes screen real estate that operators need for data.

### Layout Grid

| Property | Value |
|----------|-------|
| Max width | 1280px |
| Columns | 12 |
| Gutters | 24px |
| Margin (desktop) | 48px |
| Margin (tablet) | 24px |
| Margin (mobile) | 16px |
| Card padding (default) | 24px |
| Card padding (compact) | 16px |

---

## Component Styling

### Buttons

Buttons carry visible weight. Shadows signal that the button is a physical affordance — something you press, not just a label you click. This is deliberate Corporate Enterprise vocabulary.

```
Primary:      --trust-blue bg + white text + 0 1px 2px rgba(0,0,0,0.10) shadow
              Hover: --trust-blue-hover bg + slightly deeper shadow
              Active: --trust-blue-hover bg + inset 0 1px 2px rgba(0,0,0,0.15)

Secondary:    #FFFFFF bg + --border-default border + --text-primary text + same subtle shadow
              Hover: --bg-muted bg + --border-strong border

Ghost:        transparent bg + --trust-blue text + no border
              Hover: --trust-blue-muted bg

Destructive:  --error bg + white text + no visible shadow
              Hover: #B91C1C bg (darker error)
```

- Border radius: **6px** — rounded enough to feel modern, square enough to feel institutional
- Minimum height: 40px (default), 32px (compact), 48px (large)
- Padding: 16px 24px (default)
- No glow, no blur, no neon — shadows only

### Cards

Cards are the primary data container. They sit above the page background with visible shadow — they have physical presence.

```
Background:    --bg-page (#FFFFFF)
Border:        1px --border-default (#CBD5E1)
Border radius: 8px
Shadow:        0 1px 3px rgba(0,0,0,0.07), 0 1px 2px rgba(0,0,0,0.06)
Padding:       24px

Hover (interactive cards):
  Shadow:      0 4px 8px rgba(0,0,0,0.10), 0 2px 4px rgba(0,0,0,0.06)
  Border:      1px --border-strong (#94A3B8)
  Transition:  150ms ease-out
```

Header section within card (optional):
- Background: `--bg-subtle`
- Border-bottom: 1px `--border-default`
- Padding: 16px 24px

### Inputs

Inputs have thicker borders than Minimal Tech — 1.5px instead of 1px — communicating that data entry here is a deliberate, auditable action.

```
Background:      --bg-muted (#F1F5F9)
Border:          1.5px solid --border-default (#CBD5E1)
Border radius:   6px
Padding:         10px 14px
Font:            Inter 16px, --text-primary
Placeholder:     --text-muted

Focus:
  Border:        1.5px solid --trust-blue (#2563EB)
  Ring:          0 0 0 3px --trust-blue-border (#BFDBFE)
  Background:    --bg-page (#FFFFFF)

Error:
  Border:        1.5px solid --error (#DC2626)
  Ring:          0 0 0 3px #FECACA

Disabled:
  Background:    --bg-emphasis (#E2E8F0)
  Text:          --text-disabled
  Cursor:        not-allowed
```

### Navigation

Top navigation is the Navy bar — the most visually assertive element on the page. It immediately establishes the platform's institutional gravity.

```
Nav bar:
  Background:    --navy (#1E3A5F)
  Height:        64px
  Shadow:        0 1px 3px rgba(0,0,0,0.15)

Nav items (default):  rgba(255,255,255,0.70) text
Nav items (hover):    rgba(255,255,255,0.90) text + rgba(255,255,255,0.08) bg
Nav items (active):   #FFFFFF text + rgba(255,255,255,0.15) bg, 3px bottom border in --trust-blue

Wordmark:             #FFFFFF, Source Serif Pro 600 18px
Sub-navigation:       --bg-subtle background, 48px height, --text-primary items
```

Sidebar navigation (dashboard views):
- Width: 240px
- Background: `--bg-subtle`
- Border-right: 1px `--border-default`
- Active item: `--trust-blue-muted` background + `--trust-blue` left border (3px) + `--trust-blue` text

### Data Tables

Tables are the heartbeat of enterprise dashboards. They must be immediately readable, scannable, and operationally dense.

```
Table wrapper:   --bg-page bg, 1px --border-default border, 8px radius, shadow (card-level)

Header row:
  Background:    --bg-subtle (#F8FAFC)
  Border-bottom: 2px --border-strong (#94A3B8)
  Text:          Inter 12px, 600 weight, --text-secondary, +0.05em letter-spacing, uppercase
  Padding:       12px 16px

Body rows:
  Odd rows:      --bg-page (#FFFFFF) background
  Even rows:     --bg-muted (#F1F5F9) background
  Hover:         --bg-emphasis (#E2E8F0) background, 100ms
  Border-bottom: 1px --border-light (#E2E8F0)
  Text:          Inter 14px, 400 weight, --text-primary
  Padding:       12px 16px

Sortable headers: chevron icon (neutral gray → trust blue on active)
Selected rows:    --trust-blue-muted background + 2px --trust-blue left border
```

### Badges and Status Indicators

Badges use solid fills — not ghost/outlined variants. In a professional data environment, status must be immediately legible without color interpretation. Solid fills are faster to scan.

```
Badge structure:   4px 10px padding, 4px border-radius, Inter 12px 600, uppercase, +0.03em tracking

Success badge:     --success-bg background, --success text (#059669)
Warning badge:     --warning-bg background, --warning text (#D97706)
Error badge:       --error-bg background, --error text (#DC2626)
Info badge:        --trust-blue-muted background, --trust-blue text
Neutral badge:     --bg-emphasis background, --text-secondary text
```

Status indicators (for service health, deployment state):

```
Filled dot:   8px diameter circle in semantic color
Active:       --success (#059669) dot, no glow, no animation
Warning:      --warning (#D97706) dot, no glow
Error:        --error (#DC2626) dot, no glow
Unknown:      --text-muted (#94A3B8) dot

Label:        Inter 14px, --text-primary, immediately follows dot
```

No glowing, no pulsing, no animations on status dots — except for a single case: "in-progress" states (deployment running, scan executing) may use a slow 2s opacity pulse (0.6 → 1.0 → 0.6). Everything else is static.

### Code Blocks

```
Background:    --bg-muted (#F1F5F9)
Border:        1px --border-default
Border-radius: 6px
Font:          JetBrains Mono 14px
Padding:       16px 20px
Text:          --text-max (#0F172A)
Shadow:        inset 0 1px 2px rgba(0,0,0,0.04)

Inline code:
  Background:  --bg-emphasis (#E2E8F0)
  Border-radius: 4px
  Padding:     2px 6px
  Font:        JetBrains Mono 13px
```

---

## Motion

Corporate Enterprise motion is conservative and purposeful. Motion communicates state transitions — it is not decoration.

| Pattern | Duration | Easing | Notes |
|---------|----------|--------|-------|
| Button hover | 150ms | ease-out | Shadow depth change + color shift |
| Input focus | 150ms | ease-out | Border color + ring expansion |
| Card hover | 150ms | ease-out | Shadow depth change |
| Dropdown open/close | 150ms | ease-out | Opacity + 4px translateY |
| Modal open | 200ms | ease-out | Opacity + scale(0.98 → 1.0) |
| Page transition | 200ms | ease-in-out | Opacity only |
| Skeleton loading | 1500ms | ease-in-out, infinite | Shimmer left-to-right |
| In-progress pulse | 2000ms | ease-in-out, infinite | Opacity 0.6 → 1.0 → 0.6, dots only |

All motion respects `prefers-reduced-motion: reduce`. When reduced motion is active, all transitions are instant (0ms) and the pulse animation is disabled.

No bounce easing. No spring physics. No playful micro-interactions. State changes are crisp — they reflect an environment where operators need to see exactly what changed and when.

Skeleton loaders are preferred over spinners for content-heavy views (tables, dashboards). Spinners are acceptable for single-element loading states (button submitting, inline status refresh).

---

## Brand Identity

### Platform Wordmark: MCP Host

The primary wordmark is set in **Source Serif Pro Semibold (600)** with the letters "MCP" at slightly reduced opacity or weight offset from "Host" to create a two-part reading: the protocol acronym, then the product name. This mirrors the naming conventions of enterprise infrastructure products (AWS EC2, Azure AD, Google GKE).

```
Wordmark (dark bg):  "MCP Host" — "MCP" in rgba(255,255,255,0.80), "Host" in #FFFFFF
Wordmark (light bg): "MCP Host" — "MCP" in --navy-light (#2D4F7C), "Host" in --navy (#1E3A5F)
```

### Logomark

The logomark is a **shield form, rendered institutionally** — not a techy geometric abstraction, but a clean heraldic-adjacent mark that reads as "this organization takes security seriously."

Construction principles:
- Built on 24x24 grid
- Shield silhouette with a horizontal bar bisecting the lower third — reading as both a shield and the letters "MCP" if examined closely (optional, not forced)
- Two colors only: `--navy` and `--trust-blue`
- The trust blue appears as a thin inner line or highlight — suggesting the active/live system inside the institutional shell
- Must read as a clear silhouette at 16px (favicon)
- No gradients in the logomark — flat fills only

### Sub-Product Lockups

Each sub-product uses the platform logomark at 20px × 20px, followed by the product name in Inter Medium (500):

| Surface | Lockup | Accent Treatment |
|---------|--------|-----------------|
| **JustMCP.it** | [mark] + "JustMCP" Inter 500 + ".it" in Operational Teal (#0D9488) | The TLD colored in sub-product accent; wordmark is otherwise navy |
| **MCP Jumpstart** | [mark] + "MCP Jumpstart" Inter 500 | "Jumpstart" in Builder Indigo (#4F46E5); "MCP" in navy |
| **SafeMCP** | [mark] + "SafeMCP" Inter 500 | Full mark and wordmark in platform navy — undifferentiated, because SafeMCP is the platform core |

The logomark is always displayed in `--navy` on light backgrounds and white on `--navy` backgrounds. Sub-product accent colors never appear on the logomark itself.

---

## Voice & Tone

The platform voice is authoritative, measured, and precise. It is the voice of an institution, not a startup.

| Attribute | Do | Do Not |
|-----------|-----|--------|
| **Authoritative** | "Enterprise-grade MCP infrastructure with full audit trails." | "Ship MCP servers fast with our easy platform!" |
| **Precise** | "Dual-principal authorization required for policy modification." | "Double security for extra safety." |
| **Measured** | "Your deployment completes in under 90 seconds." | "Blazing-fast deploys in seconds!!!" |
| **Direct** | "Policy violation detected. Simulation halted." | "Oops! Something went wrong with your policy." |
| **Formal without being stiff** | "Get started with MCP Host." | "Let's get you set up!" |

Headline rules:
- Maximum 10 words in display headlines
- No rhetorical questions
- No exclamation points in body copy
- Technical terms are used correctly and consistently (MCP, OAuth, RBAC — never abbreviated informally)

Error message rules:
- State what happened (past tense, factual)
- State what the user can do (imperative, specific)
- Never apologize — acknowledge and instruct

---

## Accessibility

This direction targets WCAG 2.2 AA as a minimum. Enterprise procurement frequently includes accessibility audits; compliance is a sales requirement, not a nice-to-have.

| Requirement | Implementation |
|-------------|----------------|
| Text contrast (body) | 4.5:1 minimum — `--text-primary` on `--bg-page` = 12.6:1 |
| Text contrast (secondary) | 4.5:1 minimum — `--text-secondary` on `--bg-page` = 6.2:1 |
| UI component contrast | 3:1 minimum for borders, icons, controls |
| Focus indicators | 3px ring in `--trust-blue-border` + `--trust-blue` border shift — visible at 3:1 |
| Touch targets | Minimum 44×44px for all interactive elements |
| Color-only states | Never — every status badge includes a text label alongside color fill |
| Motion | All animations honor `prefers-reduced-motion` |
| Screen readers | All icons have accessible labels; data tables have `<th scope>` |
| Keyboard navigation | Full keyboard operability; focus order matches visual order |

High-contrast defaults: The light-first design naturally produces high contrast ratios. The dark navy navigation bar against white content creates a clear landmark structure that benefits low-vision users.

---

## Anti-Patterns

Enumerate what this direction explicitly rejects:

| Anti-Pattern | Why It Fails Here |
|--------------|------------------|
| Trendy gradients on UI surfaces | Signals "startup," not "infrastructure." Gradients age quickly; navy and white do not. |
| Rounded-everything (>12px radius) | Excessive rounding signals consumer apps. Enterprise data UI needs geometric discipline. |
| Emoji in UI copy | Destroys institutional credibility in an enterprise context. |
| Casual language ("let's go!", "you're all set!") | Violates the authoritative voice register. |
| Dark-mode-only design | Enterprise dashboards default to light; dark-only alienates a significant buyer segment. |
| Glow effects on any element | Glow reads as "gaming" or "crypto." This platform signals security, not aesthetics. |
| Neon or saturated accent colors | Trust Blue and Teal are muted enough to read as professional. Avoid hot pink, lime, etc. |
| Decorative illustrations or mascots | The interface is the product. No illustrated characters or abstract hero art. |
| Shadow excess (multiple heavy shadows) | One subtle shadow per card. Heavy shadow stacks look dated and cluttered. |
| Hairline (1px) fonts below 14px | Inter at 12px requires at least 500 weight; 400 at 12px on light backgrounds risks legibility. |
| Neutral or warm grays | All grays are blue-tinted (slate scale). Warm grays break the cool institutional palette. |
| Dark mode as the default | Light-first. Offer dark mode as a user preference, not a brand choice. |

---

## Dark Mode Variant

Dark mode is supported but light-first. When a user enables dark mode, the following token substitutions apply. Component logic and structure do not change — only the color tokens.

| Light Token | Dark Substitute | Hex |
|-------------|----------------|-----|
| `--bg-page` | Dark canvas | `#0F172A` |
| `--bg-subtle` | Raised surface | `#1E293B` |
| `--bg-muted` | Elevated surface | `#263245` |
| `--bg-emphasis` | Active surface | `#334155` |
| `--border-light` | Dark border light | `#1E293B` |
| `--border-default` | Dark border default | `#334155` |
| `--border-strong` | Dark border strong | `#475569` |
| `--text-max` | Dark text max | `#F1F5F9` |
| `--text-primary` | Dark text primary | `#CBD5E1` |
| `--text-secondary` | Dark text secondary | `#94A3B8` |
| `--text-muted` | Dark text muted | `#475569` |
| `--navy` nav background | Unchanged — navy reads correctly on dark | `#1E3A5F` |
| Card shadows | Reduced opacity (0.3 → 0.15) or border-only | — |

The serif headings read equally well in dark mode — this is a key advantage of Source Serif Pro at heavier weights.
