---
id: US-097
title: Revoke or rotate an API token
issue_type: story
slug: revoke-rotate-api-token
status: in-progress
priority: P1
story_points: 2
estimated_scope: XS
category: tenancy-and-admin
components:
  - backend
  - frontend
labels:
  - wave-2
  - tenancy
  - auth
  - api-tokens
assignee: null
reporter: null
epic: mvp-tenancy
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - marcus-qa-lead
  - priya-ml-engineer
secondary_personas: []
related_stories:
  - US-096
dependencies:
  - US-096
blocks: []
duplicates: []
schema_refs:
  - api_tokens
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-20"
---

# Revoke or rotate an API token

## Story

As an **org Owner**,
I want to **revoke an API token immediately and optionally issue a replacement in the same action**
so that **when a token leaks, I can kill it without losing my CI configuration continuity**.

## Acceptance Criteria

- [ ] Token detail page has "Revoke" and "Rotate" actions
- [ ] Revoke sets `revoked_at`; all subsequent requests bearing the token get 401
- [ ] Rotate creates a new token with identical role/name and revokes the old one; new raw token shown ONCE
- [ ] Revoked tokens remain visible in the list for 90 days (audit) then archive
- [ ] Active sessions using a revoked token receive 401 within 60s (cache TTL)

## Notes

- Cache invalidation: Redis keyed by token hash; TTL matches acceptable grace period

## Out of Scope

- Scheduled rotation (Wave 3)
- Rotation webhooks so CI systems auto-update (Wave 3)
