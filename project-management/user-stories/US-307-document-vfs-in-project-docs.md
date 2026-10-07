---
id: US-307
title: "Document the VFS substrate in PROJ-ARCH, PROJ-LAYOUT, and PROJ-SCHEMA"
slug: "document-vfs-in-project-docs"
personas: [P-003, P-007]
epic: "Virtual File System"
priority: "could-have"
complexity: "S"
tags: [vfs, documentation, proj-arch, proj-layout]
---

# US-307: Document the VFS substrate in PROJ-ARCH, PROJ-LAYOUT, and PROJ-SCHEMA

## User Story

**As a** Design and Code Reviewer (P-007) onboarding alongside a Delivery Lead (P-003),
**I want to** find the VFS substrate — transport, handshake, scope model, mounts, pubsub — documented in the project reference docs,
**So that** new contributors and agents can understand the file-tree architecture without reverse-engineering the Elixir modules.

## Acceptance Criteria

- [ ] Given `docs/PROJ-LAYOUT.md`, when reviewed, then it covers `backend/lib/noizu_prompt_lingua/mcp/vfs/` (server, router, root, scope, principal, pubsub, per-domain mounts) and the `/vfs` transport wiring in `backend/lib/noizu_prompt_lingua_web/mcp_config.ex`.
- [ ] Given `docs/PROJ-ARCH.md`, when reviewed, then it describes the VFSWS transport, the `vfs/auth` handshake and DualTokenVerifier pipeline, per-op scope enforcement (`vfs/read` / `vfs/write`), and the read-only Wave 0 / write-path boundary (US-304).
- [ ] Given `docs/PROJ-SCHEMA.md`, when reviewed, then it notes how VFS nodes map onto the underlying domain entities (or explicitly documents that VFS is a projection with no schema of its own).
- [ ] Given the doc-maintenance commands (`/update-layout-doc`, `/update-arch-doc`), when the changes land, then the corresponding `.summary.md` companions are regenerated consistently.
- [ ] Given a grep of `docs/` for "VFS" before the work, when repeated after, then coverage goes from zero to the entries above.

## Notes

Verified gap: `docs/PROJ-ARCH.md`, `docs/PROJ-LAYOUT.md`, and `docs/PROJ-SCHEMA.md` currently contain no VFS coverage at all, despite Wave 0 being implemented and conformance-tested in the backend. Flag at merge time that the doc-update commands should be run per the CLAUDE.md maintenance note.
