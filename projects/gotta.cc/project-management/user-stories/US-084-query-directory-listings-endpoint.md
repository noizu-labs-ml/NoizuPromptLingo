---
id: US-084
title: "Query Directory Listings via API Endpoint"
slug: "query-directory-listings-endpoint"
personas: [P-007]
epic: "API & Integration"
priority: "must-have"
complexity: "XL"
tags: [api, listings, endpoint, pagination, filtering, developer]
---

# US-084: Query Directory Listings via API Endpoint

## User Story

**As an** API Developer (P-007),
**I want to** query the directory listings programmatically with filtering and pagination,
**So that** I can build applications and tools that surface quality web content to my users without scraping.

## Acceptance Criteria

- [ ] Given I have a valid API key, when I send a GET request to `/api/v1/listings` with a category slug parameter, then I receive a paginated JSON response of listings in that category ordered by composite score descending
- [ ] Given I query the listings endpoint, when I include optional query parameters (`min_score`, `max_score`, `tags`, `page`, `per_page`), then the response is filtered and paginated accordingly
- [ ] Given a listings response is returned, when I inspect the JSON schema, then each listing object includes: `id`, `url`, `title`, `description`, `composite_score`, `dimension_scores` (object with five keys), `category_path`, `listed_at`, `last_scored_at`, and `editors_pick` (boolean)
- [ ] Given I request a page beyond the available results, when the endpoint responds, then it returns an empty `data` array with a `total` count and `has_more: false` in the metadata
- [ ] Given my API key is rate-limited, when I exceed my tier's request quota, then the endpoint returns HTTP 429 with a `Retry-After` header and a JSON body explaining the limit
- [ ] Given the API response is returned, when I check response headers, then `X-RateLimit-Limit`, `X-RateLimit-Remaining`, and `X-RateLimit-Reset` are present on every response

## Notes

This is the highest-value API endpoint and the one most likely to drive ecosystem adoption. Schema stability is critical — use versioned endpoints (`/api/v1/`) from day one to enable future evolution without breaking consumers. See US-088 for rate limiting dashboard and US-089 for interactive API docs.
