---
id: US-106
title: Flag an OTel span or production interaction for future eval use
issue_type: story
slug: flag-otel-span-or-interaction
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
  - tagging
  - otel
assignee: null
reporter: null
epic: post-mvp-capture
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - derek-support-engineer
  - priya-ml-engineer
secondary_personas:
  - yuki-red-teamer
related_stories:
  - US-098
  - US-099
  - US-107
  - US-108
  - US-109
dependencies:
  - US-082
blocks:
  - US-107
  - US-108
  - US-109
duplicates: []
schema_refs:
  - flagged_captures
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-21"
---

# Flag an OTel span or production interaction for future eval use

## Story

As a **Support Automation Engineer**,
I want to **flag an OTel-captured production interaction (a user message + agent response pair) as "interesting" with optional tags and notes**
so that **real-world deviations, bugs, or edge cases I spot in production become seed fixtures for my next regression suite or dataset**.

## Acceptance Criteria

- [ ] "Flag" action available on any OTel span view and on any run_step row (if the step's trace correlates to user-visible ingress)
- [ ] Flag form: `title`, `tags` (free-form labels), `notes`, optional `reason` enum (`deviation`, `bug`, `edge_case`, `good_example`, `regression`)
- [ ] Flagged captures persisted to a `flagged_captures` table with: id, organization_id, source_trace_id, source_span_id, source_run_step_id (if known), title, tags, notes, reason, flagged_by_user_id, inserted_at
- [ ] Flagged items appear in the capture library (US-107)
- [ ] Redaction pass available on flag creation: user can scrub PII from the captured attributes before persisting

## Notes

- Flagged captures are the inverse of freeball promotion: freeball captures deviation *inside* a test; flags capture it *from production*
- New schema entity: `flagged_captures` (folded into post-Wave-3 schema pass)
- Redaction is critical — production spans may contain PII; default redaction is user-driven, not automatic

## Out of Scope

- Automated flagging rules (Wave 3, US-116+)
- Cross-user flag visibility (defaults to org-wide; per-user private flags are Wave 3)
