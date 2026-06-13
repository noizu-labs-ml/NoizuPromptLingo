---
name: trl-technical-writer
description: >
  Author, proof-edit, and review technical documentation for software
  applications and developer tools including onboarding guides, API docs,
  READMEs, runbooks, changelogs, and architecture documents. Use this skill
  when the user wants to write documentation from scratch, proof-edit
  existing docs for clarity and correctness, review a README, create an
  onboarding guide, restructure disorganized documentation, audit docs for
  completeness, write a getting-started tutorial, create a CLAUDE.md or
  CONTRIBUTING.md, draft release notes, or improve the readability of
  technical writing — even if they don't say "technical writer" or
  "documentation." Also trigger when users mention proof editing, copy
  editing, doc review, writing style, readability, onboarding docs,
  developer experience, DX, docs-as-code, README improvements, API
  reference, installation instructions, or troubleshooting guides.
---

# Technical Writer

Proof editor and author for software documentation — from blank page to polished, ship-ready docs.

## Overview

This skill transforms documentation needs into clear, correct, audience-calibrated technical writing. It covers the full lifecycle: authoring from scratch, structural editing, proof editing, and quality auditing. It provides:

- **Authoring methodology** — Structured process for writing docs from a brief or codebase analysis
- **Proof editing framework** — Multi-pass review covering structure, accuracy, clarity, consistency, and mechanics
- **Document type templates** — Patterns for onboarding guides, API docs, READMEs, runbooks, changelogs, and architecture docs
- **Audience calibration** — Adjusting depth, vocabulary, and assumptions for the target reader
- **Voice and tone system** — Consistent editorial voice matched to context (tutorial vs. reference vs. operations)
- **Quality rubric** — Objective scoring for documentation quality with readability metrics

## Core Philosophy

**Five Principles:**

1. **Clarity is kindness** — Every sentence should be understood on first read; if the reader has to re-read, the writer failed
2. **Accuracy over eloquence** — A technically correct but plainly written doc beats a beautifully written but misleading one
3. **The reader is busy** — Front-load the answer; structure for scanning; respect the reader's time
4. **Docs are code** — They have bugs (inaccuracies), they go stale, they need testing (review), and they deserve the same care as production code
5. **Show, don't just tell** — A working example is worth a thousand words of explanation; every concept should have a concrete illustration

## When to Use This Skill

- **Writing docs from scratch** — Given a codebase, tool, or feature, author complete documentation
- **Proof editing existing docs** — Review and improve clarity, accuracy, structure, and mechanics
- **Creating onboarding guides** — Write getting-started docs for new users or new team members
- **README authoring/review** — Create or improve project READMEs, CLAUDE.md, CONTRIBUTING.md
- **API documentation** — Write or review endpoint references, SDK guides, authentication docs
- **Runbook and operations docs** — Create troubleshooting guides, incident response procedures, operational runbooks
- **Doc quality audit** — Assess a project's documentation for gaps, staleness, and quality issues
- **Restructuring docs** — Reorganize disorganized documentation into a coherent information architecture
- **Release notes and changelogs** — Draft user-facing release communications from git history or specs

> For landing pages and marketing copy, see **trl-content-publishing** — this skill covers *technical* documentation, not promotional content.
> For SEO optimization of published docs, see **trl-seo-guru** (`kb/01-ai-seo-complete-guide.md`).
> For designing doc site UI/UX, see **trl-user-experience-engineer** (`references/outputs/html-css.md`).

## Document Types

### Type Selector

| If you need... | Choose | Typical Length | Reference |
|----------------|--------|---------------|-----------|
| New user setup | **Onboarding Guide** | 500-2000 words | `doc-types/onboarding-guides.md` |
| Endpoint/SDK reference | **API Documentation** | Varies by surface | `doc-types/api-documentation.md` |
| Project overview | **README / Project Docs** | 300-1500 words | `doc-types/readme-and-project-docs.md` |
| Ops procedures | **Runbook** | 500-3000 words | `doc-types/runbooks-and-operations.md` |
| Version history | **Changelog / Release Notes** | 100-500 words/release | `doc-types/runbooks-and-operations.md` |
| System design | **Architecture Doc** | 1000-5000 words | `doc-types/readme-and-project-docs.md` |
| Agent instructions | **CLAUDE.md** | 500-3000 words | `doc-types/readme-and-project-docs.md` |

### Audience Calibration

| Audience | Vocabulary | Assumed Knowledge | Example Depth | Reference |
|----------|-----------|-------------------|---------------|-----------|
| **New user (external)** | Plain language, define jargon | None about this tool | Full working examples | `process/audience-calibration.md` |
| **Developer (integration)** | Technical, domain-specific OK | Programming basics, HTTP, CLI | Code snippets with context | `process/audience-calibration.md` |
| **Team member (internal)** | Internal terminology OK | Codebase familiarity | References to files/modules | `process/audience-calibration.md` |
| **Operator (DevOps/SRE)** | Ops vocabulary, terse OK | Infrastructure concepts | Commands with expected output | `process/audience-calibration.md` |

## Core Workflows

### 1. Author from Scratch

```
Brief/Codebase → Audience Analysis → Information Architecture →
Outline → Draft Sections → Internal Review → Polish → Ship
```

| Phase | Action | Output | Reference |
|-------|--------|--------|-----------|
| 1. Discover | Analyze codebase, identify doc needs | Doc brief | `assets/doc-brief-worksheet.md` |
| 2. Architect | Define structure, sections, flow | Outline with section summaries | `patterns/information-architecture.md` |
| 3. Draft | Write section by section | Raw draft | `patterns/structural-patterns.md` |
| 4. Review | Self-edit for accuracy, clarity, completeness | Revised draft | `process/proof-editing-checklist.md` |
| 5. Polish | Voice/tone consistency, formatting, examples | Final doc | `patterns/voice-and-tone.md` |

> For large files (200+ lines), break into sections per the repo's large file generation protocol.

### 2. Proof Edit Existing Docs

```
Read Doc → Structural Pass → Accuracy Pass → Clarity Pass →
Consistency Pass → Mechanics Pass → Summary Report
```

Five-pass editing framework:

| Pass | Focus | Catches |
|------|-------|---------|
| **Structural** | Organization, flow, missing sections, redundancy | Wrong order, gaps, orphaned content |
| **Accuracy** | Technical correctness, code examples, commands | Outdated info, wrong flags, broken examples |
| **Clarity** | Sentence structure, jargon, ambiguity, scannability | Dense paragraphs, undefined terms, buried answers |
| **Consistency** | Terminology, formatting, voice, naming | Mixed conventions, inconsistent capitalization |
| **Mechanics** | Grammar, spelling, punctuation, links | Typos, broken links, markdown errors |

> For the complete checklist with per-pass items, see `process/proof-editing-checklist.md`.

### 3. Doc Quality Audit

```
Inventory → Gap Analysis → Staleness Check → Quality Score → Recommendations
```

| Step | Action | Output |
|------|--------|--------|
| 1. Inventory | List all docs, categorize by type | Doc map |
| 2. Gap analysis | Compare against expected docs for project type | Missing doc list |
| 3. Staleness | Check last-modified vs. code changes | Stale doc list |
| 4. Score | Apply quality rubric to each doc | Per-doc scores |
| 5. Recommend | Prioritized improvement plan | Action items |

> For the scoring rubric, see `eval/doc-quality-rubric.md`.

## Voice and Tone System

| Context | Voice | Tone | Example |
|---------|-------|------|---------|
| **Tutorial** | Conversational guide | Encouraging, patient | "Let's set up your first project. You'll need..." |
| **Reference** | Precise authority | Neutral, direct | "The `--force` flag skips confirmation prompts." |
| **Onboarding** | Friendly expert | Welcoming, supportive | "Welcome! This guide walks you through..." |
| **Runbook** | Calm operator | Urgent but controlled | "If the service is unresponsive, first check..." |
| **Changelog** | Project voice | Informative, concise | "Added support for custom themes via `config.yaml`." |
| **Architecture** | Technical peer | Analytical, thorough | "The system uses event sourcing because..." |

**Universal rules:**
- Active voice by default ("Run the command" not "The command should be run")
- Second person for instructions ("You can configure..." not "Users can configure...")
- Present tense for current behavior ("The API returns..." not "The API will return...")
- Imperative for steps ("Install the package" not "You should install the package")

> For the full voice guide with examples and anti-patterns, see `patterns/voice-and-tone.md`.

## Structural Patterns

Reusable structures for common documentation needs:

| Pattern | Use When | Structure |
|---------|----------|-----------|
| **Problem → Solution → Verification** | Troubleshooting, how-tos | State problem, give fix, show how to confirm |
| **Context → Steps → Result** | Tutorials, guides | Why we're doing this, how, what you should see |
| **Overview → Details → Reference** | Feature docs, API pages | Summary, explanation, exhaustive reference |
| **Before → During → After** | Migration guides, upgrades | Current state, transition steps, new state |
| **Concept → Example → Gotchas** | Explanatory docs | What it is, see it work, watch out for this |

> For detailed structural pattern templates, see `patterns/structural-patterns.md`.

## Quality Baselines

| Criterion | Minimum | Target | Measured By |
|-----------|---------|--------|-------------|
| **Accuracy** | All code examples run | All examples tested against current version | Manual verification |
| **Completeness** | Core use cases covered | Edge cases and errors documented | Gap analysis |
| **Readability** | Grade 10 reading level | Grade 8 reading level | Flesch-Kincaid |
| **Scannability** | Headers every 300 words | Headers every 150-200 words | Structure check |
| **Freshness** | Updated within 90 days of code change | Updated with every release | Git comparison |
| **Examples** | One example per concept | Example + counter-example per concept | Count |

> For the full quality rubric, see `eval/doc-quality-rubric.md`.
> For readability scoring methodology, see `eval/readability-metrics.md`.

## Quick Start Guides

### Write a README from Scratch
1. Read the codebase — understand what it does, who it's for, and how to use it
2. Fill out the [doc brief worksheet](assets/doc-brief-worksheet.md) (or answer discovery questions)
3. Apply the README pattern from [readme-and-project-docs.md](references/doc-types/readme-and-project-docs.md)
4. Draft section by section following [structural patterns](references/patterns/structural-patterns.md)
5. Self-edit using the [proof-editing checklist](references/process/proof-editing-checklist.md)

### Proof Edit an Existing Doc
1. Read the doc end-to-end without editing (understand intent and audience)
2. Run five editing passes per [proof-editing-checklist.md](references/process/proof-editing-checklist.md)
3. Score with [doc-quality-rubric.md](references/eval/doc-quality-rubric.md)
4. Produce summary: what changed, what improved, what still needs attention

### Create an Onboarding Guide
1. Identify the audience and their starting knowledge (see [audience calibration](references/process/audience-calibration.md))
2. Map the happy path: install → configure → first success
3. Follow the onboarding pattern in [onboarding-guides.md](references/doc-types/onboarding-guides.md)
4. Test every command and example against a fresh environment
5. Add troubleshooting section for common failure modes

### Audit a Project's Documentation
1. Inventory all existing docs (README, guides, API refs, comments)
2. Run gap analysis against expected docs for the project type
3. Score each doc with [doc-quality-rubric.md](references/eval/doc-quality-rubric.md)
4. Produce prioritized improvement plan (high-impact gaps first)

## Reference Guide

### When to Read Each Reference

| Task | Read These |
|------|-----------|
| **Starting any doc project** | `process/authoring-workflow.md`, `process/audience-calibration.md` |
| **Writing a specific doc type** | Relevant file in `doc-types/` |
| **Structuring content** | `patterns/information-architecture.md`, `patterns/structural-patterns.md` |
| **Editing/reviewing docs** | `process/proof-editing-checklist.md` |
| **Setting voice and tone** | `patterns/voice-and-tone.md` |
| **Scoring doc quality** | `eval/doc-quality-rubric.md`, `eval/readability-metrics.md` |
| **Full worked example** | `worked-example-onboarding-guide.md` |

## Related Skills

- **trl-content-publishing** — Monetize technical writing through newsletters, articles, and courses
- **trl-seo-guru** — Optimize published documentation for search engine and AI answer engine visibility
- **trl-user-experience-engineer** — Design doc site layouts, navigation, and visual presentation
- **trl-skill-engineer** — Apply documentation patterns when writing SKILL.md files and agent playbooks

## Bundled Resources

### References

**Document Types** (`references/doc-types/`):
- [onboarding-guides.md](references/doc-types/onboarding-guides.md) — Patterns and templates for getting-started guides, installation docs, and first-run experiences
- [api-documentation.md](references/doc-types/api-documentation.md) — Endpoint references, SDK guides, authentication docs, and API changelog patterns
- [readme-and-project-docs.md](references/doc-types/readme-and-project-docs.md) — README, CLAUDE.md, CONTRIBUTING.md, architecture docs, and project overview patterns
- [runbooks-and-operations.md](references/doc-types/runbooks-and-operations.md) — Operational runbooks, troubleshooting guides, incident procedures, and changelog/release notes

**Process** (`references/process/`):
- [authoring-workflow.md](references/process/authoring-workflow.md) — End-to-end workflow for writing docs from blank page to ship
- [proof-editing-checklist.md](references/process/proof-editing-checklist.md) — Five-pass editing checklist: structural, accuracy, clarity, consistency, mechanics
- [audience-calibration.md](references/process/audience-calibration.md) — Framework for adjusting depth, vocabulary, and assumptions to the target reader

**Patterns** (`references/patterns/`):
- [structural-patterns.md](references/patterns/structural-patterns.md) — Reusable document structures: problem-solution, context-steps-result, overview-details-reference
- [voice-and-tone.md](references/patterns/voice-and-tone.md) — Editorial voice guide with context-specific tone rules and anti-patterns
- [information-architecture.md](references/patterns/information-architecture.md) — Organizing docs: hierarchy, navigation, cross-linking, and progressive disclosure

**Evaluation** (`references/eval/`):
- [doc-quality-rubric.md](references/eval/doc-quality-rubric.md) — Scoring rubric for documentation quality with weighted criteria
- [readability-metrics.md](references/eval/readability-metrics.md) — Flesch-Kincaid, gunning fog, and practical readability assessment

**Worked Examples**:
- [worked-example-onboarding-guide.md](references/worked-example-onboarding-guide.md) — Full walkthrough: authoring an onboarding guide for a CLI tool from codebase analysis through polished output

### Assets

- [doc-brief-worksheet.md](assets/doc-brief-worksheet.md) — Fillable intake form for documentation projects
- [editorial-checklist.md](assets/editorial-checklist.md) — Printable checklist for the five-pass proof editing process
- [project-tracker.md](assets/project-tracker.md) — Documentation project progress tracker
