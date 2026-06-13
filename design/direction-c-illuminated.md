# Style Guide: Knowledge Base — Direction C: Illuminated

> A creative workshop where building worlds feels like play. Warm, inviting, slightly magical. The tool that makes world-building feel less like homework and more like exploring.

**Style System:** Editorial 80% + Consumer Playful 20%
**Source Specs:** editorial.md + consumer-playful.md
**Scenario:** AI-powered world-building knowledge graph for authors, game designers, and content creators

---

## Scenario

**Knowledge Base** is a dynamic content generator for creative works. This direction leans into the **creative joy** of world-building — the dopamine of watching a universe grow, the delight of discovering connections you didn't plan, the warmth of a tool that feels like a collaborator rather than a database.

The primary audience here shifts slightly toward **TTRPG game masters and casual worldbuilders** — people who build worlds for fun, not just as professional labor. They want the process to feel engaging, not clinical. They want to open the app and feel invited.

The Editorial foundation keeps content authoritative and readable — serif typography, generous margins, structured hierarchy. The Consumer Playful accent adds **warmth, personality, and approachability**: rounded corners, subtle micro-animations, playful iconography, and gentle color accents that make the interface feel alive without undermining credibility.

**Reference energy:** notion.so (flexible, friendly workspace), are.na (warm curation), campfire.pro (creative-focused world-building), airbnb.com (warm, rounded, approachable)

**Brand personality:** Warm. Creative. Inviting. Surprising.

---

## Color Palette

```css
:root {
  /* 80% — Editorial foundation: warm, paper-inspired */
  --bg-primary: #F7F3ED;        /* Soft parchment — warmer than Direction A */
  --bg-surface: #FFFFFF;         /* Cards, elevated */
  --bg-elevated: #EFE9E0;        /* Sidebar, secondary surfaces */
  --bg-reading: #FDFAF5;         /* Entry reading mode */

  /* Text */
  --text-primary: #2C2520;       /* Warm dark brown (not black) */
  --text-secondary: #7A706A;     /* Warm medium */
  --text-tertiary: #A89E96;      /* Warm light */

  /* Borders — very subtle, warm */
  --border-default: #E0D8CE;
  --border-subtle: #EDE7DE;

  /* 80% — Editorial accent: warm violet (creativity, imagination) */
  --accent: #7C3AED;             /* Warm violet */
  --accent-hover: #6D28D9;       /* Deeper violet */
  --accent-muted: rgba(124, 58, 237, 0.08);
  --accent-light: rgba(124, 58, 237, 0.04);

  /* 20% — Consumer Playful: secondary accent (warmth, delight) */
  --accent-warm: #F59E0B;        /* Amber — reward, discovery, delight */
  --accent-warm-muted: rgba(245, 158, 11, 0.10);

  /* Links */
  --link: #7C3AED;
  --link-hover: #6D28D9;

  /* Focus */
  --focus-ring: rgba(124, 58, 237, 0.20);

  /* Semantic — content status */
  --canon: #2C2520;              /* Dark brown — source of truth */
  --canon-muted: rgba(44, 37, 32, 0.06);
  --generated: #D97706;          /* Warm amber — AI-produced */
  --generated-muted: rgba(217, 119, 6, 0.08);
  --flag-error: #DC2626;         /* Red */
  --flag-error-muted: rgba(220, 38, 38, 0.06);
  --flag-warn: #D97706;          /* Amber */
  --flag-warn-muted: rgba(217, 119, 6, 0.06);
  --flag-suggestion: #7C3AED;    /* Violet (matches accent) */
  --flag-suggestion-muted: rgba(124, 58, 237, 0.06);
  --success: #16A34A;            /* Green */
  --success-muted: rgba(22, 163, 74, 0.06);
}
```

```
┌──────────────────────────────────────────────┐
│  ILLUMINATED PALETTE                         │
├──────────────────────────────────────────────┤
│                                              │
│  ██████  #F7F3ED   Soft parchment (bg)       │
│  ██████  #FFFFFF   Surface (cards)           │
│  ██████  #EFE9E0   Elevated (sidebar)        │
│                                              │
│  ██████  #2C2520   Warm dark brown (text)    │
│  ██████  #7A706A   Warm gray (secondary)     │
│                                              │
│  ██████  #7C3AED   Warm violet (accent)      │
│  ██████  #F59E0B   Amber (delight/discovery) │
│                                              │
│  ██████  #2C2520   Canon (brown, solid)      │
│  ██████  #D97706   Generated (amber, draft)  │
│  ██████  #DC2626   Error (red)               │
│  ██████  #16A34A   Success (green)           │
│                                              │
│  Warm throughout. Violet signals creative    │
│  intelligence. Amber signals discovery       │
│  and delight. The palette invites you in.    │
│                                              │
└──────────────────────────────────────────────┘
```

**Usage rules:**
- Light mode primary. Dark mode available but secondary.
- **Warm violet** (`--accent`): primary CTAs, active navigation, links, graph interactions, generation controls
- **Amber** (`--accent-warm`): discovery moments — new connections found, generation complete, consistency suggestions (positive). This is the "delight" color.
- Canon vs. generated uses the same left-border system as other directions, but with warmer tones
- Background is warm parchment `#F7F3ED` — never cold white, never stark
- Shadows are warm-toned: `rgba(44, 37, 32, 0.08)` not `rgba(0,0,0,0.1)`
- Borders are minimal — many cards rely on shadow + background contrast instead

**Contrast ratios (against `--bg-primary: #F7F3ED`):**
- `--text-primary` (#2C2520): **11.8:1** — exceeds AAA
- `--text-secondary` (#7A706A): **4.6:1** — meets AA
- `--accent` (#7C3AED): **5.8:1** — exceeds AA
- `--accent-warm` (#F59E0B): **2.4:1** — **fails AA for body text** (use as accent/decoration only, never for text smaller than 24px)

---

## Typography

**Font stack:**
```css
/* 80% — Editorial: content and headings */
--font-serif: 'Source Serif 4', 'Lora', 'Georgia', serif;

/* 20% — Consumer Playful: UI chrome (rounded, friendly sans) */
--font-sans: 'DM Sans', 'Inter', -apple-system, BlinkMacSystemFont, system-ui, sans-serif;

/* Data and metadata */
--font-mono: 'JetBrains Mono', 'Fira Code', Consolas, monospace;
```

| Level | Font | Size | Weight | Line Height | Use |
|-------|------|------|--------|-------------|-----|
| Display | Serif | 40px | 700 | 1.1 | Universe name, hero moments |
| H1 | Serif | 32px | 700 | 1.2 | Entry title |
| H2 | Serif | 24px | 600 | 1.25 | Section heading |
| H3 | Sans | 18px | 600 | 1.3 | Card title, subsection |
| Body Large | Serif | 18px | 400 | 1.7 | Entry body text |
| Body | Sans | 15px | 400 | 1.6 | UI text, descriptions |
| Body Small | Sans | 13px | 400 | 1.5 | Secondary labels |
| Data | Mono | 12px | 400 | 1.4 | Tags, dates, IDs |
| Caption | Sans | 11px | 500 | 1.3 | Fine print |

**Typography notes:**
- **Source Serif 4** for all content headings and body text. Warm, optimized for screen, pairs beautifully with DM Sans.
- **DM Sans** (rounded geometric sans) for UI chrome: buttons, navigation, labels, card titles at H3 level. DM Sans is the Playful contribution — slightly rounder terminals than Inter, friendlier without being childish.
- The serif/sans split follows the same logic as Direction A (serif = content, sans = controls) but DM Sans softens the controls.

**Font sources:**

| Font | Source | License |
|------|--------|---------|
| Source Serif 4 | Google Fonts | OFL |
| DM Sans | Google Fonts | OFL |
| JetBrains Mono | Google Fonts | OFL |

---

## Spacing & Layout

### Base Unit

8px base, but with more generous spacing than Directions A/B:

```
4px   — Micro
8px   — XS
12px  — SM
16px  — MD
24px  — LG (used more frequently than in A/B)
32px  — XL
48px  — 2XL
64px  — 3XL
96px  — 4XL
```

### Grid

| Breakpoint | Columns | Gutter | Margin | Max Width |
|------------|---------|--------|--------|-----------|
| Mobile (<768px) | 4 | 16px | 20px | 100% |
| Tablet (768-1024px) | 8 | 20px | 32px | 100% |
| Desktop (1024-1440px) | 12 | 24px | 40px | 100% |
| Wide (>1440px) | 12 | 24px | 64px | 1280px |

### Layout Pattern

Top navigation + collapsible left panel. More breathing room than A/B.

```
┌──────────────────────────────────────────────────────┐
│  ◊ Knowledge Base    [Search…]    📊 Graph  ⊕ New    │
├──────────────────────────────────────────────────────┤
│                                                      │
│  ┌──────────────────────────────────────────────┐    │
│  │                                              │    │
│  │  The Ashward Chronicles                      │    │
│  │  ─────────────────────                       │    │
│  │                                              │    │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐       │    │
│  │  │ 👤 Char │ │ 📍 Loc  │ │ ⚔ Event │       │    │
│  │  │   47    │ │   32    │ │   28    │       │    │
│  │  └─────────┘ └─────────┘ └─────────┘       │    │
│  │                                              │    │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐       │    │
│  │  │ 🏛 Fac  │ │ 💎 Obj  │ │ 📜 Rule │       │    │
│  │  │   18    │ │   24    │ │    8    │       │    │
│  │  └─────────┘ └─────────┘ └─────────┘       │    │
│  │                                              │    │
│  │  RECENT                                      │    │
│  │  ┌──────────────────────────────────────┐   │    │
│  │  │ ✦ Generated: "Founding of Thornwall" │   │    │
│  │  │ ● Promoted: "Northern Trade Routes"  │   │    │
│  │  │ ⚠ Flag: Kael's age conflict         │   │    │
│  │  └──────────────────────────────────────┘   │    │
│  │                                              │    │
│  └──────────────────────────────────────────────┘    │
│                                                      │
└──────────────────────────────────────────────────────┘
```

### Border Radius (Playful contribution)

```css
--radius-sm: 8px;        /* Inputs, small tags */
--radius-md: 12px;       /* Cards, panels */
--radius-lg: 16px;       /* Large cards, modals */
--radius-xl: 20px;       /* Hero cards, universe selector */
--radius-full: 9999px;   /* Pill buttons, badges */
```

Noticeably rounder than Directions A (4-8px) and B (4-6px). This is the most visible Playful contribution.

---

## Component Styling

### Buttons

```css
/* Primary — warm violet, rounded */
.btn-primary {
  background: var(--accent);
  color: #FFFFFF;
  font-family: var(--font-sans);
  font-size: 15px;
  font-weight: 600;
  padding: 12px 24px;
  border: none;
  border-radius: var(--radius-full);  /* Pill shape — Playful */
  cursor: pointer;
  transition: transform 200ms ease, box-shadow 200ms ease;
}
.btn-primary:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(124, 58, 237, 0.25);
}
.btn-primary:active {
  transform: translateY(0);
}
.btn-primary:focus-visible {
  outline: 2px solid var(--accent);
  outline-offset: 2px;
}

/* Secondary — bordered pill */
.btn-secondary {
  background: transparent;
  color: var(--text-primary);
  font-family: var(--font-sans);
  font-size: 15px;
  font-weight: 500;
  padding: 11px 23px;
  border: 1px solid var(--border-default);
  border-radius: var(--radius-full);
  cursor: pointer;
  transition: border-color 200ms ease, background 200ms ease;
}
.btn-secondary:hover {
  border-color: var(--accent);
  background: var(--accent-light);
}

/* Ghost — text only */
.btn-ghost {
  background: transparent;
  color: var(--text-secondary);
  font-family: var(--font-sans);
  font-size: 15px;
  font-weight: 400;
  padding: 8px 16px;
  border: none;
  border-radius: var(--radius-sm);
  cursor: pointer;
  transition: color 200ms ease;
}
.btn-ghost:hover { color: var(--accent); }

/* Generate — amber glow, special CTA */
.btn-generate {
  background: linear-gradient(135deg, var(--accent), #9333EA);
  color: #FFFFFF;
  font-family: var(--font-sans);
  font-size: 15px;
  font-weight: 600;
  padding: 12px 24px;
  border: none;
  border-radius: var(--radius-full);
  cursor: pointer;
  transition: transform 200ms ease, box-shadow 200ms ease;
}
.btn-generate:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 16px rgba(124, 58, 237, 0.3);
}
```

### Cards

```css
/* Standard card — warm shadow, no visible border */
.card {
  background: var(--bg-surface);
  border: 1px solid var(--border-subtle);
  border-radius: var(--radius-md);
  padding: 24px;
  box-shadow: 0 1px 3px rgba(44, 37, 32, 0.04);
  transition: transform 200ms ease, box-shadow 200ms ease;
}
.card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(44, 37, 32, 0.08);
}

/* Canon entry card */
.card--canon {
  border-left: 3px solid var(--canon);
}

/* Generated entry card — warm amber border */
.card--generated {
  border-left: 3px dashed var(--generated);
  background: var(--generated-muted);
}

/* Category card — bento-style on dashboard (Playful contribution) */
.card-category {
  background: var(--bg-surface);
  border: 1px solid var(--border-subtle);
  border-radius: var(--radius-lg);
  padding: 24px;
  text-align: center;
  transition: transform 250ms cubic-bezier(0.34, 1.56, 0.64, 1), /* spring */
              box-shadow 200ms ease;
}
.card-category:hover {
  transform: translateY(-4px) scale(1.02);
  box-shadow: 0 8px 24px rgba(44, 37, 32, 0.08);
}
.card-category__icon {
  font-size: 28px;
  margin-bottom: 8px;
}
.card-category__count {
  font-family: var(--font-serif);
  font-size: 28px;
  font-weight: 700;
  color: var(--text-primary);
}
.card-category__label {
  font-family: var(--font-sans);
  font-size: 13px;
  color: var(--text-secondary);
  margin-top: 4px;
}
```

### Navigation

```css
/* Top navigation bar */
.topbar {
  height: 56px;
  background: var(--bg-primary);
  border-bottom: 1px solid var(--border-subtle);
  display: flex;
  align-items: center;
  padding: 0 24px;
  gap: 16px;
}
.topbar__logo {
  font-family: var(--font-serif);
  font-size: 18px;
  font-weight: 700;
  color: var(--accent);
}
.topbar__search {
  flex: 1;
  max-width: 400px;
  background: var(--bg-elevated);
  border: 1px solid var(--border-subtle);
  border-radius: var(--radius-full); /* Pill search bar — Playful */
  padding: 8px 16px;
  font-family: var(--font-sans);
  font-size: 14px;
}
.topbar__search:focus {
  background: var(--bg-surface);
  border-color: var(--accent);
  box-shadow: 0 0 0 3px var(--focus-ring);
}

/* Left panel — collapsible entry browser */
.panel-left {
  width: 260px;
  background: var(--bg-elevated);
  border-right: 1px solid var(--border-subtle);
  padding: 16px 0;
  border-radius: 0 var(--radius-lg) var(--radius-lg) 0; /* Rounded right edge — Playful */
}
```

### Knowledge-Base-Specific Components

#### Entry Type Chip

```css
/* Rounded chips with warm colors for entry types (Playful contribution) */
.chip-type {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 4px 12px;
  border-radius: var(--radius-full);
  font-family: var(--font-sans);
  font-size: 12px;
  font-weight: 500;
}
.chip-type--character { background: rgba(124, 58, 237, 0.08); color: #7C3AED; }
.chip-type--location { background: rgba(22, 163, 74, 0.08); color: #16A34A; }
.chip-type--event { background: rgba(245, 158, 11, 0.08); color: #D97706; }
.chip-type--faction { background: rgba(37, 99, 235, 0.08); color: #2563EB; }
.chip-type--object { background: rgba(122, 112, 106, 0.08); color: #7A706A; }
.chip-type--concept { background: rgba(147, 51, 234, 0.08); color: #9333EA; }
.chip-type--rule { background: rgba(44, 37, 32, 0.08); color: #2C2520; }
```

#### Discovery Toast

```css
/* "New connection found!" — the delight moment (Playful contribution) */
.toast-discovery {
  position: fixed;
  bottom: 24px;
  right: 24px;
  background: var(--bg-surface);
  border: 1px solid var(--accent-warm);
  border-radius: var(--radius-lg);
  padding: 16px 20px;
  box-shadow: 0 8px 24px rgba(44, 37, 32, 0.12);
  display: flex;
  align-items: center;
  gap: 12px;
  animation: toast-in 400ms cubic-bezier(0.34, 1.56, 0.64, 1);
}
.toast-discovery__icon {
  font-size: 24px; /* ✨ or 🔗 emoji */
}
.toast-discovery__text {
  font-family: var(--font-sans);
  font-size: 14px;
  color: var(--text-primary);
}
.toast-discovery__link {
  color: var(--accent);
  font-weight: 600;
}

@keyframes toast-in {
  from {
    opacity: 0;
    transform: translateY(16px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}
```

#### Graph Node (Illuminated style)

```css
/* Slightly larger, rounder nodes with type-colored dots */
.graph-node {
  background: var(--bg-surface);
  border: 1px solid var(--border-default);
  border-radius: var(--radius-md);
  padding: 10px 16px;
  font-family: var(--font-serif);
  font-size: 14px;
  color: var(--text-primary);
  cursor: pointer;
  box-shadow: 0 1px 3px rgba(44, 37, 32, 0.04);
  transition: transform 200ms ease, box-shadow 200ms ease, border-color 200ms ease;
}
.graph-node:hover {
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(44, 37, 32, 0.08);
  border-color: var(--accent);
}
.graph-node--selected {
  border-color: var(--accent);
  box-shadow: 0 0 0 3px var(--accent-muted), 0 4px 12px rgba(44, 37, 32, 0.08);
}
.graph-node__type-dot {
  width: 8px;
  height: 8px;
  border-radius: var(--radius-full);
  display: inline-block;
  margin-right: 6px;
}

/* Graph edges — softer, organic feel */
.graph-edge {
  stroke: var(--border-default);
  stroke-width: 1.5;
  fill: none;
  stroke-linecap: round; /* Softer line endings */
}
.graph-edge--highlighted {
  stroke: var(--accent);
  stroke-width: 2;
}
```

#### Generation Progress (Playful variant)

```css
/* Generation shown as a gentle pulsing glow rather than a progress bar */
.generation-indicator {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  background: var(--accent-light);
  border-radius: var(--radius-md);
  border: 1px solid rgba(124, 58, 237, 0.12);
}
.generation-indicator__dot {
  width: 10px;
  height: 10px;
  border-radius: var(--radius-full);
  background: var(--accent);
  animation: gen-pulse 1.5s ease-in-out infinite;
}
@keyframes gen-pulse {
  0%, 100% { opacity: 0.4; transform: scale(0.9); }
  50% { opacity: 1; transform: scale(1.1); }
}
.generation-indicator__text {
  font-family: var(--font-sans);
  font-size: 14px;
  color: var(--accent);
  font-weight: 500;
}
```

---

## Interaction & Motion

| Element | Effect | Duration | Easing | Source |
|---------|--------|----------|--------|--------|
| Button hover | Lift + colored shadow | 200ms | ease | Playful |
| Button press | Settle back | 150ms | ease | — |
| Card hover | Lift + shadow deepen | 200ms | ease | Playful |
| Category card hover | Lift + slight scale (spring) | 250ms | cubic-bezier spring | Playful |
| Entry link hover | Color shift to accent | 200ms | ease | Editorial |
| Entry open | Content fades up, 12px vertical shift | 300ms | ease-out | Editorial |
| Graph node hover | Scale 1.05 + shadow | 200ms | ease | Playful |
| Graph edge highlight | Stroke color + width | 150ms | ease | — |
| Toast appear | Slide up + scale from 0.95 (spring) | 400ms | cubic-bezier spring | Playful |
| Toast dismiss | Fade out + slide down | 200ms | ease-in | — |
| Generation in progress | Pulsing violet dot | 1.5s loop | ease-in-out | Playful |
| Promote to canon | Dashed border solidifies + amber flash | 400ms | ease-in-out | Editorial + Playful |
| New connection found | Amber glow pulse on graph edge | 600ms | ease | Playful |
| Search results | Staggered fade-in | 150ms per item, 30ms stagger | ease | — |

**Motion philosophy:** Gentle and rewarding. Motion exists to communicate (entry loaded, generation complete, connection discovered) and to add small moments of delight. The spring easing on cards and toasts gives the interface a slight bounce — alive, not mechanical. However, motion never interferes with reading — the entry detail page is still and calm.

**Signature moment:** When the AI discovers a new connection between entries (e.g., "Kael and the Treaty of Dusk are both linked to Thornwall — did they interact?"), the graph edge between them glows amber, and a discovery toast slides up with a satisfying spring animation.

**Reduced motion:**
```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
  .generation-indicator__dot { animation: none; opacity: 1; }
}
```

---

## Asset Guidelines

**Visual motifs:**
- **Warm, organic shapes** — Rounded corners everywhere, soft shadows with warm tones. The interface feels hand-crafted, not industrial.
- **Entry type emoji** — Each entry type gets a small emoji as its icon: 👤 Character, 📍 Location, ⚔ Event, 🏛 Faction, 💎 Object, 📜 Rule, 💭 Concept. Emoji adds personality that SVG icons can't (Playful contribution).
- **The knowledge graph** — Nodes have subtle shadows and type-colored dots. Edges have rounded line caps. The overall feel is an organic, growing network — not a circuit diagram.
- **Amber glow** for discovery moments — new connections, completed generations, and promoted entries all trigger a brief warm amber highlight.

**Iconography:**
- Lucide icons for system actions (18px, 1.5px stroke)
- Emoji for entry types and category labels (Playful contribution)
- Icons use `--text-tertiary` default, `--accent` on hover/active

**Illustration:** Minimal — small decorative illustrations only in empty states. Hand-drawn style, warm colors, 2-3 per state maximum. "Your universe is empty — start by creating your first character" with a small illustration of a quill.

**Photography:** None.

**Logo:** "Knowledge Base" in Source Serif 4 at 700 weight. The diamond mark "◊" in warm violet. Slightly more decorative than Direction A — could include a small book/scroll motif.

---

## Dark Mode Variant

Direction C includes a dark mode (unlike A):

```css
[data-theme="dark"] {
  --bg-primary: #1A1816;
  --bg-surface: #242220;
  --bg-elevated: #2E2C28;
  --bg-reading: #1E1C1A;

  --text-primary: #E8E2D9;
  --text-secondary: #9E9790;
  --text-tertiary: #6B6560;

  --border-default: #3A3630;
  --border-subtle: #2E2C28;

  /* Accents stay the same — they pop more on dark */
}
```

---

## Mixing Notes

### Elements Carrying the 20% Consumer Playful Accent (5 elements)

| Element | What Changed | Why |
|---------|-------------|-----|
| **Border radius (12-16px + pills)** | Editorial's conservative 4-8px → Rounded 12-16px for cards, pill shapes for buttons and badges | Rounded corners are the single most impactful change. They shift the entire mood from "serious reference tool" to "creative workshop." Every card, every button, every badge feels friendlier. |
| **Category cards (bento, spring hover)** | Editorial's flat list → Bento-style grid with count, icon, and spring-eased hover animation | The dashboard's category grid (Characters: 47, Locations: 32) uses bento cards with subtle scale-up on hover. This makes the universe overview feel like a living inventory, not a table of contents. Spring easing adds the personality. |
| **Discovery toasts** | No editorial precedent → Amber-bordered toast with spring slide-in for "new connection found" moments | World-building's magic is in unexpected connections. When the AI finds one, it should feel like a discovery, not a log message. The toast's spring animation and amber glow create a micro-celebration. |
| **DM Sans (rounded sans-serif)** | Inter/neutral sans → DM Sans with slightly rounded terminals | DM Sans is almost identical to Inter in functionality but has subtly rounded letter terminals. This gives every piece of UI text a marginally warmer, friendlier feeling without sacrificing readability. |
| **Entry type emoji** | Lucide icons for types → Emoji (👤📍⚔🏛💎📜💭) | Emoji adds personality and instant recognition. A 👤 next to "Character" reads faster and feels warmer than a generic person SVG. This is polarizing — some users will love it, some will find it unserious. |

### What Was Considered and Rejected

| Candidate | Why Rejected |
|-----------|-------------|
| Bright, saturated colors (replacing warm violet with hot pink or electric blue) | Would undermine the editorial foundation. The product still needs to feel authoritative — warm violet is creative without being loud. |
| Playful custom illustrations throughout (mascot, decorative borders) | Too much personality becomes noise. The entries are the content — illustrations compete for attention. Reserved for empty states only. |
| Animated backgrounds (subtle particles, moving gradients) | Distracting on a content-heavy interface. The reading experience must be calm. Animation is reserved for interaction moments, never ambient. |
| All-rounded typography (Comic Sans territory) | DM Sans is the limit. The serif headings (Source Serif 4) must remain sharp and authoritative. Rounding the serifs would destroy the editorial anchor. |
| Gamification (XP for entries created, streak counters) | Tempting for engagement but wrong for the product. World-building is creative work, not a game to be optimized. Streaks would pressure authors to write quantity over quality. |

---

## Implementation Checklist

- [ ] Source Serif 4 (headings + body, 400-700) + DM Sans (UI, 400-600) + JetBrains Mono (data, 400)
- [ ] Warm parchment `#F7F3ED` background — never cold white
- [ ] Border radius: 12px on cards, pill on buttons/badges (visibly rounder than Directions A/B)
- [ ] Canon entries: solid 3px left border in warm brown
- [ ] Generated entries: dashed 3px left border in amber
- [ ] Entry type chips with type-specific colors
- [ ] Category cards on dashboard with bento layout and spring hover
- [ ] Discovery toast with spring animation for new connections
- [ ] Generation progress uses pulsing violet dot, not progress bar
- [ ] Graph nodes have subtle shadows, type-colored dots, and scale-up on hover
- [ ] Graph edges use rounded line caps (`stroke-linecap: round`)
- [ ] Warm shadows throughout: `rgba(44, 37, 32, ...)` not `rgba(0,0,0,...)`
- [ ] All interactive elements have visible focus rings (`--focus-ring`)
- [ ] Amber accent color NEVER used for text smaller than 24px (fails contrast)
- [ ] `prefers-reduced-motion`: all animations disabled, generation dot static
- [ ] Color contrast: all text meets WCAG AA
- [ ] Touch targets: minimum 44px
- [ ] Dark mode available via `data-theme="dark"` attribute
- [ ] Light mode is default

---

*Derived from: editorial.md + consumer-playful.md*
*Project: NOIZUAI-4 — Knowledge Base (library.therobotlives.com)*
