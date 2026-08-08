---
id: US-086
title: "Log tool_guard Identity Mismatches in Shadow Mode"
slug: "tool-guard-identity-mismatch-shadow-mode"
personas: [P-006]
epic: "Edge Cases & Error States"
priority: "should-have"
complexity: "M"
tags: [security, tool-guard, observability, rollout]
---

# US-086: Log tool_guard Identity Mismatches in Shadow Mode

## User Story

**As** Ilya Petrov, the Platform Administrator (P-006),
**I want to** have tool_guard log every case where the server-resolved JWT identity disagrees with a caller-supplied identity argument, without blocking the call,
**So that** I can measure how often spoofing attempts or legacy client bugs would trip enforcement before switching it on.

## Acceptance Criteria

- [ ] Given tool_guard is running in shadow mode, when a tool call arrives with a caller-supplied identity argument that differs from the JWT-resolved identity, then the call proceeds normally and a structured mismatch event is logged.
- [ ] Given a mismatch event is logged, when Ilya inspects it, then it includes the JWT-resolved identity, the caller-supplied identity, the tool name, and a timestamp, sufficient to triage without re-running the call.
- [ ] Given tool_guard is in shadow mode, when the JWT-resolved and caller-supplied identities agree, then no mismatch event is emitted, avoiding log noise for the common case.
- [ ] Given Ilya queries shadow-mode mismatch logs over a time range, when he filters and aggregates them, then he can produce a mismatch count/rate suitable for a go/no-go enforcement decision.

## Notes

Precursor to eventually flipping tool_guard to enforcing mode; blocking mismatches outright is out of scope here and would be a follow-on story. Directly extends the tool_guard rollout described in the epic context.
