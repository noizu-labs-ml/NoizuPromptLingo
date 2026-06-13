---
id: US-147
title: Auto-flagging rules for production captures
issue_type: story
slug: auto-flagging-rules
status: in-progress
priority: P2
story_points: 5
estimated_scope: M
category: flagged-captures
components:
  - backend
  - frontend
labels:
  - wave-3
  - capture
  - automation
assignee: null
reporter: null
epic: post-mvp-capture
wave: 3
fix_version: "0.2.0"
sprint: null
most_impacted_personas:
  - derek-support-engineer
  - priya-ml-engineer
secondary_personas: [] 
related_stories:
  - US-106
  - US-107
dependencies:
  - US-106
blocks: []
duplicates: []
schema_refs:
  - auto_flag_rules
  - flagged_captures
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-21"
---

# Auto-flagging rules for production captures

## Story

As a **Support Automation Engineer**,
I want to **declare rules (regex on agent response, attribute thresholds, latency spikes) that automatically flag matching OTel captures**
so that **my curation inbox surfaces the interactions most worth my manual review**.

## Acceptance Criteria

- [ ] Rule types: regex on input/response, attribute equality (e.g. `error.type = "rate_limit"`), latency above threshold, token-count above threshold
- [ ] Multiple rules per org; each assigns a default `reason` and tag set
- [ ] Rules evaluated asynchronously on ingest; matches create `flagged_captures` rows with `flagged_by_user_id = null` + `auto_rule_id` set
- [ ] Rules disable-toggled individually; deletion is soft (rules stay in history)
- [ ] Rule-match counts visible for tuning

## Notes

- LLM-as-classifier rules are out of scope for v1 (too costly); pure deterministic rules only

## Out of Scope

- LLM-driven classifiers as rules (Wave 3+)
- Rules across multiple orgs (never — rules are org-scoped)
