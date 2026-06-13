---
id: US-088
title: "API Rate Limiting"
slug: "rate-limiting"
personas: [P-006, P-007]
epic: "Admin & Moderation"
priority: "must-have"
complexity: "M"
tags: [admin, rate-limiting, api, security, infrastructure]
---

# US-088: API Rate Limiting

## User Story

**As a** platform administrator (P-006),
**I want to** enforce configurable rate limits per user, plan tier, and endpoint category,
**So that** the platform remains stable under load and individual users cannot monopolize shared resources.

## Acceptance Criteria

- [ ] Given a user exceeds the rate limit for generation requests, when the limit is hit, then the API returns HTTP 429 with a `Retry-After` header indicating when the limit resets.
- [ ] Given rate limits are configured per plan tier in admin settings, when I update the limit for the "free" tier, then the new limit takes effect within 60 seconds for all free-tier users.
- [ ] Given a user receives a 429 response, when they are using the web app, then a dismissible banner is shown explaining they have hit a rate limit and when it will reset.
- [ ] Given an API key user (P-007) hits the rate limit, when the limit is reached, then the 429 response body includes a structured JSON error with `error_code: "rate_limit_exceeded"` and `reset_at` in ISO 8601 format.
- [ ] Given I am on /admin/rate-limits, when I view the configuration table, then I can see and edit limits for each plan tier across endpoint categories (generation, read, write, export).

## Notes

Depends on US-083 (admin dashboard). Rate limiting should be implemented at the API gateway layer (e.g., Redis token bucket) to minimize application-layer overhead. Related: US-082 (API key management), US-089 (abuse detection).
