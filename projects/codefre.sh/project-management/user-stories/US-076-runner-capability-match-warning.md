---
id: US-076
title: Warn when freeball runner model is weaker than the target agent
issue_type: story
slug: runner-capability-match-warning
status: draft
priority: P1
story_points: 3
estimated_scope: S
category: freeball-protocol
components:
  - backend
  - frontend
labels:
  - wave-2
  - freeball
  - guardrails
assignee: null
reporter: null
epic: mvp-runner
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - yuki-red-teamer
  - nia-academic
secondary_personas:
  - priya-ml-engineer
related_stories:
  - US-022
  - US-071
dependencies:
  - US-022
  - US-071
blocks: []
duplicates: []
schema_refs:
  - agent_versions
  - run_steps
  - runs
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Warn when freeball runner model is weaker than the target agent

## Story

As an **AI Red Team Researcher**,
I want to **see a warning when my freeball runner model is weaker (smaller/less-capable tier) than the target agent model**
so that **I don't silently evaluate a frontier agent with a runner that can't generate coherent follow-up prompts**.

## Acceptance Criteria

- [ ] At run trigger time, backend compares configured `runner_model` tier to target `agent_version.model` tier
- [ ] Tier comparison uses an app-maintained model-capability ranking (e.g. opus > sonnet > haiku; gpt-4.1 > gpt-4o > gpt-3.5)
- [ ] Warning surfaces in the UI: "Runner (Haiku) is weaker than target (Opus). Freeball improvisation may be low-quality."
- [ ] User can acknowledge and proceed, or switch runner models inline
- [ ] CLI emits the same warning to stderr; `--force` bypasses it

## Notes

- Model ranking table lives in app config; keep it up-to-date as providers release new models
- Cross-provider ranking is approximate; document this

## Out of Scope

- Hard-block on capability mismatch (let research workflows decide)
- Dynamic capability detection from empirical runs (Wave 3)
