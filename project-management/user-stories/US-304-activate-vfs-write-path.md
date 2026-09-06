---
id: US-304
title: "Activate the VFS write path for writable mounts"
slug: "activate-vfs-write-path"
personas: [P-002]
epic: "Virtual File System"
priority: "should-have"
complexity: "L"
tags: [vfs, write-path, wave-1, persistence]
---

# US-304: Activate the VFS write path for writable mounts

## User Story

**As an** Autonomous Coding Agent (P-002),
**I want to** create and update platform entities by writing files through the VFS tree (where the domain mount is writable),
**So that** the file-tree interface is fully symmetrical with my existing read workflow instead of being a read-only window.

## Acceptance Criteria

- [ ] Given a principal with `vfs/write` scope, when it writes to a node under a designated writable mount, then the underlying entity is created/updated and an immediate `vfs/read` of the same path returns the written content.
- [ ] Given a write attempt against a mount that is deliberately read-only, when issued, then it fails with the enosys-mapped error and the platform state is unchanged.
- [ ] Given a write with content that violates the domain's validation rules, when issued, then it is rejected with a structured error and nothing is persisted.
- [ ] Given two concurrent writes to the same node, when both complete, then the resulting state is consistent and the loser receives a conflict or last-write-wins per the documented policy — never a silent torn write.
- [ ] Given the existing transport conformance test that currently asserts `vfs/write` maps `:enosys` to `-32046` on the read-only Wave 0 backend, when the write path activates, then the test suite is updated to cover real round-trip writes on writable mounts.

## Notes

Wave 0 shipped read-only: `vfs/write` on the transport currently maps `:enosys` to error `-32046` (confirmed in `backend/test/noizu_prompt_lingua/mcp/vfs/vfs_ws_transport_test.exs`). Activation must be per-mount opt-in, coordinated with US-303 (scope enforcement) and US-305 (pubsub notifications on mutation). Scope boundary with PRD-N2 storage-providers: this is the VFS file-tree write surface, not toolset-config storage.
