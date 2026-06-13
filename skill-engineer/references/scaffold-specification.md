# Scaffold Specification

Exact output format for generated skills. Use this as the blueprint when the trl-skill-engineer generates a new skill scaffold.

## Generated File Tree

Every scaffold produces this structure:

```
skills/{skill-name}/
├── SKILL.md                              # Entry point (generated with all required sections)
├── references/
│   ├── agent-playbook.claude-code.md     # Agent role + workflows (stub with structure)
│   ├── worked-example-{scenario}.md      # At least one worked example (stub)
│   └── {domain-specific files}           # Based on discovery results
├── assets/
│   └── project-tracker.md                # Progress tracking template
└── scripts/                              # Empty directory (reserved)
```

## SKILL.md Template

### Frontmatter

```yaml
---
name: {skill-name}
description: >
  {One-sentence summary of what the skill does}. Use this skill when
  {the user wants to [primary trigger 1], [primary trigger 2], [primary trigger 3],
  [primary trigger 4], or [primary trigger 5]} — even if they don't say
  "{obvious keyword}." Also trigger when users mention {keyword 1},
  {keyword 2}, {keyword 3}, or {keyword 4}.
---
```

### Trigger Language Guidelines

The description field is the most critical part of the skill — it controls routing.

**Formula:**
1. **What** — One sentence describing the skill's purpose
2. **When** — "Use this skill when the user wants to..." followed by 4-6 specific action phrases
3. **Implicit** — "— even if they don't say '{obvious domain term}'" to catch indirect requests
4. **Keywords** — "Also trigger when users mention..." followed by 4-8 domain terms

**Quality checks:**
- Does it catch someone asking obliquely? ("how do I make my site faster" → trl-seo-guru)
- Does it avoid false positives? (a casual mention of "design" shouldn't trigger UXE if it's about database design)
- Is it specific enough? Generic descriptions compete with other skills

### Section Template

```markdown
# {Skill Title}

{One-line subtitle describing the skill's value proposition.}

## Overview

{1-2 paragraph summary.} It provides:

- **{Capability 1}** — {brief description}
- **{Capability 2}** — {brief description}
- **{Capability 3}** — {brief description}
- **{Capability 4}** — {brief description}

## Core Philosophy

**{N} Principles:**

1. **{Principle 1}** — {explanation}
2. **{Principle 2}** — {explanation}
3. **{Principle 3}** — {explanation}

## When to Use This Skill

- **{Scenario 1}** — {when this applies}
- **{Scenario 2}** — {when this applies}
- **{Scenario 3}** — {when this applies}

> For {related capability}, see **{skill-name}** (`references/{file}.md`).

## {Core Content Sections}

{Domain-specific content using tables, workflows, phases.}

## Quick Start Guides

### {Path 1}
1. {Step}
2. {Step}
3. {Step}

### {Path 2}
1. {Step}
2. {Step}

## Reference Guide

### When to Read Each Reference

| Task | Read These |
|------|-----------|
| **{Task 1}** | `{file1}.md` |
| **{Task 2}** | `{file2}.md` |

All reference paths are relative to `references/`.

## Related Skills

- **{skill-1}** — {one-line description of relationship}
- **{skill-2}** — {one-line description of relationship}

## Bundled Resources

### References
- [{file}.md](references/{file}.md) — {description}

### Assets
- [{file}.md](assets/{file}.md) — {description}
```

## Agent Playbook Template

```markdown
# {Skill Title} — Claude Code Agent Playbook

> Agent-executable version of {skill-name} workflows. Designed for Claude Code
> to run {primary workflows}. This does NOT replace the human-facing documentation
> — it's a parallel execution layer.

---

## Agent Role Definition

\```yaml
role: {Role Title}
persona: |
  You are a {domain description}. You guide {what you guide}.
  You prioritize {priority 1} over {priority 2}.

capabilities:
  - {Capability 1}
  - {Capability 2}
  - {Capability 3}

operating_principles:
  - {Principle 1}
  - {Principle 2}

constraints:
  - {Constraint 1}
  - {Constraint 2}

inputs:
  - {Input 1}
  - {Input 2}

outputs:
  - {Output 1}
  - {Output 2}
\```

---

## Workflow 1: {Name}

{Brief description of what this workflow does.}

### Trigger

\```
"{Trigger phrase with [VARIABLE] placeholders}"
\```

### Steps

\```yaml
workflow: {workflow-id}
duration: ~{estimated time}

steps:
  - id: {step-id}
    action: {action type}
    description: >
      {What this step does}
    output: {What this step produces}
\```

### Output Template

{Template for the workflow's final output.}
```

## Asset Templates

### project-tracker.md

```markdown
# {Skill Name} — Project Tracker

## Skill Metadata
- **Name**: {skill-name}
- **Domain**: {domain}
- **Target Date**: {date}
- **Status**: Discovery / Architecture / Scaffold / Content / Validation

## Phase Checklist

| Phase | Status | Completed |
|-------|--------|-----------|
| Discovery | ☐ Not Started | — |
| Architecture | ☐ Not Started | — |
| Scaffold | ☐ Not Started | — |
| Content | ☐ Not Started | — |
| Validation | ☐ Not Started | — |

## File Tracker

| File | Status | Notes |
|------|--------|-------|
| SKILL.md | ☐ | — |
| agent-playbook.claude-code.md | ☐ | — |
| worked-example-{scenario}.md | ☐ | — |
| {additional files} | ☐ | — |

## Quality Audit Log

| Date | Score | Notes |
|------|-------|-------|
| — | — | — |
```

## Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Skill directory | kebab-case | `api-debugger` |
| SKILL.md `name` field | kebab-case, matches directory | `api-debugger` |
| H1 title | Title Case | `API Debugger` |
| Reference files | kebab-case with descriptive names | `error-classification.md` |
| Worked examples | `worked-example-{scenario}.md` | `worked-example-rest-api.md` |
| Asset files | kebab-case, descriptive | `error-template.md` |
| Subdirectories in references/ | lowercase, singular or plural | `patterns/`, `eval/` |

## Slash Command Registration

Skills are automatically invocable as `/{skill-name}` when placed in `skills/{skill-name}/SKILL.md`. No separate registration in `.claude/commands/` is required — Claude Code's native skill detection reads the YAML frontmatter.

If the skill needs additional commands (e.g., a shortcut like `/quick-scaffold`), create a markdown file in `.claude/commands/`:

```markdown
---
name: quick-scaffold
description: >
  Quick-scaffold a new skill from a brief. Shortcut for trl-skill-engineer's fast path.
---

{Command instructions here}
```

## Completeness Validation

After scaffold generation, verify:

- [ ] Directory structure matches canonical layout
- [ ] SKILL.md has all 11 required sections
- [ ] YAML frontmatter has `name` and `description` with trigger language
- [ ] `name` field matches directory name (kebab-case)
- [ ] At least one cross-reference blockquote to a related skill
- [ ] `agent-playbook.claude-code.md` exists with role definition
- [ ] At least one `worked-example-*.md` exists
- [ ] `project-tracker.md` exists in assets/
- [ ] `scripts/` directory exists (even if empty)
- [ ] All files referenced in Bundled Resources section actually exist
- [ ] No circular cross-references
