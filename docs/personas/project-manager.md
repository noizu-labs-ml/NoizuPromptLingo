# Persona: Project Manager

**ID**: P-004
**Created**: 2026-02-02T10:15:00Z
**Updated**: 2026-02-02T10:15:00Z

## Demographics

- **Role**: Agile Project Manager / Team Coordinator
- **Tech Savvy**: Medium to High
- **Primary Interface**: Dashboard + CLI for task orchestration
- **Primary Device**: Desktop + Mobile for on-the-go updates

## Context

Orchestrates day-to-day execution across multiple AI agents, vibe coders, and traditional developers. Distinct from product management (P-002), focuses on sprint execution, task routing, workload balancing, and unblocking team members. Acts as the coordination layer between strategic planning (Product Manager) and tactical execution (Developers & Agents).

## Goals

1. Optimize task flow through the development pipeline
2. Identify and resolve blockers before they cascade
3. Balance workload between agents, vibe coders, and senior developers
4. Maintain clear audit trail of execution and handoffs
5. Ensure smooth coordination between autonomous agents and human team members
6. Track and improve agent-to-human collaboration efficiency

## Pain Points

1. Hard to tell what agents are actually working on
2. Task status updates lag behind actual progress
3. Context gets lost in agent-to-agent handoffs
4. Difficult to estimate agent work complexity
5. No clear escalation path when agents get stuck

## Behaviors

- Monitors task queue dashboard and agent work logs throughout the day
- Routes tasks to appropriate agents based on specialization and workload
- Reassigns blocked tasks or escalates to senior developers
- Reviews agent work logs to identify efficiency patterns and bottlenecks
- Creates sprint-sized task batches optimized for agent/human pairing
- Uses chat rooms to facilitate agent-to-human handoffs
- Tracks agent throughput metrics to forecast sprint completion

## Quotes

> "I need to know which agent has the ball, and whether they're about to drop it."

> "Give me a burndown chart that includes agent throughput, not just human commits."

## Key MCP Command Usage

| Category | Primary Commands |
|----------|------------------|
| Task Coordination | `list_tasks`, `update_task` (assign/reassign), `add_task_complexity` |
| Agent Management | `assign_task_to_agent`, `view_agent_status`, `escalate_blocked_task` |
| Progress Tracking | `get_sprint_metrics`, `view_agent_work_logs`, `get_task_queue` |
| Chat Coordination | `send_message`, `create_todo`, `get_notifications` |
| Reporting | Export work logs, generate burndown charts with agent metrics |

## Collaboration Patterns

### With Product Manager (P-002)
- Receives prioritized backlog and feature requirements
- Reports on sprint execution and velocity (including agent metrics)
- Escalates scope or technical blockers
- Translates strategic goals into executable task batches

### With AI Agents (P-001)
- Assigns tasks based on agent specialization and current workload
- Monitors agent progress via work logs
- Unblocks agents by providing clarification or escalating
- Routes agent-generated artifacts to appropriate reviewers

### With Dave (Fellow Developer, P-005)
- Coordinates agent-to-human handoffs for code review
- Requests complexity estimates for agent-assigned tasks
- Escalates agent blockers requiring senior technical input
- Tracks technical debt from agent rapid iterations

### With Vibe Coders (P-003)
- Routes prototype tasks to vibe coders for rapid iteration
- Coordinates handoff to senior developers for hardening
- Balances exploratory work with production deadlines
