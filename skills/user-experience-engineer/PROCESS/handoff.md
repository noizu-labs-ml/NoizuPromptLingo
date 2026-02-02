# Design Handoff Protocol

> The bridge between design and development. This document defines how to prepare, deliver, and support implementation of designs.

---

## 1. Handoff Philosophy

### 1.1 Core Principles

1. **Handoff is collaboration, not delivery** - You're starting a conversation, not ending one
2. **Developers are users of your design** - Their experience matters
3. **Documentation prevents misinterpretation** - If it's not written, it doesn't exist
4. **Availability beats perfection** - Better to ship and iterate than polish forever

### 1.2 The Handoff Paradox

```
Under-documented → Developers guess → Wrong implementation
Over-documented → Developers overwhelmed → Key details missed

Goal: Right-sized documentation that answers questions before they're asked
```

---

## 2. Handoff Readiness

### 2.1 Pre-Handoff Checklist

Before scheduling handoff, ensure:

**Design Completeness:**
- [ ] All screens designed (desktop + mobile)
- [ ] All states covered (empty, loading, error, success)
- [ ] All components have defined states
- [ ] Responsive behavior documented
- [ ] Edge cases addressed

**Documentation Ready:**
- [ ] Design tokens exported
- [ ] Component specs written
- [ ] Interaction specs documented
- [ ] Accessibility notes included

**Assets Prepared:**
- [ ] Icons exported (SVG)
- [ ] Images optimized
- [ ] Fonts specified
- [ ] Favicon package ready

### 2.2 Handoff Package Contents

```
handoff/
├── README.md                 # Overview and navigation
├── design-files/
│   └── [figma-link.md]      # Links to source files
├── specs/
│   ├── foundations.md       # Colors, typography, spacing
│   ├── components.md        # Component specifications
│   ├── pages.md             # Page-specific notes
│   └── interactions.md      # Animation and behavior
├── tokens/
│   ├── colors.json
│   ├── typography.json
│   └── spacing.json
├── assets/
│   ├── icons/
│   ├── images/
│   └── favicon/
└── qa/
    └── checklist.md         # Implementation verification
```

---

## 3. Documentation Standards

### 3.1 Foundation Documentation

```markdown
# Design Foundations

## Colors

### Brand Colors
| Token | Value | Usage |
|-------|-------|-------|
| `--color-primary` | #3B82F6 | Primary actions, links |
| `--color-primary-hover` | #2563EB | Hover states |
| `--color-primary-light` | #DBEAFE | Backgrounds, highlights |

### Semantic Colors
| Token | Value | Usage |
|-------|-------|-------|
| `--color-success` | #22C55E | Positive feedback |
| `--color-warning` | #F59E0B | Caution states |
| `--color-error` | #EF4444 | Errors, destructive |

### Neutrals
| Token | Value | Usage |
|-------|-------|-------|
| `--color-gray-900` | #1E293B | Primary text |
| `--color-gray-600` | #64748B | Secondary text |
| `--color-gray-200` | #E2E8F0 | Borders |
| `--color-gray-50` | #F8FAFC | Backgrounds |

## Typography

### Font Stack
```css
--font-sans: 'Inter', system-ui, -apple-system, sans-serif;
--font-mono: 'JetBrains Mono', ui-monospace, monospace;
```

### Scale
| Token | Size | Line Height | Weight | Usage |
|-------|------|-------------|--------|-------|
| `--text-xs` | 12px | 1.4 | 400 | Captions |
| `--text-sm` | 14px | 1.5 | 400 | Secondary |
| `--text-base` | 16px | 1.5 | 400 | Body |
| `--text-lg` | 18px | 1.6 | 400 | Lead |
| `--text-xl` | 20px | 1.4 | 600 | H4 |
| `--text-2xl` | 24px | 1.3 | 600 | H3 |
| `--text-3xl` | 30px | 1.25 | 700 | H2 |
| `--text-4xl` | 36px | 1.2 | 700 | H1 |

## Spacing

Base unit: 4px

| Token | Value | Common Usage |
|-------|-------|--------------|
| `--space-1` | 4px | Tight gaps |
| `--space-2` | 8px | Icon gaps, inline |
| `--space-3` | 12px | Input padding |
| `--space-4` | 16px | Card padding |
| `--space-6` | 24px | Section padding |
| `--space-8` | 32px | Component margins |
| `--space-12` | 48px | Section margins |
| `--space-16` | 64px | Large sections |
```

### 3.2 Component Documentation

For each component, document:

```markdown
# Component: Button

## Overview
Primary interactive element for actions.

## Variants
| Variant | Background | Text | Border | Use Case |
|---------|------------|------|--------|----------|
| Primary | `--color-primary` | white | none | Main actions |
| Secondary | transparent | `--color-gray-900` | `--color-gray-200` | Secondary actions |
| Ghost | transparent | `--color-primary` | none | Tertiary, in-context |
| Destructive | `--color-error` | white | none | Delete, remove |

## Sizes
| Size | Height | Padding | Font | Min Width |
|------|--------|---------|------|-----------|
| sm | 32px | 8px 12px | 14px | 64px |
| md | 40px | 10px 16px | 14px | 80px |
| lg | 48px | 12px 24px | 16px | 96px |

## States

### Default → Hover
- Background: darken 10%
- Transition: 150ms ease-out

### Default → Focus
- Add: 2px ring, `--color-primary` @ 30% opacity
- Ring offset: 2px
- Transition: 100ms ease-out

### Default → Active
- Background: darken 15%
- Transform: scale(0.98)

### Disabled
- Opacity: 50%
- Cursor: not-allowed
- No hover/focus effects

### Loading
- Show spinner icon (16px)
- Text: "Loading..." or keep original
- Disabled interactions

## Anatomy
```
┌────────────────────────────────┐
│  [icon]  Label Text  [icon]   │
│   16px    (varies)    16px    │
└────────────────────────────────┘
      └─── 8px gap ───┘
```

## Accessibility
- Minimum touch target: 44x44px
- Focus must be visible
- Disabled buttons: `aria-disabled="true"`
- Loading buttons: `aria-busy="true"`

## Code Reference
```tsx
<Button 
  variant="primary"
  size="md"
  disabled={false}
  loading={false}
  leftIcon={<Icon />}
>
  Label
</Button>
```
```

### 3.3 Page Documentation

For each page/screen:

```markdown
# Page: Landing Page

## Overview
Primary conversion page for waitlist signup.

## URL
`/` (homepage)

## SEO
- Title: "ProductName - Tagline | Company"
- Description: "Primary value proposition in 155 characters..."
- OG Image: `/og/landing.png`

## Layout

### Desktop (1440px)
```
┌─────────────────────────────────┐
│  Header (sticky, 64px)         │
├─────────────────────────────────┤
│  Hero (min 600px)              │
│  - Headline (max-w 800px)      │
│  - Subheadline (max-w 600px)   │
│  - Form (inline, 540px total)  │
├─────────────────────────────────┤
│  Features (py-96px)            │
│  - 3-col grid, gap-24px        │
├─────────────────────────────────┤
│  CTA Section (py-64px, dark)   │
├─────────────────────────────────┤
│  Footer (py-48px)              │
└─────────────────────────────────┘
```

### Mobile (375px)
- Hero: Stack form vertically
- Features: Single column
- Padding: 16px sides, 48px vertical

## Components Used
- Header (variant: transparent → solid on scroll)
- Button (primary, lg)
- Input (default, with icon)
- FeatureCard (elevated)
- Footer (minimal)

## Interactions
| Element | Trigger | Action |
|---------|---------|--------|
| Header CTA | Click | Smooth scroll to hero form |
| Email input | Focus | Blue ring |
| Email input | Invalid submit | Shake + error message |
| Submit button | Click | Loading state → Success |
| Feature cards | Hover | Slight lift (translateY -2px) |

## States
- **Default**: Form empty, ready
- **Loading**: Button shows spinner
- **Success**: Form replaced with thank you message
- **Error**: Inline error below input

## Analytics Events
| Event | Trigger | Properties |
|-------|---------|------------|
| `page_view` | Load | `page: landing` |
| `form_focus` | Input focus | `field: email` |
| `form_submit` | Submit click | `variant: hero` |
| `signup_success` | API success | `source: landing_hero` |
```

### 3.4 Interaction Documentation

```markdown
# Interactions & Motion

## Global Timing
| Token | Duration | Use |
|-------|----------|-----|
| `--duration-fast` | 150ms | Micro-interactions |
| `--duration-normal` | 200ms | Standard transitions |
| `--duration-slow` | 300ms | Page transitions |

## Global Easing
| Token | Curve | Use |
|-------|-------|-----|
| `--ease-out` | cubic-bezier(0, 0, 0.2, 1) | Enter |
| `--ease-in` | cubic-bezier(0.4, 0, 1, 1) | Exit |
| `--ease-in-out` | cubic-bezier(0.4, 0, 0.2, 1) | Move |

## Component Transitions

### Hover Effects
```css
/* Standard hover lift */
.card:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-lg);
  transition: all 200ms var(--ease-out);
}
```

### Focus Effects
```css
/* Focus ring */
.focusable:focus-visible {
  outline: none;
  box-shadow: 0 0 0 2px var(--color-background),
              0 0 0 4px var(--color-primary);
  transition: box-shadow 100ms var(--ease-out);
}
```

### Loading States
```css
/* Spinner animation */
@keyframes spin {
  to { transform: rotate(360deg); }
}
.spinner {
  animation: spin 1s linear infinite;
}

/* Skeleton pulse */
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}
.skeleton {
  animation: pulse 1.5s ease-in-out infinite;
}
```

## Page Transitions
| From | To | Animation |
|------|-----|-----------|
| Any | Modal | Fade in 200ms + scale from 95% |
| Modal | Any | Fade out 150ms |
| Page | Page | Fade 300ms (or none for SPA) |

## Scroll Behaviors
- Smooth scroll for anchor links
- Header: Solid background after 100px scroll
- Parallax: None (performance concern)
```

---

## 4. Asset Delivery

### 4.1 Icon Export

**Format:** SVG (optimized)

**Naming:** `icon-[name].svg`

**Optimization checklist:**
- [ ] Remove unnecessary metadata
- [ ] Use `currentColor` for fills (theming)
- [ ] Viewbox: `0 0 24 24` (standard)
- [ ] No embedded fonts
- [ ] No raster images

**Export command (SVGO):**
```bash
svgo --config=svgo.config.js icons/*.svg
```

### 4.2 Image Export

| Type | Format | Sizes | Quality |
|------|--------|-------|---------|
| Hero | WebP + JPG | 1920w, 1280w, 640w | 85% |
| Card | WebP + JPG | 800w, 400w | 80% |
| Avatar | WebP + JPG | 200w, 100w | 90% |
| OG | PNG | 1200x630 | 100% |

**Naming:** `[category]-[name]-[size].[ext]`

Example: `hero-dashboard-1920.webp`

### 4.3 Design Token Export

**JSON format:**
```json
{
  "colors": {
    "primary": {
      "value": "#3B82F6",
      "type": "color"
    },
    "primary-hover": {
      "value": "#2563EB",
      "type": "color"
    }
  },
  "spacing": {
    "1": {
      "value": "4px",
      "type": "spacing"
    }
  }
}
```

**CSS variables format:**
```css
:root {
  /* Colors */
  --color-primary: #3B82F6;
  --color-primary-hover: #2563EB;
  
  /* Spacing */
  --space-1: 4px;
  --space-2: 8px;
}
```

### 4.4 Favicon Package

Required files:
```
favicon/
├── favicon.ico          # 16x16, 32x32 (legacy)
├── favicon.svg          # Modern browsers
├── apple-touch-icon.png # 180x180
├── icon-192.png         # PWA
├── icon-512.png         # PWA splash
└── site.webmanifest     # PWA manifest
```

---

## 5. Handoff Meeting

### 5.1 Meeting Agenda (60 min)

**1. Context Setting (10 min)**
- Project goals reminder
- User personas quick review
- Success metrics

**2. Design Walkthrough (25 min)**
- Key user flows (with prototype)
- Component library overview
- Responsive behavior
- State variations

**3. Technical Discussion (15 min)**
- Implementation approach
- Potential challenges
- API/data dependencies
- Performance considerations

**4. Q&A and Next Steps (10 min)**
- Open questions
- Communication channel
- Check-in schedule
- Definition of done

### 5.2 Meeting Prep Checklist

**Designer prepares:**
- [ ] Prototype link (interactive)
- [ ] Design file access granted
- [ ] Spec documents finalized
- [ ] Asset package uploaded
- [ ] Known issues documented

**Developer prepares:**
- [ ] Technical constraints list
- [ ] Questions about design
- [ ] Proposed implementation approach
- [ ] Timeline estimate

### 5.3 Post-Meeting Actions

| Action | Owner | Timeline |
|--------|-------|----------|
| Share meeting notes | Designer | Same day |
| Answer follow-up questions | Designer | 24 hours |
| Create implementation tickets | Developer | 2 days |
| First implementation review | Both | End of week 1 |

---

## 6. Implementation Support

### 6.1 Communication Protocol

**Questions Channel:**
- Use: Slack channel, Discord, or async tool
- Name: `#project-design-dev`
- Response time: Within 24 hours (business hours)

**Question Format:**
```
**Question about:** [Component/Page/Behavior]
**Context:** [What you're trying to implement]
**Specific question:** [Clear, specific question]
**Screenshot/link:** [If applicable]
```

**Designer Response:**
```
**Answer:** [Direct answer]
**Rationale:** [Why it's designed this way]
**Reference:** [Link to spec/mockup]
**Alternative:** [If there's flexibility]
```

### 6.2 Implementation Reviews

**Frequency:** Weekly or per milestone

**Format:** 30-minute screen share

**Checklist:**
- [ ] Visual accuracy (colors, spacing, typography)
- [ ] Responsive behavior
- [ ] Interactive states
- [ ] Accessibility basics
- [ ] Performance check

**Feedback Format:**
```markdown
## Implementation Review: [Component/Page]

### ✅ Looks Good
- [Item 1]
- [Item 2]

### 🔧 Needs Adjustment
| Issue | Expected | Actual | Priority |
|-------|----------|--------|----------|
| [Issue] | [Spec] | [Current] | High/Med/Low |

### 💡 Suggestions (not blockers)
- [Suggestion 1]
```

### 6.3 Change Requests

During implementation, changes may be needed. Protocol:

**Minor (< 30 min effort):**
- Discuss in channel
- Document decision
- Update spec if needed

**Major (> 30 min effort):**
- Formal change request
- Impact assessment
- Stakeholder approval if scope change
- Update all documentation

---

## 7. QA Checklist

### 7.1 Visual QA

```markdown
## Visual QA Checklist

**Typography**
- [ ] Font family matches spec
- [ ] Font sizes match scale
- [ ] Line heights correct
- [ ] Font weights correct
- [ ] No text overflow/truncation issues

**Colors**
- [ ] Brand colors match exactly
- [ ] Semantic colors correct
- [ ] No color banding/artifacts
- [ ] Dark mode (if applicable)

**Spacing**
- [ ] Margins match spec
- [ ] Padding consistent
- [ ] Alignment correct
- [ ] No unexpected gaps

**Components**
- [ ] All variants implemented
- [ ] All states work (hover, focus, active, disabled)
- [ ] Icons render correctly
- [ ] Images load properly

**Layout**
- [ ] Grid alignment correct
- [ ] Container widths correct
- [ ] No horizontal scroll
- [ ] Footer at bottom
```

### 7.2 Responsive QA

```markdown
## Responsive QA Checklist

**Breakpoints to test:**
- [ ] 375px (iPhone SE)
- [ ] 414px (iPhone Plus)
- [ ] 768px (iPad portrait)
- [ ] 1024px (iPad landscape)
- [ ] 1440px (Desktop)
- [ ] 1920px (Large desktop)

**At each breakpoint:**
- [ ] Layout adapts correctly
- [ ] Text remains readable
- [ ] Touch targets ≥44px (mobile)
- [ ] Images scale properly
- [ ] No content cut off
```

### 7.3 Interaction QA

```markdown
## Interaction QA Checklist

**Buttons**
- [ ] Hover state works
- [ ] Focus ring visible (keyboard)
- [ ] Active/pressed state
- [ ] Disabled state prevents interaction
- [ ] Loading state shows

**Forms**
- [ ] Focus states visible
- [ ] Error states display
- [ ] Validation works
- [ ] Submit button states
- [ ] Success feedback shows

**Navigation**
- [ ] All links work
- [ ] Active state indicates current page
- [ ] Mobile menu opens/closes
- [ ] Scroll behavior smooth

**Animations**
- [ ] Timing matches spec
- [ ] Easing feels natural
- [ ] No jank/stutter
- [ ] Reduced motion respected
```

### 7.4 Accessibility QA

```markdown
## Accessibility QA Checklist

**Automated (run Axe/WAVE):**
- [ ] 0 critical violations
- [ ] 0 serious violations
- [ ] Review moderate/minor

**Keyboard:**
- [ ] Tab order logical
- [ ] Focus visible always
- [ ] No keyboard traps
- [ ] Skip link works
- [ ] Modals trap focus

**Screen Reader:**
- [ ] Headings hierarchical
- [ ] Images have alt text
- [ ] Forms have labels
- [ ] Buttons have names
- [ ] Dynamic content announced

**Visual:**
- [ ] Color contrast passes (4.5:1 text)
- [ ] Not color-only indicators
- [ ] Text resizes to 200%
- [ ] Focus indicators visible
```

---

## 8. Handoff Anti-Patterns

### 8.1 Common Mistakes

| Anti-Pattern | Problem | Better Approach |
|--------------|---------|-----------------|
| **"It's in the Figma"** | No guidance, dev guesses | Written specs + Figma |
| **Pixel-perfect demands** | Unrealistic, slows dev | Acceptable ranges |
| **Missing states** | Dev invents states | Document all states |
| **"Make it pop"** | Vague, subjective | Specific, measurable criteria |
| **No mobile designs** | Dev guesses responsive | Design all breakpoints |
| **Ghost after handoff** | Dev blocked by questions | Commit to availability |

### 8.2 Acceptable Variances

Not everything needs to be exact. Define acceptable ranges:

| Property | Tolerance | Notes |
|----------|-----------|-------|
| Colors | Exact | Use tokens, no exceptions |
| Font size | ±1px | Browser rendering varies |
| Spacing | ±2px | Some flexibility OK |
| Border radius | Exact | Use tokens |
| Shadows | Match appearance | Exact values less critical |
| Animation timing | ±50ms | Feel matters more than numbers |

---

## 9. Templates

### 9.1 Handoff README Template

```markdown
# [Project Name] Design Handoff

## Quick Links
- 🎨 [Figma File](link)
- 📋 [Spec Document](link)
- 📦 [Asset Package](link)
- 💬 [Questions Channel](link)

## Overview
[1-2 sentence project description]

## Getting Started
1. Review the [foundations spec](./specs/foundations.md)
2. Check the [component library](./specs/components.md)
3. Import [design tokens](./tokens/)
4. Review [page specs](./specs/pages.md)

## Key Contacts
- Designer: [Name] - [contact]
- Stakeholder: [Name] - [contact]

## Timeline
- Handoff date: [Date]
- First review: [Date]
- Launch target: [Date]

## Known Issues
- [Issue 1] - Will address in v1.1
- [Issue 2] - Waiting for [dependency]
```

### 9.2 Implementation Review Template

```markdown
## Implementation Review: [Date]

**Reviewed:** [Page/Component]
**Build:** [URL or branch]
**Reviewer:** [Name]

### Summary
🟢 On track / 🟡 Minor issues / 🔴 Needs work

### Visual Accuracy: [Score /10]
[Notes]

### Responsive: [Score /10]
[Notes]

### Interactions: [Score /10]
[Notes]

### Issues Found
| # | Issue | Severity | Status |
|---|-------|----------|--------|
| 1 | [Issue] | High | Open |

### Next Steps
- [ ] [Action item 1]
- [ ] [Action item 2]

**Next review:** [Date]
```

---

## References

- `OUTPUTS/figma-spec.md` - Detailed spec formats
- `quality-gates.md` - Gate 3 (Handoff) and Gate 4 (Implementation)
- `iteration.md` - Handling implementation feedback
- `PATTERNS/accessibility.md` - Accessibility requirements

---

*Version: 0.1.0*
