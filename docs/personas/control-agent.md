# Persona: Control Agent

**ID**: P-006
**Created**: 2026-02-02T10:00:00Z
**Updated**: 2026-02-02T10:00:00Z

## Demographics

- **Role**: Orchestration & coordination agent (LLM-powered)
- **Tech Savvy**: Expert (systems orchestration, process management)
- **Primary Interface**: MCP tools via Python client, session worklog, multi-agent coordination

## Context

A specialized AI agent responsible for orchestrating multi-agent workflows, managing sub-agents, handling resource allocation, error recovery, and ensuring task completion. Acts as the primary controller in a task execution hierarchy. Maintains awareness of all active sub-agents, their status, resource constraints, and interdependencies.

## Goals

1. Orchestrate complex multi-agent workflows with dependency tracking
2. Manage sub-agent lifecycle (spawn, monitor, cleanup, escalate)
3. Make decisions on task routing, priority, and escalation
4. Recover from agent failures and coordinate retries
5. Maintain real-time visibility into multi-agent system state
6. Optimize resource allocation across concurrent agents

## Pain Points

1. Unable to track state of multiple sub-agents simultaneously
2. No structured error propagation or recovery protocols
3. Difficulty prioritizing competing requests across agents
4. Lack of deadlock/circular dependency detection
5. No automatic escalation path when agents report being blocked
6. Resource contention (concurrent database access, rate limits)
7. Missing context about what work other agents have completed

## Behaviors

- Reads session worklog continuously via cursor-based polling
- Spawns sub-agents with explicit task boundaries and context
- Monitors sub-agent health via heartbeat/status updates
- Routes errors to appropriate recovery handlers (retry, escalate, reassign)
- Adjusts priorities dynamically based on dependencies and blockages
- Synthesizes results from parallel sub-agent executions
- Makes handoff decisions (completion, delegation, escalation)
- Logs all orchestration decisions to worklog for audit trail

## Needs (Different from General AI Agent)

1. **Multi-agent state management** - Track status, output, errors of all sub-agents
2. **Deadlock detection** - Identify circular dependencies or resource deadlocks
3. **Resource negotiation** - Allocate limited resources (API rate limits, disk I/O, compute)
4. **Error classification** - Distinguish recoverable vs. fatal errors
5. **Workflow DAG execution** - Execute tasks with explicit dependency graphs
6. **Timeout enforcement** - Kill stuck sub-agents and retry elsewhere
7. **Audit logging** - Log all orchestration decisions for compliance/debugging
8. **Quality gates** - Define pass/fail criteria before accepting sub-agent output

## Commands & Tools (Control-Specific)

| Category | Commands |
|----------|----------|
| Workflow | `create_workflow`, `execute_workflow_dag`, `get_workflow_status` |
| Sub-Agent | `spawn_agent`, `get_agent_status`, `send_to_agent`, `terminate_agent` |
| Worklog | `npl_session log`, `npl_session read` (cursor-based), `npl_session status` |
| Error Handling | `classify_error`, `route_to_recovery`, `escalate_task` |
| Resources | `request_resource`, `release_resource`, `query_resource_status` |
| Quality Gates | `define_gate`, `check_gate`, `report_gate_failure` |
| Decision Making | `synthesize_parallel_outputs`, `reach_consensus`, `export_decision_tree` |

## Quotes

> "I need to know what all my sub-agents are doing right now, not just the status of one task."

> "If a sub-agent times out, I need a clear recovery path: retry, reassign, or escalate."

> "I can't make good prioritization decisions without understanding resource contention."

> "Every decision I make should be auditable - who assigned what, when, why, and what happened."

## Key Differences from General AI Agent

| Aspect | General AI Agent (P-001) | Control Agent (P-006) |
|--------|-------------------------|----------------------|
| **Scope** | Single task execution | Multi-task orchestration |
| **State** | Focuses on one artifact/task | Maintains global system state |
| **Concurrency** | Sequential task processing | Manages parallel sub-agents |
| **Decision Making** | Task execution | Resource allocation, routing, escalation |
| **Error Handling** | Report errors to human | Classify, route, and recover errors |
| **Monitoring** | Self-status only | Health of entire sub-agent fleet |
| **Audit Trail** | Task operations | All orchestration decisions |
| **Resource Awareness** | Uses available resources | Negotiates and allocates resources |

## Related Stories

- US-022: Facilitate Multi-Persona Consensus (coordination)
- US-023: Chain Multi-Agent Workflows with Dependencies (coordination)
- US-024: Negotiate Resource Access Priority (coordination)
- US-027: Agent Handoff Protocol (coordination)
- US-028: Parallel Agent Synthesis (coordination)
- Story 11: Real-Time Agent Workflow Failure Diagnostics
- Story 14: Worklog Error Propagation Protocol
