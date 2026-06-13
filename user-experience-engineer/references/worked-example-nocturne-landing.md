# Worked Example: Nocturne Landing Page for a Developer Tool

> End-to-end walkthrough of designing a dark-native landing page for a CLI observability tool. From design brief through style selection rationale, component inventory, key design decisions, and YAML theme implementation.

---

## 1. Design Brief

### The Product

**Product name:** Siphon
**Tagline:** Real-time log tailing for humans
**What it does:** A CLI tool that ingests logs from multiple sources (Docker, Kubernetes, AWS CloudWatch, systemd), applies intelligent pattern matching, and surfaces anomalies in a TUI dashboard. Think `tail -f` meets an observability platform, in your terminal.
**Price:** Open-source core, $29/month Pro (team features, hosted log aggregation, alerting)
**Website purpose:** Landing page to explain the product, show the TUI in action, convert visitors to either `brew install siphon` (free) or Pro signup (paid).

### Target Audience

- **Primary:** Backend engineers, SREs, platform engineers (25-45, work in terminal daily)
- **Secondary:** DevOps leads evaluating tools for their team
- **Psychographics:** Prefer CLI over GUI. Skeptical of SaaS bloat. Value tools that are fast, composable, and respect their workflow. Spend significant time in dark terminal environments already.

### Goals

1. **Hero clarity** -- Visitor understands what Siphon does within 5 seconds
2. **Trust through demo** -- Animated TUI screenshot or video showing real log tailing
3. **Two-path conversion** -- Free (install command) and Pro (pricing/signup) paths clearly separated
4. **Developer credibility** -- Show benchmarks, supported integrations, and open-source commitment

### Constraints

- Single page (no multi-page marketing site)
- Must load fast (developers are impatient; target < 2s LCP)
- Must look good on both OLED laptops (common among developers) and standard LCD monitors
- No JavaScript-heavy animations -- this audience opens DevTools and judges you

---

## 2. Style Selection Rationale: Why Nocturne

### The Decision

Nocturne is the only viable choice here. This is not a close call. Here is why:

**Audience-environment alignment.** The target users live in dark terminals. Their IDE is dark. Their browser might be the only light-mode thing on screen. A Nocturne landing page matches their working environment -- it does not assault their dark-adapted eyes with a white marketing page.

**Product-style coherence.** Siphon is a TUI tool. Its primary interface IS a dark terminal. The landing page should feel like an extension of the product, not a foreign context. When a developer sees the Nocturne landing page, then sees the Siphon TUI screenshot, there is zero cognitive dissonance.

**Glow as functional metaphor.** Siphon highlights anomalies in log streams. The Nocturne glow system maps directly to this concept -- important things emit light against a dark field. The landing page can use glow to highlight key product features the same way the product uses color to highlight log anomalies.

**Data visualization opportunity.** The landing page needs to show metrics (performance benchmarks, integration counts, pricing tiers). Nocturne's dark canvas makes data visualization sing -- colored charts and numbers against near-black backgrounds are dramatically more readable than on white.

### Styles Considered and Rejected

| Style | Why Rejected |
|-------|-------------|
| Minimal Tech | Too sterile. Developer tools need atmosphere, not just cleanliness. White backgrounds clash with the terminal-native product identity. |
| Swiss Grid | Too corporate/institutional. Signals "enterprise SaaS" when the product signals "hacker tool." |
| Editorial | Text-heavy style for a product that needs to show, not tell. Wrong information density. |
| Gradient Flow | Too playful/consumer-facing. Would undermine the precision and seriousness developers expect from infrastructure tooling. |

### Glow Color Selection

**Plasma Cyan** (`#06B6D4` / bright: `#22D3EE`)

Rationale:
- Signals technology, clarity, precision -- exactly what a dev tool needs
- Maps to the terminal aesthetic (cyan is a standard ANSI color; developers associate it with highlighted output)
- High contrast against the near-black canvas -- passes WCAG AA comfortably
- Avoids the overused "GitHub Copilot purple" and "Vercel blue" that saturate the dev tool space

---

## 3. Component Inventory

### Page Structure (Top to Bottom)

```
┌─────────────────────────────────────────────────────┐
│  NAVBAR                                              │
│  Logo | Features | Integrations | Pricing | GitHub   │
├─────────────────────────────────────────────────────┤
│                                                      │
│  HERO SECTION                                        │
│  Headline + Subheadline                              │
│  Install command (copyable)                          │
│  Animated TUI demo                                   │
│                                                      │
├─────────────────────────────────────────────────────┤
│                                                      │
│  SOCIAL PROOF BAR                                    │
│  GitHub stars | Downloads/week | Contributors         │
│                                                      │
├─────────────────────────────────────────────────────┤
│                                                      │
│  FEATURES (3-column grid)                            │
│  Multi-source | Pattern Matching | Anomaly Detection │
│  Each: icon + title + description                    │
│                                                      │
├─────────────────────────────────────────────────────┤
│                                                      │
│  DEMO SECTION (full-width)                           │
│  Large TUI screenshot with annotation callouts       │
│  Or: embedded asciinema recording                    │
│                                                      │
├─────────────────────────────────────────────────────┤
│                                                      │
│  INTEGRATIONS GRID                                   │
│  Logos: Docker, K8s, AWS, GCP, systemd, Datadog...   │
│                                                      │
├─────────────────────────────────────────────────────┤
│                                                      │
│  BENCHMARKS SECTION                                  │
│  Performance comparison chart (Siphon vs. others)    │
│  Key metrics: startup time, memory, throughput        │
│                                                      │
├─────────────────────────────────────────────────────┤
│                                                      │
│  PRICING (2-column)                                  │
│  Free (install command) | Pro ($29/mo, feature list) │
│                                                      │
├─────────────────────────────────────────────────────┤
│                                                      │
│  FINAL CTA                                           │
│  "Start tailing in 30 seconds"                       │
│  brew install siphon                                 │
│                                                      │
├─────────────────────────────────────────────────────┤
│  FOOTER                                              │
│  GitHub | Docs | Discord | License | Company         │
└─────────────────────────────────────────────────────┘
```

### Component Count

| Component | Instances | Nocturne Treatment |
|-----------|-----------|-------------------|
| Navbar | 1 | Transparent + backdrop-blur, glow on active item |
| Hero headline | 1 | `--text-bright` at display weight (300), large |
| Install command block | 2 (hero + final CTA) | Monospace, `--surface` bg, glow border, copy button |
| TUI demo | 1-2 | Styled terminal frame with ambient glow behind it |
| Feature card | 3 | `--surface-raised` card, glow icon, hover glow border |
| Integration logo | 8-12 | Dimmed to `--text-dim`, brighten on hover |
| Benchmark chart | 1 | Cyan data line with glow drop-shadow on dark canvas |
| Pricing card | 2 | Free: ghost card; Pro: featured card with glow border |
| CTA button | 3-4 | Primary: plasma cyan glow stack; Secondary: outlined |
| Footer | 1 | Minimal, `--text-dim` links, `--mist` top border |
| Social proof stat | 3 | Bright number + dim label, inline |
| Ambient glow | 1-2 | Background radial gradient, slow drift animation |

---

## 4. Key Design Decisions

### 4.1 Hero: Install Command as Primary CTA

**Decision:** The hero's primary CTA is a copyable `brew install siphon` command block, not a "Sign Up" button.

**Rationale:** Developer tool landing pages that lead with "Sign Up" signal SaaS friction. Developers want to try first. The install command IS the conversion event for the free tier. It reduces the path from "interested" to "using" to a single clipboard copy.

**Implementation:**
```
┌──────────────────────────────────────────────┐
│  $ brew install siphon                   [⎘] │
└──────────────────────────────────────────────┘
```

- Monospace font (JetBrains Mono or Berkeley Mono)
- Background: `--surface` (one step above canvas -- recessed, like a terminal)
- Border: `1px solid` transitioning from `--mist` to `--glow` on hover
- Copy button: ghost style, `--text-dim`, glows cyan on click with a brief "Copied!" flash
- The `$` prompt character is `--text-dim` (not selectable)

### 4.2 TUI Demo: Terminal Frame with Ambient Glow

**Decision:** Show the product running inside a styled terminal window frame, with an ambient glow radiating from behind the frame.

**Rationale:** The product IS a terminal interface. Showing it inside a realistic-but-stylized terminal frame creates visual continuity. The ambient glow behind the frame makes the demo feel like a light source -- the product literally glows on the page, which is the Nocturne philosophy of "elements emit light."

**Implementation:**
- Terminal frame: `--surface-raised` background, rounded corners (12px), three colored dots in the title bar (dimmed, not macOS-bright)
- Content: Either a static screenshot with CSS animations for the "live" feel, or an embedded asciinema recording
- Behind the frame: a 120% scale radial gradient of `--glow` at 6-8% opacity, with the slow `drift` animation from the Nocturne atmospheric effects spec
- On scroll-into-view: the glow fades in over 800ms (not the content -- the atmospheric glow behind it)

### 4.3 Feature Cards: Icon Glow as Category Signal

**Decision:** Each feature card has a single glow-tinted icon that represents the feature category. The icon glows subtly at rest and intensifies on hover.

**Rationale:** In Nocturne, brightness is currency. The icons serve as visual anchors in a dark field. By keeping them at a low glow at rest (glow color at 40% opacity), they draw the eye without spending the luminosity budget. On hover, the full glow activates, creating the "light responds to attention" feel.

**Card structure:**
```
┌────────────────────────────┐
│                            │
│     ◉ [glow icon]         │  ← 32px icon, --glow at 40%, brightens on hover
│                            │
│  Multi-Source Ingestion    │  ← --text-primary, font-weight 500
│                            │
│  Tail Docker, Kubernetes,  │  ← --text-secondary, font-weight 400
│  CloudWatch, systemd, and  │
│  custom sources. One tool. │
│                            │
└────────────────────────────┘
```

- Card: `--surface-raised` background, `1px solid --mist` border, 12px radius
- Hover: border transitions to `color-mix(in srgb, var(--glow) 40%, var(--mist))`, subtle bloom `box-shadow`
- Spacing: 28px internal padding (Nocturne spec -- generous, dark cards need air)
- Grid: 3 columns on desktop, 1 on mobile, 24px gap

### 4.4 Benchmarks: Data Visualization on Dark Canvas

**Decision:** Show performance benchmarks as a horizontal bar chart with glow-treated data bars.

**Rationale:** This is where Nocturne's data visualization strength pays off. Colored bars against a dark canvas are dramatically more readable than on white. The glow treatment on the bars makes the data feel alive, not just informative.

**Implementation:**
```
Startup time (ms)
  Siphon    ████████░░░░░░░░░░░░  120ms  ← --glow bar + drop-shadow glow
  Tool A    ██████████████░░░░░░  340ms  ← --text-dim bar, no glow
  Tool B    ████████████████████  520ms  ← --text-dim bar, no glow

Memory usage (MB)
  Siphon    ███░░░░░░░░░░░░░░░░░   18MB
  Tool A    ██████████░░░░░░░░░░   62MB
  Tool B    ███████████████░░░░░  145MB
```

- Siphon's bars: `--glow` fill with `drop-shadow(0 0 4px var(--glow) at 40%)` -- they emit light
- Competitor bars: `--fog` fill, no glow -- present but visually subordinate
- Labels: `--text-dim` for metric names, `--text-primary` for values
- Grid lines: `--mist` at 50% opacity (barely visible, as spec requires)
- No chart container/border -- data floats directly on the canvas

### 4.5 Pricing: Ghost vs. Featured Card

**Decision:** Two pricing cards. Free is a ghost-style card (transparent background, `--fog` border). Pro is a featured card with glow treatment.

**Rationale:** The luminosity hierarchy does the selling. The Pro card glows -- it is literally the brighter option. The Free card is present and accessible but does not compete for attention. This avoids the heavy-handed "MOST POPULAR" badge pattern while achieving the same effect through pure visual hierarchy.

**Free card:**
```
┌─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┐
  Free                        ← --text-primary
  $0 forever                  ← --text-secondary

  ✓ Multi-source ingestion    ← --text-secondary, checkmark in --glow at 60%
  ✓ Pattern matching
  ✓ TUI dashboard
  ✓ Community support

  [brew install siphon]       ← secondary button (outlined)
└─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┘
```

**Pro card:**
```
┌───────────────────────────┐  ← glow-tinted border
│  Pro                      │  ← --text-bright
│  $29/month                │  ← --glow color
│                           │
│  Everything in Free, plus:│
│  ✓ Team log aggregation   │  ← checkmarks in full --glow
│  ✓ Smart alerting         │
│  ✓ Historical search      │
│  ✓ SSO + RBAC             │
│  ✓ Priority support       │
│                           │
│  [Start 14-day trial →]   │  ← PRIMARY button (full glow stack)
└───────────────────────────┘
```

Pro card uses the featured card pattern from the Nocturne spec: `radial-gradient(ellipse at top, glow 8% mixed with surface-raised, surface-raised 70%)` background, glow-tinted border.

### 4.6 Integration Logos: Dim-to-Bright on Hover

**Decision:** Integration logos (Docker, Kubernetes, AWS, etc.) are displayed at low luminosity (`--text-dim` / 40% opacity) and brighten to full on hover.

**Rationale:** A grid of 8-12 full-brightness logos would destroy the luminosity budget. Dimming them respects the dark canvas while still communicating breadth. The hover-brighten effect invites exploration without visual noise.

**Implementation:**
- Logo grid: 4-6 columns, centered, 32px gap
- SVG logos: filled with `--text-dim`, transition to `--text-primary` on hover (200ms ease-out)
- On hover: add subtle glow underneath (`box-shadow: 0 0 16px var(--glow) at 8%`)
- `grayscale(1)` filter at rest, `grayscale(0)` on hover (optional -- depends on whether brand colors add value)

### 4.7 Ambient Glow Placement

**Decision:** Two ambient glow elements. One behind the hero (top-center, drifting slowly). One behind the pricing section (bottom-center, static).

**Rationale:** Nocturne's atmospheric effects spec calls for ambient glow that gives the canvas life. Two placements create a subtle visual rhythm -- the page breathes. Placing them behind the two conversion-critical sections (hero and pricing) subconsciously draws attention.

**Implementation:**
- Hero glow: 800px diameter, `--glow` at 4%, `drift` animation (20s cycle), positioned behind the TUI demo
- Pricing glow: 600px diameter, `--glow` at 3%, static (no animation -- the pricing section is lower energy)
- Both: `pointer-events: none`, `z-index: 0`, `position: absolute` within their section
- Both: hidden under `prefers-reduced-motion: reduce` (spec requirement)

---

## 5. YAML Theme Implementation

### File Structure

```
src/config/theme-siphon/
├── style-guide.meta.yaml              # Theme identity
├── style-guide.vars.yaml              # Core CSS custom properties
├── style-guide.color-palette.yaml     # Nocturne palette definition
├── style-guide.color-modes.yaml       # Dark-only (no light mode)
├── style-guide.typography.yaml        # Font stack, scale, weights
├── style-guide.spacing.yaml           # 8px base, Nocturne-generous spacing
├── style-guide.globals.yaml           # Global resets and defaults
├── style-guide.semantic-classes.yaml  # Utility classes
├── style-guide.css-snippets.yaml      # Glow stacks, ambient effects
├── style-guide.glyphs.yaml            # Icon treatment
├── style-guide.branding.yaml          # Logo, favicon
└── style-guide.page-sections.yaml     # Section-level layout
```

### Key YAML Excerpts

**style-guide.meta.yaml**
```yaml
theme:
  name: siphon
  display_name: "Siphon"
  description: "Dark-native landing page for a CLI observability tool"
  style: nocturne
  glow_color: plasma-cyan
  version: "1.0.0"
```

**style-guide.vars.yaml** (seed values -- the cascade fills the rest)
```yaml
vars:
  # Canvas
  --canvas: "#0C0C10"
  --surface: "#18181F"
  --surface-raised: "#23232E"
  --void: "#09090B"

  # Borders
  --mist: "#2A2A3A"
  --fog: "#3A3A4F"

  # Text hierarchy (luminosity steps)
  --text-dim: "#5C5C72"
  --text-secondary: "#8888A0"
  --text-primary: "#CDCDE0"
  --text-bright: "#EDEDF4"
  --text-max: "#FFFFFF"

  # Glow system (Plasma Cyan)
  --glow: "#06B6D4"
  --glow-bright: "#22D3EE"
  --glow-ambient: "color-mix(in srgb, #06B6D4 8%, transparent)"
  --glow-halo: "color-mix(in srgb, #06B6D4 30%, transparent)"

  # Semantics
  --success: "#4ADE80"
  --warning: "#FACC15"
  --error: "#F87171"
  --info: "#60A5FA"

  # Radii (softer than Minimal Tech per Nocturne spec)
  --radius-sm: "6px"
  --radius-md: "8px"
  --radius-lg: "12px"
  --radius-xl: "16px"
```

**style-guide.typography.yaml**
```yaml
typography:
  font_family:
    primary: "'Inter', system-ui, -apple-system, sans-serif"
    mono: "'JetBrains Mono', 'Berkeley Mono', 'Cascadia Code', monospace"

  scale:
    display:
      size: "56px"
      weight: 300
      line_height: 1.05
      letter_spacing: "-0.02em"
      color: "var(--text-bright)"
    h1:
      size: "36px"
      weight: 400
      line_height: 1.15
      color: "var(--text-primary)"
    h2:
      size: "24px"
      weight: 500
      line_height: 1.25
      color: "var(--text-primary)"
    body:
      size: "16px"
      weight: 400
      line_height: 1.65
      letter_spacing: "0.01em"
      color: "var(--text-secondary)"
    caption:
      size: "12px"
      weight: 400
      line_height: 1.4
      letter_spacing: "0.02em"
      color: "var(--text-dim)"
    code:
      size: "14px"
      weight: 400
      line_height: 1.5
      font_family: "var(--font-mono)"
      color: "color-mix(in srgb, var(--glow) 80%, var(--text-primary))"

  # Nocturne-specific: reduce weight by one step vs light-native
  notes: |
    Font weights are intentionally lighter than typical. On dark backgrounds,
    light text appears heavier due to irradiation illusion. 300 for display,
    400 for body, 500 max for headings.
```

**style-guide.css-snippets.yaml** (Nocturne-specific effects)
```yaml
snippets:
  glow-stack-primary:
    description: "Full glow stack for primary CTA buttons"
    css: |
      box-shadow:
        0 0 1px var(--glow),
        0 0 12px color-mix(in srgb, var(--glow) 30%, transparent);
    hover: |
      box-shadow:
        0 0 1px var(--glow),
        0 0 20px color-mix(in srgb, var(--glow) 45%, transparent);
      transform: translateY(-1px);

  glow-stack-focus:
    description: "Focus ring with glow bloom"
    css: |
      outline: 2px solid var(--glow);
      outline-offset: 2px;
      box-shadow: 0 0 8px color-mix(in srgb, var(--glow) 25%, transparent);

  ambient-glow:
    description: "Background atmospheric glow element"
    css: |
      position: absolute;
      width: 800px;
      height: 800px;
      border-radius: 50%;
      background: radial-gradient(
        circle,
        color-mix(in srgb, var(--glow) 4%, transparent),
        transparent 70%
      );
      pointer-events: none;
      z-index: 0;
      animation: drift 20s ease-in-out infinite alternate;
    reduced_motion: "animation: none;"

  terminal-frame:
    description: "Styled terminal window for TUI screenshots"
    css: |
      background: var(--surface-raised);
      border: 1px solid var(--mist);
      border-radius: var(--radius-lg);
      padding: 0;
      overflow: hidden;
    titlebar: |
      height: 36px;
      background: var(--surface);
      border-bottom: 1px solid var(--mist);
      display: flex;
      align-items: center;
      padding: 0 12px;
      gap: 8px;
    dots: |
      width: 12px;
      height: 12px;
      border-radius: 50%;
      /* Dimmed dots -- not macOS-bright */
      &:nth-child(1) { background: color-mix(in srgb, #F87171 50%, var(--surface)); }
      &:nth-child(2) { background: color-mix(in srgb, #FACC15 50%, var(--surface)); }
      &:nth-child(3) { background: color-mix(in srgb, #4ADE80 50%, var(--surface)); }

  install-command:
    description: "Copyable CLI install command block"
    css: |
      background: var(--surface);
      border: 1px solid var(--mist);
      border-radius: var(--radius-md);
      padding: 14px 20px;
      font-family: var(--font-mono);
      font-size: 16px;
      color: var(--text-primary);
      display: flex;
      align-items: center;
      justify-content: space-between;
      transition: border-color 0.2s, box-shadow 0.2s;
    hover: |
      border-color: var(--glow);
      box-shadow: 0 0 12px color-mix(in srgb, var(--glow) 10%, transparent);
    prompt_char: |
      color: var(--text-dim);
      user-select: none;
      margin-right: 8px;
```

**style-guide.spacing.yaml**
```yaml
spacing:
  base: "8px"
  scale:
    micro: "4px"
    xs: "8px"
    sm: "12px"
    md: "16px"
    lg: "24px"
    xl: "32px"
    2xl: "48px"
    3xl: "64px"
    4xl: "96px"

  section_vertical: "80px"
  card_padding: "28px"
  card_internal_gap: "20px"
  glow_clearance: "16px"

  grid:
    mobile:
      columns: 4
      gutter: "16px"
      margin: "16px"
    tablet:
      columns: 8
      gutter: "24px"
      margin: "32px"
    desktop:
      columns: 12
      gutter: "28px"
      margin: "80px"
    wide:
      columns: 12
      gutter: "32px"
      max_width: "1400px"

  notes: |
    Nocturne requires ~25% more vertical spacing than light-native designs.
    Section spacing at 80px minimum. Card padding at 28px. Glow elements
    need 16px minimum clearance from neighbors so halos don't collide.
```

---

## 6. Accessibility Notes

### Contrast Verification

All critical text pairs verified against the Nocturne palette:

| Element | Foreground | Background | Ratio | Pass |
|---------|-----------|------------|-------|------|
| Body text | `--text-secondary` (#8888A0) | `--canvas` (#0C0C10) | 5.2:1 | AA |
| Headings | `--text-primary` (#CDCDE0) | `--canvas` (#0C0C10) | 11.4:1 | AAA |
| Feature card text | `--text-secondary` (#8888A0) | `--surface-raised` (#23232E) | 3.8:1 | AA (18px+) |
| Caption/metadata | `--text-dim` (#5C5C72) | `--canvas` (#0C0C10) | 3.4:1 | Large text only |
| Glow CTA text | `--void` (#09090B) | `--glow` (#06B6D4) | 5.8:1 | AA |

**Note:** `--text-dim` on `--surface-raised` only reaches 2.8:1 -- use `--text-secondary` minimum for any readable content on card backgrounds. `--text-dim` is reserved for decorative labels and metadata at 14px+ only.

### Reduced Motion

Every animated element degrades gracefully:

| Element | Full Motion | Reduced Motion |
|---------|------------|----------------|
| Ambient glow drift | 20s ease-in-out cycle | Static position, no animation |
| Hover glow intensify | 200ms ease-out | Instant state change, no glow bloom |
| Scroll-reveal glow fade | 800ms opacity | Content visible immediately |
| Install command copy flash | Brief cyan flash | Solid "Copied!" text, no flash |

### Keyboard Navigation

- All CTAs reachable via Tab
- Focus ring: `2px solid var(--glow)` + `outline-offset: 2px` + glow bloom (bloom removed under reduced motion, solid outline kept)
- Install command block: focusable, Enter triggers copy
- Skip link: present, targets `#main-content`

---

## 7. Implementation Checklist (Nocturne-Specific)

Before launch, verify against the full Nocturne implementation checklist from the style spec:

- [ ] Canvas is near-black (#0C0C10), not gray, not pure black
- [ ] 5+ luminosity steps visible: dim, secondary, primary, bright, max
- [ ] Plasma Cyan glow used consistently as the single accent
- [ ] Glow stack on primary CTA: crisp edge + inner halo + outer bloom
- [ ] Body text uses `--text-secondary`, not white
- [ ] Display headline weight is 300 (lighter than typical -- irradiation compensation)
- [ ] Card padding is 28px (25% more than light-native equivalent)
- [ ] Depth communicated by brightness stepping (canvas < surface < surface-raised), not shadows
- [ ] All contrast ratios pass WCAG 2.2 AA
- [ ] Focus ring is glow + solid outline, clearly visible
- [ ] All ambient motion respects `prefers-reduced-motion`
- [ ] Glow elements have 16px clearance from neighbors
- [ ] No large bright fills -- max bright area is button-sized
- [ ] Error states (if any forms) use semantic glow, not background color change
- [ ] Tested on OLED and LCD screens (true black vs. backlight bleed differences)

---

*For the Nocturne style specification, see [styles/nocturne.md](styles/nocturne.md). For the YAML theme system and CSS generation pipeline, see [outputs/engine-styleguide.md](outputs/engine-styleguide.md). For landing page patterns and conversion frameworks, see [outputs/landing-pages.md](outputs/landing-pages.md).*

---

*Version: 0.1.0*
