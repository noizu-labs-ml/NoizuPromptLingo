---
id: US-071
title: "Screen-reader compatible CLI output"
slug: screen-reader-compatible-output
personas: [P-007]
epic: "Accessibility"
priority: should-have
complexity: medium
tags: [accessibility, screen-reader, terminal, a11y]
---

# US-071: Screen-reader compatible CLI output

## User Story

**As a** visually impaired user
**I want to** all CLI output to be screen-reader compatible
**So that** I can use the tool without visual feedback

## Acceptance Criteria

- **Given** a screen reader is active or TERM=dumb
  **When** progress is shown
  **Then** text-based status messages are used instead of spinners and progress bars

- **Given** a generation completes
  **When** the result is reported
  **Then** a clear text message states the output file path and success/failure

## Notes
Detect screen reader via TERM environment. Never rely solely on visual indicators for critical state.
