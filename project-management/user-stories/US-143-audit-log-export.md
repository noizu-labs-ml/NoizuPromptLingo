---
id: US-143
title: Audit log export
issue_type: story
slug: audit-log-export
status: in-progress
priority: P2
story_points: 5
estimated_scope: M
category: tenancy-and-admin
components:
  - backend
  - frontend
labels:
  - wave-3
  - tenancy
  - audit
  - compliance
assignee: null
reporter: null
epic: mvp-tenancy
wave: 3
fix_version: "0.2.0"
sprint: null
most_impacted_personas:
  - marcus-qa-lead
secondary_personas: [] 
related_stories: []
dependencies:
  - US-039
blocks: []
duplicates: []
schema_refs:
  - audit_events
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Audit log export

## Story

As a **QA Lead at an enterprise**,
I want to **export a chronological log of administrative actions (user added, role changed, token issued, script published)**
so that **SOC2 auditors get a CSV without me digging through individual tables**.

## Acceptance Criteria

- [ ] `audit_events` table captures: actor, action, subject (resource type + id), timestamp, org_id, diff (jsonb optional)
- [ ] Actions captured: membership CRUD, token CRUD, role changes, published versions, archive/unarchive, freeball promotions
- [ ] Export endpoint supports date-range filter and returns CSV + JSONL
- [ ] Audit events are append-only and retain for minimum 365 days

## Notes

- Separate from the version-table audit trail; complementary: version tables answer "what was the state?"; audit events answer "who did what?"

## Out of Scope

- Real-time SIEM forwarding (Wave 3+ — combine with US-144 webhooks)
- Per-user audit filters (Wave 3+)
