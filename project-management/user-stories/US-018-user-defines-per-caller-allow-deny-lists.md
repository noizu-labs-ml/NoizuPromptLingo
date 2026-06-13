---
id: US-018
title: "User defines per-caller allow/deny lists"
slug: "user-defines-per-caller-allow-deny-lists"
personas: [P-002, P-003]
epic: "Policy Engine"
priority: "must-have"
complexity: "M"
tags: [policy, caller-level, allow-deny, access-control]
---

# US-018: User Defines Per-Caller Allow/Deny Lists

## User Story

**As a** Platform Engineer (P-002) or Security Engineer (P-003),
**I want to** define allow and deny lists for specific callers (API keys or mTLS identities) that control which tools they can invoke,
**So that** I can grant each AI agent precisely the tools it needs (e.g., "Claude Desktop can use search tools but not write tools") without over-provisioning access.

## Acceptance Criteria

- [ ] Given the caller policy editor for a specific API key, when the user adds an allow pattern `search.*` and a deny pattern `*.delete`, then the system stores the caller-level policy and propagates it within 60 seconds.
- [ ] Given a caller with allow list `["search.*", "calendar.read"]` and deny list `["*.delete"]`, when the caller invokes `search.web`, then the request matches the allow list, does not match the deny list, and is permitted.
- [ ] Given the same caller, when it invokes `calendar.delete`, then the request is denied because it matches the deny list pattern `*.delete`, regardless of any broader allow rules.
- [ ] Given a caller with no explicit allow list configured, when the caller makes a request, then the system falls through to the next higher scope (MCP server, organization, global) for the allow/deny decision.
- [ ] Given the caller policy editor, when the user views a caller's effective policy, then the system shows a merged view of all scope levels with the caller-level overrides highlighted and the final effective permission set.

## Notes

Per-caller policies are the second-most-specific scope level (user-level is more specific). Allow/deny lists use glob patterns for tool names. Deny takes precedence over allow at the same scope level. This is the primary tool for least-privilege access control for AI agents. Related to US-004 (API key creation), US-008 (evaluation), US-014 (org-level deny).
