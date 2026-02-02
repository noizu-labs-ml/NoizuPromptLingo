# Skills: Specialized Agent Systems

> Specialized skill systems for AI agents working on design, conversions, and product development.

This directory contains modular agent skills developed through iterative experimentation. Each skill is LLM-agnostic and designed for rapid, high-quality output generation.

---

## Overview

**Purpose**: Provide reusable skills for AI agents across different domains.

**Philosophy**: Outcome-focused, accessibility-first, conversion-optimized, and grounded in 2026 design standards.

---

## Available Skills

| Skill | Purpose | Status |
|-------|---------|--------|
| **[Conversion Engineer](./conversion-engineer/)** | Optimize digital products for revenue, conversions, and user outcomes | In Development |
| **[User Experience Engineer](./user-experience-engineer/)** | UX/UI design methodology from discovery to production across multiple formats | In Development |

---

## Quick Navigation

### Get Started

| I want to... | Go here |
|--------------|---------|
| Generate passive income with AI templates | `passive-income-agents/ai-templates/` |
| Start a technical newsletter | `passive-income-agents/content-publishing/` |
| Design print-on-demand products | `passive-income-agents/print-on-demand/` |
| Understand design principles | `ux-ui-design-system/CORE.md` |
| Create rapid wireframes | `ux-ui-design-system/WIREFRAMES.md` |
| Select a visual style | `ux-ui-design-system/STYLES/INDEX.md` |
| Build a landing page | `ux-ui-design-system/OUTPUTS/landing-pages.md` |
| Validate a product idea | `ux-ui-design-system/MARKETING.md` |
| Access component patterns | `ux-ui-design-system/PATTERNS/INDEX.md` |

### Reference Files

| File | Purpose |
|------|---------|
| **CONSOLIDATION-GUIDE.md** | History of how this repo was organized from 8 experimental directories |
| **CORE.md** (root) | Duplicate of design system core principles (canonical version in `ux-ui-design-system/`) |
| **UI-UX-0 through UI-UX-7** | Original experimental directories (archived, see CONSOLIDATION-GUIDE.md) |

---

## Usage Examples

### Example 1: Validate a SaaS Idea

```mermaid
flowchart LR
    A[Elevator Pitch] --> B[Read MARKETING.md]
    B --> C[Generate Personas]
    C --> D[Create Landing Page]
    D --> E[Run Traffic Experiment]
    E --> F{Conversion > 3%?}
    F -->|Yes| G[Build Product]
    F -->|No| H[Iterate Positioning]
```

**Files to use:**
1. `ux-ui-design-system/MARKETING.md` - Persona generation & positioning
2. `ux-ui-design-system/PROCESS/brief-interpretation.md` - Extract core requirements
3. `ux-ui-design-system/OUTPUTS/landing-pages.md` - Build conversion-focused page
4. `ux-ui-design-system/EVAL/conversion-benchmarks.md` - Assess results

---

### Example 2: Design a Developer Tool TUI

```mermaid
flowchart LR
    A[Requirements] --> B[ASCII Wireframes]
    B --> C[Style: Minimal Tech]
    C --> D[Textual TUI Code]
    D --> E[Accessibility Review]
```

**Files to use:**
1. `ux-ui-design-system/WIREFRAMES.md` - ASCII wireframe syntax
2. `ux-ui-design-system/STYLES/minimal-tech.md` - Developer-focused style
3. `ux-ui-design-system/OUTPUTS/textual-tui.md` - Python Textual implementation
4. `ux-ui-design-system/EVAL/accessibility-checklist.md` - Keyboard nav validation

---

### Example 3: Launch an AI Prompt Library

```mermaid
flowchart LR
    A[Niche Research] --> B[Prompt Creation]
    B --> C[Package for Sale]
    C --> D[List on Gumroad]
    D --> E[Track Revenue]
```

**Files to use:**
1. `passive-income-agents/ai-templates/` - Prompt library templates
2. `ux-ui-design-system/OUTPUTS/landing-pages.md` - Sales page design
3. `passive-income-agents/ai-templates/` - Revenue tracking templates

---

## Key Features & Benefits

### Design System Benefits

✅ **Multi-Format Output** - Same design principles generate ASCII wireframes, SVG mockups, p5.js prototypes, Next.js apps, Textual TUIs, or Figma specs
✅ **Conversion-Optimized** - Every pattern includes CTA placement, trust signals, and friction reduction strategies
✅ **Accessibility Baseline** - WCAG 2.2 AA compliance baked into every component and style
✅ **Rapid Iteration** - Text-based wireframes (ASCII, PlantUML Salt, Wireweave DSL) enable fast feedback loops
✅ **Grayscale-First** - Structure validation before color prevents "pretty but broken" designs
✅ **LLM-Native** - Designed for consumption by Claude, GPT-4, and other modern LLMs

### Passive Income Benefits

✅ **Systematic Approach** - No guesswork, structured workflows from ideation to revenue
✅ **Conservative Targets** - Year 1 projections: $800-2300/month across three streams
✅ **Skill Leverage** - Optimized for technical founders with software + creative skills
✅ **Platform Agnostic** - Works with Gumroad, Substack, Etsy, Redbubble, Printful, etc.
✅ **Low Risk** - Print-on-demand has zero inventory cost; digital products are one-time effort
✅ **Compounding Returns** - Products continue earning after initial creation

---

## System Philosophy

### Design System Core Principles

1. **Restraint is the default** - Start minimal, add only what earns its place
2. **Convention over innovation** - 90% familiar patterns, 10% novel (when justified)
3. **Accessibility is architecture** - Not an afterthought, baked in from start
4. **Design serves outcomes** - Every decision traces to user/business goal
5. **Grayscale before color** - Structure validation before aesthetic polish
6. **Trust through transparency** - No dark patterns, clear communication

### Revenue System Core Principles

1. **Leverage existing skills** - Don't learn new domains; monetize what you know
2. **Market validation first** - Build audience before building product
3. **Quality over quantity** - One well-marketed product beats ten buried ones
4. **Automate fulfillment** - Digital delivery, print-on-demand, no inventory
5. **Track relentlessly** - Revenue, conversion, traffic - optimize what you measure
6. **Iterate based on data** - Let metrics guide product development

---

## Integration & Workflow

Both systems are designed to work together:

```mermaid
flowchart TD
    subgraph "Revenue Generation"
        A[Idea] --> B[MARKETING.md: Validate]
        B --> C[OUTPUTS: Landing Page]
        C --> D[Passive Income Stream]
    end

    subgraph "Design System"
        E[Brief] --> F[PROCESS: Interpret]
        F --> G[WIREFRAMES: Low-Fi]
        G --> H[STYLES: Select]
        H --> I[OUTPUTS: Production]
        I --> J[EVAL: Quality Check]
    end

    D --> E
    J --> D
```

**Example workflow:**
1. Use `passive-income-agents/` to identify a digital product opportunity
2. Use `ux-ui-design-system/MARKETING.md` to validate demand
3. Use `ux-ui-design-system/OUTPUTS/` to build the sales page
4. Use `passive-income-agents/` tracking templates to monitor revenue
5. Iterate based on conversion data

---

## File Organization

```
spike-ui-ux/
├── README.md                      # This file
├── CONSOLIDATION-GUIDE.md         # Repo history & consolidation notes
├── CORE.md                        # (Duplicate) Design principles
│
├── passive-income-agents/         # Revenue generation system
│   ├── ai-templates/
│   ├── content-publishing/
│   └── print-on-demand/
│
├── ux-ui-design-system/           # Design methodology system
│   ├── CORE.md
│   ├── MARKETING.md
│   ├── WIREFRAMES.md
│   ├── STYLES/
│   ├── PATTERNS/
│   ├── PROCESS/
│   ├── OUTPUTS/
│   └── EVAL/
│
└── UI-UX-[0-7]/                   # Archived experimental directories
    ├── INDEX.md                   # Per-directory summaries
    ├── LAYOUT.md                  # File organization
    └── SUMMARY.md                 # High-level overview
```

---

## Version & Maintenance

- **Design System Version**: 0.2.0 (2026-01-29)
- **Revenue System Version**: 0.1.0 (2026-01-27)
- **Last Updated**: 2026-02-02
- **Status**: Production-ready, actively maintained

---

## Contributing & Feedback

These systems were developed through iterative experimentation (8 spike directories consolidated). Feedback and contributions welcome:

- Design system improvements: Focus on `ux-ui-design-system/`
- Revenue strategy additions: Focus on `passive-income-agents/`
- New output formats: Add to `ux-ui-design-system/OUTPUTS/`
- New income streams: Add subdirectory to `passive-income-agents/`

---

## License

[Specify license here - MIT, Apache 2.0, etc.]

---

*Built for technical founders, designers, and LLM-powered agents who ship fast and ship well.*
