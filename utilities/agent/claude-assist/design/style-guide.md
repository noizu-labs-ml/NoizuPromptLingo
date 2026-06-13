# Claude Assist — Style Guide

> Nocturne (80%) + Minimal Tech (20%) — a dark-native dev tool that treats the void as canvas and uses luminosity to create hierarchy. Minimal Tech's restraint tempers Nocturne's atmosphere: no gratuitous glow, no ambient drift. Every bright pixel earns its place.

**Package:** `claude-assist` (npm)
**Status:** draft
**Last updated:** 2026-05-11

---

## 1. Design Identity

### What This Tool Signals
- **Professional instrument** — not a toy, not a dashboard. A tool you reach for daily.
- **Terminal kinship** — shares the visual language of the user's existing environment (dark terminal, monospace, dense information).
- **Quiet competence** — works, stays out of the way, surfaces what matters.
- **Information density over decoration** — every pixel shows data or enables action.

### Style Mix Rationale

| Aspect | Nocturne (80%) | Minimal Tech (20%) |
|--------|----------------|---------------------|
| Canvas | Dark-native, no light mode | — |
| Hierarchy | Luminosity-driven | Clean whitespace, restraint |
| Color | Single glow accent (Plasma Cyan) | Monochrome + accent discipline |
| Components | Glow-based feedback on primary actions | Flat, borderless secondary elements |
| Motion | Subtle glow transitions | Minimal — function over atmosphere |
| Typography | Reduced weight for dark canvas | Inter/system sans, monospace for code |
| Spacing | 25% more generous than light-native | Compact data displays where density matters |

**Mix rule:** Nocturne owns the canvas, color, and primary interactions. Minimal Tech owns the restraint — no ambient glow orbs, no decorative gradients, no atmospheric motion. If an element doesn't show data or enable action, it doesn't exist.

---

## 2. Color System

### 2.1 Palette

**Glow color: Plasma Cyan** — signals technology, clarity, and precision. Natural fit for a dev tool that lives alongside terminals.

| Token | Hex | Use |
|-------|-----|-----|
| `--void` | `#09090B` | True black (scrollbar track, deep dividers) |
| `--canvas` | `#0F0F14` | Page background |
| `--surface` | `#18181F` | Cards, panels, sidebar |
| `--surface-raised` | `#22222E` | Modals, popovers, elevated cards |
| `--surface-active` | `#2A2A38` | Selected items, hover backgrounds |
| `--border-subtle` | `#2A2A3A` | Subtle dividers, card borders |
| `--border-strong` | `#3A3A4F` | Stronger separators, input borders |
| `--text-dim` | `#5C5C72` | Metadata, timestamps, line numbers (large text only) |
| `--text-muted` | `#7A7A94` | Secondary labels, placeholder text |
| `--text-secondary` | `#9898B0` | Body text, descriptions |
| `--text-primary` | `#CDCDE0` | Headings, thread content |
| `--text-bright` | `#EDEDF4` | Emphasis, active items |
| `--text-max` | `#FFFFFF` | Active focus states only, never body text |

**Glow tokens:**

| Token | Hex | Use |
|-------|-----|-----|
| `--glow` | `#06B6D4` | Primary accent (buttons, links, active states) |
| `--glow-bright` | `#22D3EE` | Hover/focus glow expansion |
| `--glow-dim` | `color-mix(in srgb, #06B6D4 50%, transparent)` | Badges, subtle indicators |
| `--glow-bg` | `color-mix(in srgb, #06B6D4 8%, #18181F)` | Selected row background, active tab |

### 2.2 Semantic Colors

| Purpose | Color | Hex | Treatment |
|---------|-------|-----|-----------|
| Success | Green | `#4ADE80` | Solid badge, soft text glow |
| Warning | Amber | `#FACC15` | Solid badge, border accent |
| Error | Red | `#F87171` | Solid badge, pulsing glow on critical |
| Info | Blue | `#60A5FA` | Solid badge, steady glow |

### 2.3 Quality Labels (Dataset Feature)

| Quality | Color | Hex |
|---------|-------|-----|
| Gold | Warm yellow | `#EAB308` |
| Silver | Cool gray | `#94A3B8` |
| Bronze | Warm brown | `#D97706` |

### 2.4 Usage Rules
- Canvas (`--canvas`) occupies 85%+ of visible area
- Glow color never used for large fills — max area: button-sized
- Borders use `--border-subtle` by default; `--border-strong` for interactive/focused elements
- No gradients except on featured/promoted cards (use radial glow from top)
- Depth via brightness stepping only — no drop shadows

---

## 3. Typography

### 3.1 Font Stack

| Role | Family | Fallback |
|------|--------|----------|
| UI text | Inter | system-ui, -apple-system, sans-serif |
| Code / conversation content | JetBrains Mono | Fira Code, SF Mono, Menlo, monospace |
| Headings | Inter | same as UI |

### 3.2 Scale

All weights reduced by one step for dark canvas (irradiation illusion). Letter-spacing increased slightly.

| Level | Size | Weight | Color | Letter-spacing | Use |
|-------|------|--------|-------|----------------|-----|
| Page Title | 28px | 500 | `--text-bright` | -0.01em | Page headings (Dashboard, Search) |
| Section | 20px | 500 | `--text-primary` | 0 | Section headers within pages |
| Subsection | 16px | 500 | `--text-primary` | 0 | Card titles, panel headers |
| Body | 14px | 400 | `--text-secondary` | 0.01em | Descriptions, body text |
| Small | 13px | 400 | `--text-muted` | 0.01em | Secondary info, timestamps |
| Caption | 12px | 400 | `--text-dim` | 0.02em | Metadata, line numbers |
| Code | 13px | 400 | varies | 0 | Conversation content, tool calls |
| Code Small | 12px | 400 | varies | 0 | Inline code, file paths |

### 3.3 Conversation Message Rendering

| Element | Font | Size | Color |
|---------|------|------|-------|
| User message text | JetBrains Mono | 13px | `--text-primary` |
| Assistant message text | JetBrains Mono | 13px | `--text-secondary` |
| Thinking block text | JetBrains Mono | 13px | `--text-dim` |
| Tool name | JetBrains Mono | 12px | `--glow` |
| Tool input/output | JetBrains Mono | 12px | `--text-muted` |
| Code blocks (in messages) | JetBrains Mono | 13px | syntax highlighted |
| Role label | Inter | 11px uppercase | `--text-dim` |

---

## 4. Spacing

8px base grid. Vertical spacing 25% more generous than light-native equivalents.

| Token | Size | Use |
|-------|------|-----|
| `--space-1` | 4px | Inline icon gaps, badge padding |
| `--space-2` | 8px | Icon-to-label, tight component padding |
| `--space-3` | 12px | Input padding, small card padding |
| `--space-4` | 16px | Standard component spacing, list item padding |
| `--space-5` | 20px | Card padding |
| `--space-6` | 24px | Between component groups |
| `--space-8` | 32px | Panel padding, section gaps |
| `--space-10` | 40px | Major section divisions |
| `--space-12` | 48px | Page section spacing |

### Component Spacing

| Component | Padding | Gap |
|-----------|---------|-----|
| Sidebar | 12px horizontal | 4px between items |
| Sidebar item | 8px 12px | — |
| Card | 20px | — |
| Search bar | 12px 16px | — |
| Thread message | 16px 20px | 2px between messages |
| Message + thinking block | — | 0px (flush) |
| Filter chips | 6px 12px | 8px between chips |
| Button sm | 6px 12px | — |
| Button md | 8px 16px | — |
| Button lg | 12px 24px | — |
| Stat card | 16px | — |
| Table row | 10px 16px | — |

---

## 5. Layout

### 5.1 App Shell

```
┌──────────────────────────────────────────────────────┐
│  Navbar (56px)                                       │
│  ┌─────────┬──────────────────────────────────────┐  │
│  │ Logo    │  SearchBar (compact)    IndexStatus  │  │
│  └─────────┴──────────────────────────────────────┘  │
├────────────┬─────────────────────────────────────────┤
│ Sidebar    │ Main Content                            │
│ (220px)    │                                         │
│            │                                         │
│ Dashboard  │                                         │
│ Search     │                                         │
│ Browse     │                                         │
│ Datasets   │                                         │
│ ─────────  │                                         │
│ Settings   │                                         │
│            │                                         │
│            │                                         │
│            │                                         │
└────────────┴─────────────────────────────────────────┘
```

- Sidebar: `--surface` background, `--border-subtle` right border
- Active sidebar item: `--glow-bg` background, `--glow` left border (3px), `--text-bright` text
- Inactive sidebar item: `--text-muted`, no background
- Navbar: `--canvas` with `--border-subtle` bottom border, no blur/transparency (keep it simple)
- Main content: `--canvas` background, max-width 1200px with auto margins on ultra-wide

### 5.2 Thread Viewer Layout

```
┌─────────────────────────────────────────────────────────────┐
│ ThreadHeader: title, project badge, date, model, actions    │
├─────────────────────────────────────────────────────────────┤
│ ┌──────────────────────────────────────────────────┐ ┌────┐ │
│ │ MessageList (scrollable)                         │ │Meta│ │
│ │                                                  │ │    │ │
│ │ ┌─ USER ────────────────────────────────────┐    │ │Tags│ │
│ │ │ message content                           │    │ │    │ │
│ │ └───────────────────────────────────────────┘    │ │Sum │ │
│ │                                                  │ │    │ │
│ │ ┌─ ASSISTANT ───────────────────────────────┐    │ │Tok │ │
│ │ │ ▸ thinking (collapsed)                    │    │ │    │ │
│ │ │ response text                             │    │ │    │ │
│ │ │ ▸ tool_use: Bash (collapsed)              │    │ │    │ │
│ │ └───────────────────────────────────────────┘    │ │    │ │
│ │                                                  │ │    │ │
│ │ ┌─ TOOL RESULT ─────────────────────────────┐    │ │    │ │
│ │ │ ▸ output (collapsed, first 3 lines shown) │    │ │    │ │
│ │ └───────────────────────────────────────────┘    │ │    │ │
│ └──────────────────────────────────────────────────┘ └────┘ │
└─────────────────────────────────────────────────────────────┘
```

- User messages: left-aligned, `--surface` background, `--glow` left border (2px)
- Assistant messages: left-aligned, no background (sits on canvas), `--text-secondary`
- Tool calls: `--surface` background, collapsed by default, tool name in `--glow`
- Thinking blocks: collapsed by default, `--text-dim` when expanded, italic
- Metadata panel: 280px right sidebar (collapsible on narrow viewports)

### 5.3 Responsive Breakpoints

| Breakpoint | Width | Layout Changes |
|------------|-------|----------------|
| Desktop | > 1024px | Full sidebar + content + metadata panel |
| Tablet | 768–1024px | Collapsible sidebar (hamburger), metadata panel hidden |
| Mobile | < 768px | Bottom nav, full-width content, metadata as slide-up sheet |

This is a power-user tool, so desktop is the primary target. Mobile is functional but not optimized — the CLI handles mobile-context use cases.

---

## 6. Components

### 6.1 Buttons

```css
/* Primary — glowing, used sparingly */
.btn-primary {
  background: var(--glow);
  color: var(--void);
  border: none;
  border-radius: 6px;
  font-weight: 500;
  font-size: 13px;
  box-shadow: 0 0 1px var(--glow), 0 0 8px var(--glow-dim);
}
.btn-primary:hover {
  box-shadow: 0 0 1px var(--glow), 0 0 16px var(--glow-dim);
}

/* Secondary — outlined */
.btn-secondary {
  background: transparent;
  color: var(--text-primary);
  border: 1px solid var(--border-strong);
  border-radius: 6px;
}
.btn-secondary:hover {
  border-color: var(--glow);
  color: var(--glow-bright);
}

/* Ghost — text only, for toolbar actions */
.btn-ghost {
  background: transparent;
  color: var(--text-muted);
  border: none;
}
.btn-ghost:hover {
  color: var(--text-primary);
  background: var(--surface-active);
}
```

### 6.2 Search Bar

- Full-width input, `--surface` background, `--border-subtle` border
- On focus: `--glow` border, subtle glow `box-shadow`
- Mode toggle (Text/Semantic) as pill tabs inside the input, right-aligned
- Search icon left-aligned, `--text-dim`
- Results appear below in a dropdown panel (`--surface-raised`)

### 6.3 Thread Card

```
┌──────────────────────────────────────────────────────┐
│  [project-badge]  Thread Title Here                  │
│  Preview snippet of the conversation content that    │
│  gives enough context to recognize the thread...     │
│                                                      │
│  42 messages  ·  claude-opus-4-7  ·  2h ago         │
└──────────────────────────────────────────────────────┘
```

- `--surface` background, `--border-subtle` border, 6px border-radius
- Hover: `--border-strong` border, `--surface-active` background
- Project badge: `--glow-dim` background, `--glow` text, 4px border-radius, uppercase 11px
- Title: `--text-primary`, 14px, weight 500
- Snippet: `--text-muted`, 13px, 2-line clamp
- Metadata row: `--text-dim`, 12px, dot-separated

### 6.4 Stat Card

- `--surface` background, `--border-subtle` border
- Value: `--text-bright`, 24px, weight 500, JetBrains Mono
- Label: `--text-dim`, 12px, uppercase

### 6.5 Quality Badge

- Pill shape (16px height, 4px border-radius)
- Gold: `#EAB308` background at 15%, `#EAB308` text
- Silver: `#94A3B8` background at 15%, `#94A3B8` text
- Bronze: `#D97706` background at 15%, `#D97706` text

### 6.6 Filter Chips

- `--surface` background, `--border-subtle` border, 12px border-radius
- Active: `--glow-bg` background, `--glow` border, `--glow` text
- Inactive: `--text-muted` text

### 6.7 Collapsible Blocks (Tool Calls, Thinking)

- Chevron indicator (`▸` collapsed, `▾` expanded), `--text-dim`
- Header: tool name in `--glow`, input preview in `--text-muted`
- Expanded body: `--surface` background, monospace, `--text-muted`
- Collapse animation: 150ms ease-out height transition

---

## 7. Interaction

### 7.1 Timing

| Interaction | Duration | Easing |
|-------------|----------|--------|
| Button hover | 150ms | ease-out |
| Focus ring appear | 100ms | ease-out |
| Collapse/expand | 150ms | ease-out |
| Page transition | 200ms | ease-in-out |
| Search results appear | 200ms | ease-out |
| Glow expansion (hover) | 200ms | ease-out |

### 7.2 Focus States

```css
:focus-visible {
  outline: 2px solid var(--glow);
  outline-offset: 2px;
  box-shadow: 0 0 6px var(--glow-dim);
}
```

### 7.3 Selection

- Row selection (Browse, Dataset): `--glow-bg` background, `--glow` left border (2px)
- Multi-select: checkbox appears on hover, checked state uses `--glow`

### 7.4 Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `Cmd+K` | Open command palette |
| `/` | Focus search bar |
| `j/k` | Navigate thread list (vim-style) |
| `Enter` | Open selected thread |
| `e` | Edit current thread |
| `c` | Convert current thread |
| `Esc` | Close panel / deselect |

---

## 8. Iconography

- **Style:** Lucide icons (outline, 1.5px stroke)
- **Size:** 16px default, 20px for nav items, 14px inline
- **Color:** inherits text color (usually `--text-muted`, `--glow` when active)
- **No filled icons** — outline only, consistent with the luminosity principle

---

## 9. CLI / Ink Component Parity

The Ink (terminal) CLI shares visual language with the web UI where possible:

| Web UI | Ink CLI Equivalent |
|--------|--------------------|
| `--glow` (Plasma Cyan) | `cyan` / `cyanBright` |
| `--text-primary` | `white` |
| `--text-secondary` | default terminal color |
| `--text-dim` | `gray` / `dim` |
| `--surface` background | Box with `borderStyle="single"` |
| Glow button | `<Box borderColor="cyan">` |
| Collapsible block | Expandable `<Box>` with `▸`/`▾` prefix |
| Search highlights | `<Text backgroundColor="cyan" color="black">` |

---

## 10. Accessibility

### 10.1 Contrast Verification

| Pair | Ratio | Pass |
|------|-------|------|
| `--text-secondary` (#9898B0) on `--canvas` (#0F0F14) | 6.1:1 | AA body |
| `--text-primary` (#CDCDE0) on `--canvas` (#0F0F14) | 11.2:1 | AAA |
| `--text-primary` on `--surface` (#18181F) | 8.9:1 | AAA |
| `--text-muted` (#7A7A94) on `--canvas` | 4.6:1 | AA (large text, UI) |
| `--text-dim` (#5C5C72) on `--canvas` | 3.2:1 | large text only |
| `--glow` (#06B6D4) on `--void` (#09090B) | 5.8:1 | AA body |
| `--glow` on `--surface` | 4.9:1 | AA (UI components) |

### 10.2 Rules
- Body text minimum: `--text-secondary` (6.1:1)
- `--text-dim` restricted to large text (18px+) or non-essential metadata
- All interactive elements must have `:focus-visible` glow ring
- Keyboard navigation for all features (thread nav, search, wizard steps)
- Collapsible sections announce state to screen readers (`aria-expanded`)
- Reduced motion: disable glow transitions, use instant state changes

---

## 11. Do's and Don'ts

**Do:**
- Trust the void — empty space is not wasted space on a dark canvas
- Use `--glow` sparingly — one or two glowing elements per viewport max
- Prefer monospace for any content from conversations
- Test on both OLED (true blacks) and LCD (dark grays) displays
- Keep information density high in thread/browse views
- Match the terminal's visual rhythm — this tool lives alongside `claude` CLI

**Don't:**
- Add ambient glow orbs, drifting gradients, or atmospheric effects (Minimal Tech restraint)
- Use pure white (#FFFFFF) for body text
- Apply glow to decorative elements — glow means "interactive" or "active"
- Add loading spinners — use skeleton screens with luminosity sweep
- Create light mode (this is dark-native, not dark-toggle)
- Add rounded corners larger than 8px (keep it technical)
- Use emoji in the UI — this is a professional instrument
