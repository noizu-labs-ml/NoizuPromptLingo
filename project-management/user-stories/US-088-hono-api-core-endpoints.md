---
id: US-088
title: "Hono API core endpoints"
slug: hono-api-core-endpoints
personas: [P-003, P-008]
epic: "Integration & API"
priority: must-have
complexity: medium
tags: [api, integration]
---

# US-088: Hono API Core Endpoints

## User Story

**As an** ML fine-tuning engineer
**I want to** call documented REST endpoints for listing/reading conversations, running search, and managing datasets
**So that** I can drive the toolkit from my own scripts without going through the web UI

## Acceptance Criteria

- **Given** the Hono API server is running
  **When** a client calls `GET /api/conversations` (optionally with `?project=`)
  **Then** it returns a paginated JSON list of conversations, usable independent of the web UI being open

- **Given** a conversation id
  **When** a client calls `GET /api/conversations/:id`
  **Then** it returns the full thread content (messages, tool calls) as JSON

- **Given** Elena wants to search programmatically
  **When** she calls `GET /api/search?q=<query>&mode=semantic|keyword`
  **Then** results are returned ranked, matching what the web UI search would show

- **Given** the API is documented
  **When** Yusuf inspects the docs (OpenAPI/README)
  **Then** all core routes (conversations, search, datasets) are listed with request/response shapes

## Notes
This is the foundation story for the Integration & API epic — US-089 (dataset export) and US-090 (rehome) build on this same server and route conventions.
