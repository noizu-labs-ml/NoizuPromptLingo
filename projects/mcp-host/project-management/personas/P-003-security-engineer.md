---
id: P-003
name: "Marcus Webb"
slug: "security-engineer"
archetype: "The Guardian"
segment: "primary"
tags: [security, authorization, audit, compliance, safemcp, policy, soc2, gdpr]
---

# Marcus Webb — The Guardian

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 35-44 |
| **Role** | Senior Security Engineer |
| **Technical Level** | Expert |
| **Industry** | Financial Services / FinTech |
| **Location** | London, United Kingdom |

## Bio

Marcus has spent a decade in application security, the last three focused on AI system safety. His company is integrating AI agents into internal workflows, and those agents need to call external tools — databases, APIs, file systems. Marcus loses sleep over what an agent might do with unrestricted access. He needs granular authorization policies, a complete audit trail of every tool invocation, and the ability to simulate agent behavior before it touches production systems.

## Goals

1. Define and enforce fine-grained authorization policies that constrain what AI agents can do on a per-tool, per-caller, per-user basis
2. Maintain an immutable audit trail of every MCP tool invocation for compliance (SOC2, GDPR, internal policy)
3. Simulate agent interactions against policy in a sandboxed environment before enabling them in production

## Frustrations

1. AI agent permissions are currently all-or-nothing — an agent either has full access to a tool or none, with no middle ground
2. No audit log of what agents actually did — when something goes wrong, the only forensic evidence is application-level logs that were not designed for this purpose
3. Compliance auditors ask for evidence of access controls on AI tool usage and Marcus has nothing structured to show them

## Behaviors

- Writes authorization policies in Rego (OPA) or Cedar and tests them with unit tests before deploying
- Reviews every new tool integration with a threat model before enabling it for agents
- Runs quarterly access reviews and needs exportable reports showing who called what, when, and whether policy allowed it
- Uses SIEM (Splunk or Datadog) for log aggregation and wants structured, correlated event streams

## Job to Be Done

> "When an AI agent attempts to invoke a tool, I want the system to evaluate the request against composable authorization policies that consider both the agent identity and the human user context, so I can guarantee that no invocation exceeds the least-privilege boundary defined by our security posture."

## Relationship to Product

SafeMCP is Marcus's primary entry point. He evaluates it as a policy engine and audit system first — deployment hosting is secondary. He wants to define policies in a familiar DSL (Cedar or Rego), see policy evaluation results in real time, and export audit logs in a format his SIEM can ingest. He would adopt SafeMCP if the policy model is expressive enough for dual-principal authorization (caller + user) and would reject it if policies are limited to simple allow/deny lists. The simulation environment is the differentiator that makes him choose MCP Host over building something internally.

## Scenarios

1. **Policy Authoring and Testing** — Marcus writes a Cedar policy that allows the "analytics-agent" to call the "query-database" tool only when the delegated user has the "analyst" role and the query targets a non-PII schema. He tests it against simulated requests in SafeMCP before deploying.
2. **Audit Trail Export** — A compliance auditor requests evidence of all MCP tool invocations for Q1. Marcus exports the audit log from SafeMCP, filtered by time range and tool, in a structured format (JSON or CSV) with tamper-evident checksums.
3. **Agent Simulation** — Before enabling a new AI agent in production, Marcus runs it through the SafeMCP simulation environment with realistic tool payloads and observes which policy decisions would be made, catching an over-permissioned scope before any real data is touched.
