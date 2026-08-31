---
id: US-066
title: "Merge two conversations into one document"
slug: merge-two-conversations-into-one-document
personas: [P-002]
epic: "Conversation Operations"
priority: must-have
complexity: high
tags: [ops, merge]
---

# US-066: Merge Two Conversations Into One Document

## User Story

**As a** staff engineer curating team knowledge
**I want to** select two related conversations — such as a diagnosis thread and a fix thread — and merge chosen message ranges from each into a single assembled document
**So that** I can produce one coherent incident write-up instead of leaving the story scattered across two separate sessions

## Acceptance Criteria

- **Given** I have two conversations open in the Merge tool (e.g. one engineer's diagnosis thread and another's fix thread)
  **When** I select specific message ranges from each source and arrange their order
  **Then** the tool assembles a single preview document combining only the selected ranges, in the order I specified, with a clear marker of which source conversation each range came from

- **Given** I am building the merge
  **When** I reorder a selected range or remove one from the assembly
  **Then** the preview updates live to reflect the new composition without needing to restart the merge

- **Given** the assembled preview looks correct
  **When** I save the merge
  **Then** a new conversation document is created containing the merged content, and both original source conversations remain completely unmodified

- **Given** the two source conversations contain overlapping or conflicting tool-call blocks
  **When** the merge is assembled
  **Then** each block retains its original source attribution so it's clear which thread it came from, avoiding ambiguity in the resulting document

## Notes
This is Priya's signature workflow for turning two engineers' separate debugging threads into one incident doc for the team's knowledge base. High complexity reflects the multi-source range selection, live preview, and non-destructive assembly logic involved.
