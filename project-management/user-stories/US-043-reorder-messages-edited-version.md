---
id: US-043
title: "Reorder Messages in an Edited Version"
slug: reorder-messages-edited-version
personas: [P-002]
epic: "Thread Editing"
priority: should-have
complexity: medium
tags: [editing, non-destructive]
---

# US-043: Reorder Messages in an Edited Version

## User Story

**As a** staff engineer curating team knowledge
**I want to** drag-reorder messages within an edited version
**So that** I can present a more coherent narrative than the original chronological order (e.g. grouping root-cause discussion ahead of an interleaved distraction)

## Acceptance Criteria

- **Given** an edited version open for editing
  **When** I drag a message to a new position within the range being edited
  **Then** the message moves to that position and surrounding messages reflow accordingly

- **Given** I reorder messages and save the version
  **When** I reload the edited version
  **Then** the new order persists, and the original thread's chronological order is unaffected

- **Given** a reordered edited version
  **When** I view the diff against the previous version
  **Then** the reordering is reflected as a position change, not as a delete-and-add pair

## Notes

Used alongside collapse/remove when Priya assembles a single coherent incident doc from a merged thread; ordering by narrative logic rather than timestamp is the point of this story.
