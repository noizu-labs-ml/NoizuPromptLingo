---
id: US-084
title: "Confirm before irreversible delete"
slug: confirm-before-irreversible-delete
personas: [P-005, P-007]
epic: "Edge Cases & Error States"
priority: must-have
complexity: low
tags: [error-state, safety]
---

# US-084: Confirm Before Irreversible Delete

## User Story

**As an** engineering lead auditing team AI usage
**I want to** be required to explicitly confirm before any permanent delete
**So that** I (or a less experienced teammate) can't destroy conversation history with a single misclick

## Acceptance Criteria

- **Given** Daniel selects a conversation to delete
  **When** he triggers the delete action
  **Then** a confirmation dialog requires typing the conversation name (or "DELETE") before the confirm button becomes active

- **Given** Jamie attempts a delete
  **When** the confirmation dialog appears
  **Then** it states plainly, in non-technical language, that "this cannot be undone" and the source JSONL file will be permanently removed

- **Given** the confirmation dialog is open
  **When** the user clicks Cancel or presses Escape
  **Then** no data is deleted and they return to the prior view

## Notes
Jamie is wary of Edit/Convert because they're unsure the actions are reversible; this story addresses the one operation (delete) where that caution is actually warranted, while other operations (archive, clone) remain reversible and don't need this gate.
