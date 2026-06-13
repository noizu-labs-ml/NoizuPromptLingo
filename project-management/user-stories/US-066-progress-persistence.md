---
id: US-066
title: "Resume interrupted batch runs"
slug: progress-persistence
personas: [P-003]
epic: "Installation & Configuration"
priority: could-have
complexity: high
tags: [persistence, resume, state, batch]
---

# US-066: Resume interrupted batch runs

## User Story

**As a** DevOps engineer running large batches
**I want to** resume an interrupted generation run
**So that** I don't have to re-generate assets that already completed

## Acceptance Criteria

- **Given** a batch run is interrupted (Ctrl+C, crash)
  **When** I re-run the same command
  **Then** previously completed prompts are skipped (output files exist)

- **Given** the tool tracks progress in a state file
  **When** resumption occurs
  **Then** the state file is read to determine where to continue

## Notes
Partial progress already works via "skip existing output" logic. Explicit state file would enable mid-tier resumption.
