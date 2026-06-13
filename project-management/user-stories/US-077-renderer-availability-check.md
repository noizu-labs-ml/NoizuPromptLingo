---
id: US-077
title: "Check renderer availability at startup"
slug: renderer-availability-check
personas: [P-003]
epic: "Renderers"
priority: should-have
complexity: low
tags: [renderer, validation, availability, startup]
---

# US-077: Check renderer availability at startup

## User Story

**As a** user running batch generation
**I want to** know upfront if a required renderer is missing
**So that** I don't discover the problem after waiting for API generation to complete

## Acceptance Criteria

- **Given** a post-processing render step requires `mmdc`
  **When** the tool starts processing
  **Then** renderer availability is checked before any API calls

- **Given** a renderer is missing
  **When** the check runs
  **Then** a clear message indicates which tool to install and how

## Notes
Check at startup, not after generation. Use `which` or equivalent to detect installed tools.
