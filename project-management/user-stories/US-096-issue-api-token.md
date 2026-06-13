---
id: US-096
title: Issue an API token for SDK / CLI use
issue_type: story
slug: issue-api-token
status: in-progress
priority: P1
story_points: 3
estimated_scope: S
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
  - priya-ml-engineer
  - marcus-qa-lead
secondary_personas:
  - alex-oss-maintainer
related_stories:
  - US-087
  - US-091
  - US-097
dependencies:
  - US-039
blocks:
  - US-087
  - US-091
  - US-092
  - US-093
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

# Issue an API token for SDK / CLI use

## Story

As a **Senior ML Engineer**,
I want to **issue a named API token scoped to my org with a configurable role and expiry**
so that **my CI pipeline, local CLI, and SDK integrations can authenticate without sharing my login**.

## Acceptance Criteria

- [ ] Org settings page has an "API Tokens" section
- [ ] Create form: `name` (required), `role` (editor / viewer / ci), `expires_at` (optional, default 90 days)
- [ ] On creation, raw token is shown ONCE — never retrievable again (stored hashed server-side)
- [ ] Token list shows: name, role, created_at, expires_at, last_used_at (never shows raw value)
- [ ] Tokens authenticate via `Authorization: Bearer <token>` header; role determines permitted operations
- [ ] Revocation is immediate (US-097)

## Notes

- Requires new `api_tokens` table — schema addition captured in post-Wave-3 data-model update
- Hash at rest via bcrypt or argon2; key id prefix visible for support lookup

## Out of Scope

- Fine-grained per-resource ACLs on tokens (Wave 3)
- OAuth client credentials grant (Wave 3)
- Token introspection endpoint (Wave 3)
