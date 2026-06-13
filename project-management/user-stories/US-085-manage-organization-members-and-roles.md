---
id: US-085
title: "Manage Organization Members and Roles"
slug: "manage-organization-members-and-roles"
personas: [P-002, P-005]
epic: "Settings & Administration"
priority: "should-have"
complexity: "L"
tags: [settings, organizations, rbac, admin, team]
---

# US-085: Manage Organization Members and Roles

## User Story

**As an** enterprise security leader managing team access (P-002, P-005),
**I want to** invite, assign roles to, and remove members from my organization,
**So that** I can enforce least-privilege access for my team's use of the catalog, Defender, and API resources.

## Acceptance Criteria

- [ ] Given I am an org admin, when I navigate to "Organization > Members", then I see a list of all members with their roles, join date, last active date, and pending invitations
- [ ] Given I want to invite a new member, when I enter their email and select a role (`viewer`, `analyst`, `admin`), then an invitation email is sent and a pending entry appears in the member list
- [ ] Given a pending invitation, when the invitee accepts, then their account is linked to the org and they inherit the assigned role's permissions immediately
- [ ] Given I want to change a member's role, when I select a new role from the dropdown, then the change takes effect on their next request (no re-login required)
- [ ] Given I want to remove a member, when I click "Remove from org", then they lose access to org resources but retain their personal account
- [ ] Given a `viewer` role, when the user accesses the platform, then they can browse the catalog and view scan results but cannot trigger scans, submit techniques, or manage API keys

## Notes

Role permissions: `viewer` (read-only), `analyst` (read + scan + submit), `admin` (full org management). Org admins cannot demote themselves without another admin present (prevents lockout). SSO/SCIM provisioning is out of scope for initial release.
