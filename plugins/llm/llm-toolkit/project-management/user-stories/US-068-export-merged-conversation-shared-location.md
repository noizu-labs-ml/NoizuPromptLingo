---
id: US-068
title: "Export merged conversation to shared location"
slug: export-merged-conversation-shared-location
personas: [P-002]
epic: "Conversation Operations"
priority: should-have
complexity: medium
tags: [ops, merge, export]
---

# US-068: Export Merged Conversation to Shared Location

## User Story

**As a** staff engineer curating team knowledge
**I want to** export a merged/assembled document directly to a configured shared team path, such as a docs/wiki directory
**So that** the incident write-up lands where my team already looks for documentation, instead of requiring a manual local-download-then-copy step

## Acceptance Criteria

- **Given** a merged document has been saved (per US-066) and a shared export path has been configured in Settings
  **When** I choose "Export to shared location" on the merged document
  **Then** the document is written as a markdown file to the configured path (e.g. `~/team-docs/incidents/`) using the merge's title as the filename

- **Given** no shared export path has been configured yet
  **When** I attempt the export
  **Then** I'm prompted to configure one in Settings before the export can proceed

- **Given** a file already exists at the target path
  **When** I export
  **Then** I'm asked to confirm overwrite or given the option to export under a new filename, rather than silently overwriting

## Notes
Priya's team keeps incident postmortems in a shared wiki directory; this closes the loop from Merge (US-066) to team-visible documentation without a manual copy step. Should-have since local download already covers the base case — this is a convenience for team workflows.
