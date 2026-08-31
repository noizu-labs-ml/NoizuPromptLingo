---
id: US-089
title: "Dataset export API endpoint"
slug: dataset-export-api-endpoint
personas: [P-003]
epic: "Integration & API"
priority: must-have
complexity: medium
tags: [api, datasets, export]
---

# US-089: Dataset Export API Endpoint

## User Story

**As an** ML fine-tuning engineer
**I want to** call a dataset export endpoint with a chosen format
**So that** I can pull curated training data directly into my training pipeline without a manual export click in the web UI

## Acceptance Criteria

- **Given** Elena has a dataset named "bug-fixes-gold" with tagged and rated message ranges
  **When** she calls `GET /api/datasets/bug-fixes-gold/export?format=openai`
  **Then** the response body is valid OpenAI chat-format JSONL

- **Given** the same dataset
  **When** she calls with `format=anthropic` or `format=raw`
  **Then** the response uses Anthropic message format, or returns the raw tagged JSONL unmodified, respectively

- **Given** an invalid format value is passed
  **When** the endpoint is called with `format=xyz`
  **Then** it returns HTTP 400 with an error listing the valid format options

- **Given** a dataset name that doesn't exist
  **When** the endpoint is called
  **Then** it returns HTTP 404

## Notes
Directly enables Elena's core workflow — mine the corpus via semantic search, triage into gold/silver/bronze, export — as a scriptable pipeline step rather than a manual UI export.
