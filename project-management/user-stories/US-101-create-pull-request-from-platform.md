---
id: US-101
title: "Create a Pull Request from Within the Platform"
slug: "create-pull-request-from-platform"
personas: [P-007]
epic: "Integration & External APIs"
priority: "should-have"
complexity: "M"
tags: [github, pull-request, integration, code-review]
---

# US-101: Create a Pull Request from Within the Platform

## User Story

**As** Sofia Reyes, the Design & Code Reviewer (P-007),
**I want to** open a pull request against a connected GitHub repo directly from the platform,
**So that** I can move from reviewing an agent's proposed change to a real PR without switching tools and losing context.

## Acceptance Criteria

- [ ] Given a project has a connected GitHub repo per US-100 and a branch with commits, when Sofia opens the "Create PR" action, then she can set title, description pre-filled from the linked ticket where available, base branch, and target branch before submitting.
- [ ] Given Sofia submits the PR creation form, when the request succeeds, then the platform shows the resulting PR number and URL and links it back to the originating ticket.
- [ ] Given the GitHub API call fails, for example because the branch has no diff or permissions are insufficient, when this happens, then Sofia sees a specific, actionable error and no partial or duplicate PR is left behind.
- [ ] Given a PR created from the platform later changes status on GitHub, when the corresponding webhook event arrives per US-104, then the linked ticket reflects the updated PR status.

## Notes

Depends on US-100 for repo connection and ties into US-104 for webhook-driven status sync back to the ticket. Complexity M reflects the GitHub API surface plus ticket-linking UI, not the raw API call.
