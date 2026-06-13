---
id: US-079
title: "Validate schema version and warn on future versions"
slug: schema-version-validation
personas: [P-005]
epic: "Schema & Format"
priority: should-have
complexity: low
tags: [schema, version, validation, compatibility]
---

# US-079: Validate schema version and warn on future versions

## User Story

**As a** contributor adding new schema features
**I want to** the tool to validate the schema version field
**So that** users know if their prompt files use features the installed version doesn't support

## Acceptance Criteria

- **Given** a `.media.prompt` with `schema: "0.3"`
  **When** the tool version supports 0.3
  **Then** the file is processed normally

- **Given** a `.media.prompt` with `schema: "0.4"` (future version)
  **When** the tool only supports up to 0.3
  **Then** a warning indicates the file uses a newer schema version and some features may not work

## Notes
Forward compatibility: warn but don't error. Unknown fields are preserved and passed through.
