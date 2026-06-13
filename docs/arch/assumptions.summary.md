# Architectural Assumptions Summary

Foundational assumptions underlying the TDD agent orchestration system.

## Overview

Purpose: Enable reasoned evolution of the architecture by making implicit design premises explicit and interrogable.

## Assumption Categories

| Category | ID | Key Assumption |
|----------|-----|----------------|
| Workflow | WF-1 | Sequential progression (Discovery → Specification → Testing → Implementation) |
| Workflow | WF-2 | Autonomous agent operation within phases |
| Workflow | WF-3 | Controller orchestrates, doesn't implement |
| Testing | TS-1 | Tests before implementation (TDD philosophy) |
| Testing | TS-2 | Mise tasks provide sufficient feedback |
| Testing | TS-3 | Test failures stem from bugs, bad tests, or unclear PRD |
| State Mgmt | SM-1 | PRD hash ensures consistency |
| State Mgmt | SM-2 | Agent state persists within sessions |
| State Mgmt | SM-3 | Artifacts are single source of truth |
| Communication | CP-1 | Structured message format suffices |
| Communication | CP-2 | Four status values cover all states |
| Communication | CP-3 | Agents report blocking, don't resolve cross-domain issues |
| Integration | IN-1 | Mise provides test orchestration |
| Integration | IN-2 | Git tracks all artifacts |
| Integration | IN-3 | Directory structure is predictable |

## Agent-Specific Assumptions

| Agent | ID | Assumption |
|-------|-----|------------|
| idea-to-spec | AG-1 | Can infer personas from natural language feature descriptions |
| prd-editor | AG-2 | Can structure comprehensive PRDs from user stories without additional input |
| tdd-tester | AG-3 | Can infer complete test cases from PRD specifications |
| tdd-coder | AG-4 | Can implement code autonomously using PRD and test feedback |
| tdd-debugger | AG-5 | Can diagnose root causes from test failures and route to appropriate agent |

## Lifecycle Assumptions

| ID | Assumption |
|----|------------|
| LC-1 | Sessions have explicit lifecycles |
| LC-2 | Completion requires confirmation |
| LC-3 | PRDs are archived, not deleted |

## Constraint Assumptions

| ID | Assumption |
|----|------------|
| CN-1 | Single feature at a time (sequential, not parallel) |
| CN-2 | Agents are stateless between sessions |
| CN-3 | Human intervention is exceptional, not routine |

## Meta-Assumptions

| ID | Assumption |
|----|------------|
| MA-1 | Assumptions can be challenged and updated |
| MA-2 | Explicit documentation prevents future misinterpretation |

## Status Indicators

- ✅ **Validated** — Confirmed through implementation/testing
- ⚠️ **At Risk** — Evidence suggests may not hold
- ❌ **Invalidated** — Proven incorrect; architecture needs revision
- 🔍 **Under Review** — Actively being investigated

*See [assumptions.md](assumptions.md) for full details including rationale and risks*