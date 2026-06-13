---
id: US-080
title: "User runs tool in SafeMCP simulation environment before production"
slug: "safemcp-simulation"
personas: [P-003, P-004]
epic: "Sandbox & Execution"
priority: "should-have"
complexity: "XL"
tags: [safemcp, simulation, testing, dry-run, policy-validation]
---

# US-080: User Runs Tool in SafeMCP Simulation Environment Before Production

## User Story

**As a** Security Engineer (P-003),
**I want to** execute tool invocations in a SafeMCP simulation environment that mirrors production policies without affecting live systems,
**So that** I can validate that an agent's interaction pattern complies with organizational policies before enabling it in production.

## Acceptance Criteria

- [ ] Given a user navigates to SafeMCP and selects an MCP server, when they choose "Run Simulation," then the system creates an isolated simulation environment with the same policy configuration as production but with mock downstream services
- [ ] Given a simulation is running, when the agent issues tool invocations, then the system evaluates each invocation against the production policy set and records allow/deny decisions without executing against real downstream services
- [ ] Given a simulation completes, when the user views the simulation report, then the report shows every invocation with its policy decision (allowed/denied), the matched policy rules, and any policy violations that would have occurred in production
- [ ] Given a simulation reveals policy violations, when the user adjusts the policy configuration, then they can re-run the simulation with the updated policies without affecting the production policy set

## Notes

Simulation environments should support replaying recorded invocation sequences for regression testing of policy changes. The mock downstream services should return configurable responses (success, error, slow) to test edge cases. This is a differentiating SafeMCP feature. Related to US-081 (response schema validation) and US-092 (rate limit error handling).
