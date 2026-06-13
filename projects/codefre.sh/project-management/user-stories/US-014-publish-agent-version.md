---
id: US-014
title: Publish an agent version
issue_type: story
slug: publish-agent-version
status: in-progress
priority: P0
story_points: 2
estimated_scope: S
category: agent-connectors
components:
  - backend
  - frontend
labels:
  - mvp
  - wave-1
  - agents
  - versioning
assignee: null
reporter: null
epic: mvp-agents
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - marcus-qa-lead
secondary_personas:
  - nia-academic
related_stories:
  - US-012
  - US-015
dependencies:
  - US-012
blocks:
  - US-015
duplicates: []
schema_refs:
  - agent_versions
  - agents
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Publish an agent version

## Story

As a **Senior ML Engineer**,
I want to **publish my agent configuration as an immutable version**
so that **runs pin exactly which model, headers, and template were used, even if I edit the agent later**.

## Acceptance Criteria

- [ ] "Publish" action on agent detail creates a new `agent_versions` row
- [ ] `version_number` increments monotonically per agent head
- [ ] Checksum is recorded; republishing identical config is a no-op
- [ ] Head's `current_version_id` advances
- [ ] Published version is read-only; edits start a new draft
- [ ] Version history visible on the agent detail page

## Notes

- Same head + version-table pattern as scripts (US-006) and prompts (US-010)
- Marcus requires this for SOC2 audit trail; Nia requires it for paper reproducibility

## Out of Scope

- Draft/promote review workflow (Wave 2)
- Version-level diff view (Wave 2)
