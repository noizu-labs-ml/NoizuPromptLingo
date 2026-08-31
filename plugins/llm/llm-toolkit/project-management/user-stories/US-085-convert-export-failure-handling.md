---
id: US-085
title: "Convert export failure handling"
slug: convert-export-failure-handling
personas: [P-004, P-002]
epic: "Edge Cases & Error States"
priority: should-have
complexity: medium
tags: [error-state, convert]
---

# US-085: Convert Export Failure Handling

## User Story

**As a** skill-authoring developer advocate
**I want to** see a specific error and retry export with a corrected path if the Convert wizard's export step fails
**So that** I don't lose the metadata I've already configured and have to redo the whole wizard flow

## Acceptance Criteria

- **Given** Priya completes the Convert wizard's configure and preview steps and reaches export
  **When** the output path is not writable (e.g. permission denied)
  **Then** the wizard shows the specific OS-level error on the export step instead of a generic failure

- **Given** export has failed
  **When** Priya corrects the output path and retries
  **Then** export retries without losing the previously configured metadata (name, artifact type, message range, description)

- **Given** Tobias exports a skill to a directory name that already exists
  **When** export fails due to a name collision
  **Then** the error names the exact conflicting path and offers a rename option

## Notes
Matches the Convert wizard's 5-step flow (type → range → configure → preview → export). Losing configured metadata on failure would be especially costly for Tobias, who carefully tunes artifact metadata before rolling a skill out across providers.
