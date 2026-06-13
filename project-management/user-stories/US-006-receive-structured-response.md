---
id: US-006
title: "Receive structured mockup response with metadata"
slug: "receive-structured-response"
personas: [P-001, P-008]
epic: "MCP Core Service"
priority: "must-have"
complexity: "S"
tags: [mcp, response-schema, metadata, api-contract]
---

# US-006: Receive structured mockup response with metadata

## User Story

**As a** full-stack developer (P-001),
**I want to** receive a consistent, schema-validated JSON response from every MCP tool call,
**So that** I can reliably parse and integrate the output in automated pipelines or AI assistant context without ad-hoc response parsing.

## Acceptance Criteria

- [ ] Given any successful tool call, when the response is returned, then it includes `mockup_id`, `created_at`, `tool`, `output_format`, `artifact`, and `metadata` fields
- [ ] Given any failed tool call, when the response is returned, then it includes `error.code`, `error.message`, and `error.details` with no artifact field
- [ ] Given a successful response, when `metadata` is inspected, then it contains `generation_model`, `prompt_tokens`, `applied_constraints`, and `variant_index` fields
- [ ] Given a CI/CD pipeline agent (P-008), when the response schema changes between API versions, then a `schema_version` field in the response allows the consumer to detect and handle the change

## Notes

Schema is published as a JSON Schema document at `api.securamcp.com/schema/v1/response.json`. Breaking schema changes require a major version bump in the API. Related to all generation stories.
