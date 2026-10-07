---
id: US-301
title: "Operate platform data through the VFS file tree over the VFSWS transport"
slug: "operate-platform-vfs-tree-over-vfsws"
personas: [P-001, P-002]
epic: "Virtual File System"
priority: "must-have"
complexity: "M"
tags: [vfs, vfsws, transport, agent-tools, mcp]
---

# US-301: Operate platform data through the VFS file tree over the VFSWS transport

## User Story

**As an** Autonomous Coding Agent (P-002) orchestrated by a Harness Operator (P-001),
**I want to** connect to the VFS WebSocket transport at `/vfs` and browse, read, and interact with platform data as a file tree,
**So that** I can work with sessions, tickets, artifacts, and other domain data through one uniform hierarchical interface instead of learning dozens of bespoke tool signatures.

## Acceptance Criteria

- [ ] Given an authenticated client with a valid bearer token, when it opens a WebSocket to `/vfs` and sends the in-band `vfs/auth` handshake, then the connection is established and the root listing shows the per-domain mounts (sessions, tickets, chat, artifacts, memory, and the remaining mounted domains).
- [ ] Given an established VFS connection, when the client issues `vfs/read` against a JSON-backed node (for example under the sessions mount), then the file content round-trips as valid JSON matching the underlying entity.
- [ ] Given a connection attempt without a valid token, when the WebSocket upgrade is requested, then it is rejected with 401 before any VFS operation is possible.
- [ ] Given a client that requests a path outside the mounted tree, when the operation is issued, then it receives a structured error response and the connection remains usable.

## Notes

Wave 0 of the VFS substrate is implemented in the Elixir backend (`backend/lib/noizu_prompt_lingua/mcp/vfs/`, server/router/root/scope/principal/pubsub plus per-domain mounts); core behaviour lives in the `noizu_mcp` 0.3.1 hex package. Transport wiring is `Noizu.MCP.Transport.VFSWS` via `vfs_plug_opts/0` in `backend/lib/noizu_prompt_lingua_web/mcp_config.ex`. Conformance harness: `backend/test/noizu_prompt_lingua/mcp/vfs/vfs_ws_transport_test.exs`. What is missing is an agent-facing consumer story: no harness/agent client currently exercises the tree end to end outside tests.
