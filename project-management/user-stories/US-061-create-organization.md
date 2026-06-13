---
id: US-061
title: "Create organization and invite team members"
slug: "create-organization"
personas: [P-005, P-006]
epic: "Organization Management"
priority: "must-have"
complexity: "L"
tags: [organization, team-management, onboarding, multi-tenancy]
---

# US-061: Create Organization and Invite Team Members

## User Story

**As a** Engineering Manager (P-005),
**I want to** create an organization and invite team members to join it,
**So that** my team can collaborate on MCP server deployments, share access policies, and manage tools under a unified billing account.

## Acceptance Criteria

- [ ] Given the user is logged in and does not belong to an organization, when they navigate to the organization setup page and submit an org name and slug, then the system creates the organization and assigns the user as the org owner with full admin privileges.
- [ ] Given the user is an org admin, when they navigate to the team management page and clicks "Invite member," then they can enter an email address, select an initial role (admin, developer, viewer, auditor), and send an invitation.
- [ ] Given a team member receives an invitation email, when they click the invitation link, then they are prompted to sign in or create an account and upon authentication are added to the organization with the assigned role.
- [ ] Given an invitation has been sent, when the org admin views the team management page, then pending invitations are listed with the invitee email, assigned role, sent date, and a "Revoke" action.
- [ ] Given the user already belongs to an organization, when they attempt to create a new organization, then the system allows it but requires them to switch context between organizations via an org switcher in the navigation.
- [ ] Given an organization exists, when the org admin views the organization profile, then it displays the org name, slug, member count, plan tier (US-068), and creation date.

## Notes

Organizations are the multi-tenancy boundary (Roadmap Phase 3). Each org has isolated resources, policies, and billing. Users can belong to multiple organizations. Related: US-062 (roles), US-063 (API keys), US-064 (dashboard), US-068 (billing).
