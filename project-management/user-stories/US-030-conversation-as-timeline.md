---
id: US-030
title: View the conversation as a linear timeline
issue_type: story
slug: conversation-as-timeline
status: in-progress
priority: P0
story_points: 3
estimated_scope: S
category: results-and-dashboards
components:
  - frontend
labels:
  - mvp
  - wave-1
  - dashboards
  - visualization
assignee: null
reporter: null
epic: mvp-results
wave: 1
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - sofia-product-manager
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
  - scores
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# View the conversation as a linear timeline

## Story

As an **AI Product Manager**,
I want to **read the full run as a chat-style conversation timeline**
so that **I can review agent behavior the way a user would experience it, without parsing JSON**.

## Acceptance Criteria

- [ ] Run detail has a "Conversation" tab that renders steps as chat bubbles
- [ ] User turns are left-aligned; agent responses right-aligned (or vice-versa per theme)
- [ ] Freeball steps visually flagged inline in the timeline
- [ ] Per-bubble score chip on hover shows expectation verdicts for that step
- [ ] Timeline is printable (basic CSS — not a full report export)

## Notes

- This is the view Sofia demos to leadership; optimize for readability over density

## Out of Scope

- Split view (timeline + graph) (Wave 2)
- Audio/voice playback of agent responses (never)
