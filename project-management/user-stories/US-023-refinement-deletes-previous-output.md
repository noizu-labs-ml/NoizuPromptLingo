---
id: US-023
title: "Previous output is deleted during refinement"
slug: refinement-deletes-previous-output
personas: [P-001]
epic: "Interactive Refinement"
priority: should-have
complexity: low
tags: [refine, cleanup, file-management]
---

# US-023: Previous output is deleted during refinement

## User Story

**As a** developer refining an asset
**I want to** the previous output to be replaced by the refined output
**So that** I don't accumulate rejected variants on disk

## Acceptance Criteria

- **Given** a refinement iteration produces a new output
  **When** the new file is written
  **Then** the previous iteration's output file is deleted first

- **Given** refinement is cancelled (Ctrl+C)
  **When** the tool exits
  **Then** the most recent accepted output (if any) is preserved

## Notes
Prevents disk clutter during iterative refinement. The latest generation is always the one on disk.
