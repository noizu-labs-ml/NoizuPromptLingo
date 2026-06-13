---
name: user-experience-engineer
description: >
  Design and implement production-ready user interfaces from brief through
  implementation across web, terminal, and specification formats. Use this skill
  when the user wants to design a web app, create a landing page, build UI
  components, select a visual style, wireframe an interface, run an accessibility
  audit, generate Next.js or HTML/CSS code from designs, create SVG mockups,
  create SVG logos, prototype with p5.js, design terminal UIs, run a market
  validation sprint, evaluate design quality, or hand off specifications to
  developers — even if they don't say "UX" or "design." Also trigger when users
  mention wireframes, mockups, style guides, design systems, conversion
  optimization, WCAG compliance, responsive design, component libraries, design
  sprints, Figma specs, logos, brand marks, logomarks, logotypes, or landing
  page optimization.
---

# User Experience Engineer

Comprehensive design methodology for building conversion-focused, accessible, and beautiful interfaces. LLM-native and optimized for AI-assisted design at every stage.

## Overview

This skill transforms design briefs into production-ready interfaces through a structured, outcome-focused methodology. It provides:

- **Design philosophy** — First principles and decision frameworks
- **Market validation** — Pre-product testing and positioning
- **Quality assessment** — Objective rubrics, compliance checks, and benchmarks
- **Component library** — Reusable patterns for layouts, components, interactions, responsive, and accessibility
- **Six design systems** — Complete style specifications for different industries and audiences
- **Implementation guides** — Format-specific code generation (Next.js, HTML/CSS, p5.js, TUI, SVG, Figma, landing pages)
- **Design workflows** — Structured methodologies for sprints, iteration, and handoff

## Core Philosophy

**Five Principles:**

1. **Restraint is the default** — Start minimal; add only what earns its place
2. **Convention over innovation** — 90% familiar, 10% novel (when justified)
3. **Accessibility is architecture** — Not an afterthought; baked in from start
4. **Design serves outcomes** — Every decision traces to user/business goal
5. **Grayscale before color** — Validate structure before applying aesthetics

**2026 Design Standards:**
- Minimal UI (intentional, not sparse)
- Bento grids for dashboard layouts
- Intentional friction (respectful, not annoying)
- AI transparency (disclose AI-generated content)
- Motion as communication (not decoration)

> For the full decision framework, identity principles, and quality defaults, see [references/core-philosophy.md](references/core-philosophy.md).

## Design Systems

### Style Selector

| If you need... | Choose | Signals |
|----------------|--------|---------|
| Sophistication & focus | **Minimal Tech** | Intelligence, trust, calm |
| Reliability & security | **Corporate Enterprise** | Expertise, stability, scale |
| Fun & approachability | **Consumer Playful** | Warmth, personality, accessibility |
| Authority & depth | **Editorial** | Craftsmanship, premium, content focus |
| Innovation & disruption | **Bold Expressive** | Creativity, confidence, risk-taking |
| Immersion & atmosphere | **Nocturne** | Focus, expertise, calm intensity |

### Industry Defaults

| Industry | Default Style | Rationale |
|----------|---------------|-----------|
| SaaS/Tech | Minimal Tech | Signals competence |
| Finance/Healthcare | Corporate Enterprise | Trust is paramount |
| E-commerce (lifestyle) | Consumer Playful | Emotional purchase drivers |
| Media/Publishing | Editorial | Content is the product |
| Agency/Creative | Bold Expressive | Demonstrates capability |
| Gaming/Media/Music | Nocturne | Dark-native immersion |
| Monitoring/DevOps | Nocturne | Data on dark canvas |
| Creative Tools | Nocturne | Professional instrument feel |

### Style Mixing Rules

Styles can be combined: one dominates (80%), another accents (20%).

**Compatible:** Minimal Tech + Editorial (content-heavy SaaS), Corporate + Minimal (fintech), Playful + Editorial (lifestyle blogs), Nocturne + Minimal Tech (dark dev tools), Nocturne + Bold Expressive (dark creative portfolios)

**Risky:** Bold Expressive + Corporate (conflicting signals), Playful + Dense Data (cognitive overload), Nocturne + Consumer Playful (dark undermines warmth), Nocturne + Corporate Enterprise (dark undermines institutional trust)

> For detailed color palettes, typography scales, spacing systems, component styling, and do's/don'ts, see the individual style files in [references/styles/](references/styles/).

## Component & Pattern Library

| Category | File | Contents |
|----------|------|----------|
| **Layout** | `patterns/layout.md` | Bento grid, single column, sidebar+main, section stack, scroll snap |
| **Components** | `patterns/components.md` | Buttons, forms, cards, navigation, modals, feedback, data display |
| **Interaction** | `patterns/interaction.md` | Micro-interactions (50-100ms), hover (100-150ms), transitions (150-300ms) |
| **Responsive** | `patterns/responsive.md` | Fluid typography (`clamp()`), container queries, mobile nav, touch targets |
| **Accessibility** | `patterns/accessibility.md` | Visual contrast, keyboard nav, ARIA, screen readers, cognitive, motion |

Patterns are starting points — customize within constraints (colors yes, maintain contrast; spacing ±20%; respect reduced-motion).

> For detailed pattern specifications, see [references/patterns/](references/patterns/).

## Quality Baselines

Non-negotiable minimums for production work:

| Category | Metric | Minimum | Target |
|----------|--------|---------|--------|
| **Accessibility** | Axe violations | 0 critical/serious | 0 all |
| | WCAG level | 2.2 AA | 2.2 AA |
| | Color contrast | 4.5:1 body, 3:1 UI | — |
| **Performance** | Lighthouse | 75 | 90+ |
| | LCP | < 2.5s | < 1.5s |
| | FID | < 100ms | < 50ms |
| | CLS | < 0.1 | < 0.05 |
| **Design** | Rubric score | 7/10 | 8.5/10 |
| | Heuristic score | 70% | 85% |
| **Conversion** | Landing page | > 2% | > 5% |
| | Ad CTR | > 1% display, > 3% search | — |

### Evaluation Timing

| Phase | Evaluation | Reference |
|-------|------------|-----------|
| Wireframes | Heuristic review | `eval/heuristics.md` |
| Visual design | Design rubric | `eval/rubrics.md` |
| Implementation | Automated checks | `eval/automated-checks.md` |
| Pre-launch | Full audit | All eval files |
| Post-launch | Conversion analysis | `eval/conversion-benchmarks.md` |

> For detailed evaluation procedures, see [references/eval/](references/eval/).

## Output Spectrum

Design progresses from low to high fidelity:

```
Brief → ASCII Wireframes → PlantUML Salt → Grayscale SVG → Color Mockups
  ↓
Format-specific implementations:
  ├── Next.js/React (interactive web)
  ├── HTML/CSS (static/simple)
  ├── HTML style guide (visual design system reference)
  ├── Landing page (conversion-focused)
  ├── p5.js (interactive prototype)
  ├── Textual TUI (terminal app)
  ├── SVG mockups (visual direction)
  ├── SVG logos (brand identity)
  └── Figma spec (external handoff)
```

### Format Selection

| Need | Format | Reference |
|------|--------|-----------|
| Production web app | Next.js | `outputs/nextjs.md` |
| Marketing/conversion page | Landing Pages | `outputs/landing-pages.md` |
| Visual style guide | HTML Style Guide | `outputs/html-style-guide.md` |
| Visual direction | SVG Mockups | `outputs/svg-mockups.md` |
| Brand identity / logos | SVG Logos | `outputs/svg-logos.md` |
| Interaction testing | p5.js | `outputs/p5js.md` |
| CLI/terminal tool | Textual TUI | `outputs/textual-tui.md` |
| External handoff | Figma Spec | `outputs/figma-spec.md` |
| Static/simple site | HTML/CSS | `outputs/html-css.md` |

> For wireframe format details (ASCII, PlantUML Salt, Wireweave DSL, Mermaid), see [references/wireframes.md](references/wireframes.md).
> For implementation guides, see [references/outputs/](references/outputs/).

## Key Workflows

### 1. New Design Project (5-10 days)

```
Brief → Interpret → Select Style → Wireframe → Grayscale Mockup →
Add Color → Pattern Application → Quality Eval → Generate Output → Handoff
```

Start: `process/brief-interpretation.md` → Full sprint: `process/design-sprint.md`

### 2. Market Validation Sprint (5 weeks)

```
Pitch → Personas → Positioning → Landing Page → Ad Creative →
Traffic Experiment → Measurement → Decision: Build/Pivot/Kill
```

Start: `marketing-validation.md` → Landing page: `outputs/landing-pages.md`

### 3. Accessibility Audit (5-10 hours)

```
Automated Checks → Manual Keyboard Nav → Screen Reader Test →
Pattern Review → Documentation → Fixes → Re-test
```

Start: `eval/accessibility-audit.md` → Patterns: `patterns/accessibility.md`

### 4. Component Design (2-4 hours per component)

```
Need Identification → Pattern Selection → Style Application →
Accessibility Review → Responsive Adaptation → Documentation
```

Start: `patterns/components.md` → Style: `styles/<chosen>.md`

### 5. Style Guide Construction (2-4 hours)

```
Brief → Style Selection → Color Derivation → Typography →
Spacing/Grid → Components → Interaction → Assets → Validation
  ↓
Optional: Convert to HTML style guide (visual, browser-viewable)
```

Start: `process/style-guide-construction.md` → Examples: `styles/examples/`
HTML output: `outputs/html-style-guide.md` (font loading, templates, live components)

### Process Selection

| Goal | Process | Duration |
|------|---------|----------|
| Unclear requirements | Brief Interpretation | 1-2 hours |
| Test idea viability | Validation Sprint | 1-5 weeks |
| Design a product | Design Sprint | 2-4 weeks |
| Incorporate feedback | Iteration Protocol | Per cycle |
| Phase transition | Quality Gates | 30 min |
| Build a style guide | Style Guide Construction | 2-4 hours |
| Ready for dev | Handoff | 1-2 days |

> For detailed process methodologies, see [references/process/](references/process/).
> For market validation methodology, see [references/marketing-validation.md](references/marketing-validation.md).

## Quick Start Guides

### Designing a SaaS Product
1. Read [core-philosophy.md](references/core-philosophy.md) (philosophy)
2. [styles/minimal-tech.md](references/styles/minimal-tech.md) (SaaS default)
3. [process/brief-interpretation.md](references/process/brief-interpretation.md) (requirements)
4. [patterns/](references/patterns/) (build components)
5. [outputs/nextjs.md](references/outputs/nextjs.md) (generate code)
6. [eval/rubrics.md](references/eval/rubrics.md) (quality check)

### Validating a Product Idea
1. Read [marketing-validation.md](references/marketing-validation.md)
2. Generate personas and positioning
3. Create landing page via [outputs/landing-pages.md](references/outputs/landing-pages.md)
4. Run traffic test and measure
5. Check against [eval/conversion-benchmarks.md](references/eval/conversion-benchmarks.md)

### Improving Accessibility
1. Run [eval/accessibility-audit.md](references/eval/accessibility-audit.md)
2. Automated checks via [eval/automated-checks.md](references/eval/automated-checks.md)
3. Reference [patterns/accessibility.md](references/patterns/accessibility.md)
4. Fix violations and re-test

### Building a Style Guide
1. Complete [process/brief-interpretation.md](references/process/brief-interpretation.md)
2. Select style from Style Selector table above
3. Follow [process/style-guide-construction.md](references/process/style-guide-construction.md)
4. Reference [styles/examples/](references/styles/examples/) for worked examples
5. Validate against [eval/rubrics.md](references/eval/rubrics.md)
6. Optional: Convert to visual HTML via [outputs/html-style-guide.md](references/outputs/html-style-guide.md)

### Creating a Logo
1. Read [outputs/svg-logos.md](references/outputs/svg-logos.md) (logo types, principles, templates)
2. Select style from Style Selector table above (drives logo aesthetic)
3. Choose logo type: logomark, logotype, combo mark, monogram, or emblem
4. Build on construction grid, apply optical corrections
5. Produce all required variants (color, reversed, mono, favicon)
6. Convert text to paths for production delivery
7. Document usage rules (clear space, minimum sizes, don'ts)

### Building a Component Library
1. Reference [patterns/](references/patterns/) for each component
2. Apply chosen [styles/](references/styles/) system
3. Generate in target format via [outputs/](references/outputs/)
4. Evaluate via [eval/rubrics.md](references/eval/rubrics.md)

## Reference Guide

### When to Read Each Reference

| Task | Read These |
|------|-----------|
| **Starting any project** | `core-philosophy.md` |
| **Choosing visual direction** | `styles/<industry-default>.md` |
| **Understanding typography** | `typography.md` |
| **Understanding visual design principles** | `visual-design-principles.md` |
| **Wireframing** | `wireframes.md` |
| **Market validation** | `marketing-validation.md` + `outputs/landing-pages.md` |
| **Building layouts** | `patterns/layout.md` |
| **Building components** | `patterns/components.md` + `patterns/interaction.md` |
| **Ensuring accessibility** | `patterns/accessibility.md` + `eval/accessibility-audit.md` |
| **Responsive design** | `patterns/responsive.md` |
| **Quality evaluation** | `eval/rubrics.md` + `eval/heuristics.md` |
| **Performance tuning** | `eval/performance-budget.md` + `eval/automated-checks.md` |
| **Conversion optimization** | `eval/conversion-benchmarks.md` + `marketing-validation.md` |
| **Generating web code** | `outputs/nextjs.md` or `outputs/html-css.md` |
| **Terminal UI** | `outputs/textual-tui.md` |
| **Interactive prototype** | `outputs/p5js.md` |
| **Visual mockups** | `outputs/svg-mockups.md` |
| **Creating logos** | `outputs/svg-logos.md` + `styles/<chosen>.md` |
| **Design handoff** | `outputs/figma-spec.md` + `process/handoff.md` |
| **Running a design sprint** | `process/design-sprint.md` + `process/quality-gates.md` |
| **Building a style guide** | `process/style-guide-construction.md` + `styles/examples/` |
| **Visual HTML style guide** | `outputs/html-style-guide.md` |
| **Feedback iteration** | `process/iteration.md` |

All reference paths are relative to `references/`.

## Related Skills

- **conversion-engineer** — Coordinate multi-stream income portfolio using UX deliverables
- **market-intelligence** — Identify and validate niches before designing
- **monetization-strategy** — Choose income stream before building
- **ai-templates** — Build AI-powered digital products with UX-optimized landing pages
- **content-publishing** — Build authority through content with consistent visual identity
- **print-on-demand** — Design merchandise with brand-consistent visual systems

## Bundled Resources

### References

**Foundation** (read first for any project):
- [core-philosophy.md](references/core-philosophy.md) — Design philosophy, identity, decision framework, quality defaults
- [wireframes.md](references/wireframes.md) — Text-based wireframe formats: ASCII, PlantUML Salt, Wireweave DSL, Mermaid
- [marketing-validation.md](references/marketing-validation.md) — Market validation methodology: personas, positioning, landing pages, ad creative, conversion measurement
- [typography.md](references/typography.md) — Typography fundamentals: anatomy, classification, spacing, scale, pairing, performance, accessibility
- [visual-design-principles.md](references/visual-design-principles.md) — Seven foundations of visual design: Gestalt perception, elemental form, spatial structure, attentional hierarchy, communicative meaning, interactive affordance, systemic coherence

**Evaluation** (`references/eval/`):
- [rubrics.md](references/eval/rubrics.md) — Design quality scoring criteria (visual, interaction, copywriting, accessibility)
- [heuristics.md](references/eval/heuristics.md) — Nielsen's 10 usability heuristics with evaluation process
- [automated-checks.md](references/eval/automated-checks.md) — Axe, Lighthouse, ESLint configurations and automation
- [accessibility-audit.md](references/eval/accessibility-audit.md) — WCAG 2.2 compliance testing procedures
- [performance-budget.md](references/eval/performance-budget.md) — Core Web Vitals targets and monitoring
- [conversion-benchmarks.md](references/eval/conversion-benchmarks.md) — Industry conversion standards and benchmarks

**Process** (`references/process/`):
- [brief-interpretation.md](references/process/brief-interpretation.md) — Extract requirements, identify constraints, surface tensions
- [design-sprint.md](references/process/design-sprint.md) — 5-day rapid design methodology (discovery → design → specification → handoff)
- [validation-sprint.md](references/process/validation-sprint.md) — 5-week market validation (personas → positioning → landing page → traffic test)
- [iteration.md](references/process/iteration.md) — Feedback collection, triage, implementation, and verification cycles
- [quality-gates.md](references/process/quality-gates.md) — Phase transition checkpoints and approval criteria
- [handoff.md](references/process/handoff.md) — Developer handoff specifications and design-to-code protocols
- [style-guide-construction.md](references/process/style-guide-construction.md) — Step-by-step construction from style specs, including 80/20 mixing mechanics

**Patterns** (`references/patterns/`):
- [layout.md](references/patterns/layout.md) — Grid systems (8px, bento), page structures (sidebar, single-column, section stack)
- [components.md](references/patterns/components.md) — UI components (buttons, forms, cards, navigation, modals, feedback, data)
- [interaction.md](references/patterns/interaction.md) — Motion patterns, transitions, loading states, scroll animations
- [responsive.md](references/patterns/responsive.md) — Fluid typography, container queries, mobile navigation, touch optimization
- [accessibility.md](references/patterns/accessibility.md) — Visual, keyboard, screen reader, cognitive, and motion accessibility patterns

**Styles** (`references/styles/`):
- [minimal-tech.md](references/styles/minimal-tech.md) — Barely-there UI: monochrome + accent, SaaS/AI/fintech default
- [corporate-enterprise.md](references/styles/corporate-enterprise.md) — Trust-forward: blue palettes, serif headings, finance/healthcare
- [consumer-playful.md](references/styles/consumer-playful.md) — Friendly: rounded, vibrant colors, bento grids, micro-animations
- [editorial.md](references/styles/editorial.md) — Typography-first: serifs, generous margins, content-focused
- [bold-expressive.md](references/styles/bold-expressive.md) — Anti-design: rule-breaking, high contrast, experimental
- [examples/](references/styles/examples/) — 10 worked style guide examples for "Ipso The Lorem, Inc." (pure and mixed styles)

**Output Formats** (`references/outputs/`):
- [nextjs.md](references/outputs/nextjs.md) — Next.js App Router patterns, components, forms, deployment
- [html-css.md](references/outputs/html-css.md) — Vanilla HTML/CSS, design tokens, utility classes, responsive patterns
- [html-style-guide.md](references/outputs/html-style-guide.md) — Visual HTML style guides: font loading, base template, color swatches with contrast ratios, live typography, interactive components, spacing diagrams, print styles, multi-direction comparison
- [landing-pages.md](references/outputs/landing-pages.md) — Conversion-focused templates, A/B testing, analytics integration
- [p5js.md](references/outputs/p5js.md) — Interactive prototyping, animations, gesture handling
- [textual-tui.md](references/outputs/textual-tui.md) — Python TUI components, forms, themes, terminal patterns
- [svg-mockups.md](references/outputs/svg-mockups.md) — SVG mockup templates, annotation system, grayscale-to-hi-fi workflow
- [svg-logos.md](references/outputs/svg-logos.md) — SVG logo creation: logomarks, logotypes, combo marks, monograms, emblems, construction geometry, required variants, style integration
- [figma-spec.md](references/outputs/figma-spec.md) — Design handoff specifications, component docs, export strategy

### Assets
- [design-brief-worksheet.md](assets/design-brief-worksheet.md) — Fillable worksheet for capturing design requirements, constraints, and success criteria
- [project-tracker.md](assets/project-tracker.md) — Project tracking template for monitoring design progress, deliverables, and quality scores
