---
id: US-047
title: "Fork a Team Mockup into Personal Workspace"
slug: "fork-team-mockup"
personas: [P-001, P-003, P-006]
epic: "Team & Collaboration"
priority: "could-have"
complexity: "M"
tags: [fork, mockup, personal, workspace, experimentation]
---

# US-047: Fork a Team Mockup into Personal Workspace

## User Story

**As a** full-stack developer (P-001),
**I want to** fork a team mockup into my personal workspace,
**So that** I can experiment with design variations without modifying the shared canonical version.

## Acceptance Criteria

- [ ] Given a team mockup I have at least "can-comment" access to, when I click "Fork", then a copy is created in my personal workspace with a reference to the source
- [ ] Given a forked mockup, when I view it, then a banner indicates it is a fork and links back to the original
- [ ] Given a forked mockup with modifications, when I choose "Propose changes", then the original owner receives a notification with a link to compare the fork against the original
- [ ] Given a fork, when the original mockup is deleted, then the fork remains intact and the source reference is marked as unavailable

## Notes

Fork should copy the mockup content and generation parameters but not the annotation history. This is analogous to a GitHub fork model. Proposing changes is a future workflow enhancement; the core fork/copy operation is the baseline.
