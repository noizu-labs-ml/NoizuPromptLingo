---
id: US-017
title: "Use collapse modes to reference dependency output"
slug: collapse-modes
personas: [P-001, P-004]
epic: "Pipeline & Dependencies"
priority: must-have
complexity: high
tags: [dependencies, collapse, file, inline, context]
---

# US-017: Use collapse modes to reference dependency output

## User Story

**As a** developer chaining asset generation
**I want to** reference dependency output via `${alias}` in my prompt text
**So that** downstream prompts can use generated assets as inputs

## Acceptance Criteria

- **Given** `collapse: file` in a dependency declaration
  **When** the dependency is resolved
  **Then** `${alias}` in the prompt text is replaced with the filesystem path to the generated file

- **Given** `collapse: inline`
  **When** the dependency is resolved
  **Then** `${alias}` is replaced with base64-encoded content of the generated file

- **Given** `collapse: context`
  **When** the dependency is resolved
  **Then** `${alias}` is replaced with extracted metadata (dimensions, description)

## Notes
File collapse is implemented. Inline and context are planned features.
