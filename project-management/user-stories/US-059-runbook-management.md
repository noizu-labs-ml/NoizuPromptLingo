---
id: US-059
title: "Manage runbooks with version control and incident linking"
personas: [lin-zhao]
domain: docs
priority: medium
mvp_phase: "v0.3"
---

## User Story

As a **Lin Zhao (AI-Forward Platform Engineer)**, I want to manage runbooks with version control and incident-linking so that operational procedures are documented, versioned, and connected to the incidents where they're used.

## Acceptance Criteria

- [ ] Runbooks are created from a structured template with fields: title, service/scope, trigger conditions (when to use), step-by-step procedure, rollback steps, and escalation path
- [ ] Each runbook edit creates a version; the currently active version is clearly marked and older versions are accessible for audit
- [ ] When an incident is created or escalated, the agent suggests relevant runbooks based on the affected service and incident type
- [ ] Runbook usage is tracked — each time a runbook is referenced during an incident, a link is created so teams can see which runbooks are actually used and which are stale
- [ ] Runbooks can include executable steps (e.g., "run this kubectl command") that the agent can execute with human approval, logging the result back into the incident timeline

## Notes

Runbooks bridge documentation and operations. The executable-step feature is a v0.4+ enhancement but the data model should support it from the start. Usage tracking is critical for maintenance — a runbook referenced in 12 incidents is high-value and worth keeping current; one never referenced in 6 months may be stale. Consider a "runbook drill" feature where the agent walks through a runbook as a rehearsal without executing real commands.
