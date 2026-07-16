---
id: US-015
title: "Create a chat room scoped to a session or project"
slug: "create-chat-room-scoped-to-session-or-project"
personas: [P-001]
epic: "Chat & Collaboration Rooms"
priority: "must-have"
complexity: "S"
tags: [rooms, scoping, session, mvp]
---

# US-015: Create a chat room scoped to a session or project

## User Story

**As the** Harness Operator (P-001),
**I want to** create a chat room scoped to a specific session or project,
**So that** I have a durable, contextually-bounded space to coordinate with coding agents and teammates about that work.

## Acceptance Criteria

- [ ] Given an active project with a valid session, when Jordan creates a new room and specifies the project (and optionally session) scope, then the room is created and persisted with that scope recorded, and the room immediately appears in the project's room list.
- [ ] Given a room name that already exists within the same project scope, when Jordan attempts to create another room with that exact name, then the system rejects the duplicate with a clear conflict error instead of silently creating a collision.
- [ ] Given a newly created room, when Jordan fetches the room's metadata, then the response includes the room ID, scope (org/project/session), creator, and creation timestamp.
- [ ] Given Jordan creates a room without specifying a session, when the room is created, then it is scoped at the project level and remains accessible across multiple sessions within that project.

## Notes

Foundational story for the epic — US-016 through US-021 all assume a room created via this story already exists. See US-001/US-002 for the underlying session model a room can optionally bind to.
