---
id: US-009
title: "Invite Team Members to Organization"
slug: "invite-team-members"
personas: [P-001, P-002]
epic: "Onboarding & Fleet Connection"
priority: "should-have"
complexity: "S"
tags: [onboarding, team, rbac, invitations, collaboration]
---

# US-009: Invite Team Members to Organization

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** invite colleagues to my IoTGo organization with role-based access,
**So that** operations managers, security reviewers, and field technicians can access relevant data without sharing a single account.

## Acceptance Criteria

- [ ] Given I navigate to Settings → Team, when I enter an email address and select a role (Admin, Operator, Viewer, Field Tech), then an invitation email is sent and the pending invite appears in the team list.
- [ ] Given an invitee clicks the email link, when they create or log into their account, then they are automatically joined to the organization with the assigned role and redirected to the organization's dashboard.
- [ ] Given I am an Admin, when I change a team member's role, then their permissions update immediately without requiring them to log out and back in.
- [ ] Given an invite has been pending for more than 7 days, when I view the team list, then the invite is marked "Expired" and I can resend it with a single click.

## Notes

Role definitions (what each role can see and do) should be documented in the UI via a role comparison table. Removing a member is a separate action that must require confirmation to prevent accidental lockout.
