---
id: US-065
title: "Restore an archived conversation"
slug: restore-archived-conversation
personas: [P-006]
epic: "Conversation Operations"
priority: should-have
complexity: low
tags: [ops, archive]
---

# US-065: Restore an Archived Conversation

## User Story

**As an** open-source maintainer
**I want to** filter Browse to show archived conversations and restore one with a single click
**So that** I can bring back an old investigation thread if it turns out to be relevant again

## Acceptance Criteria

- **Given** I am on the Browse view
  **When** I select the "Archived" filter
  **Then** only archived conversations are listed, grouped by project the same way active conversations are

- **Given** the Archived filter is active
  **When** I click "Restore" on a listed conversation
  **Then** the conversation's archived flag is cleared and it reappears in the default (non-archived) Browse listing on the next default-filter view

- **Given** a conversation was restored
  **When** I check its tags, versions, and edit history
  **Then** all metadata created before archiving is preserved unchanged

## Notes
Complements US-064; Sofia occasionally needs to reopen an archived branch investigation when the same bug resurfaces in a different repo. Should-have alongside archive since restore has no value without it, but both are secondary to the must-have core ops.
