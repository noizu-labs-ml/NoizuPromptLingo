---
id: US-031
title: Drill down into a single step's full JSON payload
issue_type: story
slug: drill-down-step-json
status: in-progress
priority: P0
story_points: 3
estimated_scope: S
category: results-and-dashboards
components:
  - frontend
  - backend
labels:
  - mvp
  - wave-1
  - dashboards
  - debug
assignee: null
reporter: null
epic: mvp-results
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - yuki-red-teamer
secondary_personas: []
related_stories:
  - US-017
  - US-029
dependencies:
  - US-029
blocks: []
duplicates: []
schema_refs:
  - run_steps
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Drill down into a single step's full JSON payload

## Story

As an **AI Red Team Researcher**,
I want to **see the complete raw JSON envelope for any step**
so that **I can inspect tool calls, finish reasons, and anything the UI abstracts away**.

## Acceptance Criteria

- [ ] Each step row exposes a "Raw" action that opens a pretty-printed JSON viewer
- [ ] Viewer shows the full `run_steps.agent_raw` envelope plus `user_message`, `agent_message`, tokens, latency, trace/span ids, error (if any)
- [ ] Copy-to-clipboard works on any subtree
- [ ] Sensitive fields (auth headers, raw tokens) are redacted if present

## Notes

- Useful for tool-use debugging where the UI timeline hides function-call arguments

## Out of Scope

- Inline JSON editing / re-send (never — run_steps are immutable)
- Deep-diff between two steps' JSON (Wave 3)
