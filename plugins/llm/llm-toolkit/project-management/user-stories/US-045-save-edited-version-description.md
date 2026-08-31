---
id: US-045
title: "Save Edited Version with Description"
slug: save-edited-version-description
personas: [P-002, P-006]
epic: "Thread Editing"
priority: must-have
complexity: high
tags: [editing, versioning]
---

# US-045: Save Edited Version with Description

## User Story

**As a** staff engineer curating team knowledge (or open-source maintainer)
**I want to** have saving an edit create a new named version that requires a description of what changed and why
**So that** teammates — or my future self — understand the intent behind each version without diffing manually, and the original source is always safe

## Acceptance Criteria

- **Given** I have made edits (collapse/remove/reorder/inject) to a thread
  **When** I click "Save version" without entering a description
  **Then** the save is blocked and a required-field validation message is shown

- **Given** I enter a description and save
  **When** the save completes
  **Then** a new version entry is created with a name, timestamp, author, and the description, and it appears in the version list

- **Given** a version has been saved
  **When** I inspect the original source `.jsonl` file's checksum and modified time
  **Then** they are identical to before the edit — the save writes only to the versions store, never the source

- **Given** multiple versions already exist for a thread
  **When** I save another edit
  **Then** it creates a new version rather than overwriting a prior one

## Notes

High complexity because it combines the versioning store, required-field validation, and the non-destructive source guarantee in one operation — this is the safety-critical story of the Thread Editing epic.
