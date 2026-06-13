# INTRODUCTION.md Specification

The consumer-facing contract file for skills. An invoking agent reads this **before** SKILL.md to understand what the skill accepts, produces, and expects — without parsing the full documentation.

## Purpose

INTRODUCTION.md answers five questions for the calling agent:

1. **What does this skill do?** (one paragraph, not the full SKILL.md)
2. **What inputs does it accept?** (formats, file conventions, arguments)
3. **What outputs does it produce?** (artifacts, formats, locations)
4. **What conventions must I follow?** (naming, structure, anti-patterns)
5. **What should I read next?** (which files, in what order, for what purpose)

## Design Principles

- **Machine-first, human-readable** — Structured YAML blocks over prose. An agent should be able to extract I/O contracts programmatically.
- **Lean** — Under 150 lines. If it's longer, content belongs in SKILL.md or references/.
- **Non-duplicating** — Points to SKILL.md sections rather than restating them. The one exception: input/output contracts are stated here even if they also appear in the agent playbook, because this is the canonical location.
- **Stable** — Changes less frequently than SKILL.md. Treat it like a public API — breaking changes need versioning.

## Required Sections

### 1. Header Block (YAML frontmatter)

```yaml
---
skill: {skill-name}
version: "1.0"
compatible_with:
  - claude-code
  - claude-teams   # if SKILL.md works standalone
last_updated: YYYY-MM-DD
---
```

### 2. Summary

One paragraph (3-5 sentences) describing what the skill does, who it's for, and its primary value. No trigger language — that lives in SKILL.md frontmatter.

### 3. Input Contract

A YAML block declaring what the skill accepts:

```yaml
inputs:
  arguments:
    - name: {arg-name}
      type: string | file-path | choice | freeform
      required: true | false
      description: "{what it is}"
      example: "{example value}"

  file_conventions:
    - pattern: "{glob or path pattern}"
      format: markdown | yaml | json | toml | csv | custom
      description: "{what the file contains}"
      schema: "{path to schema or inline description}"
      example: |
        {minimal valid example, 5-10 lines max}

  context_expectations:
    - "{what the skill assumes is available — e.g., 'git repo', 'package.json', 'CLAUDE.md'}"
```

**Rules:**
- Every input the skill reads (beyond standard codebase files) must be declared here
- File conventions include both files the skill reads AND files the user is expected to provide
- `schema` can be a file path to a JSON Schema, a reference to an assets/ template, or a brief inline description
- `example` shows the minimal valid input — not a full production example

### 4. Output Contract

A YAML block declaring what the skill produces:

```yaml
outputs:
  artifacts:
    - name: "{artifact name}"
      path: "{where it goes — pattern or exact path}"
      format: markdown | yaml | json | directory-tree | custom
      description: "{what it contains}"
      example: |
        {minimal output example, 5-10 lines max}

  side_effects:
    - "{any non-file effects: git commits, slash command registration, etc.}"

  handoff:
    - skill: "{downstream skill name}"
      artifact: "{which output feeds into it}"
      description: "{why you'd hand off}"
```

**Rules:**
- Every file or directory the skill creates must be declared
- Side effects (git operations, external calls, etc.) must be listed
- Handoff describes which downstream skills can consume this skill's outputs — advisory, not required

### 5. Conventions

A structured list of rules the invoking agent must follow:

```yaml
conventions:
  naming:
    - "{naming convention — e.g., 'files use kebab-case'}"
  structure:
    - "{structural convention — e.g., 'one persona per file'}"
  anti_patterns:
    - "{what NOT to do — e.g., 'do not combine multiple user stories in one file'}"
  prerequisites:
    - "{what must be true before invoking — e.g., 'project-management/ directory must exist'}"
```

### 6. Reading Order

A prioritized list telling the agent what to read and when:

```markdown
## Reading Order

| Priority | File | When to Read |
|----------|------|-------------|
| 1 (always) | `INTRODUCTION.md` | Before any interaction (you're reading it now) |
| 2 (before executing) | `SKILL.md` | When you need full workflow details |
| 3 (during execution) | `references/agent-playbook.claude-code.md` | When running a specific workflow |
| 4 (as needed) | `references/{specific-file}.md` | {When this specific reference is needed} |
```

### 7. Quick Examples (optional)

1-3 minimal invocation examples showing the skill in action:

```markdown
## Quick Examples

### Minimal invocation
\`/skill-name create a widget for dashboard metrics\`

### With file input
\`/skill-name\` with `specs/widget-spec.yaml` already present in the project

### Handoff from upstream
After `/upstream-skill` produces `output.md`, invoke `/skill-name refine output.md`
```

## Complete Template

```markdown
---
skill: {skill-name}
version: "1.0"
compatible_with:
  - claude-code
last_updated: YYYY-MM-DD
---

# {Skill Title} — Introduction

{3-5 sentence summary. What it does, who it's for, primary value.}

## Input Contract

\```yaml
inputs:
  arguments:
    - name: topic
      type: freeform
      required: true
      description: "The subject to work on"
      example: "API authentication patterns"

  file_conventions:
    - pattern: "specs/{name}.yaml"
      format: yaml
      description: "Optional specification file"
      schema: "See assets/spec-template.yaml"
      example: |
        name: my-feature
        type: enhancement
        priority: high

  context_expectations:
    - "Git repository with CLAUDE.md"
\```

## Output Contract

\```yaml
outputs:
  artifacts:
    - name: "Primary deliverable"
      path: "output/{name}.md"
      format: markdown
      description: "The main output document"
      example: |
        # My Feature
        ## Overview
        ...

  side_effects:
    - "None — all output is file-based"

  handoff:
    - skill: downstream-skill
      artifact: "Primary deliverable"
      description: "Can be refined by downstream-skill"
\```

## Conventions

\```yaml
conventions:
  naming:
    - "Output files use kebab-case"
  structure:
    - "One deliverable per invocation"
  anti_patterns:
    - "Do not combine multiple topics in one invocation"
  prerequisites:
    - "output/ directory will be created if absent"
\```

## Reading Order

| Priority | File | When to Read |
|----------|------|-------------|
| 1 | `INTRODUCTION.md` | Before any interaction |
| 2 | `SKILL.md` | For full workflow details |
| 3 | `references/agent-playbook.claude-code.md` | During execution |

## Quick Examples

### Basic
\`/skill-name build an API authentication guide\`

### With spec file
Place `specs/auth-guide.yaml` in project, then \`/skill-name\`
```

## Validation Checklist

- [ ] Under 150 lines
- [ ] All YAML blocks parse cleanly
- [ ] Every declared input has an example
- [ ] Every declared output has a path pattern
- [ ] No content duplicated from SKILL.md (references OK, copy-paste not)
- [ ] Reading order includes at minimum: INTRODUCTION.md, SKILL.md, agent-playbook
- [ ] Conventions include at least one anti-pattern (skills always have "don't do this" rules)
- [ ] `version` field is set and will be bumped on breaking changes
- [ ] `last_updated` is a real date, not a placeholder

## Relationship to Other Files

```
INTRODUCTION.md          ← Consumer reads FIRST (contract)
    ↓ points to
SKILL.md                 ← Consumer reads for DEPTH (documentation)  
    ↓ points to
agent-playbook.claude-code.md  ← Agent reads for EXECUTION (workflows)
    ↓ references
references/*.md          ← Agent reads for DETAIL (domain knowledge)
```

INTRODUCTION.md is the **only file an agent needs to read to decide whether and how to invoke the skill**. Everything else is for execution depth.
