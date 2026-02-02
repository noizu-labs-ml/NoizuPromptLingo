# Minimal Tech Style Specification

> The "barely-there UI" aesthetic that signals intelligence, sophistication, and focus. Dominant in AI, developer tools, and VC-backed startups.

---

## 1. Positioning

### 1.1 What This Style Signals

- **Intelligence**: "We're smart and assume you are too"
- **Focus**: "We don't waste your time with decoration"
- **Confidence**: "Our product speaks for itself"
- **Modernity**: "We're building the future"
- **Trust**: "We're serious about what we do"

### 1.2 Best Use Cases

- AI/ML products and platforms
- Developer tools and APIs
- B2B SaaS applications
- Fintech and financial products
- Products seeking investment/credibility
- Data-heavy dashboards
- Technical documentation sites

### 1.3 Avoid When

- Target audience is non-technical or older demographic
- Brand needs to feel warm, friendly, or approachable
- Product is entertainment or lifestyle focused
- Market is saturated with minimal competitors (need differentiation)
- Cultural context values expressive design (some Asian markets)

---

## 2. Color System

### 2.1 Palette Structure

```
┌─────────────────────────────────────────────────────────┐
│  MINIMAL TECH PALETTE STRUCTURE                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Background ─────── #FFFFFF or #FAFAFA (light mode)     │
│                     #0A0A0A or #111111 (dark mode)      │
│                                                         │
│  Surface ────────── #F5F5F5 (light) / #1A1A1A (dark)    │
│                                                         │
│  Text Primary ───── #171717 (light) / #FAFAFA (dark)    │
│  Text Secondary ─── #525252 (light) / #A3A3A3 (dark)    │
│  Text Tertiary ──── #A3A3A3 (light) / #525252 (dark)    │
│                                                         │
│  Border ─────────── #E5E5E5 (light) / #262626 (dark)    │
│                                                         │
│  Accent ─────────── ONE color only (see options below)  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 2.2 Accent Color Options

Choose ONE accent color for the entire product:

| Color | Hex | Signal | Best For |
|-------|-----|--------|----------|
| Electric Blue | `#2563EB` | Trust, technology | Enterprise, security |
| Violet | `#7C3AED` | Innovation, AI | AI products, creative tools |
| Emerald | `#10B981` | Growth, success | Fintech, analytics |
| Orange | `#F97316` | Energy, warmth | Startups seeking approachability |
| Neutral (no accent) | — | Pure restraint | Documentation, utilitarian tools |

**2026 Trend Note:** Orange is currently dominant for differentiation against blue-heavy tech landscape.

### 2.3 Semantic Colors

| Purpose | Light Mode | Dark Mode |
|---------|------------|-----------|
| Success | `#22C55E` | `#4ADE80` |
| Warning | `#EAB308` | `#FACC15` |
| Error | `#EF4444` | `#F87171` |
| Info | `#3B82F6` | `#60A5FA` |

### 2.4 Color Usage Rules

- Background should be 80%+ of visual field
- Accent color used only for: primary CTAs, active states, key data points
- Never use accent for large areas (backgrounds, cards)
- Text colors create hierarchy; avoid using many grays
- Borders should be barely visible—subtle separation only

---

## 3. Typography

### 3.1 Font Selection

**Primary recommendation:** Inter, Geist, or SF Pro

**Acceptable alternatives:**
- Söhne (premium feel)
- IBM Plex Sans (open source, technical)
- Manrope (slightly warmer)
- Space Grotesk (more distinctive)

**Avoid:**
- Serif fonts (conflicts with modern tech signal)
- Highly stylized display fonts
- Fonts with strong personality

### 3.2 Type Scale

Base: 16px

| Level | Size | Weight | Line Height | Use |
|-------|------|--------|-------------|-----|
| Display | 48-72px | 600 | 1.1 | Hero headlines only |
| H1 | 36px | 600 | 1.2 | Page titles |
| H2 | 24px | 600 | 1.3 | Section headers |
| H3 | 20px | 600 | 1.4 | Subsections |
| H4 | 16px | 600 | 1.5 | Card titles, labels |
| Body | 16px | 400 | 1.6 | Primary content |
| Body Small | 14px | 400 | 1.5 | Secondary content |
| Caption | 12px | 400 | 1.4 | Metadata, timestamps |
| Code | 14px | 400 (mono) | 1.5 | Code snippets |

### 3.3 Typography Rules

- Maximum two weights: 400 (regular) and 600 (semibold)
- Never use bold (700) for body text
- Headlines can use 500 or 600, be consistent
- Letter-spacing: 0 for body, -0.02em for large headlines
- Mono font for code: JetBrains Mono, Fira Code, or SF Mono

---

## 4. Spacing System

### 4.1 Base Unit

8px base with full scale:

```
4px   - Micro (icon padding, tight groups)
8px   - XS (related elements)
12px  - SM (form field padding)
16px  - MD (standard spacing)
24px  - LG (section padding)
32px  - XL (between sections)
48px  - 2XL (major divisions)
64px  - 3XL (page sections)
96px  - 4XL (hero spacing)
```

### 4.2 Component Spacing

| Component | Padding | Gap |
|-----------|---------|-----|
| Button (sm) | 8px 12px | — |
| Button (md) | 12px 16px | — |
| Button (lg) | 16px 24px | — |
| Input field | 12px 16px | — |
| Card | 24px | 16px internal |
| Modal | 32px | 24px internal |
| Section | 64px vertical | — |
| Page margins | 24px (mobile) / 64px+ (desktop) | — |

### 4.3 Grid System

```
Mobile:     4 columns, 16px gutters, 16px margins
Tablet:     8 columns, 24px gutters, 32px margins  
Desktop:    12 columns, 24px gutters, 64px margins
Wide:       12 columns, 32px gutters, max-width 1280px centered
```

---

## 5. Component Styling

### 5.1 Buttons

```css
/* Primary Button */
.btn-primary {
  background: var(--accent);
  color: white;
  border: none;
  border-radius: 6px;
  font-weight: 500;
  transition: opacity 0.15s;
}
.btn-primary:hover {
  opacity: 0.9;
}

/* Secondary Button */
.btn-secondary {
  background: transparent;
  color: var(--text-primary);
  border: 1px solid var(--border);
  border-radius: 6px;
}
.btn-secondary:hover {
  background: var(--surface);
}

/* Ghost Button */
.btn-ghost {
  background: transparent;
  color: var(--text-secondary);
  border: none;
}
.btn-ghost:hover {
  color: var(--text-primary);
}
```

**Button Rules:**
- Border radius: 6px (not too round, not sharp)
- No shadows on buttons
- Subtle hover states (opacity or background shift)
- No gradient backgrounds
- Icon + text spacing: 8px

### 5.2 Form Inputs

```css
.input {
  background: var(--background);
  border: 1px solid var(--border);
  border-radius: 6px;
  padding: 12px 16px;
  font-size: 16px;
  transition: border-color 0.15s;
}
.input:focus {
  border-color: var(--accent);
  outline: none;
  box-shadow: 0 0 0 3px rgba(accent, 0.1);
}
.input::placeholder {
  color: var(--text-tertiary);
}
```

**Input Rules:**
- Always show border (even if subtle)
- Focus state: accent color border + subtle shadow
- Error state: red border, red helper text below
- Labels above inputs, not inside
- Helper text in caption size, secondary color

### 5.3 Cards

```css
.card {
  background: var(--background);
  border: 1px solid var(--border);
  border-radius: 8px;
  padding: 24px;
}
/* Alternative: no border, subtle shadow */
.card-elevated {
  background: var(--background);
  border: none;
  border-radius: 8px;
  padding: 24px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}
```

**Card Rules:**
- Choose border OR shadow, not both
- Consistent radius across all cards (8px recommended)
- No background colors on cards (stay white/dark)
- Hover states only if card is clickable

### 5.4 Navigation

**Header:**
- Height: 64px
- Logo left, nav center or right
- Minimal items (5 max in primary nav)
- CTA button if needed, primary style
- Mobile: hamburger or bottom nav

**Sidebar (if applicable):**
- Width: 240-280px
- Collapsible to icons (64px)
- Group items with subtle dividers
- Active state: accent background at 10% opacity

### 5.5 Tables

```css
.table {
  width: 100%;
  border-collapse: collapse;
}
.table th {
  text-align: left;
  font-weight: 500;
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--text-secondary);
  padding: 12px 16px;
  border-bottom: 1px solid var(--border);
}
.table td {
  padding: 16px;
  border-bottom: 1px solid var(--border);
}
.table tr:hover {
  background: var(--surface);
}
```

---

## 6. Interaction Patterns

### 6.1 Animation Principles

- **Duration:** 150ms for micro-interactions, 300ms for transitions
- **Easing:** `ease-out` for entrances, `ease-in` for exits
- **Properties:** Prefer `opacity` and `transform` (GPU accelerated)
- **Restraint:** Animate only what needs attention

### 6.2 Hover States

| Element | Hover Effect |
|---------|--------------|
| Buttons | Opacity 0.9 or background shift |
| Links | Underline or color shift |
| Cards (clickable) | Subtle border color change or lift |
| Table rows | Background color shift |
| Icons | Opacity or scale (1.05 max) |

### 6.3 Loading States

- Skeleton screens over spinners
- Pulse animation on skeletons
- No loading text ("Loading...") - implicit understanding
- Progressive loading for content

### 6.4 Feedback Patterns

- Toast notifications: bottom-right, auto-dismiss 4s
- Form validation: inline, below field
- Success states: checkmark icon + brief message
- Error states: red accent, clear recovery action

---

## 7. Data Visualization

Minimal Tech style often features data as visual element:

### 7.1 Chart Styling

- Single accent color for primary data series
- Gray scale for secondary/comparison data
- No grid lines or minimal (light gray, dashed)
- Axis labels in caption size
- Interactive tooltips on hover

### 7.2 Metric Display

```
┌────────────────────────────────────┐
│  MONTHLY ACTIVE USERS              │  ← Caption, secondary color
│  1,234,567                         │  ← Display size, primary color  
│  ↑ 12.3% from last month           │  ← Body small, success color
└────────────────────────────────────┘
```

### 7.3 Dashboard Layout

- Key metrics at top (3-4 max)
- Charts in clean grid
- Generous spacing between sections
- Filter/controls in secondary styling

---

## 8. Do's and Don'ts

### Do's ✓

- Let whitespace do the work
- Use one accent color consistently
- Keep interactions subtle and fast
- Prioritize content hierarchy
- Use data visualization as visual interest
- Maintain consistency obsessively
- Test in both light and dark modes

### Don'ts ✗

- Add decorative elements "to fill space"
- Use multiple accent colors
- Add shadows to everything
- Use rounded corners > 12px (too playful)
- Include illustrations or mascots
- Use gradients on UI elements
- Add animation for animation's sake
- Use ALL CAPS for body text

---

## 9. Reference Sites

Study these for execution quality:

| Site | Notable Elements |
|------|------------------|
| linear.app | Animation, density balance, dark mode |
| vercel.com | Typography, whitespace, gradient accent |
| stripe.com | Documentation, data visualization |
| notion.so | Clean UI, subtle interactions |
| raycast.com | macOS native feel, keyboard-first |
| resend.com | Email aesthetic, single accent |
| clerk.com | Auth UI patterns, trust signals |

---

## 10. Implementation Checklist

Before shipping, verify:

- [ ] Single typeface used throughout
- [ ] Maximum 2-3 colors (excluding semantic)
- [ ] Consistent spacing scale applied
- [ ] All interactive states defined
- [ ] Dark mode implemented (if applicable)
- [ ] Accessibility contrast ratios pass
- [ ] Animations respect reduced-motion
- [ ] No decorative-only elements
- [ ] Loading states for all async content
- [ ] Mobile responsive without breaking minimalism

---

*Version: 0.1.0*
*Last updated: 2026-01-29*
