---
id: US-087
title: "Resume fails when session directory is gone"
slug: resume-fails-session-directory-gone
personas: [P-001, P-007]
epic: "Edge Cases & Error States"
priority: could-have
complexity: medium
tags: [error-state, resume]
---

# US-087: Resume Fails When Session Directory Is Gone

## User Story

**As a** solo power-user developer
**I want to** be told clearly when the original session directory for "resume" no longer exists
**So that** I don't end up launching a broken command against a missing project path

## Acceptance Criteria

- **Given** Marcus clicks "resume" on a thread whose original Claude Code session directory has been deleted
  **When** the resume command would normally be generated
  **Then** the app detects the missing directory first and shows "Original session directory no longer exists" instead of running a broken command

- **Given** Jamie tries resume on an old session a mentor referenced
  **When** the directory is gone
  **Then** the message explains in plain terms why resume isn't possible (e.g. "the project folder this conversation belonged to has been moved or deleted")

- **Given** the directory is gone
  **When** the error is shown
  **Then** the user is offered the option to view the read-only thread content instead of resuming

## Notes
could-have — this is a polish edge case on top of the core resume feature; deferred behind higher-priority error-state stories since a missing session directory is a comparatively rare occurrence for both personas.
