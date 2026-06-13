---
id: US-038
title: "See progress during batch generation"
slug: progress-indicators
personas: [P-001, P-007]
epic: "CLI & UX"
priority: should-have
complexity: medium
tags: [cli, progress, indicators, ratatui]
---

# US-038: See progress during batch generation

## User Story

**As a** CLI user running batch generation
**I want to** see a progress indicator showing which prompts are being processed
**So that** I know the tool is working and how far along it is

## Acceptance Criteria

- **Given** batch generation of 10 prompts
  **When** processing is underway
  **Then** a progress bar or spinner shows: current/total, the file being processed, and elapsed time

- **Given** a screen reader is active
  **When** progress is shown
  **Then** progress is communicated via text output, not solely visual indicators

## Notes
Uses `indicatif` for progress bars and `ratatui` for potential TUI mode. Must be screen-reader compatible.
