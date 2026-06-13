---
id: US-061
title: "Create Team and Invite Members"
slug: "create-team-and-invite-members"
personas: [P-002, P-001]
epic: "Academy — Labs"
priority: "should-have"
complexity: "M"
tags: [academy, teams, collaboration, enterprise, invitations]
---

# US-061: Create Team and Invite Members

## User Story

**As an** enterprise AppSec manager (P-002),
**I want to** create a team workspace and invite my security engineers,
**So that** I can manage Academy training as a group, assign labs, and track team-level progress.

## Acceptance Criteria

- [ ] Given I am an authenticated user on a plan that supports teams, when I navigate to Teams in my account, then I can create a new team with a name, optional description, and visibility (private/org-visible)
- [ ] Given I create a team, when I invite members by email or username, then invited users receive an email invitation and the invite appears as pending in the team roster
- [ ] Given a pending invitation, when the invited user accepts, then they are added to the team with the "member" role and appear in the team roster
- [ ] Given I am a team owner or admin, when I view the team roster, then I can change member roles (admin/member), remove members, and resend or revoke pending invitations
- [ ] Given a team is created, when I view it, then I see aggregate stats: member count, labs assigned, average completion rate, and team leaderboard rank (if applicable)

## Notes

Teams require a paid plan tier — this story assumes billing/plan gating is handled separately. Initial roles should be minimal: owner (one per team), admin (can manage members and assignments), member (can participate). Team size limits should be configurable per plan.
