---
id: US-083
title: "Handle orphaned JSONL directories"
slug: handle-orphaned-jsonl-directories
personas: [P-006]
epic: "Edge Cases & Error States"
priority: should-have
complexity: medium
tags: [error-state, indexing]
---

# US-083: Handle Orphaned JSONL Directories

## User Story

**As an** open-source maintainer
**I want to** have conversations flagged when their project's local path no longer exists
**So that** I notice renamed or deleted repos instead of losing that history from view silently

## Acceptance Criteria

- **Given** a project's local path referenced by indexed conversations no longer exists on disk
  **When** Sofia opens Browse
  **Then** the corresponding project group is flagged "orphaned" with a visible badge

- **Given** an orphaned project group is flagged
  **When** Sofia clicks into it
  **Then** she is prompted to either Rehome (point to the new path) or Archive the conversations, rather than the group being silently hidden

- **Given** Sofia renames a repo directory and the watcher detects the old path is gone
  **When** the next index scan runs
  **Then** the orphan flag appears automatically, without a manual rescan trigger

## Notes
This directly supports Sofia's workflow of using rehome after repo renames across the many small repos she maintains in short bursts — without this flag, renamed-repo history would effectively disappear from Browse.
