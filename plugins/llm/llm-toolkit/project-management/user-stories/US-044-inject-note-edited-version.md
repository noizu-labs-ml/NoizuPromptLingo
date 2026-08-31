---
id: US-044
title: "Inject a Note into an Edited Version"
slug: inject-note-edited-version
personas: [P-002]
epic: "Thread Editing"
priority: should-have
complexity: medium
tags: [editing, non-destructive]
---

# US-044: Inject a Note into an Edited Version

## User Story

**As a** staff engineer curating team knowledge
**I want to** insert a free-text note/annotation at a chosen point in an edited version
**So that** I can add context (e.g. "this dead end took 40 min — root cause was X") that wasn't present in the original conversation

## Acceptance Criteria

- **Given** an edited version open for editing
  **When** I choose "Insert note" at a point between two messages
  **Then** a free-text note block is created at that position, visually distinct from AI/human/tool messages

- **Given** I save an edited version containing an injected note
  **When** another user opens that version
  **Then** the note renders as markdown and is clearly labeled as an editor annotation, not part of the original conversation

- **Given** I leave the note text empty
  **When** I try to save the insert
  **Then** the editor blocks the insert and requires non-empty note text

## Notes

Priya uses injected notes to explain to teammates why a debugging dead end was deliberately left in the runbook for context, rather than silently removed.
