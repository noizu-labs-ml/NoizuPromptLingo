---
id: US-062
title: "Clone a conversation before editing"
slug: clone-conversation-before-editing
personas: [P-006, P-002]
epic: "Conversation Operations"
priority: must-have
complexity: low
tags: [ops, clone]
---

# US-062: Clone a Conversation Before Editing

## User Story

**As an** open-source maintainer (or staff engineer curating team knowledge)
**I want to** clone a conversation into a new independent copy before I start heavy editing
**So that** I can experiment freely with the Thread Editor without any risk to the original session

## Acceptance Criteria

- **Given** a conversation is open in the thread viewer
  **When** I click "Clone" and confirm
  **Then** a new conversation entry is created with its own id, the same messages, and the source JSONL file is left completely untouched

- **Given** a clone has just been created
  **When** the clone completes
  **Then** the UI navigates me to the cloned conversation and its title/metadata clearly indicates it is a clone (e.g. "Copy of ..." or a clone badge referencing the source id)

- **Given** I later edit the clone using the non-destructive Thread Editor (collapse/remove/reorder/inject)
  **When** I save the edits as a new version
  **Then** the original conversation's messages and version history remain unaffected

## Notes
Sofia clones before editing so she can safely trim a messy debugging session down to something postable in a GitHub issue without fear of losing the raw original; Priya clones before merging two engineers' threads so each source thread stays intact for later reference.
