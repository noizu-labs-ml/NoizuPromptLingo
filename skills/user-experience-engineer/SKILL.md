# User Experience Engineer Skill

**Comprehensive design methodology system for building conversion-focused, accessible, and beautiful interfaces.**

> A complete workflow from brief interpretation through implementation across multiple output formats (web, mobile, TUI, specs). LLM-native and optimized for AI-assisted design at every stage.

---

## Overview

The User Experience Engineer skill transforms design briefs into production-ready interfaces through a structured, outcome-focused methodology. It provides:

- **Design philosophy** (CORE.md) - First principles and decision frameworks
- **Market validation** (MARKETING.md) - Pre-product testing and positioning
- **Quality assessment** (EVAL/) - Objective rubrics and compliance checks
- **Component library** (PATTERNS/) - Reusable patterns for common UI needs
- **Design systems** (STYLES/) - Five complete style specifications
- **Implementation guides** (OUTPUTS/) - Format-specific code generation
- **Design workflows** (PROCESS/) - Structured methodologies for sprints and iteration

---

## Core Philosophy

**Five Principles:**

1. **Restraint is the default** - Start minimal; add only what earns its place
2. **Convention over innovation** - 90% familiar, 10% novel (when justified)
3. **Accessibility is architecture** - Not an afterthought; baked in from start
4. **Design serves outcomes** - Every decision traces to user/business goal
5. **Grayscale before color** - Validate structure before applying aesthetics

**2026 Design Standards:**
- Minimal UI (intentional, not sparse)
- Bento grids for dashboard layouts
- Intentional friction (respectful, not annoying)
- AI transparency (disclose AI-generated content)
- Motion as communication (not decoration)

---

## System Architecture

```
user-experience-engineer/
├── SKILL.md                    # This file
├── INDEX.md                    # System overview & navigation
├── CORE.md                     # Design philosophy & principles (725 lines)
├── MARKETING.md                # Market validation methodology (1025 lines)
├── WIREFRAMES.md               # Text-based wireframe formats
│
├── EVAL/                       # Quality assessment (7 files)
│   ├── INDEX.md
│   ├── rubrics.md              # Design quality scoring
│   ├── heuristics.md           # Nielsen's 10 heuristics
│   ├── automated-checks.md     # Axe, Lighthouse configs
│   ├── accessibility-audit.md  # WCAG 2.2 compliance
│   ├── performance-budget.md   # Core Web Vitals
│   └── conversion-benchmarks.md # Industry standards
│
├── PROCESS/                    # Design workflows (7 files)
│   ├── INDEX.md
│   ├── brief-interpretation.md # Extract requirements
│   ├── design-sprint.md        # 5-day rapid design
│   ├── validation-sprint.md    # 5-week market validation
│   ├── iteration.md            # Feedback loops
│   ├── handoff.md              # Developer specifications
│   └── quality-gates.md        # Gate criteria
│
├── OUTPUTS/                    # Implementation formats (8 files)
│   ├── INDEX.md
│   ├── nextjs.md               # React/Next.js production
│   ├── html-css.md             # Static HTML/CSS sites
│   ├── landing-pages.md        # Conversion-focused pages
│   ├── svg-mockups.md          # Scalable vector mockups
│   ├── p5js.md                 # Interactive prototypes
│   ├── textual-tui.md          # Terminal user interfaces
│   └── figma-spec.md           # Design handoff specs
│
├── PATTERNS/                   # Component library (6 files)
│   ├── INDEX.md
│   ├── layout.md               # Grids, bento, sidebars (~600 lines)
│   ├── components.md           # Buttons, forms, cards (~700 lines)
│   ├── interaction.md          # Transitions, animations (~500 lines)
│   ├── responsive.md           # Fluid typography, queries (~500 lines)
│   └── accessibility.md        # WCAG patterns (~600 lines)
│
└── STYLES/                     # Design systems (6 files)
    ├── INDEX.md                # Style selection framework
    ├── minimal-tech.md         # Barely-there UI (SaaS/dev)
    ├── corporate-enterprise.md # Trust-forward (finance/healthcare)
    ├── consumer-playful.md     # Friendly, approachable
    ├── editorial.md            # Typography-first (content/publishing)
    └── bold-expressive.md      # Anti-design, experimental
```

---

## Five Design Systems

### 1. Minimal Tech (Barely-There UI)
**Best for:** AI/ML, developer tools, B2B SaaS, fintech, VC startups

**Signals:** Intelligence, trust, calm, sophistication

**Characteristics:**
- Single geometric sans-serif
- Monochrome + one accent color
- Generous whitespace
- Subtle/no borders
- Data visualization as design

---

### 2. Corporate Enterprise (Trust-Forward)
**Best for:** Financial services, healthcare, legal, government, B2B enterprise

**Signals:** Reliability, expertise, stability, scale

**Characteristics:**
- Conservative typography
- Blue-dominant palettes
- Clear hierarchy
- Dense but organized
- Trust badges prominent

---

### 3. Consumer Playful (Friendly)
**Best for:** Consumer apps, e-commerce lifestyle, social, food/beverage, entertainment

**Signals:** Warmth, personality, accessibility, friendliness

**Characteristics:**
- Rounded shapes
- Vibrant warm colors
- Playful illustrations
- Bento grid layouts
- Micro-animations

---

### 4. Editorial (Typography-First)
**Best for:** Publications, long-form, portfolios, luxury brands, cultural institutions

**Signals:** Craftsmanship, premium, authority, depth

**Characteristics:**
- Typography as primary element
- Serif fonts common
- Strong vertical rhythm
- Generous margins
- Minimal UI chrome

---

### 5. Bold Expressive (Anti-Design)
**Best for:** Creative agencies, fashion/art, music, portfolios, disruptive launches

**Signals:** Creativity, confidence, innovation, risk-taking

**Characteristics:**
- Rule-breaking layouts
- High contrast combinations
- Oversized typography
- Intentional imperfection
- Experimental interactions

---

## Component Library Overview

### Layout Patterns
- **Bento Grid** - Mixed media, dashboards (8x8 grid system)
- **Single Column** - Long-form reading (52-66 char lines)
- **Sidebar + Main** - Apps, docs (25/75 split)
- **Section Stack** - Landing pages (full-width sections)

### Component Patterns
- **Buttons** (Primary, Secondary, Ghost, Danger)
- **Forms** (Inputs, Selects, Toggles, Validation)
- **Cards** (Basic, Media, Interactive, Groups)
- **Navigation** (Header, Sidebar, Tabs, Breadcrumb)
- **Modals** (Dialog, Drawer, Sheet)
- **Feedback** (Toasts, Alerts, Progress, Spinners)
- **Data** (Tables, Lists, Empty States, Pagination)

### Interaction Patterns
- **Micro-interactions** (50-100ms)
- **Hover states** (100-150ms)
- **Transitions** (150-300ms)
- **Loading states** (variable)
- **Error recovery** (clear messaging)

---

## Evaluation & Quality

### Quality Baselines (Minimum Thresholds)

**Accessibility:**
- ✅ 0 critical/serious Axe violations
- ✅ WCAG 2.2 AA compliance
- ✅ Keyboard navigable
- ✅ Screen reader compatible
- ✅ Color contrast: 4.5:1 body, 3:1 UI

**Performance:**
- ✅ Lighthouse Performance ≥75 (target ≥90)
- ✅ LCP < 2.5 seconds
- ✅ FID < 100ms
- ✅ CLS < 0.1

**Design Quality:**
- ✅ Rubric score ≥7/10 (target ≥8.5/10)
- ✅ Heuristic score ≥70% (target ≥85%)
- ✅ Core Web Vitals pass

**Conversion (where applicable):**
- ✅ Landing page conversion >2% (target >5%)
- ✅ Ad CTR >1% display, >3% search
- ✅ Email list: <$50 B2B, <$5 consumer cost per signup

---

## Output Spectrum

Design principles generate multiple formats from single design:

```
Brief
  ↓
ASCII Wireframes (fastest, no tooling)
  ↓
PlantUML Salt (structured, version-controllable)
  ↓
Grayscale SVG (validate structure)
  ↓
Color Mockups (SVG, fully designed)
  ↓
Format-specific implementations:
  ├── Next.js/React (interactive web)
  ├── HTML/CSS (static/simple)
  ├── Figma spec (handoff to designers)
  ├── p5.js (interactive prototype)
  ├── Textual TUI (terminal app)
  └── Landing page (conversion-focused)
```

---

## Key Workflows

### 1. New Design Project (5-10 days)
```
Brief → Interpret → Select Style → Wireframe →
Grayscale Mockup → Add Color → Pattern Application →
Quality Eval → Generate Output → Handoff
```

**Deliverables:** Production-ready design + implementation code

### 2. Market Validation Sprint (5 weeks)
```
Pitch → Personas → Positioning → Landing Page →
Ad Creative → Traffic Experiment → Measurement →
Decision: Build/Pivot/Kill
```

**Deliverables:** Validated demand signal + conversion metrics

### 3. Accessibility Audit (5-10 hours)
```
Automated Checks → Manual Keyboard Nav → Screen Reader Test →
Pattern Review → Documentation → Fixes → Re-test
```

**Deliverables:** Compliance report + remediation plan

### 4. Component Design (2-4 hours per component)
```
Need Identification → Pattern Selection → Style Application →
Accessibility Review → Responsive Adaptation → Documentation
```

**Deliverables:** Reusable component + specifications

---

## Quick Start Workflows

### I'm designing a SaaS product
1. Read `CORE.md` (philosophy)
2. `STYLES/minimal-tech.md` (SaaS default)
3. `PROCESS/brief-interpretation.md` (extract requirements)
4. `PATTERNS/` (build components)
5. `OUTPUTS/nextjs.md` (generate code)
6. `EVAL/rubrics.md` (quality check)

### I'm validating a product idea
1. Read `MARKETING.md`
2. Generate personas
3. Create landing page (`OUTPUTS/landing-pages.md`)
4. Run traffic test
5. Measure conversion (`EVAL/conversion-benchmarks.md`)

### I need to improve accessibility
1. Read `EVAL/accessibility-audit.md`
2. Run automated checks (`EVAL/automated-checks.md`)
3. Manual keyboard test
4. Reference `PATTERNS/accessibility.md`
5. Document and fix violations

### I'm building a component library
1. Identify 10-15 core components
2. Reference `PATTERNS/` for each
3. Apply chosen style system (`STYLES/`)
4. Generate in target format (`OUTPUTS/`)
5. Document in `EVAL/rubrics.md`

---

## Design System Specifications

Each STYLES file contains:
- **Color palette** (primary, secondary, accent, semantic, gradients)
- **Typography scale** (headings, body, caption, monospace)
- **Spacing system** (8px grid, consistent rhythm)
- **Border & shadows** (hierarchy, depth)
- **Component styling** (all PATTERNS/ applied to this style)
- **Interaction patterns** (hover, active, disabled states)
- **Do's and don'ts** (visual examples)
- **Reference sites** (real-world examples)

---

## Integration with Conversion Engineer

This skill pairs with the Conversion Engineer skill:

**Landing Pages:**
- Use `OUTPUTS/landing-pages.md` for AI template sales pages
- Use `MARKETING.md` for validation before launch
- Use `EVAL/conversion-benchmarks.md` to measure success

**Brand Identity:**
- Use `STYLES/` to establish consistent visual identity
- Apply to print-on-demand designs via POD skill
- Reinforce via newsletter and content

**Workflows:**
```
Conversion Engineer identifies opportunity
  ↓
UX Engineer validates with landing page
  ↓
If successful: Use OUTPUTS/ to build product
  ↓
Apply STYLES/ to POD merch for brand consistency
```

---

## LLM-Native Design

This system is optimized for Claude, GPT-4, and other modern LLMs:

- **Text-based wireframes** (ASCII, PlantUML Salt, Wireweave DSL)
- **Structured specifications** (YAML/JSON-friendly)
- **Code generation** (prompt-to-implementation)
- **Iterative refinement** (feedback loops built in)
- **Multi-format output** (same design → multiple implementations)

**Example prompt:**
```
@design.brief: E-commerce product page
@design.style: Consumer Playful
@design.output: Next.js component
```

---

## Version & Standards

- **System Version:** 0.2.0 (2026-01-29)
- **WCAG Compliance:** 2.2 AA minimum
- **Core Web Vitals:** All pass required
- **Design Rubric:** 7/10 minimum, 8.5/10 target
- **Browser Support:** Last 2 versions + mobile

---

## File Navigation

**Start here:**
- `CORE.md` - Design philosophy (read first)
- `INDEX.md` - Full system overview
- `MARKETING.md` - Validation before building

**Select style:**
- `STYLES/INDEX.md` - Choose visual direction
- `STYLES/minimal-tech.md` (SaaS/dev)
- `STYLES/consumer-playful.md` (consumer apps)

**Build interface:**
- `PROCESS/brief-interpretation.md` - Extract requirements
- `PATTERNS/layout.md` - Choose layout
- `PATTERNS/components.md` - Build components
- `PATTERNS/accessibility.md` - Ensure compliance

**Quality check:**
- `EVAL/rubrics.md` - Design quality
- `EVAL/accessibility-audit.md` - Compliance
- `EVAL/conversion-benchmarks.md` - Conversion (where applicable)

**Generate code:**
- `OUTPUTS/nextjs.md` - React/Next.js
- `OUTPUTS/html-css.md` - Static sites
- `OUTPUTS/landing-pages.md` - Conversion pages
- `OUTPUTS/textual-tui.md` - Terminal UIs

---

## Success Indicators

**Project goes well when:**
- Design embodies CORE principles
- Accessibility ≥ WCAG 2.2 AA
- Converts at target benchmarks
- Handoff to dev takes <1 hour
- Team provides positive feedback

**Project needs rework when:**
- Rubric score < 6/10
- Accessibility violations exist
- Conversion < 1% for landing pages
- Users confused by navigation
- Performance < 75 Lighthouse

---

## Related Documentation

- **CLAUDE.md** - Project instructions (includes UX Design System context)
- **docs/roadmap.yaml** - Product roadmap
- **docs/features-grid.md** - Implementation status
- **docs/PROJ-ARCH.md** - System architecture

---

## Version History

- **v0.2.0** (2026-01-29) - Complete system with all components
- **v0.1.0** (2026-01-20) - Initial CORE.md and MARKETING.md
- **Status:** Production-ready, actively maintained

---

*This is a living system. Patterns, styles, and processes evolve based on project learnings and industry changes. Start with `CORE.md`, then navigate using the index files and workflow guides above.*
