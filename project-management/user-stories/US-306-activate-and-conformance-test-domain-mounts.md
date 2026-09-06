---
id: US-306
title: "Activate and conformance-test all per-domain VFS mounts"
slug: "activate-and-conformance-test-domain-mounts"
personas: [P-003, P-006]
epic: "Virtual File System"
priority: "should-have"
complexity: "M"
tags: [vfs, mounts, conformance, wave-status]
---

# US-306: Activate and conformance-test all per-domain VFS mounts

## User Story

**As a** Delivery Lead (P-003) coordinating with the Platform Administrator (P-006),
**I want to** know exactly which of the ~20 per-domain VFS mounts are fully active versus stubbed, and drive every active mount through a shared conformance suite,
**So that** agent-facing guarantees are uniform across domains and "it works on sessions but silently misbehaves on market" never ships.

## Acceptance Criteria

- [ ] Given the mount registry (`backend/lib/noizu_prompt_lingua/mcp/vfs/`: sessions, tickets, chat, artifacts, memory, instructions, review, github, browser, markdown, wiki, npl, organizations, projects, jobs, customers, market, campaigns, notifications, unicode, clients, overview), when inspected, then each mount carries an explicit active/stub status.
- [ ] Given each mount marked active, when its conformance test runs, then it passes a shared scenario set: listing, scoped read, denied read, write denial (or round-trip where writable per US-304).
- [ ] Given a mount marked stubbed, when an agent operates on it, then it receives a consistent not-implemented error rather than partial or fabricated data.
- [ ] Given the conformance sweep in CI, when any mount regresses, then the build fails naming the failing mount.
- [ ] Given the delivery board, when the epic status is reviewed, then mount activation state is reported as a checklist, not inferred from file presence.

## Notes

All mounts have files and per-mount test files under `backend/test/noizu_prompt_lingua/mcp/vfs/`, but file presence does not prove full activation (which domains are fully wired versus partially stubbed is exactly the unverified part of Wave 0). This story is the audit + uniform-conformance pass that turns that ambiguity into a maintained registry.
