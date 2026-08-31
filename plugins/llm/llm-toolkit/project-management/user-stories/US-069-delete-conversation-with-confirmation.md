---
id: US-069
title: "Delete a conversation with confirmation"
slug: delete-conversation-with-confirmation
personas: [P-005, P-006]
epic: "Conversation Operations"
priority: should-have
complexity: low
tags: [ops, delete, safety]
---

# US-069: Delete a Conversation With Confirmation

## User Story

**As an** engineering lead auditing team AI usage (or open-source maintainer)
**I want to** be required to explicitly confirm before permanently deleting a conversation
**So that** I don't accidentally destroy a session's JSONL and index entries with a single misclick

## Acceptance Criteria

- **Given** I click "Delete" on a conversation
  **When** the confirmation dialog appears
  **Then** it requires me to type the conversation's exact title before the "Delete permanently" button becomes enabled

- **Given** I have typed the correct title and confirmed
  **When** the delete executes
  **Then** the conversation's JSONL file is removed from disk and all FTS5/embedding index entries for it are purged

- **Given** I type an incorrect or partial title
  **When** I attempt to confirm
  **Then** the delete button remains disabled and no data is removed

- **Given** a conversation has already been converted into a durable asset (skill/agent/runbook) or included in a dataset
  **When** I attempt to delete it
  **Then** the confirmation dialog warns me of the downstream references before I can proceed

## Notes
Daniel and Sofia both handle destructive cleanup — Daniel purging stale audit-flagged threads, Sofia cleaning up dead branches — so the type-to-confirm gate protects against irreversible mistakes given deletion is the one operation with no undo.
