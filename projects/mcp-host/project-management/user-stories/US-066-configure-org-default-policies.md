---
id: US-066
title: "Configure org-level default policies"
slug: "configure-org-default-policies"
personas: [P-003, P-006]
epic: "Organization Management"
priority: "should-have"
complexity: "L"
tags: [organization, policies, security, safe-mcp, defaults]
---

# US-066: Configure Org-Level Default Policies

## User Story

**As a** Security Engineer (P-003),
**I want to** configure default access and execution policies at the organization level,
**So that** every MCP server deployed by my team inherits a baseline security posture without requiring per-server policy configuration.

## Acceptance Criteria

- [ ] Given the user has the org admin role (US-062), when they navigate to the org policy settings page, then they can define default policies that apply to all newly deployed MCP servers within the organization.
- [ ] Given the admin creates a default policy, when they define it in the policy editor, then they can set: allowed transport types, maximum resource limits (CPU, memory, timeout), network egress restrictions, and required auth methods.
- [ ] Given default org policies are configured, when a team member deploys a new MCP server (US-028), then the server inherits the org default policies as a baseline, which can be tightened but not relaxed at the server level.
- [ ] Given the admin updates existing default policies, when the update is saved, then the system displays a list of all active servers affected by the change and prompts the admin to confirm whether the changes apply retroactively or only to new deployments.
- [ ] Given a server-level policy contradicts an org-level default, when the conflict is detected during deployment, then the system rejects the server-level policy and displays an error explaining which org policy is being violated.
- [ ] Given the admin views the policy audit trail, when they open the policy history, then every org policy change is listed with the admin who made it, the timestamp, and a diff of the change.

## Notes

Org-level policies enforce a security floor, not a ceiling. They map to the six scope levels in the dual-principal authorization model (global, org, server, tool, caller, user). The policy editor should use Monaco Editor with YAML validation, consistent with US-030. Related: US-030, US-061, US-062.
