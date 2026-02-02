# Figma Spec & Design Handoff Guide

> Structured documentation for handing off designs to developers or external teams who use Figma or similar design tools.

---

## 1. When to Use Figma Specs

| Scenario | Why Figma Spec |
|----------|---------------|
| External dev team | They need design files, not code |
| Design system creation | Systematic component documentation |
| Client deliverable | Professional handoff format |
| Team onboarding | Reference documentation |
| Agency handoff | Standard industry format |

---

## 2. Spec Document Structure

### 2.1 Recommended Format

```
design-spec/
├── README.md              # Overview and navigation
├── 00-overview/
│   ├── project-brief.md   # Goals, audience, constraints
│   ├── sitemap.md         # Page structure
│   └── user-flows.md      # Key user journeys
├── 01-foundations/
│   ├── colors.md          # Color system
│   ├── typography.md      # Type scale and usage
│   ├── spacing.md         # Spacing system
│   ├── grid.md            # Grid and layout
│   └── iconography.md     # Icon library
├── 02-components/
│   ├── buttons.md         # Button variants
│   ├── forms.md           # Form elements
│   ├── cards.md           # Card patterns
│   ├── navigation.md      # Nav components
│   └── [component].md     # Other components
├── 03-patterns/
│   ├── layouts.md         # Page layouts
│   ├── responsive.md      # Breakpoint behavior
│   └── interactions.md    # Animation/transition specs
├── 04-pages/
│   ├── landing.md         # Landing page spec
│   ├── dashboard.md       # Dashboard spec
│   └── [page].md          # Other pages
└── assets/
    ├── mockups/           # SVG/PNG exports
    ├── icons/             # Icon exports
    └── images/            # Image assets
```

---

## 3. Foundation Specs

### 3.1 Color System

```markdown
# Color System

## Brand Colors

| Name | Hex | RGB | HSL | Usage |
|------|-----|-----|-----|-------|
| Primary | #3B82F6 | 59, 130, 246 | 217, 91%, 60% | CTAs, links, accent |
| Primary Dark | #2563EB | 37, 99, 235 | 217, 83%, 53% | Hover states |
| Primary Light | #DBEAFE | 219, 234, 254 | 214, 95%, 93% | Backgrounds |

## Neutral Colors

| Name | Hex | Usage |
|------|-----|-------|
| Gray 900 | #1E293B | Primary text |
| Gray 600 | #64748B | Secondary text |
| Gray 400 | #94A3B8 | Placeholder text |
| Gray 200 | #E2E8F0 | Borders |
| Gray 100 | #F1F5F9 | Backgrounds |
| Gray 50 | #F8FAFC | Subtle backgrounds |

## Semantic Colors

| Name | Hex | Usage |
|------|-----|-------|
| Success | #22C55E | Positive states, confirmations |
| Warning | #F59E0B | Caution, pending states |
| Error | #EF4444 | Errors, destructive actions |
| Info | #3B82F6 | Informational messages |

## Accessibility Notes

- Text on white: Use Gray 600+ for WCAG AA (4.5:1)
- Text on primary: Use white (#FFFFFF)
- Never use light gray on light backgrounds
```

### 3.2 Typography

```markdown
# Typography

## Font Family

**Primary:** Inter (Google Fonts)
- Fallback: system-ui, -apple-system, sans-serif

**Monospace:** JetBrains Mono
- Fallback: ui-monospace, monospace

## Type Scale

| Name | Size | Line Height | Weight | Usage |
|------|------|-------------|--------|-------|
| Display | 48px / 3rem | 1.1 | 700 | Hero headlines |
| H1 | 36px / 2.25rem | 1.2 | 700 | Page titles |
| H2 | 30px / 1.875rem | 1.25 | 700 | Section headers |
| H3 | 24px / 1.5rem | 1.3 | 600 | Subsections |
| H4 | 20px / 1.25rem | 1.4 | 600 | Card titles |
| Body Large | 18px / 1.125rem | 1.6 | 400 | Lead paragraphs |
| Body | 16px / 1rem | 1.5 | 400 | Default text |
| Body Small | 14px / 0.875rem | 1.5 | 400 | Secondary text |
| Caption | 12px / 0.75rem | 1.4 | 400 | Labels, metadata |

## Font Weights

- Regular (400): Body text
- Medium (500): Buttons, labels
- Semibold (600): Subheadings
- Bold (700): Headlines

## Line Length

- Optimal: 60-75 characters
- Maximum: 85 characters
- Minimum: 45 characters

## Implementation

```css
/* CSS Variables */
--font-sans: 'Inter', system-ui, sans-serif;
--font-mono: 'JetBrains Mono', monospace;

--text-xs: 0.75rem;
--text-sm: 0.875rem;
--text-base: 1rem;
--text-lg: 1.125rem;
--text-xl: 1.25rem;
--text-2xl: 1.5rem;
--text-3xl: 1.875rem;
--text-4xl: 2.25rem;
--text-5xl: 3rem;
```
```

### 3.3 Spacing System

```markdown
# Spacing System

## Base Unit

4px base unit. All spacing is a multiple of 4.

## Scale

| Token | Value | Pixels | Common Usage |
|-------|-------|--------|--------------|
| space-1 | 0.25rem | 4px | Tight inline spacing |
| space-2 | 0.5rem | 8px | Icon gaps, small padding |
| space-3 | 0.75rem | 12px | Input padding |
| space-4 | 1rem | 16px | Default gap, card padding |
| space-5 | 1.25rem | 20px | Medium spacing |
| space-6 | 1.5rem | 24px | Section padding (mobile) |
| space-8 | 2rem | 32px | Component margins |
| space-10 | 2.5rem | 40px | Large gaps |
| space-12 | 3rem | 48px | Section margins |
| space-16 | 4rem | 64px | Section padding (desktop) |
| space-20 | 5rem | 80px | Large section spacing |
| space-24 | 6rem | 96px | Hero padding |

## Usage Guidelines

### Component Internal
- Button padding: space-2 vertical, space-4 horizontal
- Card padding: space-4 to space-6
- Input padding: space-2 to space-3

### Component External
- Between related items: space-2 to space-4
- Between sections: space-8 to space-12
- Page margins: space-4 (mobile), space-8 (desktop)

### Layout
- Grid gap: space-4 to space-6
- Section vertical padding: space-16 to space-24
```

### 3.4 Grid System

```markdown
# Grid & Layout

## Container

| Breakpoint | Max Width | Side Padding |
|------------|-----------|--------------|
| Mobile | 100% | 16px |
| Tablet (768px+) | 100% | 24px |
| Desktop (1024px+) | 1200px | 32px |
| Wide (1440px+) | 1400px | 40px |

## Grid

12-column grid with flexible gutters.

| Breakpoint | Columns | Gutter |
|------------|---------|--------|
| Mobile | 4 | 16px |
| Tablet | 8 | 24px |
| Desktop | 12 | 24px |

## Common Layouts

### 2-Column (50/50)
- Desktop: 6 + 6 columns
- Tablet: 4 + 4 columns
- Mobile: Stack (full width)

### 2-Column (Sidebar)
- Desktop: 3 + 9 columns (sidebar left)
- Tablet: 2 + 6 columns
- Mobile: Stack or hide sidebar

### 3-Column
- Desktop: 4 + 4 + 4 columns
- Tablet: Stack to 2 columns
- Mobile: Stack to 1 column

### Bento Grid
```
┌─────────────┬─────────────┐
│    Wide     │   Square    │
│   (span 2)  │   (span 1)  │
├──────┬──────┼─────────────┤
│  Sq  │  Sq  │    Tall     │
│      │      │  (span 2    │
├──────┴──────┤   rows)     │
│    Wide     │             │
└─────────────┴─────────────┘
```
```

---

## 4. Component Specs

### 4.1 Button Specification

```markdown
# Button Component

## Variants

### Primary Button
- Background: Primary (#3B82F6)
- Text: White (#FFFFFF)
- Hover: Primary Dark (#2563EB)
- Active: Primary Dark + opacity 90%
- Disabled: Opacity 50%

### Secondary Button
- Background: Transparent
- Border: 1px solid Gray 200
- Text: Gray 900
- Hover: Gray 50 background
- Active: Gray 100 background

### Ghost Button
- Background: Transparent
- Text: Primary
- Hover: Primary + 10% opacity background

## Sizes

| Size | Height | Padding | Font Size | Border Radius |
|------|--------|---------|-----------|---------------|
| Small | 32px | 8px 12px | 14px | 6px |
| Medium | 40px | 10px 16px | 14px | 8px |
| Large | 48px | 12px 24px | 16px | 8px |

## States

| State | Visual Change |
|-------|---------------|
| Default | Base styles |
| Hover | Darken background 10% |
| Focus | 2px ring, offset 2px |
| Active | Darken background 15% |
| Disabled | Opacity 50%, no pointer |
| Loading | Spinner icon, text "Loading..." |

## Anatomy

```
┌─────────────────────────────────┐
│  [icon]  Label Text  [icon]    │
│   16px     varies      16px    │
│ optional              optional │
└─────────────────────────────────┘
      8px gap between elements
```

## Figma Properties

```
Component: Button
├── Variant: primary | secondary | ghost
├── Size: sm | md | lg
├── State: default | hover | focus | active | disabled | loading
├── Left Icon: boolean
├── Right Icon: boolean
└── Label: string
```
```

### 4.2 Input Field Specification

```markdown
# Input Field Component

## Anatomy

```
Label (optional)
┌─────────────────────────────────┐
│ [icon] Placeholder/Value [icon]│
└─────────────────────────────────┘
Helper text or Error message
```

## Measurements

| Property | Value |
|----------|-------|
| Height | 40px (medium), 32px (small), 48px (large) |
| Padding | 12px horizontal |
| Border | 1px |
| Border Radius | 6px |
| Label margin-bottom | 4px |
| Helper margin-top | 4px |

## States

### Default
- Border: Gray 200
- Background: White
- Text: Gray 900
- Placeholder: Gray 400

### Focus
- Border: Primary (2px)
- Box shadow: 0 0 0 3px Primary/10%

### Error
- Border: Error (#EF4444)
- Helper text: Error color
- Icon: Error icon (right)

### Disabled
- Background: Gray 50
- Text: Gray 400
- Cursor: not-allowed

### Read-only
- Background: Gray 50
- Border: Gray 200
- Text: Gray 900

## Figma Properties

```
Component: Input
├── Size: sm | md | lg
├── State: default | focus | error | disabled | readonly
├── Label: string | none
├── Placeholder: string
├── Helper Text: string | none
├── Left Icon: icon | none
└── Right Icon: icon | none
```
```

### 4.3 Card Specification

```markdown
# Card Component

## Variants

### Default Card
- Background: White
- Border: 1px Gray 200
- Border Radius: 12px
- Padding: 24px

### Elevated Card
- Background: White
- Border: none
- Shadow: shadow-lg
- Border Radius: 12px
- Padding: 24px

### Interactive Card
- Same as elevated
- Hover: shadow-xl, translateY(-2px)
- Transition: 200ms ease

## Anatomy

```
┌─────────────────────────────────┐
│  Image/Media (optional)        │  aspect-ratio: 16/9
│                                │  border-radius: 12px 12px 0 0
├─────────────────────────────────┤
│  Header                        │  padding: 24px
│  ├── Eyebrow (optional)        │  font: caption, uppercase
│  ├── Title                     │  font: h4
│  └── Subtitle (optional)       │  font: body-small, muted
├─────────────────────────────────┤
│  Content                       │  padding: 0 24px
│  └── Description               │  font: body
├─────────────────────────────────┤
│  Footer (optional)             │  padding: 24px
│  └── Actions/Metadata          │  border-top: 1px if content
└─────────────────────────────────┘
```

## Figma Properties

```
Component: Card
├── Variant: default | elevated | interactive
├── Has Image: boolean
├── Has Header: boolean
├── Has Footer: boolean
├── Width: fixed | hug | fill
```
```

---

## 5. Page Specifications

### 5.1 Landing Page Spec

```markdown
# Landing Page Specification

## Overview

- **Purpose:** Convert visitors to waitlist signups
- **Primary CTA:** "Join Waitlist" (email capture)
- **Target:** 15-30% conversion rate

## Page Structure

```
┌─────────────────────────────────────────────┐
│  Header (sticky)                            │  64px
├─────────────────────────────────────────────┤
│                                             │
│  Hero Section                               │  600px min
│  - Headline (H1)                            │
│  - Subheadline                              │
│  - Email capture form                       │
│  - Social proof text                        │
│                                             │
├─────────────────────────────────────────────┤
│                                             │
│  Social Proof Bar                           │  80px
│  - Logo strip (grayscale)                   │
│                                             │
├─────────────────────────────────────────────┤
│                                             │
│  Features Section                           │  auto
│  - Section title (H2)                       │
│  - 3-column feature cards                   │
│                                             │
├─────────────────────────────────────────────┤
│                                             │
│  How It Works                               │  auto
│  - 3 steps with icons                       │
│  - Connecting line/arrows                   │
│                                             │
├─────────────────────────────────────────────┤
│                                             │
│  Testimonials                               │  auto
│  - Quote carousel or grid                   │
│                                             │
├─────────────────────────────────────────────┤
│                                             │
│  Final CTA                                  │  300px
│  - Dark background                          │
│  - Headline                                 │
│  - CTA button                               │
│                                             │
├─────────────────────────────────────────────┤
│  Footer                                     │  80px
└─────────────────────────────────────────────┘
```

## Section: Hero

### Desktop (1440px)

```
Container: 1200px centered
Padding: 96px top, 64px bottom
Background: Gray 50

Content centered:
- Headline: 48px/56px, bold, max-width 800px
- Subheadline: 20px/32px, regular, muted, max-width 600px
- Form: inline, 400px input + 140px button
- Social proof: 14px, muted, margin-top 24px
```

### Mobile (375px)

```
Padding: 48px top, 32px bottom

Content stacked:
- Headline: 32px/40px, bold
- Subheadline: 16px/24px
- Form: stacked (input full width, button full width)
- Social proof: 12px
```

## Section: Features

### Specifications

```
Container: 1200px
Padding: 96px vertical
Background: White

Title: centered, H2, margin-bottom 48px

Grid: 
- Desktop: 3 columns, 24px gap
- Tablet: 2 columns
- Mobile: 1 column

Feature Card:
- Padding: 24px
- Icon: 48px container, emoji or SVG
- Title: H4, margin 16px top
- Description: body-small, muted
```

## Interactions

| Element | Interaction |
|---------|-------------|
| Header CTA | Smooth scroll to hero form |
| Email input | Focus ring, validation |
| Submit button | Loading state, success message |
| Feature cards | Subtle hover lift (if interactive) |
| Testimonials | Auto-play carousel (optional) |

## Responsive Breakpoints

| Breakpoint | Key Changes |
|------------|-------------|
| 1440px+ | Max container width |
| 1024px | Grid 3→2 columns |
| 768px | Header nav collapses |
| 640px | Hero form stacks |
| 375px | Mobile-optimized spacing |
```

---

## 6. Interaction Specifications

### 6.1 Animation Tokens

```markdown
# Animation & Motion

## Timing

| Token | Duration | Usage |
|-------|----------|-------|
| instant | 0ms | Immediate feedback |
| fast | 150ms | Micro-interactions |
| normal | 200ms | Standard transitions |
| slow | 300ms | Page transitions |
| slower | 500ms | Complex animations |

## Easing

| Name | Curve | Usage |
|------|-------|-------|
| ease-out | cubic-bezier(0, 0, 0.2, 1) | Enter animations |
| ease-in | cubic-bezier(0.4, 0, 1, 1) | Exit animations |
| ease-in-out | cubic-bezier(0.4, 0, 0.2, 1) | Move/resize |
| linear | linear | Progress bars |

## Standard Transitions

### Hover States
- Duration: 150ms
- Easing: ease-out
- Properties: background-color, border-color, box-shadow

### Focus States
- Duration: 100ms
- Easing: ease-out
- Properties: box-shadow (ring)

### Page Transitions
- Duration: 300ms
- Easing: ease-in-out
- Type: Fade or slide

### Modal/Overlay
- Enter: 200ms ease-out
- Exit: 150ms ease-in
- Backdrop: fade 200ms

## Micro-interactions

### Button Press
```
hover: scale(1.02), translateY(-1px), shadow increase
active: scale(0.98), translateY(0), shadow decrease
duration: 150ms
```

### Card Hover
```
hover: translateY(-4px), shadow-xl
duration: 200ms ease-out
```

### Form Validation
```
error-shake: translateX(-4px, 4px, 0)
duration: 300ms
```
```

### 6.2 State Documentation

```markdown
# Component States

## Interactive States Matrix

| Component | Default | Hover | Focus | Active | Disabled | Loading |
|-----------|---------|-------|-------|--------|----------|---------|
| Button | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Input | ✓ | ✓ | ✓ | - | ✓ | - |
| Link | ✓ | ✓ | ✓ | ✓ | ✓ | - |
| Card | ✓ | ✓ (if interactive) | ✓ | - | - | ✓ |
| Checkbox | ✓ | ✓ | ✓ | - | ✓ | - |

## Empty States

Every data-driven component needs an empty state:

```
┌─────────────────────────────────┐
│                                 │
│         [Illustration]          │
│                                 │
│     No [items] yet              │
│                                 │
│  Description of what to do      │
│                                 │
│     [Primary Action]            │
│                                 │
└─────────────────────────────────┘
```

## Loading States

### Skeleton
- Use for content that will load
- Match exact layout of loaded content
- Subtle pulse animation (1.5s infinite)
- Background: Gray 100 → Gray 200 → Gray 100

### Spinner
- Use for actions in progress
- 24px default size
- Primary color
- Animation: rotate 1s linear infinite

### Progress Bar
- Use for determinate progress
- Show percentage if known
- Height: 4px (minimal) or 8px (prominent)
```

---

## 7. Asset Export Specifications

### 7.1 Image Export

```markdown
# Asset Export Guidelines

## Icons

| Format | Size | Usage |
|--------|------|-------|
| SVG | Vector | Web, modern apps |
| PNG @1x | 24px | Legacy fallback |
| PNG @2x | 48px | Retina displays |
| PNG @3x | 72px | High-DPI mobile |

Naming: `icon-[name]-[size].svg`
Example: `icon-arrow-right-24.svg`

## Illustrations

| Format | Max Width | Quality |
|--------|-----------|---------|
| SVG | Vector | Preferred |
| PNG @1x | 800px | 80% quality |
| PNG @2x | 1600px | 80% quality |
| WebP | Same | 80% quality |

Naming: `illustration-[name]-[variant].svg`

## Photos

| Usage | Format | Max Width | Quality |
|-------|--------|-----------|---------|
| Hero | WebP + JPG fallback | 1920px | 85% |
| Card | WebP + JPG | 800px | 80% |
| Avatar | WebP + JPG | 200px | 85% |
| Thumbnail | WebP + JPG | 400px | 75% |

Naming: `photo-[name]-[size].webp`

## Favicon Package

```
favicon.ico (16x16, 32x32)
favicon-16x16.png
favicon-32x32.png
apple-touch-icon.png (180x180)
android-chrome-192x192.png
android-chrome-512x512.png
site.webmanifest
```

## OG Images

| Platform | Size | Format |
|----------|------|--------|
| Default OG | 1200 x 630 | PNG/JPG |
| Twitter | 1200 x 628 | PNG/JPG |
| LinkedIn | 1200 x 627 | PNG/JPG |

Naming: `og-[page-name].png`
```

### 7.2 Figma Export Settings

```markdown
# Figma Export Checklist

## Before Export

- [ ] All components properly named
- [ ] Variants organized
- [ ] Auto-layout applied where appropriate
- [ ] Constraints set for responsive behavior
- [ ] Colors use shared styles
- [ ] Typography uses text styles
- [ ] Spacing consistent with tokens

## Export Settings

### For Icons
- Format: SVG
- Include "id" attribute: Yes
- Outline text: Yes
- Flatten: If complex

### For Mockups
- Format: PNG @2x
- Background: Include/Exclude as needed

### For Handoff
- Use Figma's Dev Mode
- Enable code snippets (CSS)
- Link to documentation

## Handoff Checklist

- [ ] Design file shared with developers
- [ ] Components documented
- [ ] Tokens exported (JSON or CSS)
- [ ] Assets exported and organized
- [ ] Spec document completed
- [ ] Questions channel established
```

---

## 8. Handoff Checklist

```markdown
# Design Handoff Checklist

## Documentation Complete

- [ ] Project brief and goals documented
- [ ] User flows documented
- [ ] Sitemap/IA documented
- [ ] All foundations specified (colors, type, spacing, grid)
- [ ] All components specified with states
- [ ] All pages specified with responsive behavior
- [ ] Interactions and animations documented
- [ ] Accessibility requirements noted

## Assets Delivered

- [ ] Design files shared (Figma/Sketch)
- [ ] Icons exported (SVG)
- [ ] Illustrations exported
- [ ] Photos optimized and exported
- [ ] Favicon package generated
- [ ] OG images created

## Tokens Exported

- [ ] Colors (CSS variables or JSON)
- [ ] Typography (CSS or JSON)
- [ ] Spacing (CSS or JSON)
- [ ] Shadows (CSS or JSON)
- [ ] Border radii (CSS or JSON)

## Communication

- [ ] Kickoff meeting scheduled
- [ ] Questions channel created (Slack/Discord)
- [ ] Review milestones defined
- [ ] Feedback process established
```

---

## References

- `CORE.md` - Design principles
- `STYLES/INDEX.md` - Style selection
- `PATTERNS/components.md` - Component patterns
- `svg-mockups.md` - SVG mockup creation

---

*Version: 0.1.0*
