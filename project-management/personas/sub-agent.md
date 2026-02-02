# Persona: Sub-Agent

**ID**: P-007
**Created**: 2026-02-02T10:00:00Z
**Updated**: 2026-02-02T10:00:00Z

## Demographics

- **Role**: Specialized task execution agent (LLM-powered)
- **Tech Savvy**: Expert (domain-specific, programmatic)
- **Primary Interface**: MCP tools, session worklog, parent control-agent communication

## Context

A specialized AI agent that executes discrete, bounded tasks as part of a multi-agent workflow. Operates under supervision of a Control Agent, receives explicit task parameters and context, reports progress via structured worklog entries, and escalates when blocked. Designed for reliability, observability, and graceful failure handling in a coordinated environment.

## Goals

1. Execute assigned task reliably and report completion status
2. Handle timeouts and resource constraints gracefully
3. Report progress and blockers clearly to parent controller
4. Generate high-quality artifacts that pass quality gates
5. Support retry and recovery workflows without data corruption
6. Maintain audit trail of all work performed

## Pain Points

1. Unclear what context is available (NPL conventions, project state)
2. No clear escalation path when blocked (what to report, to whom)
3. Resource contention (database locks, rate limits) with no negotiation protocol
4. Timeout handling inconsistent across different task types
5. Difficulty reporting partial progress during long-running tasks
6. Quality validation happens after completion, wasting time
7. No standard error format for parent controllers to parse

## Behaviors

- Receives task specification with explicit boundaries and context
- Loads required context (NPL components, project conventions)
- Reports initial status via worklog: "started" with task summary
- Periodically reports progress via worklog: "in_progress" with completion %
- On completion, reports final status: "completed" or "failed" with results
- On resource contention, reports: "blocked" with reason and recovery hint
- On error, reports: "error" with error type, message, stack trace, recovery hint
- Never corrupts data during failure or retry (idempotent operations)

## Needs (Different from General AI Agent)

1. **Task specification clarity** - Explicit boundaries, expected inputs/outputs
2. **Context loading** - Upfront NPL syntax, project conventions, dependencies
3. **Progress reporting** - Standardized status format for parent consumption
4. **Timeout handling** - Graceful degradation when approaching time limits
5. **Resource constraints** - Clear signals when hitting rate limits or locks
6. **Error classification** - Distinguish recoverable vs. fatal errors
7. **Idempotency** - Safe retries without data duplication or corruption
8. **Quality validation** - Early feedback if output won't pass parent's gates
9. **Recovery hints** - Suggest to parent what should happen if blocked

## Commands & Tools (Sub-Agent-Specific)

| Category | Commands |
|----------|----------|
| Task Context | `npl_load` (task context), receive task specification via worklog |
| Progress | `npl_session log --action=in_progress --completion-pct=X` |
| Artifacts | `create_artifact`, `add_revision`, `get_artifact` (verify output) |
| Validation | `check_quality_gate`, `validate_artifact_schema` |
| Error Reporting | `npl_session log --action=error --error-type=X --recovery-hint=Y` |
| Blockage Reporting | `npl_session log --action=blocked --reason=X --recovery-hint=Y` |
| Resource Awareness | `query_resource_status`, `check_rate_limit` |
| Completion | `npl_session log --action=completed --summary=X` |

## Quotes

> "I need the exact task specification upfront - what input, what output format, what passes validation?"

> "If I hit a rate limit or database lock, I need to report it clearly so my parent knows whether to retry or reassign."

> "I should be able to report progress periodically for long-running tasks, not just on completion."

> "If my output fails a quality gate, tell me before I'm done so I can fix it."

> "If I'm retried, make sure my previous partial outputs don't corrupt the data."

## Key Differences from General AI Agent

| Aspect | General AI Agent (P-001) | Sub-Agent (P-007) |
|--------|-------------------------|------------------|
| **Scope** | Autonomous task selection | Explicitly assigned task |
| **Context** | Self-bootstrapping | Provided by parent |
| **Reporting** | Polls for feedback | Pushes status via worklog |
| **Error Handling** | Report & stop | Classify & provide recovery hints |
| **Resource Management** | Best-effort usage | Respects explicit constraints |
| **Timeout Handling** | Varies by task | Standard timeout protocol |
| **Idempotency** | Not guaranteed | Required (supports retries) |
| **Quality Validation** | Post-completion | Can happen mid-task (gates) |
| **Progress Visibility** | Binary (done/not done) | Continuous % completion |

## Task Specification Format

Sub-agents expect task specifications with:

```
{
  "task_id": "unique-task-id",
  "task_name": "descriptive-name",
  "task_description": "what needs to be done",
  "expected_inputs": {...},
  "expected_outputs": {...},
  "output_schema": "validation schema (JSON Schema or YAML)",
  "quality_gates": [...],
  "timeout_seconds": 300,
  "max_retries": 3,
  "context": {
    "npl_components": ["syntax", "agents"],
    "project_conventions": "path/to/conventions.md"
  },
  "dependencies": ["task-id-1", "task-id-2"],
  "resource_constraints": {
    "max_api_calls": 100,
    "db_lock_timeout": 30
  }
}
```

## Worklog Entry Schema

Sub-agents use standardized worklog entries:

```json
{
  "timestamp": "ISO-8601",
  "agent_id": "sub-agent-001",
  "action": "started|in_progress|blocked|error|completed",
  "task_id": "unique-task-id",
  "summary": "human-readable status",
  "completion_pct": 0-100,
  "error_type": "timeout|rate_limit|validation|resource|unknown",
  "error_message": "detailed error description",
  "stack_trace": "full stack for debugging",
  "recovery_hint": "what parent should try (retry|reassign|escalate|fail)",
  "artifacts": ["artifact-id-1", "artifact-id-2"],
  "metadata": {...}
}
```

## Related Stories

- US-014: Pick Up Task from Queue (task assignment)
- US-018: Update Task Status (progress reporting)
- Story 4: Prevent Concurrent Write Conflicts (resource contention)
- Story 14: Worklog Error Propagation Protocol
- Story 15: Browser Automation Timeout & Retry Handling
- Story 27: Agent Handoff Protocol
