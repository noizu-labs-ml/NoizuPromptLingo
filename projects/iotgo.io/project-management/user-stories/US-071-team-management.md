---
id: US-071
title: "Team Management (Invite and Roles)"
slug: "team-management"
personas: [P-001, P-005]
epic: "Settings & Administration"
priority: "must-have"
complexity: "M"
tags: [team, roles, invite, permissions, admin]
---

# US-071: Team Management (Invite and Roles)

## User Story

**As an** IT Security Director (P-005),
**I want to** invite team members to the organization and assign them predefined roles that control what they can view and act on,
**So that** I can enforce least-privilege access and ensure only authorized personnel can trigger autonomous actions or modify policies.

## Acceptance Criteria

- [ ] Given I am an organization Admin, when I invite a user by email, then they receive an invitation email and upon accepting are added to the org with the role I assigned.
- [ ] Given I am assigning a role, when I open the role selector, then I can choose from: Admin (full access), Engineer (read/write, no policy changes), Operator (read + action approval), Viewer (read-only), and Custom (granular permissions).
- [ ] Given a user has the Operator role, when they attempt to modify autonomy policies or delete an agent, then the action is blocked and an "Insufficient permissions" message is shown.
- [ ] Given I remove a user from the organization, when the removal is confirmed, then their access is revoked immediately; any pending approvals they were assigned are re-queued to the next eligible approver.
- [ ] Given I view the team roster, when it loads, then I see each member's name, email, role, last active timestamp, and the option to change their role or remove them.

## Notes

Custom roles are a could-have for MVP; the five predefined roles should cover most use cases. Role changes take effect immediately on next API request (no caching of permissions beyond token TTL).
