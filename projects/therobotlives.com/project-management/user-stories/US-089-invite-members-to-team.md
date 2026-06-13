---
id: US-089
title: "Invite Members to Team"
slug: "invite-team-members"
personas: [P-003, P-007]
epic: "Team & Org Features"
priority: "could-have"
complexity: "M"
tags: [teams, invitations, collaboration]
---

# US-089: Invite Members to Team

## User Story

**As a** Startup Founder (P-007),
**I want to** invite colleagues to join my organization team with different permission levels,
**So that** my team can collaborate on shared spaces and resources.

## Acceptance Criteria

- [ ] Given I am an organization admin, when I access the team management page, then I see a list of current members and an "Invite Member" button
- [ ] Given I click "Invite Member", when I enter an email address and select a role (Member, Admin, Editor), then the system sends an invitation email
- [ ] Given an invited user clicks the invitation link, when they register or log in, then they are automatically added to the organization with the specified role
- [ ] Given I invite someone who is already a team member, when I submit, then I see an error message "This user is already a member of the organization"
- [ ] Given I revoke a member's access, when I confirm the revocation, then the member is removed from all organization-owned spaces and loses team permissions

## Notes

Roles: Admin (full access), Editor (can post/edit content), Member (view-only). Invitations expire after 7 days if not accepted. Audit log tracks all membership changes.