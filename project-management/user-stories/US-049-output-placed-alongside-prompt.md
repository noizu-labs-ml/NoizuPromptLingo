---
id: US-049
title: "Output placed alongside prompt file"
slug: output-placed-alongside-prompt
personas: [P-001]
epic: "Output & Naming"
priority: must-have
complexity: low
tags: [output, file-placement, convention]
---

# US-049: Output placed alongside prompt file

## User Story

**As a** developer organizing assets by project
**I want to** output files in the same directory as the `.media.prompt` file
**So that** assets stay co-located with their prompt definitions

## Acceptance Criteria

- **Given** `projects/my-app/assets/hero.media.prompt`
  **When** generation runs
  **Then** `projects/my-app/assets/hero.png` is created

- **Given** a nested directory structure
  **When** multiple prompts are in different directories
  **Then** each output goes to its own prompt's directory

## Notes
Simple convention: output directory = prompt file directory. No special output path configuration needed.
