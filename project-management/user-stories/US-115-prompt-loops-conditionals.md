---
id: US-115
title: Loops and conditionals in prompt templating
issue_type: story
slug: prompt-loops-conditionals
status: in-progress
priority: P3
story_points: 5
estimated_scope: M
category: prompt-management
components:
  - backend
  - frontend
labels:
  - wave-3
  - prompts
  - templating
  - stretch
assignee: null
reporter: null
epic: mvp-authoring
wave: 3
fix_version: "0.3.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - alex-oss-maintainer
secondary_personas: []
related_stories:
  - US-048
dependencies:
  - US-048
blocks: []
duplicates: []
schema_refs: []
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Loops and conditionals in prompt templating

## Story

As a **Senior ML Engineer**,
I want **`{% for %}` / `{% if %}` constructs in prompt bodies alongside `{{var}}` substitution**
so that **I can render list-bound contexts (e.g. user history, tool inventories) without maintaining multiple near-identical prompt versions**.

## Acceptance Criteria

- [ ] Templating engine supports `for` over array variables and `if` on boolean/string variables
- [ ] Published prompts render to deterministic text given the same variable bindings
- [ ] Variable validation at publish time confirms all loops / conditionals reference declared variables
- [ ] Debug view shows post-render prompt with variables substituted

## Notes

- Minijinja or similar small Jinja-compatible library keeps scope controlled
- Full Jinja compatibility NOT required; stop at for/if

## Out of Scope

- Arbitrary macros / function calls in templates (never; templates stay declarative)
