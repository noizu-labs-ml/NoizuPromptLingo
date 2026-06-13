# Skill Structure Patterns

Five archetypes for organizing a skill. Each maps to a distinct knowledge shape, usage pattern, and SKILL.md style.

---

## Archetype Selection Guide

Before reading the full descriptions, use this table to find your archetype:

| If your skill does this...                          | Choose archetype  |
|-----------------------------------------------------|-------------------|
| Answers lookup questions from a large reference set | Catalog           |
| Walks users through a multi-phase process           | Workflow          |
| Is invoked by other skills as a shared capability   | Service           |
| Helps users make a major strategic decision         | Strategy          |
| Teaches how to build or improve other skills        | Meta              |
| Produces a single type of artifact on demand        | Workflow (light)  |
| Has deeply varied use cases with many output types  | Service           |
| Is an advisory layer over a large problem space     | Strategy          |

---

## Archetype 1: Catalog

### Description

A heavily populated knowledge base organized for fast lookup. The agent reads an index first, then navigates to numbered files. Process is minimal — the value is in the reference content itself.

### When to Use

- The skill's primary job is answering "what is" or "how does X work" questions
- Knowledge is stable and reference-shaped (not workflow-shaped)
- Users will consult the skill repeatedly as a reference rather than running a one-time process
- The domain has many distinct topics that benefit from numbered/indexed organization

### Directory Structure

```
skill-name/
├── SKILL.md
├── kb/
│   ├── index.md              # Quick reference + navigation guide
│   ├── summary.md            # Compressed overview of all files
│   ├── 00-sources.md         # (optional) Source list
│   ├── 01-topic-one.md
│   ├── 02-topic-two.md
│   ├── 03-topic-three.md
│   └── ...                   # Numbered files, each covering one topic
└── assets/
    └── (templates, checklists)
```

### SKILL.md Emphasis

- Short workflow section (usually just: read summary → consult KB file → output)
- Prominent "Knowledge Base" section listing all numbered files with one-line descriptions
- Mode table if multiple operations exist (audit / optimize / generate / measure)
- Navigation hint: "Read `kb/summary.md` first, then consult numbered files as needed"

### Reference Organization

- `kb/` is the primary content store, not `references/`
- Files are numbered to establish a canonical reading order
- `index.md` maps user questions to file numbers
- `summary.md` provides compressed context the agent loads every invocation

### Exemplar: trl-seo-guru

```
seo-guru/
├── SKILL.md
└── kb/
    ├── 00-sources-index.md
    ├── 01-ai-seo-complete-guide.md
    ├── 02-platform-specific-geo.md
    ├── 03-aeo-complete-guide.md
    ├── 04-structured-data-for-llms.md
    ├── 05-adobe-llm-optimizer-best-practices.md
    ├── 06-geo-cross-functional-strategy.md
    ├── 07-geo-vs-seo.md
    ├── 08-seo-aeo-geo-complete-guide.md
    ├── 09-aeo-llmrefs-guide.md
    ├── 10-geo-llmrefs-guide.md
    ├── 11-optimize-chatgpt-perplexity.md
    ├── 12-structured-data-seo-geo.md
    ├── index.md
    └── summary.md
```

The SKILL.md opens with a four-mode workflow (audit/optimize/generate/measure), then lists all KB files by number with a one-line description. Users don't need to read the full KB — the index routes them to the right file.

---

## Archetype 2: Workflow

### Description

A step-by-step process skill with moderate reference support. The agent follows phases and consults reference files at specific steps. Process is primary; knowledge base is secondary.

### When to Use

- The skill produces an artifact through a defined sequence of steps
- Users engage the skill to complete a task, not to look something up
- The domain has a canonical "right order" of operations
- There's a clear entry point (intake/brief) and exit point (deliverable)

### Directory Structure

```
skill-name/
├── SKILL.md
├── references/
│   ├── agent-playbook.claude-code.md   # Claude Code-specific instructions
│   ├── agent-playbook.md               # General agent workflow
│   ├── {domain}-guide.md               # Core methodology
│   ├── templates-reference.md          # Reusable output templates
│   ├── platform-setup.md               # (optional) Platform-specific setup
│   └── worked-example-{name}.md        # Worked example showing full output
└── assets/
    └── (trackers, starter templates)
```

### SKILL.md Emphasis

- Prominent workflow diagram (mermaid flowchart) showing phases
- "When to Use This Skill" section with bullet-point scenarios
- Phase table: Phase → Action → Reference file
- Selection tables for choosing between product types, approaches, or platforms
- Cross-references to upstream/downstream skills

### Reference Organization

- `agent-playbook.claude-code.md` is the primary execution guide for Claude Code
- Domain guides cover the methodology in depth
- Templates live separately so they can be referenced without reading methodology
- One worked example per major product type or use case

### Exemplar: trl-ai-templates

```
ai-templates/
├── SKILL.md
└── references/
    ├── agent-playbook.claude-code.md
    ├── agent-playbook.md
    ├── platform-setup.md
    ├── templates-reference.md
    └── worked-example-devops-prompt-kit.md
```

The SKILL.md contains a full product type table with price ranges and dev time estimates, a "When to Use" section, a phase-by-phase workflow, and cross-references to `trl-market-intelligence` and `trl-monetization-strategy`.

---

## Archetype 3: Service

### Description

A deep, multi-dimensional reference library for a cross-cutting capability. This skill is invoked by other skills and by users directly. It has many output types organized into subdirectories. The SKILL.md is a comprehensive navigation hub.

### When to Use

- Multiple other skills depend on this skill for part of their workflow
- The domain covers fundamentally different output types (evaluation, code output, design patterns, process guides)
- Users invoke it from many different starting points with different goals
- The skill has 10+ reference files and would be confusing without subdirectory organization

### Directory Structure

```
skill-name/
├── SKILL.md                            # Navigation hub (400+ lines)
├── references/
│   ├── eval/                           # Evaluation and audit guides
│   │   └── *.md
│   ├── outputs/                        # Output format guides
│   │   └── *.md
│   ├── patterns/                       # Reusable patterns and components
│   │   └── *.md
│   ├── process/                        # Step-by-step process guides
│   │   └── *.md
│   ├── styles/                         # Style catalogs and examples
│   │   └── *.md
│   ├── core-philosophy.md              # Foundational principles
│   └── worked-example-{name}.md       # End-to-end example
└── assets/
    └── (templates, mockups)
```

### SKILL.md Emphasis

- Long-form skill map showing all subdirectories and their contents
- "When to Use" section covering all distinct use cases with guidance
- Invocation patterns for different user entry points
- Cross-references throughout (not just in a Related Skills section at the bottom)
- Style catalog table with quick-reference style options

### Reference Organization

Subdirectories by output type, not by topic:
- `eval/` — things the skill assesses
- `outputs/` — things the skill produces
- `patterns/` — reusable components within outputs
- `process/` — how to do the work
- `styles/` — stylistic variation guides

### Exemplar: trl-user-experience-engineer

```
user-experience-engineer/
├── SKILL.md
└── references/
    ├── eval/
    │   ├── accessibility-audit.md
    │   ├── automated-checks.md
    │   ├── conversion-benchmarks.md
    │   ├── heuristics.md
    │   ├── performance-budget.md
    │   └── rubrics.md
    ├── outputs/
    │   ├── engine-styleguide.md
    │   ├── figma-spec.md
    │   ├── html-css.md
    │   ├── landing-pages.md
    │   ├── nextjs.md
    │   ├── p5js.md
    │   ├── svg-logos.md
    │   ├── svg-mockups.md
    │   └── textual-tui.md
    ├── patterns/
    │   ├── accessibility.md
    │   ├── components.md
    │   ├── interaction.md
    │   ├── layout.md
    │   └── responsive.md
    ├── process/
    │   ├── brief-interpretation.md
    │   ├── design-sprint.md
    │   ├── handoff.md
    │   ├── iteration.md
    │   ├── quality-gates.md
    │   ├── style-guide-construction.md
    │   └── validation-sprint.md
    └── styles/
        ├── bold-expressive.md
        ├── consumer-playful.md
        ├── corporate-enterprise.md
        ├── editorial.md
        ├── minimal-tech.md
        └── nocturne.md
```

The SKILL.md is 400+ lines — a full navigation hub with style tables, output format selection, invocation patterns, and cross-references. It reads like a capability map.

---

## Archetype 4: Strategy

### Description

A decision-framework skill. Light on execution detail, heavy on comparison matrices, assessment guides, and selection tools. The skill helps users make a major decision, then hands off to execution skills.

### When to Use

- The skill's primary output is a decision or recommendation, not an artifact
- Users engage it when they're uncertain which direction to go
- The domain has meaningful tradeoffs that require structured comparison
- The skill is an "entry point" to a larger system of execution skills

### Directory Structure

```
skill-name/
├── SKILL.md
└── references/
    ├── assessment.md           # Self-assessment framework (strengths, constraints)
    ├── stream-comparison.md    # Side-by-side comparison of options
    ├── roadmap-generator.md    # Output: sequenced action plan
    └── worked-example-{name}.md
```

### SKILL.md Emphasis

- Decision trees and selection criteria front-and-center
- "When to Use This Skill" section that is actually a decision guide
- Handoff section: "once you've decided, use these skills"
- Minimal workflow (the process is: assess → compare → decide → hand off)
- Cross-references are primary navigation (this skill routes to other skills)

### Reference Organization

Flat `references/` with four canonical files:
1. Assessment framework — captures user's situation
2. Comparison matrix — structured tradeoff analysis
3. Roadmap generator — converts decision to action plan
4. Worked example — shows a realistic decision process end-to-end

### Exemplar: trl-monetization-strategy

```
monetization-strategy/
├── SKILL.md
└── references/
    ├── assessment.md
    ├── roadmap-generator.md
    ├── stream-comparison.md
    └── worked-example-backend-dev.md
```

The SKILL.md leads with "Three Income Streams" comparison tables, then "When to Use This Skill" as a decision guide. Cross-references throughout route to `trl-ai-templates`, `trl-content-publishing`, `trl-print-on-demand`, and `trl-conversion-engineer`.

---

## Archetype 5: Meta

### Description

A skill that teaches a practice and generates artifacts that are themselves skill components. Self-referential by design — the skill demonstrates the practices it teaches. Reference organization includes patterns, worked examples, and catalogs.

### When to Use

- The skill's output is other skills (or components of other skills)
- The domain is a practice that applies to itself
- Worked examples are essential because the output is complex and structural
- The skill needs to serve both discovery (what to build) and execution (how to build it)

### Directory Structure

```
skill-name/
├── SKILL.md                            # Demonstrates the practice it teaches
├── references/
│   ├── discovery-workflow.md           # How to identify the need
│   ├── ecosystem-conventions.md        # Governing rules for the system
│   ├── quality-checklist.md            # How to verify output quality
│   ├── scaffold-specification.md       # Formal specification for outputs
│   ├── skill-design-principles.md      # Design philosophy
│   ├── npl-integration-guide.md        # Integration with agent infrastructure
│   ├── mcp-catalog/                    # Catalog of related tools/integrations
│   │   └── *.md
│   └── patterns/                       # Pattern library
│       ├── skill-structure-patterns.md   # (this file)
│       ├── trigger-language-patterns.md
│       └── cross-reference-patterns.md
└── examples/
    └── {worked-example}/              # Full skill examples
```

### SKILL.md Emphasis

- Demonstrates conventions it defines (assumptions table, mind reading, mermaid)
- Explicit "what this skill produces" section
- Reference map showing all sub-documents and their purpose
- Meta-commentary where appropriate ("this SKILL.md is itself an example of...")
- Quality gates — how to verify the skill you just wrote is correct

### Reference Organization

Three layers:
1. Core references (flat) — principles, conventions, specs, checklists
2. Patterns (subdirectory) — reusable structural patterns
3. Examples (separate top-level dir) — complete worked examples

### Exemplar: trl-skill-engineer

```
skill-engineer/
├── SKILL.md
├── references/
│   ├── discovery-workflow.md
│   ├── ecosystem-conventions.md
│   ├── npl-integration-guide.md
│   ├── quality-checklist.md
│   ├── scaffold-specification.md
│   ├── skill-design-principles.md
│   ├── mcp-catalog/
│   └── patterns/
│       ├── skill-structure-patterns.md
│       ├── trigger-language-patterns.md
│       └── cross-reference-patterns.md
└── examples/
```

The SKILL.md opens with what the skill produces, demonstrates the exact conventions (mermaid, cross-references, assumptions table) it teaches, and includes a quality gate section for verifying skill output.

---

## Quick Reference

| Archetype | Primary nav     | SKILL.md length | Reference depth  | Main output      |
|-----------|-----------------|-----------------|------------------|------------------|
| Catalog   | Numbered files  | Medium (150 ln) | `kb/` flat       | Answers          |
| Workflow  | Phase steps     | Medium (200 ln) | `references/` flat | Artifacts      |
| Service   | Subdirectories  | Long (400+ ln)  | `references/**`  | Many output types |
| Strategy  | Decision trees  | Medium (150 ln) | `references/` flat | Decisions      |
| Meta      | Pattern library | Long (300+ ln)  | `references/` + `patterns/` + `examples/` | Other skills |
