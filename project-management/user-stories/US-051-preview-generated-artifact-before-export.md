---
id: US-051
title: "Preview Generated Artifact Before Export"
slug: preview-generated-artifact-before-export
personas: [P-004, P-002]
epic: "Convert"
priority: must-have
complexity: low
tags: [convert, preview]
---

# US-051: Preview Generated Artifact Before Export

## User Story

**As a** skill-authoring developer advocate (or staff engineer curating team knowledge)
**I want** step 4 of the wizard to show a syntax-highlighted preview of the exact file(s) that will be written
**So that** I can catch formatting or content issues before anything touches disk

## Acceptance Criteria

- **Given** I reach step 4 after configuring metadata
  **When** the preview loads
  **Then** it shows the full rendered content of each file to be written (e.g. `SKILL.md`), syntax-highlighted appropriately for its format

- **Given** the preview reveals content I want to fix
  **When** I click "Back"
  **Then** I return to step 3 with my prior configuration values retained for editing

- **Given** the preview is showing
  **When** I click "Export"
  **Then** the wizard proceeds to the export step and writes exactly the content that was previewed, with no hidden transformation

## Notes

Low complexity — mostly a read-only render step, but it's the last checkpoint before disk writes, so accuracy of the preview relative to the final export matters more than the UI complexity.
