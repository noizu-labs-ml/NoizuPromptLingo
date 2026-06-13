---
id: US-045
title: "Generate multiple output formats simultaneously"
slug: multi-format-output
personas: [P-001, P-008]
epic: "Output & Naming"
priority: must-have
complexity: low
tags: [output, formats, multi-format, naming]
---

# US-045: Generate multiple output formats simultaneously

## User Story

**As a** developer creating web assets
**I want to** generate both PNG and WebP from a single prompt
**So that** I get optimized assets for different browsers in one command

## Acceptance Criteria

- **Given** `output.formats` with `[{format: png, quality: 100}, {format: webp, quality: 85}]`
  **When** generation completes
  **Then** both `hero.png` and `hero.webp` are produced

- **Given** variants (`-n 2`) with multiple formats
  **When** generation completes
  **Then** files are: `hero.png`, `hero.webp`, `hero.2.png`, `hero.2.webp`

## Notes
Naming convention: `{stem}.{ext}`, `{stem}.2.{ext}`, etc.
