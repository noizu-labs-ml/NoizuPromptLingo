---
id: US-046
title: "View Version History and Diff"
slug: view-version-history-diff
personas: [P-002, P-005]
epic: "Thread Editing"
priority: should-have
complexity: medium
tags: [editing, versioning, diff]
---

# US-046: View Version History and Diff

## User Story

**As a** staff engineer curating team knowledge (or engineering lead auditing team AI usage)
**I want to** see all saved versions of a thread listed with timestamps and descriptions in the thread header, and diff any two versions
**So that** I can track how a thread evolved into a shared artifact, and audit what a teammate changed and why

## Acceptance Criteria

- **Given** a thread with 3 saved versions
  **When** I open the thread header
  **Then** all 3 versions are listed with timestamp, author, and description, newest first

- **Given** I select two versions from the list
  **When** I click "Diff"
  **Then** a diff view highlights added, removed, reordered, and collapsed message ranges between the two versions

- **Given** a thread has only the original conversation with no saved edits
  **When** I open the version list
  **Then** it shows only "Original" and the diff action is disabled

## Notes

Daniel uses this during his weekly oversight scan to check what teammates changed and why in versions produced from source threads, without re-reading the full thread each time.
