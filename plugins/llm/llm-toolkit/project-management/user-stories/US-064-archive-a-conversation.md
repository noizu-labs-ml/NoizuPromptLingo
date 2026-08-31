---
id: US-064
title: "Archive a conversation"
slug: archive-a-conversation
personas: [P-006, P-005]
epic: "Conversation Operations"
priority: should-have
complexity: low
tags: [ops, archive]
---

# US-064: Archive a Conversation

## User Story

**As an** open-source maintainer (or engineering lead auditing team AI usage)
**I want to** archive a conversation to hide it from the default Browse listing without deleting it
**So that** dead investigation branches and reviewed sessions stop cluttering my day-to-day view while remaining recoverable

## Acceptance Criteria

- **Given** a conversation is open or selected in Browse
  **When** I choose "Archive" from its action menu
  **Then** the conversation is marked archived and immediately disappears from the default Browse listing

- **Given** a conversation has just been archived
  **When** the archive completes
  **Then** its JSONL file and index entries remain on disk and in the search index — only its Browse visibility state changes

- **Given** a conversation is already archived
  **When** I run a keyword or semantic search that matches its content
  **Then** it is still excluded from default search results unless the "include archived" option is explicitly enabled

## Notes
Sofia archives dead investigation branches once a bug is resolved; Daniel archives threads he has already reviewed during his weekly scan so they don't reappear in the next pass. Deferred to should-have since it's a convenience layer on top of the must-have core CRUD ops (US-061/062/063).
