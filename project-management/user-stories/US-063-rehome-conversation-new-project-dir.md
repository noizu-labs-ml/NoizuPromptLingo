---
id: US-063
title: "Rehome conversation to new project dir"
slug: rehome-conversation-new-project-dir
personas: [P-006]
epic: "Conversation Operations"
priority: must-have
complexity: medium
tags: [ops, rehome]
---

# US-063: Rehome Conversation to New Project Dir

## User Story

**As an** open-source maintainer
**I want to** move a conversation's JSONL to a different project directory and have the index update to match
**So that** sessions still show up correctly grouped in Browse after I rename or reorganize one of my many small repos

## Acceptance Criteria

- **Given** a conversation currently indexed under project directory `~/repos/old-repo-name`
  **When** I call `POST /api/conversations/:id/rehome` with a target project path (or use the equivalent "Rehome" action in the thread header)
  **Then** the underlying JSONL file is moved on disk to the new project directory and the FTS5/embedding index entries are updated to reference the new path

- **Given** the rehome has completed
  **When** I open Browse
  **Then** the conversation appears grouped under the new project and no longer appears under the old project group

- **Given** I supply a target project path that does not exist on disk
  **When** I submit the rehome request
  **Then** the API returns a validation error and the conversation is left untouched at its original location

- **Given** a rehome target path collides with an existing file of the same name in the destination directory
  **When** I submit the rehome request
  **Then** the operation fails with a clear conflict error rather than silently overwriting the existing file

## Notes
This directly supports Sofia's workflow of renaming repos and needing old sessions to follow the rename so her project-grouped Browse view stays accurate.
