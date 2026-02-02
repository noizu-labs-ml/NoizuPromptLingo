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

## Workflow (PRD-Driven)

**Standard Path** (most features):
1. Get/create PRD (ideas → personas → stories → PRD)
2. Pass PRD to `npl-tdd-tester` → generates test suites
3. Pass tests + PRD to `npl-tdd-coder` → implements code (RED → GREEN → REFACTOR)
4. Coder uses `mise run test-status` / `mise run test-errors` for feedback
5. When all tests pass → implementation complete

**Full Path** (with full orchestration):
1. **Discovery**: npl-idea-to-spec - pitch idea, get personas/stories
2. **Specification**: npl-prd-editor - create PRD from stories
3. **Test Creation**: npl-tdd-tester - generate test suite from PRD
4. **Implementation**: npl-tdd-coder - autonomously implement (RED → GREEN → REFACTOR)
5. **Debug Loop**: When blocked, npl-tdd-debugger diagnoses and routes back
6. **Completion**: Controller confirms

## Key Concepts

- **Controller**: Orchestrates agents, manages state, routes blocked reports
- **Artifacts**: personas/, user-stories/, docs/PRDs/, tests/, src/
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