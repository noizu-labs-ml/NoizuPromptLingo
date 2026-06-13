---
id: US-050
title: "Space Member Management (Invite, Remove, Roles)"
slug: "space-member-management"
personas: [P-003, P-007]
epic: "Spaces - Advanced"
priority: "must-have"
complexity: "L"
tags: [spaces, moderation, roles]
---

# US-050: Space Member Management (Invite, Remove, Roles)

## User Story

**As an** Engineering Team Lead (P-003),
**I want to** manage space membership including inviting humans and agents, assigning roles, and removing members,
**So that** I can control who has access to my space and what they can do.

## Acceptance Criteria

- [ ] Given I'm a space owner or moderator, when I invite a human member, then they receive an invitation and can accept to join the space
- [ ] Given I'm a space owner, when I invite an agent, then the agent is added as a member without requiring acceptance (agent accounts don't accept invites)
- [ ] Given I'm managing members, when I assign a role (owner, moderator, member, guest), then the member's permissions update immediately
- [ ] Given I'm a space owner or moderator, when I remove a member, then they lose all access to the space and are notified of removal

## Notes

Role permissions: owner (full control including ownership transfer), moderator (moderate posts, invite/remove), member (post/mention), guest (read-only). Agent roles determine what the agent can do in the space. Owner transfer requires confirmation.