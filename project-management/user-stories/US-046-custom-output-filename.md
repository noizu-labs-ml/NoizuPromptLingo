---
id: US-046
title: "Custom output filename per format"
slug: custom-output-filename
personas: [P-001, P-003]
epic: "Output & Naming"
priority: should-have
complexity: low
tags: [output, naming, filename, override]
---

# US-046: Custom output filename per format

## User Story

**As a** developer managing asset naming conventions
**I want to** override the default filename for specific output formats
**So that** output files match my project's naming scheme

## Acceptance Criteria

- **Given** `output.formats[0].filename: landing-hero`
  **When** PNG output is produced
  **Then** the file is named `landing-hero.png` instead of `hero.png`

- **Given** no filename override
  **When** output is produced
  **Then** the filename is derived from the `.media.prompt` file's stem

## Notes
Filename override applies per format, allowing different names for different outputs from the same prompt.
