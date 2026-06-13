---
id: US-055
title: "Validate prompt schema before API calls"
slug: missing-prompt-text-validation
personas: [P-005, P-008]
epic: "Error Handling & Resilience"
priority: must-have
complexity: low
tags: [validation, schema, structural-errors]
---

# US-055: Validate prompt schema before API calls

## User Story

**As a** user writing `.media.prompt` files
**I want to** schema validation to catch errors before any API calls
**So that** I don't waste API credits on malformed requests

## Acceptance Criteria

- **Given** a `.media.prompt` file missing `prompt.text`
  **When** validation runs
  **Then** an error lists the file path and the missing required field

- **Given** a YAML parse error
  **When** the file is loaded
  **Then** an error shows the file path and parse error details

- **Given** an unresolved dependency reference
  **When** DAG resolution runs
  **Then** an error lists the referencing file and the missing dependency ID

## Notes
All structural validation happens in the loading phase, before any API calls. Fail fast.
