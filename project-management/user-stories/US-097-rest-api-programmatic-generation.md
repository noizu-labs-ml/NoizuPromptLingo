---
id: US-097
title: "REST API for programmatic mockup generation"
slug: "rest-api-programmatic-generation"
personas: [P-001, P-008, P-006]
epic: "Integration & API"
priority: "should-have"
complexity: "L"
tags: [api, rest, integration, programmatic]
---

# US-097: REST API for programmatic mockup generation

## User Story

**As a** Full-Stack Developer (P-001),
**I want to** generate mockups via a REST API,
**So that** I can integrate mockup generation into my own tooling, CI pipelines, and automated workflows without using the web UI.

## Acceptance Criteria

- [ ] Given a valid API key in the `Authorization` header, when I POST to `/api/v1/mockups` with a JSON body containing `prompt`, `type`, and `format`, then a mockup generation job is created and a `202 Accepted` response is returned with a `job_id`
- [ ] Given a `job_id`, when I poll `GET /api/v1/mockups/{job_id}`, then the response reflects the current job status (`pending`, `in_progress`, `completed`, `failed`) and includes the output URL on completion
- [ ] Given the API is called without a valid API key, when the request is processed, then a `401 Unauthorized` response is returned with a descriptive error body

## Notes

API keys are managed in the user account settings page. The REST API should be documented with OpenAPI 3.1 and a Swagger UI hosted at `/api/docs`. Rate limits from US-086 apply to API calls. This is the foundation for US-098, US-099, US-100.
