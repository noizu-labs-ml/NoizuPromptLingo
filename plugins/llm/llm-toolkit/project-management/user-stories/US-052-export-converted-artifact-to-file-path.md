---
id: US-052
title: "Export Converted Artifact to File Path"
slug: export-converted-artifact-to-file-path
personas: [P-002, P-004, P-006]
epic: "Convert"
priority: must-have
complexity: medium
tags: [convert, export]
---

# US-052: Export Converted Artifact to File Path

## User Story

**As a** staff engineer curating team knowledge, skill-authoring developer advocate, or open-source maintainer
**I want** exporting to write the artifact (SKILL.md + dir, agent .md, command file, snippet, or runbook doc) to the configured output path and confirm success with the final path shown
**So that** I know exactly where the new artifact landed and can immediately use it or commit it

## Acceptance Criteria

- **Given** I click "Export" on the wizard's final step for a "skill" artifact
  **When** the export completes
  **Then** the `SKILL.md` file and its directory are written to the configured path, and a success confirmation displays the absolute final path

- **Given** I export a "runbook" artifact
  **When** export completes
  **Then** a single runbook markdown document is written to the configured path (no directory created), matching what was previewed

- **Given** the configured output path's parent directory doesn't exist
  **When** I click "Export"
  **Then** the wizard creates any missing parent directories, or reports a clear error if it cannot

- **Given** export fails partway through (e.g. a disk permission error)
  **When** the failure occurs
  **Then** no partial or corrupt file is left at the target path, and the wizard reports the specific error

## Notes

Sofia exports runbooks she then pastes into GitHub issues; Tobias's skill exports feed directly into `skill-manage enable` for cross-provider rollout.
