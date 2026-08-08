---
id: US-002
title: "Resume an existing session and see its rooms/tickets/artifacts"
slug: "resume-session-with-rooms-tickets-artifacts"
personas: [P-001, P-002]
epic: "Work Sessions"
priority: "must-have"
complexity: "S"
tags: [sessions, resume, context, mcp]
---

# US-002: Resume an existing session and see its rooms/tickets/artifacts

## User Story

**As a** Harness Operator (P-001) restarting a coding agent (P-002) mid-project,
**I want to** resume a previously created work session by its ID and immediately see the rooms, tickets, and artifacts already attached to it,
**So that** the agent picks up exactly where the last run left off without re-deriving context from scratch.

## Acceptance Criteria

- [ ] Given a session UUID from a prior run, when the resume call is invoked with that UUID, then the response includes the session's status, title, description, and org/project scope.
- [ ] Given a resumed session that has two chat rooms and five tickets already linked, when the resume call completes, then all five tickets and both rooms are returned (or enumerable via a follow-up scoped list call) without requiring the caller to already know their IDs.
- [ ] Given a session UUID that belongs to a different organization than the caller's current auth context, when resume is attempted, then the call is rejected with an authorization error and no session data is returned.
- [ ] Given a session that was left in "active" status, when it is resumed, then its status remains "active" and a "last resumed at" timestamp is updated.

## Notes

Complements US-001; together these two stories form the mandatory bootstrap path every harness run takes (create-or-resume). See US-004 for discovering which session ID to resume when it isn't already known.
