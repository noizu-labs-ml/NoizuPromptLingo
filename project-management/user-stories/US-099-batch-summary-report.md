---
id: US-099
title: "Summary report after batch generation"
slug: batch-summary-report
personas: [P-003, P-006]
epic: "CLI & UX"
priority: should-have
complexity: medium
tags: [cli, summary, report, batch]
---

# US-099: Summary report after batch generation

## User Story

**As a** DevOps engineer reviewing batch results
**I want to** a summary report showing successes, failures, and skips
**So that** I know exactly what happened without scrolling through verbose output

## Acceptance Criteria

- **Given** a batch of 20 prompts completes
  **When** processing finishes
  **Then** a summary shows: X succeeded, Y skipped (existing), Z failed, with total duration

- **Given** failures occurred
  **When** the summary is shown
  **Then** failed prompt IDs and error types are listed

## Notes
Summary should be shown by default (not only in verbose mode). Failure details help with debugging.
