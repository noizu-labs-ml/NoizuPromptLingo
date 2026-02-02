# Agent Orchestration Summary

Five specialized agents transform feature ideas into tested production code through a TDD workflow.

## Quick Reference

| Agent | Purpose | Output |
|-------|---------|--------|
| npl-idea-to-spec | Ideas → personas/stories | Personas, User Stories |
| npl-prd-editor | Stories → PRD | PRD documents |
| tdd-tester | PRD → tests | Test files |
| tdd-coder | PRD + tests → code | Source code |
| tdd-debugger | Diagnose failures | Fixes, routing |

## Workflow

1. **Discovery**: npl-idea-to-spec - pitch idea, get personas/stories
2. **Specification**: npl-prd-editor - create PRD from stories
3. **Test Creation**: tdd-tester - generate test suite from PRD
4. **Implementation**: tdd-coder - autonomously implement using `mise run test-status` and `mise run test-errors`
5. **Debug Loop**: When blocked, tdd-debugger diagnoses and routes to appropriate agent
6. **Completion**: Controller confirms and archives

## Key Concepts

- **Controller**: Orchestrates agents, manages state, routes blocked reports
- **Artifacts**: personas/, user-stories/, .prd/, tests/, src/
- **Mise Tasks**: `test-status`, `test-errors` required for TDD loop
- **Status Values**: `ok`, `blocked`, `needs_clarification`, `complete`

## Error Recovery

| Scenario | Recovery |
|----------|----------|
| tdd-coder blocked on PRD | Update PRD → signal continue |
| Test failures unclear | tdd-debugger → relay diagnosis |
| Tests need update | tdd-tester → re-run tdd-coder |
| Circular blocks | Controller architectural decision |
| Agent crash | Reinitialize with saved state |

→ *See [agent-orchestration.md](./agent-orchestration.md) for full details*