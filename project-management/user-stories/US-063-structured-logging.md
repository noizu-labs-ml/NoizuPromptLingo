---
id: US-063
title: "Structured logging for CI pipelines"
slug: structured-logging
personas: [P-003]
epic: "Installation & Configuration"
priority: should-have
complexity: medium
tags: [logging, structured, ci, json]
---

# US-063: Structured logging for CI pipelines

## User Story

**As a** DevOps engineer integrating with CI
**I want to** structured logging output that machines can parse
**So that** I can aggregate generation results across pipeline runs

## Acceptance Criteria

- **Given** a JSON-friendly logging mode (env var or flag)
  **When** generation runs
  **Then** log lines include structured fields: timestamp, level, prompt_id, service, duration, status

- **Given** normal terminal mode
  **When** generation runs
  **Then** human-readable colored output is shown

## Notes
Detect CI environment (CI=true, TERM=dumb) and automatically switch to structured output.
