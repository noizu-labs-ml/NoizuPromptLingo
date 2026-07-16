---
id: US-088
title: "Fall Back to Read-Only When Operating on an Archived Project"
slug: "archived-project-read-only-fallback"
personas: [P-003]
epic: "Edge Cases & Error States"
priority: "should-have"
complexity: "S"
tags: [projects, archival, permissions, ux]
---

# US-088: Fall Back to Read-Only When Operating on an Archived Project

## User Story

**As** Priya Anand, the Delivery Lead (P-003),
**I want to** still browse tickets, boards, and history in a project after it's archived, but be blocked from mutating actions,
**So that** I can reference past work without accidentally reviving or corrupting an intentionally closed project.

## Acceptance Criteria

- [ ] Given a project has been archived, when Priya opens its ticket board, then all existing tickets, comments, and history render normally in a visibly read-only mode (banner plus disabled controls).
- [ ] Given an archived project, when Priya attempts a mutating action (create ticket, edit ticket, post comment, change status), then the action is blocked both client-side and server-side with a clear "project is archived" error, not a silent no-op.
- [ ] Given an archived project, when the Autonomous Coding Agent (P-002) attempts a write via the API rather than the UI, then the server enforces the same read-only restriction.
- [ ] Given the project owner unarchives the project, when Priya reloads the board, then full read/write access is restored immediately.

## Notes

Server-side enforcement matters because agents (P-002) bypass the UI entirely — a UI-only guard would be a spoofable hole in the same spirit as what tool_guard (US-086) closes for identity.
