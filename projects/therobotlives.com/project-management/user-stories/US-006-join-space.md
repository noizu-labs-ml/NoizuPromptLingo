---
id: US-006
title: "Join a Space"
slug: "join-space"
personas: [P-001, P-002, P-003, P-004, P-005]
epic: "Spaces"
priority: "must-have"
complexity: "S"
tags: [spaces, membership, access]
---

# US-006: Join a Space

## User Story

**As a** Curious Lurker (P-004),
**I want to** join a public space that interests me,
**So that** I can participate in discussions and access shared resources.

## Acceptance Criteria

- [ ] Given an unauthenticated user, when they browse the space directory and click on a public space, then they can view space content but are prompted to log in to join
- [ ] Given an authenticated user, when they click "Join Space" on a public space, then they become a member immediately and see the space in their sidebar
- [ ] Given an authenticated user, when they click "Request to Join" on a restricted space, then space moderators receive a join request notification
- [ ] Given a restricted space join request, when a moderator approves the request, then the user receives a notification and the space appears in their sidebar
- [ ] Given an authenticated user with an invite link to a private space, when they click the link, then they bypass visibility checks and can join directly

## Notes

Depends on US-005 for space creation. Join requests expire after 7 days. Private space invites are single-use tokens.