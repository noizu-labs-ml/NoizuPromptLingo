---
id: US-049
title: Define tool/function schemas on a prompt
issue_type: story
slug: prompt-tool-schemas
status: in-progress
priority: P1
story_points: 5
estimated_scope: M
category: prompt-management
components:
  - backend
  - frontend
labels:
  - wave-2
  - prompts
  - tool-use
assignee: null
reporter: null
epic: mvp-authoring
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - yuki-red-teamer
secondary_personas: []
related_stories:
  - US-010
  - US-031
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

# Define tool/function schemas on a prompt

## Story

As a **Senior ML Engineer**,
I want to **declare the tool/function schemas a prompt exposes to the agent**
so that **I can test agents that use function calling and score whether they invoke the right tools with the right arguments**.

## Acceptance Criteria

- [ ] Prompt editor lets user add one or more tool definitions (JSON Schema)
- [ ] Tool defs are adapter-agnostic at the schema level; adapter maps them to its convention (OpenAI `tools`, Anthropic `tools`, etc.)
- [ ] Tool calls from the agent are captured in `run_steps.agent_raw` with tool name + arguments
- [ ] Structural expectations (US-004 `scoring_method='structural'`) can assert on tool-call presence, name, and argument shape

## Notes

- Actual tool *execution* is not our concern — we observe what the agent would call, not run the function
- Yuki uses this heavily for "did the agent try to call a dangerous tool?" checks

## Out of Scope

- Stubbing tool responses so multi-turn tool-use can proceed (Wave 3)
- Tool response mocking registry (Wave 3)
