---
id: US-036
title: "Force overwrite existing output files"
slug: force-overwrite-existing
personas: [P-001, P-003]
epic: "CLI & UX"
priority: must-have
complexity: low
tags: [cli, force, overwrite, idempotent]
---

# US-036: Force overwrite existing output files

## User Story

**As a** developer re-generating assets after a prompt change
**I want to** use `--force` to overwrite existing output
**So that** I can update assets without manually deleting old files

## Acceptance Criteria

- **Given** an output file already exists and `--force` is NOT set
  **When** generation runs
  **Then** the prompt is skipped with a message like "hero.png already exists, skipping"

- **Given** an output file already exists and `--force` IS set
  **When** generation runs
  **Then** the existing file is overwritten with the new output

## Notes
Default behavior is skip (safe). `--force` is opt-in for re-generation scenarios.
