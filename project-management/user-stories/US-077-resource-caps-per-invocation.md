---
id: US-077
title: "System enforces resource caps per invocation"
slug: "resource-caps-per-invocation"
personas: [P-002, P-003]
epic: "Sandbox & Execution"
priority: "must-have"
complexity: "L"
tags: [sandbox, resource-limits, cpu, memory, timeout, fair-use]
---

# US-077: System Enforces Resource Caps (CPU, Memory, Wall-Clock) Per Invocation

## User Story

**As a** Platform Engineer (P-002),
**I want to** configure and enforce CPU, memory, and wall-clock timeout limits on every tool invocation,
**So that** a single runaway or resource-hungry tool cannot degrade platform stability or starve other tenants of compute resources.

## Acceptance Criteria

- [ ] Given an MCP server is registered with resource limits defined in its manifest, when a tool invocation is dispatched to the sandbox, then the sandbox runtime is provisioned with those CPU and memory constraints enforced by the container runtime (cgroups for gVisor, VM config for Firecracker)
- [ ] Given a tool invocation exceeds its configured memory limit, when the limit is breached, then the sandbox terminates the process with an OOM error and the invocation result includes a clear "memory limit exceeded" message with the limit value
- [ ] Given a tool invocation exceeds its wall-clock timeout, when the deadline is reached, then the sandbox terminates the execution and returns a "timeout exceeded" error response to the caller within 5 seconds
- [ ] Given no per-tool resource limits are declared, when the invocation is dispatched, then the platform applies the organization-level default resource caps as a fallback

## Notes

Resource caps are scoped hierarchically: global defaults < org overrides < server overrides < per-tool overrides. Wall-clock timeouts should account for cold-start latency in Firecracker microVMs so that slow provisioning does not eat into the tool's actual execution budget. Related to US-076 (network isolation).
