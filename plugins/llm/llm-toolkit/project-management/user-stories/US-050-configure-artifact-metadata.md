---
id: US-050
title: "Configure Artifact Metadata"
slug: configure-artifact-metadata
personas: [P-004]
epic: "Convert"
priority: must-have
complexity: medium
tags: [convert, wizard, metadata]
---

# US-050: Configure Artifact Metadata

## User Story

**As a** skill-authoring developer advocate
**I want** step 3 of the Convert wizard to collect name, description, parameters, and output file path for the artifact being generated, with validation on required fields
**So that** the generated artifact is properly named and placed without needing a follow-up manual edit

## Acceptance Criteria

- **Given** I reach step 3 with "skill" chosen as the artifact type
  **When** the form loads
  **Then** it shows fields for name, description, parameters (list), and output file path, defaulting the path to a sensible `SKILL.md` + directory location

- **Given** I leave the name or output file path empty
  **When** I try to advance to the preview step
  **Then** the wizard blocks advancing and highlights the missing required fields

- **Given** I enter an output file path that already exists
  **When** I try to proceed
  **Then** the wizard warns me of the potential overwrite before allowing me to continue

## Notes

Tobias configures metadata carefully here since it determines how `skill-manage enable` will later catalog and link the artifact across Claude, Codex, and Grok install roots.
