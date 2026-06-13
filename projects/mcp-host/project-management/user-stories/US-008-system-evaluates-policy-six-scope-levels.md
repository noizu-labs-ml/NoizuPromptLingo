---
id: US-008
title: "System evaluates policy at six scope levels (innermost-first)"
slug: "system-evaluates-policy-six-scope-levels"
personas: [P-003, P-008]
epic: "Auth & Onboarding"
priority: "must-have"
complexity: "XL"
tags: [policy-engine, dual-principal, access-control, core]
---

# US-008: System Evaluates Policy at Six Scope Levels (Innermost-First)

## User Story

**As a** Security Engineer (P-003) governing the platform for MCP Client Systems (P-008),
**I want the** system to evaluate access policies at six nested scope levels (global, org, server, tool, caller, user) resolving innermost-first,
**So that** fine-grained policies at lower scopes can override broader defaults while explicit denials at any level always block access.

## Acceptance Criteria

- [ ] Given a tool invocation request, when the Policy Engine receives the dual-principal context, then it evaluates policies in order: global, organization, MCP server, tool, caller, and user, collecting allow/deny decisions at each level.
- [ ] Given an explicit `deny` at any scope level, when the evaluation chain runs, then the request is immediately denied regardless of allow decisions at other levels (deny takes absolute precedence).
- [ ] Given no explicit deny at any level, when all six scope evaluations complete, then the final decision is `allow` only if every evaluated scope returns `allow` or `not-applicable` (i.e., no scope returns a conflicting decision).
- [ ] Given a tool-level policy requiring user confirmation (confirmation gate), when the evaluation chain reaches the tool scope and finds the gate, then the system pauses the request and emits a confirmation prompt to the user before proceeding.
- [ ] Given the policy evaluation result, when the decision is `deny`, then the system returns a detailed denial reason including which scope level and which specific rule caused the denial (without exposing internal policy structure to unauthorized callers).

## Notes

The six scope levels are: global (platform-wide), organization (all callers/users in org), MCP server (all tools on a server), tool (individual tool), caller (specific API client), and user (specific human). Evaluation is innermost-first meaning the most specific scope has the final say, but explicit denials propagate upward. This is the most complex story in the auth epic and may need decomposition into sub-tasks per scope level. Related to US-007, US-009, US-013 through US-018.
