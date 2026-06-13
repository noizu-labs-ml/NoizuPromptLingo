---
id: US-015
title: "Pass provider-specific options"
slug: provider-specific-options
personas: [P-001, P-004]
epic: "Provider Management"
priority: must-have
complexity: low
tags: [provider-options, yaml, configuration]
---

# US-015: Pass provider-specific options

## User Story

**As a** user tuning generation quality
**I want to** pass provider-specific parameters via `provider_options`
**So that** I can control output quality, safety filters, voice settings, and other API parameters

## Acceptance Criteria

- **Given** a `.media.prompt` with `provider_options: { safety_filter_level: BLOCK_MEDIUM_AND_ABOVE }`
  **When** the Gemini API is called
  **Then** the safety filter parameter is included in the request

- **Given** provider-specific options the provider doesn't support
  **When** the API call is made
  **Then** unsupported options are silently ignored (API returns the error if it cares)

## Notes
Each provider interprets its own `provider_options` keys. Unknown keys pass through to the API.
