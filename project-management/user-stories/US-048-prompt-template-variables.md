---
id: US-048
title: Define template variables on a prompt
issue_type: story
slug: prompt-template-variables
status: in-progress
priority: P1
story_points: 3
estimated_scope: S
category: prompt-management
components:
  - backend
  - frontend
labels:
  - wave-2
  - prompts
  - templating
assignee: null
reporter: null
epic: mvp-authoring
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
secondary_personas:
  - alex-oss-maintainer
related_stories:
  - US-009
  - US-010
dependencies:
  - US-010
blocks: []
duplicates: []
schema_refs:
  - prompt_versions
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Define template variables on a prompt

## Story

As a **Senior ML Engineer**,
I want to **declare named variables in a prompt that get substituted at run time**
so that **I can reuse one prompt across contexts (e.g. different user names, domains, cohorts) without duplicating bodies**.

## Acceptance Criteria

- [ ] Prompt editor supports `{{var_name}}` syntax in body
- [ ] Declared variables appear in a sidebar with name, description, default value, required-flag
- [ ] Publishing validates every `{{var}}` in body has a matching declaration
- [ ] Script nodes that reference a variable-bearing prompt expose a binding UI
- [ ] Unbound required variables prevent the script from publishing

## Notes

- Variable binding at the node level is part of this story; binding at the run level (override defaults per run) is Wave 3

## Out of Scope

- Loops / conditionals in templating (Wave 3)
- Variable binding from persona metadata (Wave 3)
