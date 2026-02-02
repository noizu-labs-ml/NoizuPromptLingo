# UI-UX-0 Layout

```
UI-UX-0/
├── INDEX.md - Passive income system overview, personas, revenue projections, tracking structure
│
├── accessibility-audit.md - WCAG compliance testing and audit procedures
├── automated-checks.md - Axe, Lighthouse, linting configurations for automated QA
├── conversion-benchmarks.md - Industry standards and metrics for conversion optimization
├── heuristics.md - Nielsen's 10 usability heuristics and evaluation framework
├── performance-budget.md - Performance targets, Core Web Vitals monitoring
├── rubrics.md - Scoring criteria for design quality assessment
│
└── ux-ui-agent/ - Comprehensive UX/UI design system and agent specifications
    ├── CORE.md - Foundational principles: identity, decision framework, quality defaults, output spectrum (wireframes→production)
    ├── MARKETING.md - Lean validation specialist: persona generation, positioning strategy, channel selection, landing pages
    ├── WIREFRAMES.md - Text-based wireframe formats: ASCII, PlantUML Salt, Wireweave DSL, Mermaid flows
    │
    ├── EVAL/ - Quality assessment framework
    │   ├── INDEX.md - Evaluation system overview, metrics, thresholds, timing
    │   ├── accessibility-audit.md - Detailed WCAG testing procedures
    │   ├── automated-checks.md - CI/CD integration for axe-core, Lighthouse, ESLint
    │   ├── conversion-benchmarks.md - Industry baseline metrics and analysis
    │   ├── heuristics.md - Expert review protocols and scoring
    │   ├── performance-budget.md - Load time targets, optimization strategies
    │   └── rubrics.md - Multi-dimensional design quality scoring
    │
    ├── OUTPUTS/ - Format-specific implementation guides
    │   ├── INDEX.md - Output selection matrix by project phase and deliverable type
    │   ├── figma-spec.md - Design handoff documentation and export specifications
    │   ├── html-css.md - Vanilla HTML/CSS patterns, design tokens, utilities
    │   ├── landing-pages.md - Conversion-focused page patterns, A/B testing, analytics
    │   ├── nextjs.md - Next.js App Router patterns, components, forms, deployment
    │   ├── p5js.md - Interactive prototyping, animations, gesture handling
    │   ├── svg-mockups.md - SVG mockup templates, annotation system, version control
    │   └── textual-tui.md - Python TUI components, forms, themes, terminal design
    │
    ├── PATTERNS/ - Reusable UI component and interaction library
    │   ├── INDEX.md - Pattern catalog by category, composition rules, quality checklist
    │   ├── accessibility.md - Inclusive design patterns: visual, keyboard, screen reader, cognitive
    │   ├── components.md - UI elements: buttons, forms, cards, navigation, modals, feedback, data display
    │   ├── interaction.md - Motion patterns: micro-interactions, transitions, loading states, animations
    │   ├── layout.md - Page structures: bento grid, single column, sidebar, asymmetric, scroll snap
    │   └── responsive.md - Adaptive strategies: fluid typography, container queries, mobile nav, touch optimization
    │
    ├── PROCESS/ - Workflows and methodologies
    │   ├── INDEX.md - Process selection framework, phase overview, integration points
    │   ├── brief-interpretation.md - Requirements extraction, assumption surfacing, constraint identification
    │   ├── design-sprint.md - Full design workflow: discovery, design, specification, handoff
    │   ├── handoff.md - Design-to-development protocols, asset delivery, documentation
    │   ├── iteration.md - Feedback cycles, prioritization, revision protocols
    │   ├── quality-gates.md - Phase transition checkpoints, approval criteria
    │   └── validation-sprint.md - Rapid idea testing: strategy, assets, measurement, decision
    │
    └── STYLES/ - Visual style systems and selection heuristics
        ├── INDEX.md - Style selection framework, industry defaults, customization guidelines
        ├── bold-expressive.md - Anti-design, brutalist, experimental style specification
        ├── consumer-playful.md - Friendly, approachable, lifestyle style specification
        ├── corporate-enterprise.md - Professional, trust-forward, institutional style specification
        ├── editorial.md - Typography-first, magazine, content-focused style specification
        └── minimal-tech.md - Barely-there UI, calm tech, VC aesthetic style specification
```

## Directory Summary

**Total:** 44 files across 7 directories

**Root Level (7 files):** Index + evaluation documents (accessibility, automated checks, conversion, heuristics, performance, rubrics)

**ux-ui-agent/ (37 files):** Complete UX/UI design system organized into core principles, marketing/validation, and five specialized subdirectories:
- **EVAL (7):** Quality assessment tools
- **OUTPUTS (8):** Platform-specific implementation guides
- **PATTERNS (6):** Reusable component library
- **PROCESS (7):** Methodologies and workflows
- **STYLES (6):** Visual style systems
