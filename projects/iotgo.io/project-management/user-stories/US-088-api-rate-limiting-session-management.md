---
id: US-088
title: "API Rate Limiting & Session Management"
slug: "api-rate-limiting-session-management"
personas: [P-005, P-004]
epic: "Security & Compliance"
priority: "should-have"
complexity: "M"
tags: [rate-limiting, session, security, api]
---

# US-088: API Rate Limiting & Session Management

## User Story

**As a** DevOps / SRE Lead (P-004),
**I want to** configure API rate limits per API key and enforce session timeout policies,
**So that** the platform is protected against abuse, runaway integrations, and credential theft scenarios.

## Acceptance Criteria

- [ ] Given an API key is created, when it is saved, then I can set a rate limit (requests per minute) and a daily quota; the defaults are 300 rpm and 50,000 req/day
- [ ] Given an API key exceeds its rate limit, when a request is made, then the API returns HTTP 429 with a Retry-After header indicating when the limit resets
- [ ] Given I am an org admin, when I set the session idle timeout (range 15 minutes to 24 hours), then browser sessions exceeding that idle period are invalidated and the user is prompted to re-authenticate
- [ ] Given a session is invalidated mid-use, when the user performs an action, then a non-disruptive banner prompts re-authentication and preserves the current page state
- [ ] Given rate limit events occur, when I view the API usage dashboard, then I see a chart of request volume per key, limit-hit events, and quota consumption by day

## Notes

API keys for agent-to-platform communication have separate higher default limits than keys for third-party integrations. Relates to US-087 (SSO) and US-091 (REST API access).
