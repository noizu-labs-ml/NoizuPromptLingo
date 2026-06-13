---
id: US-035
title: "Preview generation plan without API calls"
slug: dry-run-preview
personas: [P-001, P-003]
epic: "CLI & UX"
priority: must-have
complexity: low
tags: [dry-run, preview, planning]
---

# US-035: Preview generation plan without API calls

## User Story

**As a** developer preparing a batch generation
**I want to** run `--dry-run --verbose` to preview the plan
**So that** I can verify prompt files, dependencies, and output paths before spending API credits

## Acceptance Criteria

- **Given** a directory of `.media.prompt` files
  **When** I run `generate-media-prompt --dry-run --verbose assets/`
  **Then** the plan shows: file list, dependency tiers, service/model for each, output paths, and any errors

- **Given** missing API keys
  **When** `--dry-run` is used
  **Then** missing keys are tolerated (shown as warnings, not errors)

## Notes
Dry-run is essential for CI validation and cost estimation. Must not make any API calls.
