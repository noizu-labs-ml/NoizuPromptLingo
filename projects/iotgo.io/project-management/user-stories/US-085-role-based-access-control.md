---
id: US-085
title: "Role-Based Access Control"
slug: "role-based-access-control"
personas: [P-005, P-001]
epic: "Security & Compliance"
priority: "must-have"
complexity: "L"
tags: [rbac, security, permissions, access-control]
---

# US-085: Role-Based Access Control

## User Story

**As an** IT Security Director (P-005),
**I want to** define roles with specific permissions and assign them to users,
**So that** each team member has access only to the capabilities appropriate to their job function.

## Acceptance Criteria

- [ ] Given I am an org admin, when I navigate to Roles, then I see a list of system roles (Admin, Operator, Viewer, Auditor) and any custom roles I have created
- [ ] Given I create a custom role, when I assign permissions, then I can grant or deny access at the resource level (fleet groups, agent types, playbooks, reports, settings) independently
- [ ] Given a user is assigned the Viewer role, when they log in, then all create/edit/delete controls are hidden or disabled and API calls requiring write permissions return 403
- [ ] Given I remove a permission from a role, when the change is saved, then all users with that role lose the permission immediately without requiring re-login
- [ ] Given a user has multiple roles, when their effective permissions are evaluated, then the most permissive grants across all assigned roles apply (additive model)

## Notes

The Auditor role grants read-only access to audit logs and compliance reports only. Relates to US-084 (audit log) and US-086 (fleet isolation). Default roles cannot be deleted but can be cloned as the basis for custom roles.
