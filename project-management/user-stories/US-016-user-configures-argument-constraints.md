---
id: US-016
title: "User configures argument constraints (e.g., file.write only to /tmp/**)"
slug: "user-configures-argument-constraints"
personas: [P-003, P-004]
epic: "Policy Engine"
priority: "must-have"
complexity: "L"
tags: [policy, argument-constraints, tool-level, access-control]
---

# US-016: User Configures Argument Constraints for Tool Invocations

## User Story

**As a** Security Engineer (P-003) or AI/ML Engineer (P-004),
**I want to** define argument constraints on MCP tools so that specific parameters are restricted to allowed patterns (e.g., `file.write` only to paths matching `/tmp/**`),
**So that** I can prevent agents from writing to sensitive filesystem paths, sending emails to unauthorized domains, or passing dangerous values to downstream services.

## Acceptance Criteria

- [ ] Given the policy editor for a specific tool, when the user adds an argument constraint, then the system presents a form for: argument name (JSON path), constraint type (regex, glob, enum, range), allowed values pattern, and an optional denial message.
- [ ] Given an argument constraint on `file.write` restricting the `path` argument to the glob pattern `/tmp/**`, when a caller invokes `file.write` with `path: "/tmp/output.json"`, then the constraint passes and execution proceeds.
- [ ] Given the same constraint, when a caller invokes `file.write` with `path: "/etc/passwd"`, then the system denies the request with HTTP 403, includes the denial message in the response, and logs the constraint violation in the audit record.
- [ ] Given multiple argument constraints on a single tool, when the tool is invoked, then the system evaluates all constraints and denies if any single constraint fails (AND logic across constraints).
- [ ] Given the argument constraint editor, when the user previews which calls would be blocked by the constraint, then the system shows a sample of recent invocations from the audit trail with pass/fail indicators for each.

## Notes

Argument constraints are enforced during policy evaluation (US-008) before the tool executes. Constraint types should support: glob patterns for paths and strings, regex for complex patterns, enum for fixed value sets, and range for numeric bounds. Related to US-008, US-015, US-020 (simulation preview).
