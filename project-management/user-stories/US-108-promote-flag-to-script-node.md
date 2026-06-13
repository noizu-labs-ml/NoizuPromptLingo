---
id: US-108
title: Promote a flagged capture to a script node input
issue_type: story
slug: promote-flag-to-script-node
status: in-progress
priority: P1
story_points: 5
estimated_scope: M
category: flagged-captures
components:
  - backend
  - frontend
labels:
  - wave-2
  - capture
  - promotion
  - scripts
assignee: null
reporter: null
epic: post-mvp-capture
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - derek-support-engineer
  - priya-ml-engineer
secondary_personas: []
related_stories:
  - US-106
  - US-107
  - US-044
dependencies:
  - US-107
  - US-044
blocks: []
duplicates: []
schema_refs:
  - flagged_captures
  - script_nodes
  - script_versions
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-21"
---

# Promote a flagged capture to a script node input

## Story

As a **Support Automation Engineer**,
I want to **take a flagged production capture and seed it as the prompt of a new script node in an existing script**
so that **"the weird thing I saw Tuesday" becomes a repeatable regression test with expectations I can author around it**.

## Acceptance Criteria

- [ ] From a flagged capture's detail view, "Promote to script" action opens a picker: existing script (required), target node (required or "new"), position (child-of or root)
- [ ] Promotion creates a new draft version of the target script (per US-044 semantics) with the capture's input embedded as a new user_turn node's prompt
- [ ] User prompted to define initial expectations on the new node (suggest via autogeneration or leave blank)
- [ ] Flagged capture's `promoted_to_script_node_id` recorded; promotion is one-to-many (a capture may seed multiple scripts)
- [ ] Redaction state preserved: promoted prompt uses the scrubbed version from the flag, not the raw OTel span

## Notes

- This is the "production reality → test fixture" pipeline Derek depends on
- Promotion creates a *draft* version; user still needs to publish via US-006 to make it runnable

## Out of Scope

- Auto-generated expectations based on the observed agent response (Wave 3)
- Promote as a freeball-anchor node (Wave 3 — interesting hybrid)
