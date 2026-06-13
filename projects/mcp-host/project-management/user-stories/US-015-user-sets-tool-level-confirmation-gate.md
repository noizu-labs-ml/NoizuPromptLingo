---
id: US-015
title: "User sets tool-level confirmation gate for sensitive operations"
slug: "user-sets-tool-level-confirmation-gate"
personas: [P-003, P-002]
epic: "Policy Engine"
priority: "should-have"
complexity: "L"
tags: [policy, confirmation-gate, tool-level, human-in-the-loop]
---

# US-015: User Sets Tool-Level Confirmation Gate for Sensitive Operations

## User Story

**As a** Security Engineer (P-003) or Platform Engineer (P-002),
**I want to** require explicit human approval before certain high-impact MCP tools can execute (e.g., `gmail.send`, `file.write`, `payment.process`),
**So that** AI agents cannot perform destructive or sensitive operations without a human-in-the-loop confirmation step.

## Acceptance Criteria

- [ ] Given the policy editor for a specific tool, when the user enables the "Confirmation Gate" toggle, then the system presents options for: confirmation timeout (default 5 minutes), whether to show the full arguments to the human, and whether approval can be delegated to an org admin.
- [ ] Given a confirmation gate is active on `gmail.send`, when a caller invokes `gmail.send` with arguments `{to: "user@example.com", body: "..."}`, then the system pauses the request, emits a confirmation prompt to the user's active session (dashboard, email, or push notification), and waits for approval or denial.
- [ ] Given a confirmation prompt sent to the user, when the user approves within the timeout window, then the system proceeds with tool execution and logs the approval in the audit record.
- [ ] Given a confirmation prompt sent to the user, when the user denies the request or the timeout expires, then the system cancels the tool invocation, returns HTTP 403 to the caller, and logs the denial reason (user-rejected or timeout-expired) in the audit record.
- [ ] Given the confirmation gate configuration, when the user chooses to display full arguments, then the confirmation prompt includes the complete tool arguments; when "display full arguments" is off, then the prompt shows only the tool name and a summary (e.g., "gmail.send to 1 recipient").

## Notes

Confirmation gates implement human-in-the-loop control for sensitive operations. The prompt delivery mechanism must be reliable -- if the user has no active session, the request should be queued or denied based on configuration. This is a SafeMCP feature. Related to US-008 (evaluation), US-016 (argument constraints).
