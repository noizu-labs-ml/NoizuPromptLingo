---
id: US-065
title: "Enforce checklist completion before status transitions"
personas: [sarah-kim]
domain: checklists
priority: medium
mvp_phase: "v0.3"
---

## User Story

As a **Sarah Kim (Small Team Eng Lead)**, I want to enforce checklist completion before items can transition to certain statuses so that my team cannot mark work as done without completing required quality gates.

## Acceptance Criteria

- [ ] Workflow rules can specify "checklist X must be 100% complete" as a transition guard
- [ ] Blocked transitions display a clear message listing incomplete checklist items
- [ ] Enforcement rules are configurable per workflow, per item type, or per project
- [ ] Override capability exists for admins/leads with an audit trail noting who overrode and why
- [ ] Agents respect enforcement rules and cannot bypass them without explicit human approval

## Notes

This is a governance feature critical for Sarah's engineering team. Enforcement should feel like a guardrail, not a wall: show progress toward unblocking rather than just "blocked." Pairs naturally with US-068 (pre-deploy checklist) and US-066 (agent-generated checklists). Agent compliance is essential since agents are virtual team members subject to the same rules.
