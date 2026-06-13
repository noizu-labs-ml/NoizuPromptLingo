---
name: trl-skill-engineer
description: >
  Design, build, and validate AI agent skills from requirements through
  production-ready scaffolds. Use this skill when the user wants to create
  a new skill, design an agent persona, build a prompt playbook, structure
  a knowledge module, evaluate skill quality, scaffold a Claude Code skill,
  integrate MCP tools into a skill, find useful MCP servers or CLI tools,
  or engineer reusable agent capabilities — even if they don't say "skill
  engineering." Also trigger when users mention prompt engineering for agents,
  building Claude skills, creating agent playbooks, MCP tool selection,
  skill scaffolding, agent instruction design, or knowledge module
  architecture.
---

# Skill Engineer

Meta-skill for designing, building, and validating AI agent skills. Works at two layers: general skill-engineering best practices and ecosystem-specific conventions.

## Overview

This skill transforms domain knowledge into structured, executable AI agent skills through a methodology that balances thoroughness with speed. It provides:

- **Design methodology** — Discovery-driven process for extracting requirements, identifying audiences, and scoping skill boundaries
- **Scaffold generation** — Complete file tree generation following canonical skill format
- **MCP & tool catalog** — Curated directory of 100+ MCP services and CLI tools organized by functional category
- **Quality validation** — Scoring rubrics, checklists, and self-bootstrap testing
- **Pattern library** — Five skill archetypes with structural templates and trigger language engineering
- **NPL awareness** — Optional integration with Noizu Prompt Lingua for advanced prompt patterns

## Core Philosophy

**Five Principles:**

1. **Constraint-driven design** — Define what the skill won't do before what it will; clear boundaries prevent scope creep and false-positive triggers
2. **Trigger precision** — The frontmatter description is the skill's API surface; engineer it like an interface contract
3. **Self-containment** — Every skill must function standalone; cross-references are advisory, never required
4. **Reference layering** — SKILL.md is the entry point (lean, scannable); depth lives in references/
5. **Testability** — A skill that can't be evaluated against its own quality criteria isn't finished

## When to Use This Skill

- **Creating a new skill from scratch** — Full interactive discovery through scaffold generation
- **Evaluating an existing skill** — Quality audit against scoring rubric and structural checklist
- **Finding MCP tools for a skill** — Browse the curated catalog or use the discovery guide to find new ones
- **Improving trigger language** — Analyze and refine a skill's frontmatter description for better precision/recall
- **Understanding skill architecture** — Learn the canonical format, layer system, and cross-reference patterns
- **Integrating NPL into a skill** — Determine if NPL adds value and how to reference it
- **Scaffolding quickly** — Provide a detailed brief and skip straight to generation

> For niche validation before building a skill-based product, see **trl-market-intelligence** (`references/niche-discovery.md`).
> For landing pages and product pages for a published skill, see **trl-user-experience-engineer** (`references/outputs/landing-pages.md`).
> For SEO optimization of skill documentation, see **trl-seo-guru** (`kb/01-ai-seo-complete-guide.md`).

## Skill Anatomy

Every skill follows an identical internal layout:

| Directory | Purpose | Required |
|-----------|---------|----------|
| `SKILL.md` | Entry point: purpose, workflow, outputs, cross-refs | Yes |
| `references/` | Deep-dive playbooks, guides, frameworks | Yes |
| `assets/` | Fillable templates, trackers, worksheets | Yes |
| `scripts/` | Reserved for future automation | No (create empty) |

### SKILL.md Required Sections

| Section | Purpose |
|---------|---------|
| **YAML Frontmatter** | `name` (kebab-case) + `description` (trigger language) |
| **H1 Title** | Matches name in Title Case |
| **Overview** | Core Purpose bullets (4-6 items) |
| **Core Philosophy** | First principles (3-5 numbered items) |
| **When to Use** | Scenario list with bold labels |
| **Cross-Reference Blockquotes** | Advisory pointers to related skills |
| **Core Content** | Domain-specific sections (tables, workflows, phases) |
| **Quick Start Guides** | 2-4 paths for common entry points |
| **Reference Guide** | Task-to-file mapping table |
| **Related Skills** | Bullet list with one-line descriptions |
| **Bundled Resources** | Full index of references/ and assets/ |

### Required Reference Files

| File | Purpose |
|------|---------|
| `agent-playbook.claude-code.md` | Agent role definition + execution workflows |
| At least one `worked-example-*.md` | End-to-end demonstration of the skill in action |

> For the full canonical format specification, see [references/ecosystem-conventions.md](references/ecosystem-conventions.md).
> For general best practices that apply across platforms, see [references/skill-design-principles.md](references/skill-design-principles.md).

## Skill Design Process

### Phase 1: Discovery

Understand the domain, audience, and constraints before building anything.

| Activity | Output | Duration |
|----------|--------|----------|
| Domain analysis | Core concepts, boundaries, anti-scope | 15-30 min |
| Audience profiling | Who uses this skill, what they know, what they need | 10-20 min |
| Use case mapping | Primary triggers, edge cases, false positives | 15-30 min |
| Tool requirements | MCP services, CLI tools, APIs needed | 10-20 min |
| Cross-reference design | Which existing skills to reference, how | 10 min |

> For the full interactive discovery protocol, see [references/discovery-workflow.md](references/discovery-workflow.md).

### Phase 2: Architecture

Translate discovery into structure.

| Activity | Output | Duration |
|----------|--------|----------|
| Select skill archetype | Structure pattern (catalog, workflow, service, strategy, meta) | 5 min |
| Design file tree | Complete directory layout with descriptions | 15 min |
| Draft trigger language | Frontmatter description with "Use this skill when..." pattern | 15 min |
| Plan reference docs | What each reference covers, dependencies between them | 20 min |
| Design quality criteria | What "good" looks like for this specific skill | 10 min |

> For skill archetype selection, see [references/patterns/skill-structure-patterns.md](references/patterns/skill-structure-patterns.md).
> For trigger language engineering, see [references/patterns/trigger-language-patterns.md](references/patterns/trigger-language-patterns.md).

### Phase 3: Scaffold

Generate the complete file tree with initial content.

```
Discovery Brief → Archetype Selection → File Tree Generation →
SKILL.md Draft → Reference Stubs → Asset Templates → Slash Command Registration
```

> For the exact output format specification, see [references/scaffold-specification.md](references/scaffold-specification.md).

### Phase 4: Content

Fill reference documents with substantive content.

| Priority | Files | Rationale |
|----------|-------|-----------|
| 1 (critical) | `agent-playbook.claude-code.md` | The skill's execution engine |
| 2 (high) | Core domain references | The skill's knowledge base |
| 3 (medium) | Worked examples | Demonstrates the skill in action |
| 4 (low) | Asset templates, additional references | Nice-to-have depth |

### Phase 5: Validation

Evaluate the skill against quality criteria.

| Check | Tool | Passing |
|-------|------|---------|
| Structural compliance | Quality checklist | All required files present |
| Trigger coverage | Scenario testing | Description matches all intended use cases |
| Self-containment | Isolation test | Skill works without other skills loaded |
| Reference depth | Content review | References add genuine value, not padding |
| Cross-reference accuracy | Link checking | All blockquote references point to real files |

> For the full quality gate, see [references/quality-checklist.md](references/quality-checklist.md).
> For the scoring rubric, see [assets/skill-scoring-rubric.md](assets/skill-scoring-rubric.md).

## Adaptive Workflow

The skill adapts based on how much information the user provides upfront:

| Input Level | Workflow | Duration |
|-------------|----------|----------|
| **Vague** ("I want a skill for X") | Full interactive discovery → architecture → scaffold → content | 2-4 hours |
| **Partial** (domain + some use cases) | Targeted questions → architecture → scaffold → content | 1-2 hours |
| **Detailed brief** (filled worksheet) | Validate → scaffold → content | 30-60 min |
| **Audit only** (existing skill) | Quality evaluation → improvement recommendations | 15-30 min |

**Completeness scoring**: The discovery phase tracks how many of 8 key dimensions have been addressed (domain, audience, use cases, constraints, tools, cross-refs, quality criteria, anti-scope). When 6+ are covered, the skill suggests moving to scaffold generation.

## Skill Archetypes

Five structural patterns cover most skill designs:

| Archetype | Example | Structure | Best For |
|-----------|---------|-----------|----------|
| **Catalog** | trl-seo-guru | Heavy KB, numbered files, light process | Reference-heavy domains |
| **Workflow** | trl-ai-templates | Phased process, moderate KB | Step-by-step methodologies |
| **Service** | trl-user-experience-engineer | Deep reference library, cross-cutting | Multi-format output skills |
| **Strategy** | trl-monetization-strategy | Decision framework, light execution | Advisory/analytical skills |
| **Meta** | trl-skill-engineer | Teaches a practice, generates artifacts | Self-referential tools |

> For detailed archetype specifications, see [references/patterns/skill-structure-patterns.md](references/patterns/skill-structure-patterns.md).

## MCP & Tool Integration

The catalog covers 100+ tools across 13 categories:

| Category | MCP Services | CLI Tools | File |
|----------|-------------|-----------|------|
| AI Coding Assistants | 5-6 | 4-5 | `mcp-catalog/ai-coding-assistants.md` |
| Code Analysis | 3-4 | 3-4 | `mcp-catalog/code-analysis.md` |
| Data & Databases | 5-6 | 2-3 | `mcp-catalog/data-and-databases.md` |
| Design & UI | 3-4 | 2-3 | `mcp-catalog/design-and-ui.md` |
| DevOps & Infrastructure | 5-6 | 3-4 | `mcp-catalog/devops-and-infra.md` |
| File & Knowledge | 5-6 | 2-3 | `mcp-catalog/file-and-knowledge.md` |
| Git & GitHub | 4-5 | 2-3 | `mcp-catalog/git-and-github.md` |
| LLM & Prompt Tools | 4-5 | 3-4 | `mcp-catalog/llm-and-prompt.md` |
| Monitoring & Observability | 4-5 | 2-3 | `mcp-catalog/monitoring-and-observability.md` |
| Search & Web | 5-6 | 2-3 | `mcp-catalog/search-and-web.md` |
| Security & Auth | 3-4 | 2-3 | `mcp-catalog/security-and-auth.md` |
| Testing & QA | 3-4 | 3-4 | `mcp-catalog/testing-and-qa.md` |
| Workflow & Automation | 4-5 | 3-4 | `mcp-catalog/workflow-and-automation.md` |

All file paths are relative to `references/`.

### When to Suggest Tools

During discovery, evaluate whether the skill under construction would benefit from MCP or CLI tool integration:

- **Always suggest** when the skill involves external data sources, APIs, or services
- **Consider suggesting** when the skill involves code generation, testing, or deployment
- **Rarely needed** for pure knowledge/advisory skills (strategy, assessment)

> For the full catalog with deployment notes and security assessments, see [references/mcp-catalog/index.md](references/mcp-catalog/index.md).
> For how to find and evaluate tools not in the catalog, see [references/mcp-catalog/discovery-guide.md](references/mcp-catalog/discovery-guide.md).

## NPL Integration

Noizu Prompt Lingua (NPL) provides advanced prompt engineering patterns that can enhance skill quality. NPL is **never required** but can be **suggested** when it would significantly improve a skill.

### When NPL Adds Value

| Scenario | NPL Feature | Benefit |
|----------|-------------|---------|
| Complex conditional logic in prompts | Formal syntax (placeholders, conditionals) | Precision over natural language |
| Multi-agent coordination | Agent declaration system | Versioned, extensible agent definitions |
| Structured reasoning requirements | Intuition pumps (chain-of-thought, reflection) | Drop-in reasoning patterns |
| Formal algorithm specification | `alg-pseudo` fences | Unambiguous procedure definitions |
| Quality self-assessment | Reflection + critique pumps | Built-in quality control |

### When NPL Is Overkill

- Simple reference/catalog skills
- Skills with straightforward linear workflows
- Skills targeting users unfamiliar with prompt engineering

### Detection

Check if NPL is available before suggesting it:
1. Check for `NPLLoad` or `NPLSpec` in available MCP tools
2. Check if `$NPL_PROJECT` environment variable is set
3. If neither: NPL is not installed — offer to explain benefits only if the skill design would significantly benefit

> For the full NPL integration guide, see [references/npl-integration-guide.md](references/npl-integration-guide.md).

## Quality Baselines

Minimum standards for any skill to ship:

| Criterion | Weight | Minimum | Target |
|-----------|--------|---------|--------|
| Trigger precision | 15% | Matches 80% of intended scenarios | 95%+ |
| Reference depth | 20% | All references add genuine value | Comprehensive domain coverage |
| Worked example quality | 20% | One realistic end-to-end example | Multiple examples covering edge cases |
| Structural compliance | 15% | All required files and sections present | Follows exemplar (UXE) formatting |
| Cross-reference accuracy | 10% | All links valid | Advisory blockquotes with file paths |
| Self-containment | 10% | Works without other skills loaded | Graceful cross-skill suggestions |
| Agent playbook quality | 10% | Role + 2 workflows | Role + 3-5 workflows with yaml steps |

**Passing score: 7.0/10 weighted average. Target: 8.5+/10.**

> For the detailed scoring rubric, see [assets/skill-scoring-rubric.md](assets/skill-scoring-rubric.md).
> For the pre-ship quality checklist, see [references/quality-checklist.md](references/quality-checklist.md).

## Quick Start Guides

### Build a Skill from Scratch
1. Fill out [skill-brief-worksheet.md](assets/skill-brief-worksheet.md) (or answer discovery questions interactively)
2. Select archetype from Skill Archetypes table above
3. Review [skill-design-principles.md](references/skill-design-principles.md) for best practices
4. Generate scaffold per [scaffold-specification.md](references/scaffold-specification.md)
5. Write `agent-playbook.claude-code.md` first (the execution engine)
6. Fill remaining references by priority (see Phase 4 table)
7. Run quality audit per [quality-checklist.md](references/quality-checklist.md)
8. Score with [skill-scoring-rubric.md](assets/skill-scoring-rubric.md) — iterate until 7.0+

### I Know What I Want (Fast Path)
1. Provide a detailed brief: domain, audience, 5+ use cases, constraints, desired outputs
2. Skill validates completeness (6+ of 8 dimensions covered)
3. Scaffold generated directly — review and refine
4. Fill content per priority order

### Evaluate an Existing Skill
1. Read [quality-checklist.md](references/quality-checklist.md) for the full gate
2. Score with [skill-scoring-rubric.md](assets/skill-scoring-rubric.md)
3. Check trigger language against [trigger-language-patterns.md](references/patterns/trigger-language-patterns.md)
4. Verify structure against [ecosystem-conventions.md](references/ecosystem-conventions.md)
5. Generate improvement recommendations

### Find Tools for a Skill
1. Browse [mcp-catalog/index.md](references/mcp-catalog/index.md) by category
2. Read category file for specific tool assessments
3. If nothing fits, use [mcp-catalog/discovery-guide.md](references/mcp-catalog/discovery-guide.md) to search
4. Evaluate candidates against security and deployment criteria

## Reference Guide

### When to Read Each Reference

| Task | Read These |
|------|-----------|
| **Starting any skill project** | `skill-design-principles.md`, `ecosystem-conventions.md` |
| **Interactive discovery** | `discovery-workflow.md` |
| **Choosing skill structure** | `patterns/skill-structure-patterns.md` |
| **Writing trigger descriptions** | `patterns/trigger-language-patterns.md` |
| **Designing cross-references** | `patterns/cross-reference-patterns.md` |
| **Choosing reasoning patterns** | `patterns/reasoning-pattern-selection.md` |
| **Wiring prompt techniques** | `patterns/prompt-engineering-patterns.md` |
| **Designing agent orchestration** | `patterns/agent-prompt-patterns.md` |
| **Generating the scaffold** | `scaffold-specification.md` |
| **Writing the agent playbook** | `agent-playbook.claude-code.md` (as format reference) |
| **Finding MCP tools** | `mcp-catalog/index.md`, then specific category files |
| **Evaluating new tools** | `mcp-catalog/discovery-guide.md` |
| **Adding NPL to a skill** | `npl-integration-guide.md` |
| **Quality evaluation** | `quality-checklist.md` + `assets/skill-scoring-rubric.md` |
| **Full build walkthrough** | `worked-example-api-debugger.md` |
| **Fast scaffold walkthrough** | `worked-example-quick-scaffold.md` |

All reference paths are relative to `references/` unless prefixed with `assets/`.

## Related Skills

- **trl-user-experience-engineer** — Design landing pages, product pages, and brand identity for published skills
- **trl-market-intelligence** — Validate niche demand before building a skill-based product
- **trl-ai-templates** — Package skills as sellable digital products (prompt libraries, workflow templates)
- **trl-content-publishing** — Write tutorials and articles that demonstrate skill capabilities
- **trl-seo-guru** — Optimize skill documentation for discoverability in search and AI engines
- **trl-conversion-engineer** — Coordinate skill-based products into a multi-stream portfolio

## Bundled Resources

### References

**Foundation** (read first for any skill project):
- [skill-design-principles.md](references/skill-design-principles.md) — General best practices: trigger language, layering, agent persona design, prompt testing, failure modes
- [ecosystem-conventions.md](references/ecosystem-conventions.md) — This repo's canonical format, layer architecture, ADRs, cross-reference rules
- [discovery-workflow.md](references/discovery-workflow.md) — Interactive discovery protocol: question sequence, adaptive branching, completeness scoring
- [scaffold-specification.md](references/scaffold-specification.md) — Output format spec: file tree, SKILL.md sections, naming conventions, slash command registration

**Quality** (read before shipping):
- [quality-checklist.md](references/quality-checklist.md) — Pre-ship quality gate: structural, trigger, content, and integration checks
- [npl-integration-guide.md](references/npl-integration-guide.md) — NPL detection, capability overview, when to suggest, integration patterns

**Patterns** (`references/patterns/`):
- [skill-structure-patterns.md](references/patterns/skill-structure-patterns.md) — Five archetypes: catalog, workflow, service, strategy, meta
- [trigger-language-patterns.md](references/patterns/trigger-language-patterns.md) — Effective trigger description engineering with examples
- [cross-reference-patterns.md](references/patterns/cross-reference-patterns.md) — Advisory cross-reference design and DAG rules
- [prompt-engineering-patterns.md](references/patterns/prompt-engineering-patterns.md) — 35 prompt engineering techniques catalog (reasoning, verification, interaction, safety, optimization) with academic sources
- [reasoning-pattern-selection.md](references/patterns/reasoning-pattern-selection.md) — Decision matrix: match problem type to reasoning pattern, composability rules, anti-patterns
- [agent-prompt-patterns.md](references/patterns/agent-prompt-patterns.md) — Agentic patterns: orchestration topologies, multi-agent reflexion, memory hierarchies, flow engineering

**MCP & Tool Catalog** (`references/mcp-catalog/`):
- [index.md](references/mcp-catalog/index.md) — Category overview, entry format, how to use the catalog
- [discovery-guide.md](references/mcp-catalog/discovery-guide.md) — How to find, evaluate, and vet new MCP services and CLI tools
- [ai-coding-assistants.md](references/mcp-catalog/ai-coding-assistants.md) — Cursor, Cline, Continue, Aider, Copilot, and related tools
- [code-analysis.md](references/mcp-catalog/code-analysis.md) — Repomix, Sourcegraph, SonarQube, CodeScene, and static analysis
- [data-and-databases.md](references/mcp-catalog/data-and-databases.md) — Supabase, Neon, Prisma, Drizzle MCP servers and DB tools
- [design-and-ui.md](references/mcp-catalog/design-and-ui.md) — Figma MCP, Storybook, browser-tools, and design tooling
- [devops-and-infra.md](references/mcp-catalog/devops-and-infra.md) — Docker, Kubernetes, Terraform, Pulumi, and infrastructure MCPs
- [file-and-knowledge.md](references/mcp-catalog/file-and-knowledge.md) — Filesystem, Obsidian, Notion, memory systems, and knowledge MCPs
- [git-and-github.md](references/mcp-catalog/git-and-github.md) — GitHub MCP, GitLab, PR tools, and version control
- [llm-and-prompt.md](references/mcp-catalog/llm-and-prompt.md) — Prompt frameworks, LLM routing, evaluation tools, fabric
- [monitoring-and-observability.md](references/mcp-catalog/monitoring-and-observability.md) — Sentry, Datadog, logging MCPs, and observability
- [search-and-web.md](references/mcp-catalog/search-and-web.md) — Brave, Exa, Tavily, web scraping, and search MCPs
- [security-and-auth.md](references/mcp-catalog/security-and-auth.md) — Vault, auth MCPs, secret management, and security tools
- [testing-and-qa.md](references/mcp-catalog/testing-and-qa.md) — Playwright, Selenium, test frameworks, and QA MCPs
- [workflow-and-automation.md](references/mcp-catalog/workflow-and-automation.md) — Zapier, n8n, Slack, email, and automation MCPs

**Worked Examples**:
- [worked-example-api-debugger.md](references/worked-example-api-debugger.md) — Full interactive walkthrough: building an "api-debugger" skill from discovery through validation
- [worked-example-quick-scaffold.md](references/worked-example-quick-scaffold.md) — Fast-path walkthrough: user provides detailed brief, skill skips to generation

### Assets

- [skill-brief-worksheet.md](assets/skill-brief-worksheet.md) — Fillable intake form for capturing skill requirements, audience, use cases, and constraints
- [skill-scoring-rubric.md](assets/skill-scoring-rubric.md) — Quality scoring template with weighted criteria and evidence sections
- [project-tracker.md](assets/project-tracker.md) — Skill-building project tracker for monitoring progress and deliverables
