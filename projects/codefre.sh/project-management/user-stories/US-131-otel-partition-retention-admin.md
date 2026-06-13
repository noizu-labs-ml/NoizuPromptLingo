---
id: US-131
title: OTel partition + retention admin
issue_type: story
slug: otel-partition-retention-admin
status: in-progress
priority: P2
story_points: 5
estimated_scope: M
category: otel-ingestion
components:
  - backend
  - frontend
labels:
  - wave-3
  - otel
  - admin
  - ops
assignee: null
reporter: null
epic: post-mvp-otel
wave: 3
fix_version: "0.2.0"
sprint: null
most_impacted_personas:
  - marcus-qa-lead
  - priya-ml-engineer
secondary_personas: []
related_stories:
  - US-081
dependencies:
  - US-081
blocks: []
duplicates: []
schema_refs:
  - otel_spans
  - otel_logs
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# OTel partition + retention admin

## Story

As an **org Owner**,
I want to **set OTel retention per org (e.g. 30/60/90/365 days) and see partition storage usage**
so that **I can balance debug value against storage cost without involving infrastructure engineers**.

## Acceptance Criteria

- [ ] Org settings > OTel > Retention dropdown (presets 30/60/90/180/365; null = indefinite, max plan limit applies)
- [ ] Storage-usage widget shows spans + logs byte totals per month, current and historical
- [ ] Background job drops partitions older than retention on a nightly schedule
- [ ] Warning surfaced if retention drop would delete OTel tied to an unresolved review queue item

## Notes

- Matches monthly partition strategy in `data-model.md` §7.1
- Partition drops are irreversible; confirmation dialog required to shorten retention

## Out of Scope

- Per-service retention (Wave 3+)
- Archive-to-S3 pipeline (Wave 3+)
