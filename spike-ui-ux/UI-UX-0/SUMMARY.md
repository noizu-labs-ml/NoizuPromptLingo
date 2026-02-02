# UI-UX-0 Summary

## Purpose

This directory contains a comprehensive **UX/UI Design Agent System** with integrated **Marketing & Validation** capabilities. It provides structured prompts, methodologies, and patterns for AI agents to execute design and validation work from ideation through production.

The system emphasizes:
- **LLM-native workflows**: Text-based wireframes (ASCII, PlantUML Salt, Wireweave DSL)
- **Lean validation**: Market testing before building
- **Design-as-code**: Version-controllable, token-efficient formats
- **Conversion focus**: Measurable outcomes over aesthetics

## Main Themes

### 1. **Design Agent System (ux-ui-agent/)**
Complete specifications for an AI design partner that interprets briefs, generates designs across fidelity levels, and produces production-ready code.

**Core capabilities:**
- Multi-format wireframing (ASCII, Salt, Wireweave, Mermaid)
- Style selection and application (5 documented styles)
- Platform-specific output (Next.js, HTML/CSS, p5.js, Textual TUI, SVG, Figma)
- Pattern library (layout, components, interactions, responsive, accessibility)

### 2. **Marketing & Validation Specialist (MARKETING.md)**
Rapid idea testing framework for validating product concepts before building.

**Key functions:**
- Persona generation from elevator pitches
- Positioning strategy development (5 archetypes)
- Landing page design for conversion testing
- Channel-specific ad creative
- Image quality assessment and platform requirements

### 3. **Quality & Evaluation Framework (EVAL/)**
Objective measurement systems for design quality across multiple dimensions.

**Assessment types:**
- Automated: Accessibility (axe-core), Performance (Lighthouse), Code quality (ESLint)
- Manual: Design rubrics, heuristic reviews, conversion analysis
- Benchmarks: Industry standards, historical data, competitor baselines

### 4. **Process & Methodology (PROCESS/)**
Structured workflows from brief to delivery.

**Key processes:**
- **Brief Interpretation**: Requirements extraction
- **Validation Sprint**: 1-2 week market testing cycle
- **Design Sprint**: 2-4 week full design workflow
- **Iteration Protocol**: Feedback incorporation
- **Quality Gates**: Phase transition checkpoints
- **Handoff**: Design-to-development transfer

### 5. **Implementation Guides (OUTPUTS/)**
Platform-specific technical specifications.

**Target platforms:**
- Web: Next.js (App Router), vanilla HTML/CSS, landing pages
- Interactive: p5.js prototypes
- Terminal: Python Textual TUI
- Documentation: SVG mockups, Figma specs

## Organization

**44 files** organized by function:

| Directory | Files | Focus |
|-----------|-------|-------|
| Root | 7 | Quick-reference evaluation docs |
| ux-ui-agent/CORE | 3 | Foundational principles + wireframe formats |
| ux-ui-agent/EVAL | 7 | Quality measurement tools |
| ux-ui-agent/OUTPUTS | 8 | Platform implementation guides |
| ux-ui-agent/PATTERNS | 6 | Reusable component library |
| ux-ui-agent/PROCESS | 7 | Workflows and methodologies |
| ux-ui-agent/STYLES | 6 | Visual style systems |

## Key Files to Review First

### Quick Start (Essential 5)
1. **INDEX.md** - System overview (NOTE: Currently shows passive income content - likely needs updating to match UI/UX focus)
2. **ux-ui-agent/CORE.md** - Design agent identity, principles, decision framework
3. **ux-ui-agent/MARKETING.md** - Validation specialist capabilities
4. **ux-ui-agent/WIREFRAMES.md** - Text-based wireframe formats reference
5. **ux-ui-agent/PROCESS/INDEX.md** - Workflow selection guide

### Deep Dive (By Use Case)

**For design work:**
- CORE.md → STYLES/INDEX.md → PATTERNS/INDEX.md → OUTPUTS/INDEX.md

**For validation/testing:**
- MARKETING.md → PROCESS/validation-sprint.md → OUTPUTS/landing-pages.md → EVAL/conversion-benchmarks.md

**For quality assurance:**
- EVAL/INDEX.md → EVAL/rubrics.md → EVAL/automated-checks.md

**For implementation:**
- OUTPUTS/INDEX.md → [specific format].md → PATTERNS/[category].md

## Notable Features

### Token Efficiency
ASCII wireframes use ~30-60 tokens per screen vs 800-1200 for HTML/CSS equivalents, enabling inclusion of entire design systems in LLM context windows.

### Multi-Stage Output Pipeline
```
ASCII/Salt → Wireweave → SVG Mockups → Production Code
   (30t)      (150t)        (varies)       (800t+)
```

### Style Systems
5 documented styles with selection heuristics:
- Minimal Tech (AI/SaaS)
- Corporate Enterprise (Finance/Healthcare)
- Consumer Playful (Lifestyle/E-commerce)
- Editorial (Publishing/Content)
- Bold Expressive (Creative/Fashion)

### Validation-First Approach
Emphasizes market testing via landing pages and ad campaigns before committing to full product development.

## Integration Context

This appears to be part of a larger **Noizu Prompt Lingo (NPL)** system based on references to:
- NPL framework integration
- MCP (Model Context Protocol) server hooks
- Eval system integration
- Agent orchestration patterns

The system is designed for AI agents working within conversation contexts, with explicit token budgeting, version control integration, and markdown-native documentation.
