---
id: US-030
title: "Configure access policy during one-click deploy"
slug: "configure-access-policy-during-deploy"
personas: [P-003, P-002]
epic: "JustMCP Deployment"
priority: "must-have"
complexity: "L"
tags: [justmcp, policy, security, deployment-config]
---

# US-030: Configure Access Policy During One-Click Deploy

## User Story

**As a** Security Engineer (P-003),
**I want to** configure access policies for an MCP server during the deployment wizard,
**So that** the dual-principal authorization model is enforced from the moment the server goes live.

## Acceptance Criteria

- [ ] Given the user is in the deployment wizard after auth configuration (US-027), when they reach the access policy step, then the system presents a policy editor with the six scope levels: global, org, server, tool, caller, and user.
- [ ] Given the user has not previously defined policies, when the policy editor loads, then it offers sensible defaults: caller-scoped allow-all with user-scoped deny on destructive operations.
- [ ] Given the user edits a policy, when they modify a scope rule, then the editor validates the policy YAML syntax in real time and highlights errors inline.
- [ ] Given the user wants to restrict specific tools, when they select "tool-level policy," then they can set per-tool allow/deny rules with parameter constraints (e.g., allow `read_file` with `path` restricted to `/data/**`).
- [ ] Given the user has existing policies from previous deployments, when they click "Import policy," then they can select and adapt a policy from their policy library.
- [ ] Given a policy is configured, when the user deploys (US-028), then the Policy Engine loads the policy and begins enforcing it on all invocations from the first request.

## Notes

This integrates the SafeMCP policy model into the JustMCP deployment flow. The policy editor should use Monaco Editor with YAML schema validation. Related: US-027, US-028, SafeMCP policy stories.
