---
id: US-144
title: SDK webhook subscriptions
issue_type: story
slug: sdk-webhook-subscriptions
status: in-progress
priority: P2
story_points: 5
estimated_scope: M
category: sdks
components:
  - backend
  - sdk-python
  - sdk-elixir
  - sdk-typescript
labels:
  - wave-3
  - sdk
  - webhooks
  - eventing
assignee: null
reporter: null
epic: post-mvp-sdks
wave: 3
fix_version: "0.2.0"
sprint: null
most_impacted_personas:
  - priya-ml-engineer
  - alex-oss-maintainer
secondary_personas:
  - marcus-qa-lead
related_stories:
  - US-091
  - US-092
  - US-093
dependencies:
  - US-091
blocks: []
duplicates: []
schema_refs:
  - webhook_deliveries
  - webhooks
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# SDK webhook subscriptions

## Story

As a **Senior ML Engineer**,
I want to **subscribe my user-hosted endpoint to CodeFresh events (run.completed, review_item.created, freeball.promoted)**
so that **my downstream systems (Slack bot, release-gate controller, metrics pipeline) react without polling**.

## Acceptance Criteria

- [ ] Webhook CRUD in org settings: endpoint URL, secret (for HMAC signing), event filter list
- [ ] Events delivered via POST with JSON body + `X-Codefresh-Signature` HMAC-SHA256 header
- [ ] Retry with exponential backoff on non-2xx; dead-letter after 5 failures
- [ ] SDK helpers (Python/Elixir/TS) for signature verification
- [ ] Delivery log queryable for debugging

## Notes

- New tables: `webhooks`, `webhook_deliveries` — folded into post-Wave-3 alignment
- Events fire at significant state transitions, not every update

## Out of Scope

- GraphQL subscriptions (Wave 3+)
- Event replay from history (Wave 3+)
