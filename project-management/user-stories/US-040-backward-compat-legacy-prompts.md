---
id: US-040
title: "Use backward-compatible legacy prompt files"
slug: backward-compat-legacy-prompts
personas: [P-001, P-003]
epic: "CLI & UX"
priority: must-have
complexity: medium
tags: [backward-compat, legacy, v0.1, v0.2]
---

# US-040: Use backward-compatible legacy prompt files

## User Story

**As a** developer with existing `.prompt` files
**I want to** run old-format prompt files without modification
**So that** I don't have to migrate all my existing assets to the new schema

## Acceptance Criteria

- **Given** a legacy `*.{ext}.prompt` file with v0.1/v0.2 schema
  **When** the file is parsed
  **Then** it is auto-detected and normalized to v0.3 internally

- **Given** legacy field mappings (`requirements.format` → `output.formats[0].format`)
  **When** the file is processed
  **Then** all legacy fields map correctly to v0.3 equivalents

## Notes
Legacy files and v0.3 files can coexist in the same directory and reference each other via dependencies.
