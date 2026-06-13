---
id: US-078
title: "Agent activity audit log with filtering"
personas: [lin-zhao]
domain: agents
priority: high
mvp_phase: "v0.2"
---

## User Story

As a **Lin Zhao (AI-Forward Platform Engineer)**, I want a comprehensive agent activity audit log with filtering by agent, action type, and time range so that I can investigate agent behavior, satisfy compliance requirements, and debug unexpected outcomes.

## Acceptance Criteria

- [ ] Every agent action is logged: item creates/updates, status transitions, checklist modifications, report generation, and failed attempts
- [ ] Log entries include: timestamp, agent identity, action type, target resource, input context, and outcome
- [ ] Filtering supports: agent name, action type, resource type, time range, and outcome (success/failure/blocked)
- [ ] Audit log is append-only and tamper-evident (agents cannot delete or modify their own log entries)
- [ ] Log export is available in JSON and CSV for external compliance tools

## Notes

Non-negotiable for enterprise adoption. Lin evaluates platforms on governance capabilities. The audit log is also the foundation for agent performance metrics (US-080) and retrospective analysis (US-075). Consider structured logging that supports both human-readable views and machine-parseable queries. Retention policy should be configurable per workspace.
