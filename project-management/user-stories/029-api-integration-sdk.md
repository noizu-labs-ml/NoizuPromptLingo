---
id: story-029
title: "Integrate with memory system via REST API and SDK"
persona: persona-human-developer
priority: must-have
complexity: L
status: draft
---

# Integrate with memory system via REST API and SDK

**As** a Human Developer,
**I want to** integrate my agent application with the memory system through a well-documented REST API and client SDK that supports memory ingestion, recall, and lifecycle management,
**So that** I can add persistent, emotionally-contextualized memory to my agent without understanding the internal architecture.

## Acceptance Criteria
- [ ] REST API covers: memory ingestion (POST /memories), recall (POST /recall), memory details (GET /memories/:id), bulk ingestion (POST /memories/batch), health check (GET /health)
- [ ] Client SDKs available for at minimum: TypeScript/JavaScript and Python
- [ ] SDK provides typed interfaces for `EmotionalMetadata`, `ContextualMetadata`, `RecallQuery`, `RecallResult`, and `MemoryRecord`
- [ ] Authentication via API key with scoped permissions (ingest-only, recall-only, admin)
- [ ] Rate limiting with clear error responses (429 with retry-after header)
- [ ] OpenAPI 3.1 specification published and auto-generated from the API implementation
- [ ] All API responses include request tracing IDs for debugging

## Scenario: Basic memory ingestion and recall cycle
- **Given** a developer has an API key with ingest+recall permissions
- **When** they submit a memory via `POST /memories` with content, emotional metadata, and contextual metadata, then query `POST /recall` with a semantic query and emotional context
- **Then** the ingested memory is returned in the recall results with emotional similarity score and relevance explanation

## Scenario: SDK usage in TypeScript agent
- **Given** a developer installs the `@therobotremembers/sdk` package
- **When** they use `const client = new MemoryClient({ apiKey }); await client.remember({ content, mood, context }); const results = await client.recall({ query, emotionalContext });`
- **Then** the SDK handles serialization, authentication, error handling, and type safety transparently

## Technical Notes
- The API should follow RESTful conventions with JSON request/response bodies
- Consider GraphQL as a secondary interface for clients that need flexible field selection on recall results
- The SDK should handle retry logic with exponential backoff for transient errors
- Webhooks for async events (memory promoted, contradiction detected, anomaly raised) should be part of the API surface
- API versioning via URL path (/v1/memories) from day one

## Related Stories
- story-001: Memory ingestion API must accept the full emotional metadata schema
- story-024: Recall API exposes emotional context recall capabilities
- story-025: Multi-path search is invoked through the recall API's `paths` parameter
- story-021: API authentication maps to Sentinel access gating roles
- story-030: Eval pipeline uses the API to submit test memories and measure recall quality
