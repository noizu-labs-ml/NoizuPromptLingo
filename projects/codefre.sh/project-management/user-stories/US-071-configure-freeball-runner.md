---
id: US-071
title: Configure the freeball runner model and prompt per organization
issue_type: story
slug: configure-freeball-runner
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
  - config
assignee: null
reporter: null
epic: mvp-runner
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - yuki-red-teamer
secondary_personas: []
related_stories:
  - US-022
  - US-076
dependencies:
  - US-022
blocks: []
duplicates: []
schema_refs:
  - freeball_nodes
  - organizations
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Configure the freeball runner model and prompt per organization

## Story

As a **Senior ML Engineer**,
I want to **set the freeball runner's model and system prompt at the org level (with per-run override)**
so that **I can pick a runner capable enough for my domain without editing per-run config every time**.

## Acceptance Criteria

- [ ] Org settings page has a "Freeball" section: runner model picker, runner system-prompt reference (uses a published prompt version)
- [ ] Defaults ship with the app (e.g. Haiku-tier for generation, a generic guidance prompt)
- [ ] Per-run `run_config.freeball_runner` can override both model and prompt version
- [ ] Runner prompt is pinned to a specific `prompt_version_id` — re-publishing that prompt doesn't affect past freeball results

## Notes

- Matches `freeball_nodes.runner_model` and `runner_prompt_version_id` from `data-model.md` §6.4
- Important that the runner prompt is user-editable — teams have opinions about how improvisation should be guided

## Out of Scope

- Per-script freeball runner overrides (Wave 3)
- Learning-mode where successful freeball paths tune the runner prompt (far future)
