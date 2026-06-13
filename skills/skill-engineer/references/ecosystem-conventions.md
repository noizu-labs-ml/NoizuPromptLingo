# Ecosystem Conventions

This repo's specific conventions for skill design. Read this alongside the general [skill-design-principles.md](skill-design-principles.md) — this document covers what's unique to the `the-robot-lives/lets-go` ecosystem.

## Canonical Module Structure

Every skill follows an identical internal layout (from `docs/arch/skill-system.md`):

```
skills/{skill-name}/
├── INTRODUCTION.md   # Consumer contract: inputs, outputs, conventions (read first)
├── SKILL.md          # Entry point: purpose, workflow, outputs, cross-refs
├── references/       # Deep-dive playbooks, guides, frameworks
├── assets/           # Fillable templates, trackers, worksheets
└── scripts/          # Reserved for future automation
```

This consistency allows agents to navigate any skill predictably.

### INTRODUCTION.md

The consumer-facing contract file. An invoking agent reads this **before** SKILL.md to understand what the skill accepts, produces, and expects. It declares:

- **Input contract** — arguments, file conventions, context expectations
- **Output contract** — artifacts produced, side effects, downstream handoffs
- **Conventions** — naming rules, structural rules, anti-patterns, prerequisites
- **Reading order** — what to read next and when

INTRODUCTION.md must be under 150 lines, YAML-structured, and non-duplicating (points to SKILL.md rather than restating it). Treat it like a public API — breaking changes require version bumps.

> For the full INTRODUCTION.md specification and template, see [introduction-specification.md](introduction-specification.md).

## SKILL.md Specification

### YAML Frontmatter

```yaml
---
name: {skill-name}         # Kebab-case, matches directory name
description: >             # Multi-line trigger description
  {What the skill does}. Use this skill when {trigger conditions}
  — even if they don't say "{keyword}." Also trigger when users mention
  {additional trigger keywords}.
---
```

The description serves dual purpose: human-readable summary AND Claude Code skill routing logic. It uses the formula:
1. What the skill does (one sentence)
2. "Use this skill when..." (primary triggers, comma-separated)
3. "— even if they don't say..." (catch implicit requests)
4. "Also trigger when users mention..." (keyword expansion)

### Required Sections (in order)

1. **H1 Title** — Matches `name` in Title Case with spaces
2. **Subtitle** — One-line description after the H1
3. **Overview** — 1-2 paragraph summary + Core Purpose bullets (4-6 items)
4. **Core Philosophy** — First principles (3-5 numbered items)
5. **When to Use This Skill** — Bullet list of scenarios with bold labels
6. **Cross-Reference Blockquotes** — Advisory pointers to related skills:
   ```
   > For niche research, see **trl-market-intelligence** (`references/niche-discovery.md`).
   ```
7. **Core Content Sections** — Domain-specific material using tables, workflows, phases
8. **Quick Start Guides** — 2-4 numbered paths for common entry points
9. **Reference Guide** — "When to Read Each Reference" task-to-file mapping table
10. **Related Skills** — Bullet list with one-line descriptions
11. **Bundled Resources** — Full index of references/ and assets/ with descriptions

### Formatting Conventions

- **Tables** for comparison/selection (product types, pricing, frameworks, scoring)
- **Workflow diagrams** as ASCII art code blocks
- **Phase-based processes** with tables (Phase/Output/Duration columns)
- **Selection guides** ("If you need X, choose Y" tables)
- **Blockquotes** exclusively for cross-references to other skills or reference files

## Layer Architecture

The skill system is organized into layers, each answering a different question:

| Layer | Skill | Question Answered |
|-------|-------|-------------------|
| **Strategy** | trl-monetization-strategy | What to build? |
| **Validation** | trl-market-intelligence | Where to build it? (niche) |
| **Orchestration** | trl-conversion-engineer | When to build it? (sequencing) |
| **Execution** | trl-ai-templates, trl-content-publishing, trl-print-on-demand | How to build it? |
| **Discovery** | trl-seo-guru | How do people find it? |
| **Service** | trl-user-experience-engineer | What does it look like? |

When adding a new skill, consider where it fits in this hierarchy:
- Does it add a new execution stream? → Execution layer peer
- Does it serve multiple skills? → Service layer (like UXE)
- Does it teach a practice? → Could be any layer depending on domain
- Does it provide reference data? → Discovery or Service layer

## Architectural Decisions (Relevant ADRs)

### ADR-1: Pure Markdown, No Code
Core knowledge assets are structured Markdown with no runtime dependencies. This means skills are universally readable by humans and AI agents. No automated validation of cross-references — manual consistency maintenance required.

### ADR-2: Self-Contained Skills
Each skill is fully self-contained with advisory cross-references, not hard dependencies. Some content duplication across skills is acceptable. An operator may only need one skill — don't force them through a pipeline.

### ADR-3: Pipeline Over Hierarchy
Linear flow: Strategy → Validation → Orchestration → Execution. This is a recommended path, not enforced. Operators iterate in practice.

### ADR-7: Claude Code as Agent Platform
Skills are invocable via Claude Code's native skill detection. The YAML frontmatter in SKILL.md is the integration point — no additional registration needed. Skills remain valid without Claude Code but lose interactive invocation.

## Agent Integration

Skills connect to Claude Code via the `.claude/` directory:

```
.claude/
├── agents/     # Autonomous agent definitions
├── commands/   # Slash command definitions
└── settings.local.json
```

Each `skills/{name}/SKILL.md` is automatically invocable as `/{name}` in Claude Code. The invocation pattern:

1. User types `/{skill-name}`
2. Claude Code reads `skills/{skill-name}/SKILL.md`
3. SKILL.md content becomes the agent's instruction set
4. Agent uses references/ and assets/ as needed during execution
5. Cross-references to other skills are advisory — agent may suggest invoking them

## Cross-Reference Rules

- Cross-references form a **DAG** (directed acyclic graph) — no circular dependencies
- Use **advisory blockquotes** with bold skill names and parenthetical file paths
- Cross-references are suggestions, never requirements
- Every skill must function standalone even if referenced skills aren't available
- Reference format: `> For X, see **skill-name** (\`references/file.md\`).`

## Reference File Conventions

### Required Files

| File | Present In | Purpose |
|------|-----------|---------|
| `INTRODUCTION.md` | All skills (root) | Consumer contract: I/O declarations, conventions, reading order |
| `agent-playbook.claude-code.md` | All skills (references/) | Agent role definition + execution workflows in YAML |
| At least one `worked-example-*.md` | All skills (references/) | End-to-end demonstration |

### Common Optional Files

| Pattern | Purpose | Examples |
|---------|---------|---------|
| `agent-playbook.md` | Human-facing playbook (non-Claude) | trl-ai-templates, trl-content-publishing |
| Domain-specific guides | Skill-specific deep dives | `keyword-research.md`, `writing-craft.md` |
| `project-tracker.md` (in assets/) | Progress tracking template | 5 of 8 skills |

### Subdirectory Organization

When references/ exceeds ~10 files, organize into subdirectories by topic. The trl-user-experience-engineer skill demonstrates this with 5 subdirectories:

| Subdirectory | Contents |
|-------------|----------|
| `eval/` | Quality evaluation procedures |
| `outputs/` | Format-specific implementation guides |
| `patterns/` | Reusable patterns |
| `process/` | Workflow methodologies |
| `styles/` | Design system specifications |

## Skills as a Git Submodule

Skills live in a separate repo (`the-robot-lives/skills`) checked out as a submodule at `skills/`. This enables:
- Independent versioning of skills vs. the parent repo
- Reuse of skills across multiple projects
- Focused contribution and review

When adding a new skill, it's added to the skills submodule repo, not the parent repo.

## Claude Teams Compatibility

SKILL.md must work standalone in Claude Teams (where references/ may not be loaded). This means:
- SKILL.md contains enough content to be useful on its own
- References provide depth, not essential information
- Platform-specific features (NPL, MCP tools) are in references, not SKILL.md
- The SKILL.md should never break or produce errors if references are unavailable
