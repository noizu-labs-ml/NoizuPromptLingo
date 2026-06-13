---
id: US-009
title: "System denies request when either principal lacks permission"
slug: "system-denies-request-either-principal-lacks-permission"
personas: [P-003, P-008]
epic: "Auth & Onboarding"
priority: "must-have"
complexity: "M"
tags: [auth, dual-principal, denial, security-invariant]
---

# US-009: System Denies Request When Either Principal Lacks Permission

## User Story

**As a** Security Engineer (P-003) auditing requests from MCP Client Systems (P-008),
**I want the** system to deny any MCP request when either the caller or the user principal lacks the required permission,
**So that** neither the AI agent nor the human user can escalate beyond their individual authorization boundaries.

## Acceptance Criteria

- [ ] Given a dual-principal context where the caller has `gmail.send` permission but the user does not have Gmail connected, when the caller invokes `gmail.send`, then the system denies the request with HTTP 403 and the audit record shows `user_policy: denied`.
- [ ] Given a dual-principal context where the user has Gmail connected but the caller's policy excludes email tools, when the caller invokes `gmail.send`, then the system denies the request with HTTP 403 and the audit record shows `caller_policy: denied`.
- [ ] Given a dual-principal context where both caller and user have `gmail.send` permission, when the caller invokes `gmail.send`, then the system allows the request and the audit record shows `caller_policy: allowed, user_policy: allowed`.
- [ ] Given a denied request, when the system generates the error response, then the response body includes a `denied_by` field indicating which principal caused the denial (`caller`, `user`, or `both`) without leaking the other principal's full policy details.
- [ ] Given a denied request due to principal mismatch, when the audit record is written, then the record includes the evaluation trace showing which scope level and which rule triggered the denial for each principal independently.

## Notes

This story enforces the core security invariant: permissions are the intersection, never the union. It is the behavioral complement to US-007 (resolution) and US-008 (evaluation). The denial response must be informative enough for debugging without exposing the full policy surface to unauthorized parties. Related to US-007, US-008, US-021.
