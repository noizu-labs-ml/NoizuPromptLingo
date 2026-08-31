---
id: US-036
title: "Jump-to-message navigation"
slug: jump-to-message-navigation
personas: [P-002, P-005]
epic: "Thread Viewer"
priority: should-have
complexity: medium
tags: [viewer, navigation]
---

# US-036: Jump-to-Message Navigation

## User Story

**As an** engineering lead auditing team AI usage
**I want to** use a mini-map or jump list to navigate directly to a specific message in a long conversation
**So that** I can spot-check a long or oddly-shaped thread for issues without manually scrolling through hundreds of messages

## Acceptance Criteria

- **Given** I open a thread with 100+ messages
  **When** the viewer renders
  **Then** a mini-map or jump-list panel appears showing message positions (e.g. by role, length, or tool-call markers), distinct from the main scroll area

- **Given** I click an entry in the jump list (or a position on the mini-map)
  **When** the click registers
  **Then** the main thread view scrolls directly to that message and briefly highlights it

- **Given** a thread is short (e.g. under 10 messages)
  **When** the viewer renders
  **Then** the jump navigation either hides itself or shows a minimal/non-intrusive version, since it adds little value for short threads

## Notes
Daniel needs to jump straight to unusually long or suspicious-looking sections of a thread during spot-checks rather than scrolling linearly; Priya uses it to jump to the specific exchange she wants when assembling a Merge doc from two engineers' threads. Medium complexity: requires a position index computed from message metadata (role, length, tool-call presence) to make the mini-map meaningful.
