---
id: US-305
title: "Receive VFS pubsub change notifications on an open VFSWS connection"
slug: "vfs-pubsub-change-notifications"
personas: [P-001, P-002]
epic: "Virtual File System"
priority: "should-have"
complexity: "M"
tags: [vfs, pubsub, realtime, notifications]
---

# US-305: Receive VFS pubsub change notifications on an open VFSWS connection

## User Story

**As a** Harness Operator (P-001) supervising an Autonomous Coding Agent (P-002) working through the VFS tree,
**I want to** receive change notifications over my open `/vfs` connection when watched nodes are mutated,
**So that** I see other actors' changes in real time instead of re-reading stale files or polling.

## Acceptance Criteria

- [ ] Given a connected client that has expressed interest in a node (or mount subtree), when another client mutates that node through the VFS, then the client receives a change notification identifying the path and the nature of the change.
- [ ] Given a change to a node outside the receiving principal's scope, when the pubsub layer fans out, then no notification for that node is delivered to that principal.
- [ ] Given a notification burst (many rapid mutations), when delivered, then the client receives them without duplicates and without unbounded queuing that starves the connection.
- [ ] Given a client that disconnects and reconnects, when it re-subscribes, then the documented catch-up behavior applies (either missed-change replay or an explicit "stale, re-read" signal) — never silent loss presented as freshness.
- [ ] Given no mutations occur, when a connection idles, then no spurious notifications are delivered.

## Notes

A pubsub module already exists in Wave 0 (`backend/lib/noizu_prompt_lingua/mcp/vfs/pubsub.ex`) with a conformance test (`pubsub_test.exs`); this story covers the agent-facing contract: subscription semantics, scope filtering, and reconnect behavior. Delivery guarantees must be explicitly specified once — at-most-once is acceptable if documented, but the agent consumer must not assume durability the backend does not provide.
