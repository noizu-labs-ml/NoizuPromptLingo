---
id: US-019
title: "Detect duplicate prompt IDs"
slug: duplicate-id-detection
personas: [P-003, P-005]
epic: "Pipeline & Dependencies"
priority: must-have
complexity: low
tags: [validation, dag, error-handling]
---

# US-019: Detect duplicate prompt IDs

## User Story

**As a** developer managing a directory of prompts
**I want to** be alerted if two `.media.prompt` files share the same `id`
**So that** dependency resolution doesn't silently pick the wrong one

## Acceptance Criteria

- **Given** two `.media.prompt` files with the same `id` field
  **When** the tool parses all prompt files
  **Then** an error message lists both file paths and the conflicting ID

- **Given** unique IDs across all prompt files
  **When** parsing
  **Then** no error is raised

## Notes
Structural validation happens before any API calls. Duplicate IDs are a hard stop.
