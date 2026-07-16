---
id: US-022
title: "Register a new Agent Persona with a bio"
slug: "register-new-agent-persona-with-bio"
personas: [P-002]
epic: "Agent Personas & Memory"
priority: "must-have"
complexity: "S"
tags: [personas, identity, memory, mvp]
---

# US-022: Register a new Agent Persona with a bio

## User Story

**As the** Autonomous Coding Agent (P-002),
**I want to** register myself as a named Persona with a bio describing my role and identity,
**So that** my work-log journal, knowledge base, and memories are all durably attached to a stable identity across sessions.

## Acceptance Criteria

- [ ] Given Sable has no existing persona record in the current org/project, when it calls persona registration with a name and bio, then a new Persona record is created and a persona ID is returned.
- [ ] Given a persona name that already exists within the same project scope, when registration is attempted again with that name, then the system returns the existing persona or a clear conflict error instead of creating a duplicate identity.
- [ ] Given a persona is registered, when any authorized caller fetches it by ID, then the bio, name, and creation metadata are returned exactly as submitted.
- [ ] Given a registration call that omits the bio field, when Sable submits it, then the call is rejected with a validation error requiring at minimum a name and bio.

## Notes

Root story for the Agent Personas & Memory epic — US-023 through US-028 all assume a registered persona already exists. Distinct from marketing "Customer Personas" and the UX-research personas elsewhere in this artifact tree.
