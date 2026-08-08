---
id: US-049
title: "Assign a Custom Role to a Member"
slug: "assign-a-custom-role-to-a-member"
personas: [P-004]
epic: "Settings & Preferences"
priority: "should-have"
complexity: "S"
tags: [rbac, custom-roles, member-management]
---

# US-049: Assign a Custom Role to a Member

## User Story

**As a** Org Owner, Marcus Chen (P-004),
**I want to** assign a custom role to a specific org member,
**So that** the member gains exactly the permissions their job function requires without over- or under-provisioning access.

## Acceptance Criteria

- [ ] Given Marcus is viewing a member's detail page, when he selects a custom role from the org's role list and confirms, then the member's profile shows the assigned role and its permissions take effect immediately.
- [ ] Given a member already has a custom role assigned, when Marcus assigns a different role, then the prior role is replaced and only the new role's permissions apply.
- [ ] Given Marcus attempts to assign a role to a member who has already left the org, when he attempts the assignment, then the action is blocked with an explanatory error.

## Notes

Depends on at least one custom role existing (US-048). Assignment is org-scoped, not project-scoped.
