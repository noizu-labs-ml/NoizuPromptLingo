---
id: US-091
title: "REST API Access"
slug: "rest-api-access"
personas: [P-001, P-004]
epic: "Integration & API"
priority: "must-have"
complexity: "L"
tags: [api, rest, integration, developer]
---

# US-091: REST API Access

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** interact with IoTGo via a documented REST API authenticated with API keys,
**So that** I can automate fleet management tasks, integrate IoTGo with CI/CD pipelines, and build custom tooling on top of the platform.

## Acceptance Criteria

- [ ] Given I have an API key, when I make a GET request to `/api/v1/fleets`, then I receive a paginated JSON list of fleet groups my key has permission to read
- [ ] Given the API is available, when I visit the API documentation URL, then I see an OpenAPI 3.0 specification with all endpoints, request/response schemas, authentication instructions, and code examples in Python, curl, and JavaScript
- [ ] Given I make an authenticated API call, when the request succeeds, then response headers include `X-RateLimit-Remaining` and `X-RateLimit-Reset` values
- [ ] Given I pass an invalid API key, when the request is made, then the API returns HTTP 401 with a JSON error body explaining the failure
- [ ] Given an endpoint supports filtering, when I pass query parameters, then results are filtered server-side and the response includes a `meta.total` count and pagination cursors

## Notes

The REST API should mirror all functionality available in the UI. Versioning follows `/api/v{N}/` with a minimum 6-month deprecation window for breaking changes. Relates to US-088 (rate limiting) and US-092 (webhook configuration).
