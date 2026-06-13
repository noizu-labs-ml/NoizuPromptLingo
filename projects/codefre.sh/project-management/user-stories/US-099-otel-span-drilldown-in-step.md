---
id: US-099
title: Drill down from a run step into its OTel span tree
issue_type: story
slug: otel-span-drilldown-in-step
status: in-progress
priority: P1
story_points: 5
estimated_scope: M
category: otel-ingestion
components:
  - backend
  - frontend
labels:
  - wave-2
  - otel
  - dashboards
  - debug
assignee: null
reporter: null
epic: post-mvp-otel
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - yuki-red-teamer
secondary_personas: []
related_stories:
  - US-031
  - US-082
  - US-098
dependencies:
  - US-082
blocks: []
duplicates: []
schema_refs:
  - otel_spans
  - run_steps
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Drill down from a run step into its OTel span tree

## Story

As a **Senior ML Engineer**,
I want to **expand a run step and see the OTel spans the agent emitted while handling that step, rendered as a timeline waterfall**
so that **"this step took 42s" becomes an actionable "which retrieval call was slow"**.

## Acceptance Criteria

- [ ] Run step detail has an "OTel Trace" tab
- [ ] Tab shows a waterfall view of spans linked to that step (`run_step_id` match)
- [ ] Each span renders: name, service, duration bar, status color, click-through to span attribute detail
- [ ] Empty state ("no spans found for this step") explains possible causes: no exporter installed, correlation pending, sampling below 1.0
- [ ] Loading is lazy (only fetch when tab is opened)

## Notes

- Waterfall rendering can use an off-the-shelf React trace viewer component
- Deep correlation success depends on user's agent installing the OTel bridge helper (US-094)

## Out of Scope

- Span events timeline (nested inside span rendering) — Wave 3
- Cross-run span comparison (Wave 3)
