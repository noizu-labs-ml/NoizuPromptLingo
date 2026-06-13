---
id: US-093
title: "Public REST API for Reading Prompts"
slug: "public-rest-api-read-prompts"
personas: [P-003, P-005, P-007]
epic: "Integration & API"
priority: "should-have"
complexity: "L"
tags: [api, rest, public-api, integration, developer]
---

# US-093: Public REST API for Reading Prompts

## User Story

**As an** Indie Developer (P-005) or ML Researcher (P-003),
**I want to** access prompts, tags, votes, and comments via a public REST API,
**So that** I can build external tools, run analysis, and integrate Meat Brains data into my own workflows.

## Acceptance Criteria

- [ ] Given a developer sends a GET request to `/api/v1/prompts`, when the request is valid, then the API returns a paginated JSON list of public prompts with fields: id, title, body, tags, vote_score, author (username only), created_at, updated_at
- [ ] Given a developer sends a GET request to `/api/v1/prompts/{id}`, when the prompt exists and is public, then the full prompt object is returned including comments (paginated) and model compatibility metadata
- [ ] Given a developer sends a GET request to `/api/v1/tags`, when the request is valid, then a list of all public tags with prompt counts is returned
- [ ] Given the API receives a request without authentication, when the endpoint is a read-only public endpoint, then the request is served (with rate limiting applied per IP) and no API key is required
- [ ] Given a developer queries the API, when a request includes filter parameters (tag, model, sort, date range), then results are filtered and sorted accordingly

## Notes

API versioning via URL path (`/api/v1/`) is required from day one to allow breaking changes in future versions. OpenAPI/Swagger documentation must be auto-generated and served at `/api/docs`. Private prompts (non-public visibility) must never be returned by public endpoints regardless of authentication state.
