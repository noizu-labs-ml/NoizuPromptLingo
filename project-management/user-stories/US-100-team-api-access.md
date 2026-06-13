---
id: US-100
title: "Team API Access for Programmatic Blog Management"
slug: "team-api-access"
personas: [P-003, P-002]
epic: "Integration & API"
priority: "won't-have-yet"
complexity: "XL"
tags: [API, integration, team-plan, programmatic, REST, developer]
---

# US-100: Team API Access for Programmatic Blog Management

## User Story

**As a** Content Marketing Manager on the Team plan (P-003),
**I want to** manage my team's blogs programmatically via a REST API,
**So that** I can integrate BloggersCompete into our existing content workflow tools and automate blog submission, score retrieval, and competition entry.

## Acceptance Criteria

- [ ] Given I am a Team plan owner, when I navigate to Settings > API, then I can generate an API key scoped to my team with a label (e.g., "CI Pipeline Key") and optional expiration date.
- [ ] Given I have an API key, when I make a `GET /api/v1/blogs` request with `Authorization: Bearer {key}`, then the response returns a paginated JSON list of my team's blogs with their current AI scores and status.
- [ ] Given I make a `POST /api/v1/blogs` request with a valid blog URL and metadata, when the request is processed, then a new blog submission is created (subject to Team plan limits) and the response returns the created blog object with an HTTP 201 status.
- [ ] Given I make a `GET /api/v1/blogs/{id}/scores` request, when the blog has been scored, then the response returns the latest AI score object with all 6 dimension scores, overall score, and `scored_at` timestamp.
- [ ] Given an API request is made with an invalid or expired key, when authentication fails, then the server returns HTTP 401 with `{"error": "Invalid or expired API key"}`.
- [ ] Given a Free or Pro user (non-Team) attempts to generate an API key, when they navigate to Settings > API, then the section is visible but gated: "API access is available on the Team plan — upgrade to unlock."
- [ ] Given API requests from a Team account, when rate limiting is enforced, then Team plan API calls are limited to 1,000 requests/hour per API key; exceeding this returns HTTP 429 with a `Retry-After` header.
- [ ] Given API documentation is needed, when I navigate to `/api/docs`, then a publicly accessible OpenAPI 3.0 spec is served with all available endpoints, parameters, example requests, and example responses documented.

## Notes

This story is won't-have-yet due to the significant implementation scope (API key management, auth middleware, versioned API, documentation). Prioritize after core platform is stable. API versioning strategy: `/api/v1/` prefix; breaking changes increment version. Webhook support (notify your endpoint when a score is updated) is a follow-on story. Rate limits stored in Redis (same infrastructure as US-093). API key hash (bcrypt or SHA-256) stored in DB; plaintext key shown only once at generation. Relates to US-078 (Team plan), US-093 (rate limiting), US-082 (Stripe — billing verification for API gate).
