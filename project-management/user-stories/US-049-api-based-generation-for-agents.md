---
id: US-049
title: "API-Based Generation for Agents"
slug: "api-based-generation-for-agents"
personas: [P-007, P-006]
epic: "Generation Engine"
priority: "could-have"
complexity: "XL"
tags: [generation, api, agent, automation, nova, integration]
---

# US-049: API-Based Generation for Agents

## User Story

**As an** AI agent collaborator integrating with TheRobotKnows via API (P-007),
**I want to** submit generation requests and retrieve results programmatically through a REST API,
**So that** I can automate lore generation pipelines, populate universes at scale, and integrate with external tools without using the web UI.

## Acceptance Criteria

- [ ] Given a valid API key is issued for a universe, when a POST request is made to `/api/v1/generate` with a prompt and generation type, then the API accepts the request and returns a job ID.
- [ ] Given a job ID is returned, when a GET request is made to `/api/v1/generate/{job_id}`, then the response returns the job status and, when complete, the generated draft content.
- [ ] Given the API is called with an invalid or expired API key, when the request is processed, then a 401 Unauthorized response is returned with a descriptive error message.
- [ ] Given a generation request via API, when it completes, then the token usage is recorded under the universe's usage quota identically to UI-triggered generations (US-048).
- [ ] Given the API documentation is available, when an agent developer reads it, then all endpoints, request/response schemas, authentication method, and rate limits are documented with examples.

## Notes

Depends on US-036, US-048. API key management UI (issue, revoke, rotate) is a prerequisite for this story and may be its own sub-story. Rate limiting per API key is required to prevent abuse. This story enables P-007 (Nova) use cases. Related: US-041 (bulk generation).
