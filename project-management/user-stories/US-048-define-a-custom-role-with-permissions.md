---
id: US-048
title: "Define a Custom Role with Named Permissions"
slug: "define-a-custom-role-with-permissions"
personas: [P-004]
epic: "Settings & Preferences"
priority: "should-have"
complexity: "M"
tags: [rbac, custom-roles, permissions]
---

# US-048: Define a Custom Role with Named Permissions

## User Story

**As a** Org Owner, Marcus Chen (P-004),
**I want to** define a custom org role with a free-form set of named permissions,
**So that** I can model my company's actual job functions instead of forcing everyone into generic built-in roles.

## Acceptance Criteria

- [ ] Given Marcus is on the custom roles page, when he creates a new role with a unique name and adds one or more named permissions, then the role is saved and appears in the org's role list.
- [ ] Given Marcus attempts to create a role whose name duplicates an existing custom role in the org (case-insensitive), when he submits, then validation blocks creation with a "role name already exists" error.
- [ ] Given Marcus edits an existing custom role to add or remove named permissions, when he saves, then all members currently assigned that role immediately reflect the updated permission set.
- [ ] Given Marcus attempts to delete a custom role assigned to one or more members, when he confirms deletion, then he is shown how many members are affected before the delete is finalized.

## Notes

Permissions are free-form named strings scoped to the org, not a fixed platform enum. Directly enables assignment in US-049.
