---
id: US-091
title: "Invite Collaborators to a Universe"
slug: "invite-collaborators"
personas: [P-001, P-003, P-008]
epic: "Collaboration & Sharing"
priority: "must-have"
complexity: "M"
tags: [collaboration, invitations, sharing, team, permissions]
---

# US-091: Invite Collaborators to a Universe

## User Story

**As a** universe owner leading a collaborative project (P-001, P-003, P-008),
**I want to** invite other users to collaborate on my universe by email,
**So that** my team members can contribute to the canon without needing to share a single account.

## Acceptance Criteria

- [ ] Given I am the owner of a universe, when I open Universe Settings > Collaborators and enter an email address, then an invitation email is sent to that address with a role selection (Viewer, Editor, or Co-owner).
- [ ] Given the invited user clicks the invitation link, when they accept, then they are added to the universe collaborator list with the specified role and can access the universe immediately.
- [ ] Given the invited user does not have an account, when they click the invitation link, then they are directed to the sign-up flow and automatically added to the universe upon completion.
- [ ] Given an invitation expires after 7 days without acceptance, when the expiry occurs, then the invite is marked expired in the collaborator list and the owner can re-send it.
- [ ] Given I am the owner, when I view the Collaborators panel, then I see each collaborator's name, role, join date, and an option to remove them or change their role.

## Notes

Related: US-092 (collaborator roles/permissions), US-077 (notification preferences). Invitation emails must include the universe name and the inviter's display name to provide clear context.
