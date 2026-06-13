---
id: US-014
title: "User defines an organization-level deny policy"
slug: "user-defines-org-level-deny-policy"
personas: [P-002, P-003, P-006]
epic: "Policy Engine"
priority: "must-have"
complexity: "M"
tags: [policy, deny, organization, access-control]
---

# US-014: User Defines an Organization-Level Deny Policy

## User Story

**As a** Platform Engineer (P-002) or Security Engineer (P-003),
**I want to** define an organization-level deny policy that blocks specific tool operations for all callers and users in my organization,
**So that** I can enforce compliance and safety guardrails (e.g., "no file-delete tools in production") without configuring each caller individually.

## Acceptance Criteria

- [ ] Given the organization policy settings, when the user creates a new deny policy at the "organization" scope, then the system presents a form for: denied tool patterns (glob syntax), environment filters (production, staging, all), an optional justification field, and an effective date.
- [ ] Given a deny policy with tool pattern `*.delete` targeting the production environment, when any caller in the organization attempts to invoke a tool matching `*.delete` on a production MCP server, then the system denies the request with HTTP 403 and logs the denial to the audit trail.
- [ ] Given a deny policy with an effective date in the future, when the current date is before the effective date, then the system does not enforce the policy but displays it in the policy list with a "Pending" badge and the activation date.
- [ ] Given an existing organization-level deny policy, when the user edits the tool patterns or environment filters, then the system records the change in the policy version history, including who made the change, when, and the previous values.
- [ ] Given a deny policy conflict (e.g., org says deny `*.delete` but a caller-level policy says allow `db.delete`), when the request is evaluated, then the org-level deny takes precedence because explicit denials propagate upward and cannot be overridden by lower-scope allows.

## Notes

Organization-level policies are the second-broadest scope. They are the primary mechanism for compliance guardrails. Deny policies at this level cannot be overridden by tool-level or caller-level allows. This is a critical security property. Related to US-008 (evaluation), US-013 (global), US-018 (per-caller lists).
