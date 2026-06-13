---
id: US-041
title: "Assign Roles in Workspace"
slug: "assign-workspace-roles"
personas: [P-005, P-004]
epic: "Team & Collaboration"
priority: "must-have"
complexity: "M"
tags: [roles, permissions, rbac, workspace, admin]
---

# US-041: Assign Roles in Workspace

## User Story

**As a** enterprise architect (P-005),
**I want to** assign admin, editor, or viewer roles to workspace members,
**So that** access to sensitive mockups is controlled and team members have appropriate capabilities.

## Acceptance Criteria

- [ ] Given a workspace member, when I change their role to "admin", then they gain access to workspace settings, billing, and member management
- [ ] Given a workspace member with "editor" role, when they access the workspace, then they can create, edit, and delete their own mockups but not workspace settings
- [ ] Given a workspace member with "viewer" role, when they access the workspace, then they can only view and comment on mockups they have been granted access to
- [ ] Given role assignment, when I change a member's role, then the change takes effect immediately without requiring re-login

## Notes

Role hierarchy: admin > editor > viewer. At least one admin must exist per workspace. Role changes should appear in the workspace activity feed (US-044).
