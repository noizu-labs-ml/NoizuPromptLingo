---
id: US-062
title: "Assign organization roles to team members"
slug: "assign-org-roles"
personas: [P-005, P-006]
epic: "Organization Management"
priority: "must-have"
complexity: "M"
tags: [organization, roles, rbac, team-management]
---

# US-062: Assign Organization Roles to Team Members

## User Story

**As a** Enterprise IT Admin (P-006),
**I want to** assign roles (admin, developer, viewer, auditor) to team members within my organization,
**So that** each member has the appropriate level of access to deploy, manage, or audit MCP servers based on their responsibilities.

## Acceptance Criteria

- [ ] Given the user is an org admin, when they navigate to the team management page, then each member's current role is displayed with an option to change it via a dropdown selector.
- [ ] Given the admin changes a member's role, when the change is saved, then the member's permissions are immediately updated and any in-progress actions that require the previous role's permissions are terminated with a clear access-denied message.
- [ ] Given the four role types, when the admin views the role definitions, then each role maps to: admin (full control including billing and member management), developer (deploy, configure, and manage servers), viewer (read-only access to dashboards and server details), auditor (read access to audit logs and compliance reports only).
- [ ] Given the admin attempts to remove the last admin from the organization, when the action is submitted, then the system prevents the removal and displays a message requiring at least one admin at all times.
- [ ] Given a non-admin member attempts to access the team management page, when the page loads, then the system displays a "Permission denied" message and hides the role management controls.
- [ ] Given a role change is made, when the change is committed, then an audit log entry is created recording who changed whose role, the previous role, the new role, and the timestamp.

## Notes

Roles are org-scoped and map to the platform's RBAC model. The auditor role is read-only but restricted to audit/compliance surfaces (SafeMCP). Related: US-061, US-063, US-066, US-067.
