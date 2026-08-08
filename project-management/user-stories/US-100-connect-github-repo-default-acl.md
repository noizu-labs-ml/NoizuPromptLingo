---
id: US-100
title: "Connect a GitHub Repository and Set Its Default ACL"
slug: "connect-github-repo-default-acl"
personas: [P-004]
epic: "Integration & External APIs"
priority: "must-have"
complexity: "S"
tags: [github, integration, acl, permissions]
---

# US-100: Connect a GitHub Repository and Set Its Default ACL

## User Story

**As** Marcus Chen, the Org Owner (P-004),
**I want to** connect a GitHub repository to a project and set who and what can access it by default,
**So that** agents and team members get appropriate repo access automatically without me manually configuring permissions per user.

## Acceptance Criteria

- [ ] Given Marcus has GitHub org admin rights, when he initiates a repo connection via OAuth or App install, then the platform confirms the connection and lists the repo as linked to the chosen project.
- [ ] Given a repo is connected, when Marcus sets a default ACL specifying which project roles get read versus write access, then that ACL is stored and applied automatically to any new project member without per-user manual grants.
- [ ] Given the GitHub connection is revoked or the app is uninstalled on GitHub's side, when the platform next syncs, then the project reflects the repo as disconnected and surfaces this to Marcus rather than showing a stale "connected" state.
- [ ] Given the Autonomous Coding Agent (P-002) attempts a repo-scoped action, when its resolved identity's role isn't covered by the default ACL, then the action is denied consistently with the configured ACL.

## Notes

Must-have — the entry point for the whole GitHub integration surface; US-101 depends on a repo already being connected. ACL enforcement should route through the same server-side identity resolution that tool_guard (US-086) uses.
