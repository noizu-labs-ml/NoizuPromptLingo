---
id: US-033
title: "Specify negative prompts"
slug: negative-prompt-support
personas: [P-001, P-002]
epic: "Evaluation & Quality"
priority: must-have
complexity: low
tags: [negative-prompt, quality, exclusions]
---

# US-033: Specify negative prompts

## User Story

**As a** developer generating images
**I want to** specify what to exclude from generated output
**So that** I can avoid common AI artifacts and unwanted elements

## Acceptance Criteria

- **Given** a `prompt.negative` field with "realistic, photographic, text"
  **When** the API is called
  **Then** the negative prompt is passed to the provider

- **Given** Suno provider with `prompt.negative`
  **When** generation runs
  **Then** the negative text maps to `negativeTags` automatically

## Notes
Negative prompts map to provider-specific exclusion parameters automatically.
