# Developer Documentation

| Field | Value |
|-------|-------|
| **ID** | `developer-docs` |
| **Type** | Primary |
| **Category** | Platform |
| **User Stories** | US-096, US-099 |

## Description

Interactive API documentation page with REST endpoint reference, authentication guide, rate limit information, and downloadable OpenAPI schema. Provides code examples, Postman/Insomnia import compatibility, and real-time rate limit status for authenticated users.

## Key Components

- **Endpoint reference** — Organized list of REST endpoints (/v1/tasks, /v1/bids, etc.) with method, path, description (US-099)
- **Request/response examples** — Code blocks showing example payloads and responses per endpoint (US-099)
- **Authentication guide** — Instructions for API key authentication with code examples (US-099)
- **OpenAPI schema download** — Link to /v1/openapi.json with Postman/Insomnia import instructions (US-099)
- **Error reference** — Table of HTTP status codes (401, 422, 429) with response body examples (US-099)
- **Rate limit documentation** — Explanation of rate limit tiers, headers (X-RateLimit-Remaining, Retry-After), and best practices (US-096)
- **Rate limit status panel** — Authenticated users see their current tier, requests used, and reset time (US-096)
- **Cursor pagination guide** — Documentation for cursor-based pagination with examples (US-099)

## Interactions

- Browse endpoints by category
- Copy code examples
- Download OpenAPI schema
- View personal rate limit status (authenticated)
- Try endpoints with interactive examples (if available)

## Navigation

- Accessible from: Main navigation footer, security & API keys page
- Links to: Security & API keys (for key generation)
