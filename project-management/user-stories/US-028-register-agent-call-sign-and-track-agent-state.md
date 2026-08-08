---
id: US-028
title: "Register an agent call sign and track agent state"
slug: "register-agent-call-sign-and-track-agent-state"
personas: [P-002, P-006]
epic: "Agent Personas & Memory"
priority: "should-have"
complexity: "S"
tags: [personas, agent-state, monitoring, admin]
---

# US-028: Register an agent call sign and track agent state

## User Story

**As the** Autonomous Coding Agent (P-002),
**I want to** register a short call sign and current state (e.g. idle, working, blocked) for myself,
**So that** the Platform Administrator (P-006) and other observers can identify and monitor active agents at a glance without inspecting full session logs.

## Acceptance Criteria

- [ ] Given Sable's persona is already registered (US-022), when it registers a call sign, then the call sign is validated for uniqueness within the org/project scope and attached to the persona record.
- [ ] Given Sable updates its current state, for example from "idle" to "working" on a ticket, when the update is submitted, then the persona's state field reflects the new value along with a last-updated timestamp.
- [ ] Given Ilya (P-006) views the roster of active agent personas, when he queries agent state, then he sees each persona's call sign, current state, and last-updated timestamp without opening individual sessions.
- [ ] Given an agent's state has not updated within a defined staleness window, when Ilya views the roster, then that agent is flagged as stale/possibly-disconnected rather than shown as falsely active.

## Notes

Call sign is a human/dashboard-friendly alias distinct from the persona's internal ID. State tracking here is lightweight liveness monitoring, not a full audit trail — that role belongs to the journal in US-023.
