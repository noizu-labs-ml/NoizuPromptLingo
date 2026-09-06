---
id: US-303
title: "Enforce per-operation vfs/read and vfs/write scope on every VFS operation"
slug: "enforce-per-operation-vfs-scope"
personas: [P-006, P-002]
epic: "Virtual File System"
priority: "must-have"
complexity: "S"
tags: [vfs, scope, authorization, security, gating]
---

# US-303: Enforce per-operation vfs/read and vfs/write scope on every VFS operation

## User Story

**As a** Platform Administrator (P-006) trusting an Autonomous Coding Agent (P-002) with a VFS connection,
**I want to** have every single VFS operation checked against the principal's `vfs/read` and `vfs/write` scopes,
**So that** holding an open connection never bypasses authorization, and a read-scoped principal can never mutate platform data.

## Acceptance Criteria

- [ ] Given a principal holding only `vfs/read`, when it attempts `vfs/write` on the read-only Wave 0 backend, then it receives the enosys-mapped error (`-32046`) and no data changes.
- [ ] Given a principal without `vfs/read` on a domain, when it attempts to list or read nodes under that domain's mount, then the operation is denied with an explicit authorization error naming the missing scope.
- [ ] Given a principal with the required scope, when it performs an allowed operation, then it succeeds without extra prompts or round trips.
- [ ] Given the gating test suite, when it runs, then it covers a denial and an allow path per mounted domain, not just a single sample mount.
- [ ] Given a malformed or missing scope claim in the token, when any operation is attempted, then the operation is denied (deny-wins) rather than treated as full access.

## Notes

Per-op scope enforcement exists in the Wave 0 transport (verified end to end in `vfs_ws_transport_test.exs`, including the `vfs/write` denial on the read-only backend). This story formalizes deny-wins semantics and extends conformance coverage to all mounts so per-domain regressions surface in CI. The deny-wins narrow fix recently landed for tree format/authorization parity (`edf255269`).
