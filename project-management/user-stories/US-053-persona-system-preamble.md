---
id: US-053
title: Attach a system-prompt preamble to a persona
issue_type: story
slug: persona-system-preamble
status: in-progress
priority: P1
story_points: 3
estimated_scope: S
category: persona-management
components:
  - backend
  - frontend
labels:
  - wave-2
  - personas
  - prompts
assignee: null
reporter: null
epic: mvp-authoring
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - derek-support-engineer
  - yuki-red-teamer
secondary_personas:
  - priya-ml-engineer
related_stories:
  - US-035
  - US-010
dependencies:
  - US-035
  - US-010
blocks: []
duplicates: []
schema_refs:
  - persona_versions
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Attach a system-prompt preamble to a persona

## Story

As a **Support Automation Engineer**,
I want to **reference a published prompt as a persona's system preamble**
so that **the runner primes the agent with persona-specific instructions (or user-voice framing) before the first user turn**.

## Acceptance Criteria

- [ ] Persona version editor accepts `system_prompt_version_id` reference to a published prompt
- [ ] At run time, if the persona has a preamble, it's injected ahead of the script's own system node (persona preamble is "outer")
- [ ] Adapter receives the combined system context per its API convention
- [ ] Persona preamble is optional; existing personas without one continue to work

## Notes

- Schema: `persona_versions.system_prompt_version_id` already modeled (`data-model.md` §5.4)
- Ordering convention: persona preamble → script system node → user turns. Document this; don't let users reorder.

## Out of Scope

- Multi-prompt persona chains (Wave 3)
- Persona-specific tool/function defs that override the script's tools (Wave 3)
