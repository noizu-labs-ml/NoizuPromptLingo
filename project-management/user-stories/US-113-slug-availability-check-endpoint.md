---
id: US-113
title: "Slug availability check endpoint for inline validation"
slug: "slug-availability-check-endpoint"
personas: [P-009, P-001]
epic: "MCP Endpoint UX Overhaul"
priority: "should-have"
complexity: "S"
tags: [backend, api, slug-validation, frontend]
---

# US-113: Slug availability check endpoint for inline validation

## User Story

**As** Quinn Harper, the Endpoint Composer (P-009),
**I want to** see immediately whether a slug is valid and free while I type it,
**So that** I never lose a half-completed form to a conflict discovered only at submit time.

## Acceptance Criteria

- [ ] Given an authenticated client, when it calls the availability endpoint with a slug, then it returns `{valid, available}` where validity mirrors the schema regex `^[a-z0-9][a-z0-9-]{0,62}$`.
- [ ] Given a reserved slug (`tobor`, `core` — built-in template rows), when checked, then the response reports it as unavailable.
- [ ] Given an existing `mcp_custom_scopes` slug, when checked, then the response reports unavailable; an unused slug reports available.
- [ ] Given the endpoint is implemented, when reviewed, then it is a cheap indexed lookup (no scans), requires authentication, and returns clear structured errors rather than naked 404s/500s for malformed input.
- [ ] Given the client integrates it (US-105/US-106/US-108), when the user types a slug, then checks are debounced (~300ms) and an endpoint failure degrades gracefully to submit-time conflict handling without blocking the UI.

## Notes

Client contract: valid-but-taken shows inline uniqueness feedback; invalid shows the format message. Keeps US-105/US-108 ACs honest about "feedback before submit".
