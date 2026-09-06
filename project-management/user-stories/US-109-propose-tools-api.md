---
id: US-109
title: "Backend propose-tools API for endpoint creation"
slug: "propose-tools-api"
personas: [P-009, P-001]
epic: "MCP Endpoint UX Overhaul"
priority: "must-have"
complexity: "L"
tags: [backend, api, llm, tool-search, genai]
---

# US-109: Backend propose-tools API for endpoint creation

## User Story

**As** Quinn Harper, the Endpoint Composer (P-009),
**I want to** an authenticated API that, given my endpoint description (and my answers to clarifying questions), returns a proposed set of tools with a rationale per tool,
**So that** the creation wizard can suggest a relevant tool set without me browsing the whole catalog.

## Acceptance Criteria

- [ ] Given an authenticated client, when it calls the propose-tools endpoint with `{description}` and no answers, then the response contains a short series (max 5) of clarifying questions derived from the description.
- [ ] Given the same call includes the answers, when processed, then the response contains a ranked tool proposal where each entry carries the tool identity, a 1-2 sentence rationale, and suggested defaults (enabled, visible).
- [ ] Given any proposal returned, when checked against the tool catalog, then every proposed tool exists in the catalog (grounded via `NoizuPromptLingua.Tools.Catalog.build/2` plus ToolSearch `:intent` ranking) — no invented or hallucinated tool names.
- [ ] Given the LLM is unavailable, times out, or returns an unusable payload, when the request completes, then the API returns a structured error (code `llm_unavailable`) that the client maps to the manual picker (US-112) — never a partial or malformed success.
- [ ] Given the endpoint is exposed, when accessed, then it requires authentication, enforces request size limits on description/answers, and documents a latency budget (timeout + p95 target) so the UI can degrade gracefully.
- [ ] Given the implementation lands, when the test suite runs, then contract shape, catalog grounding (proposals ⊆ catalog), and error mapping are covered with >= 80% coverage on new code.

## Notes

Implemented in the backend against the `genai` lib; reuses the existing per-tool embedding index (`mcp_tool_vectors`) and ToolSearch `:intent` mode rather than raw catalog prompting alone. Single endpoint, two-phase contract (questions → proposals) keeps the client stateless. Consumed by US-110/US-111.
