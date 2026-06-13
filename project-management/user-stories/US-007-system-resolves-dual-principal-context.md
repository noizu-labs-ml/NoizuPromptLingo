---
id: US-007
title: "System resolves dual-principal context (caller + user) on each request"
slug: "system-resolves-dual-principal-context"
personas: [P-008, P-003]
epic: "Auth & Onboarding"
priority: "must-have"
complexity: "L"
tags: [auth, dual-principal, policy-engine, core]
---

# US-007: System Resolves Dual-Principal Context (Caller + User) on Each Request

## User Story

**As a** MCP Client System (P-008) monitored by a Security Engineer (P-003),
**I want the** system to resolve both the caller (AI agent) and user (human) identities on every MCP request,
**So that** authorization is always the intersection of both principals' permissions, preventing privilege escalation from either side.

## Acceptance Criteria

- [ ] Given an incoming MCP request with an API key (caller) and a user token (user), when the Auth Gateway processes the request, then it resolves both principals into a unified request context containing `caller.id`, `caller.policy`, `user.id`, `user.org`, and `user.scopes`.
- [ ] Given a request with a valid API key but no user token, when the bound policy has `require_user_context: true`, then the system rejects the request with HTTP 401 and a message indicating user context is required.
- [ ] Given a request with a valid API key and no user token, when the bound policy has `require_user_context: false`, then the system resolves the caller principal only and evaluates policy against the caller alone (single-principal mode).
- [ ] Given both principals resolved, when the system passes the request to the Policy Engine, then the engine evaluates `allow(tool, args) = caller_policy(tool, args) AND user_policy(tool, args)` using boolean AND semantics (intersection, not union).
- [ ] Given a resolved dual-principal context, when the request is logged to the audit store, then the audit record includes both `caller` and `user` objects with their IDs, names, organizations, and the policy evaluation outcome.

## Notes

This is the core security invariant of MCP Host: "an MCP server can never access more than the human user behind the request could access directly." The dual-principal resolution happens on every request, not just at session creation. This is the bridge between US-006 (caller auth) and US-008 (policy evaluation). Related to US-006, US-008, US-009, US-021.
