---
id: US-090
title: "Restore a previous prompt version with one click"
personas: [maya-chen]
domain: prompt-archival
priority: high
mvp_phase: "v0.3"
---

## User Story

As a **Maya Chen (Solo Dev/Indie Hacker)**, I want to restore a previous prompt version to active use with one click and rollback confirmation so that I can quickly revert agent behavior when a prompt change causes problems.

## Acceptance Criteria

- [ ] A "Restore" button appears on each historical prompt version in the timeline and comparison views
- [ ] Clicking Restore shows a confirmation dialog displaying: the version being restored, a diff against the current active version, and a warning if eval scores differ significantly
- [ ] Restoring a version creates a new version entry (not a destructive rewrite) with metadata indicating it was a restoration of version N
- [ ] The restoration takes effect within 5 seconds — the agent begins using the restored prompt on its next task without restart
- [ ] A global undo option is available for 60 seconds after restoration in case the restore was accidental

## Notes

Fast rollback is the safety net that makes prompt experimentation low-risk. The non-destructive restore model (creating a new version rather than deleting history) is essential for audit trails and for the eval domain to maintain continuous scoring history. For Maya's solo workflow, the speed matters — when a prompt change breaks her monitor agent at 2am, she needs to revert in seconds, not minutes. The 60-second undo window prevents panic-clicks from compounding the problem. Consider a "restore and pause" option that restores the prompt but pauses the agent for manual verification before resuming.
