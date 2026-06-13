---
id: US-077
title: "Query Catalog Techniques via REST API"
slug: "query-catalog-via-rest-api"
personas: [P-001, P-003, P-006]
epic: "API & Integration"
priority: "must-have"
complexity: "L"
tags: [api, catalog, rest, integration, developer]
---

# US-077: Query Catalog Techniques via REST API

## User Story

**As a** developer integrating jailbreak intelligence into tooling (P-001, P-003, P-006),
**I want to** query the full technique catalog via a documented REST API,
**So that** I can ingest technique data into my own pipelines, dashboards, and threat models without manual data export.

## Acceptance Criteria

- [ ] Given a valid API key, when I `GET /v1/techniques`, then I receive a JSON array of technique objects with all structured fields (ID, name, category, severity, model targets, mitigations, CVSS-equivalent score)
- [ ] Given a technique ID, when I `GET /v1/techniques/{id}`, then I receive the full detail record including examples, detection notes, and related technique IDs
- [ ] Given the API, when I request a technique, then the response includes an `updated_at` timestamp and an `etag` header for cache validation
- [ ] Given the API docs, when I visit `/docs` or `/openapi.json`, then I find a complete OpenAPI 3.1 spec with all endpoints, schemas, and example responses
- [ ] Given a stale client, when I send a `If-None-Match` header with a known etag, then a 304 Not Modified is returned when the resource is unchanged
- [ ] Given an invalid API key, when I call any endpoint, then I receive a 401 with a `WWW-Authenticate` header and a descriptive error body

## Notes

API versioning via URL prefix (`/v1/`). Breaking changes will trigger a new version with a deprecation notice and 6-month sunset period for the previous version. Response bodies must be stable; additive fields are non-breaking.
