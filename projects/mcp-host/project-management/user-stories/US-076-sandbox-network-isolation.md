---
id: US-076
title: "System isolates tool execution in sandboxed environment with network policy"
slug: "sandbox-network-isolation"
personas: [P-003, P-002]
epic: "Sandbox & Execution"
priority: "must-have"
complexity: "L"
tags: [sandbox, network-policy, isolation, firecracker, gvisor]
---

# US-076: System Isolates Tool Execution in Sandboxed Environment with Network Policy

## User Story

**As a** Security Engineer (P-003),
**I want to** ensure every tool invocation runs inside an isolated sandbox with enforced network policies,
**So that** compromised or misbehaving tools cannot access other tenants' resources, internal infrastructure, or exfiltrate data across network boundaries.

## Acceptance Criteria

- [ ] Given a tool invocation request passes the Policy Engine, when the Execution Sandbox provisions the runtime, then the container or microVM is launched with a deny-all egress network policy by default
- [ ] Given a tool declares allowed outbound hosts in its manifest, when the sandbox is provisioned, then only DNS resolution and TCP connections to those declared hosts are permitted on the specified ports
- [ ] Given two concurrent tool invocations from different MCP servers, when both are executing, then neither sandbox can observe or reach the other's network namespace
- [ ] Given a tool attempts an outbound connection to an undeclared host, when the connection is initiated, then the sandbox drops the packet and emits an auditable network violation event to the Audit Store

## Notes

The sandbox runtime should support both Firecracker microVMs (stronger isolation) and gVisor containers (lighter weight) as configurable backends. Network policy enforcement maps to Kubernetes NetworkPolicy when deployed on-cluster. Related to US-077 (resource caps) and US-078 (filesystem isolation) as complementary isolation layers.
