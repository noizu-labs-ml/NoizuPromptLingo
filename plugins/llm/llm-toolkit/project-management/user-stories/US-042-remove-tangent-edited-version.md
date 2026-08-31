---
id: US-042
title: "Remove a Tangent from an Edited Version"
slug: remove-tangent-edited-version
personas: [P-002, P-006]
epic: "Thread Editing"
priority: must-have
complexity: medium
tags: [editing, non-destructive]
---

# US-042: Remove a Tangent from an Edited Version

## User Story

**As a** staff engineer curating team knowledge (or open-source maintainer working across many small repos)
**I want to** remove a selected message range from an edited version of a thread
**So that** unrelated tangents don't pollute the narrative I want to share, publish, or convert

## Acceptance Criteria

- **Given** a thread containing an unrelated tangent (e.g. a side discussion about tooling)
  **When** I select that message range and choose "Remove"
  **Then** the range disappears from the edited version and the surrounding messages are correctly rejoined

- **Given** messages have been removed from an edited version
  **When** I inspect the original `.jsonl` file
  **Then** it remains unmodified — the removal exists only in the saved edited version

- **Given** I remove a range by mistake
  **When** I undo before saving the version
  **Then** the removed range is restored to the edited version

## Notes

Sofia removes dead-end investigation branches before pasting cleaned session excerpts into a GitHub issue; Priya removes tangents before merging two engineers' threads into one incident doc.
