---
id: US-035
title: "One-click resume command"
slug: one-click-resume-command
personas: [P-001, P-007]
epic: "Thread Viewer"
priority: must-have
complexity: medium
tags: [viewer, resume, cli]
---

# US-035: One-Click Resume Command

## User Story

**As a** novice occasional user
**I want to** click a "Resume" action in the thread header that copies or launches the exact CLI command to continue that Claude Code session
**So that** I can pick up a session my mentor referenced without figuring out the correct `claude` CLI flags myself

## Acceptance Criteria

- **Given** I open a thread in the viewer
  **When** I look at the thread header
  **Then** a "Resume" button/action is visible, showing the target project path so I can confirm it's the right session

- **Given** I click "Resume"
  **When** the action fires
  **Then** the exact CLI resume command (including the correct session ID and project directory) is copied to my clipboard, with a confirmation toast/message

- **Given** the underlying JSONL session file has been archived or moved (rehomed) since the thread was indexed
  **When** I click "Resume"
  **Then** the command reflects the current on-disk location, or the UI warns me if the session file can no longer be found

- **Given** Marcus wants to jump straight back into a session from the CLI
  **When** he uses the `show` command's equivalent resume affordance
  **Then** the same correct command is produced as in the web UI, keeping CLI and web behavior consistent

## Notes
Jamie specifically relies on Resume when a mentor references an old session — this needs to be foolproof and require zero manual command construction. Must-have given it's core to the product's "get back into a session" value proposition; medium complexity because it must stay correct across rehome/archive state changes (see the Conversation operations feature set).
