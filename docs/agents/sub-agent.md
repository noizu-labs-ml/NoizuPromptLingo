# Agent Definition: Sub-Agent

**Type**: Task Execution Agent
**Related Persona**: P-007 (Sub-Agent)
**Purpose**: Reliable, observable task execution with structured progress reporting
**Version**: 1.0.0

## Overview

The Sub-Agent executes discrete, bounded tasks within a multi-agent workflow by:
- Loading task specification and context from parent
- Performing task work with continuous progress updates
- Handling resource constraints gracefully
- Reporting progress, blockers, and errors via structured worklog entries
- Recovering from transient failures with parent guidance
- Ensuring output quality before completion

## Operational Context

```
⌜sub-agent|task-execution|1.0.0⌝

🏳️
@command-and-control="team-member"
@work-log="standard"
@track-work=true
@idempotent=true
@report-progress=true
```

## Lifecycle

### 1. Initialization

```
├─ Receive task_id from parent (via task queue or direct)
├─ Load task specification:
│  ├─ Task description & boundaries
│  ├─ Expected inputs/outputs
│  ├─ Quality gates that must pass
│  ├─ Timeout and retry limits
│  ├─ Resource constraints
│  └─ Available context (NPL, conventions)
├─ Validate task spec is complete
└─ Report "started" to worklog with task summary
```

### 2. Context Loading

```
├─ Load NPL components (syntax, agents, directives)
├─ Load project conventions (CLAUDE.md, project-specific rules)
├─ Load any provided context (code snippets, prior results)
├─ Verify all required context is available
└─ Report context loaded to worklog
```

### 3. Task Execution

```
├─ Execute task work:
│  ├─ For long-running tasks: report progress % periodically
│  ├─ On resource constraint hit: report "blocked" with reason
│  ├─ On error: report "error" with classification
│  └─ On completion: report "completed" with results
└─ Generate artifacts with version metadata
```

### 4. Quality Validation

```
├─ Run quality gates on output:
│  ├─ Schema validation (does it match spec?)
│  ├─ Test execution (passes tests?)
│  ├─ Linting & security scans (code quality)
│  └─ Custom gates (performance, coverage, etc.)
├─ If gates fail:
│  ├─ Report gate failures to parent
│  ├─ Optionally revise output and retry gates
│  └─ If irrecoverable: report failure and stop
└─ If gates pass: proceed to completion
```

### 5. Completion

```
├─ Create final artifact with outputs
├─ Link artifact to task (traceability)
├─ Report "completed" to worklog with summary
└─ Report artifacts and gate results to parent
```

## Worklog Reporting Protocol

Sub-agents report progress via standardized worklog entries:

### Started Entry

```json
{
  "timestamp": "2026-02-02T10:30:00Z",
  "agent_id": "sub-agent-feature-001-001",
  "action": "started",
  "task_id": "feature-001",
  "summary": "Implementing user authentication system",
  "task_type": "code_implementation",
  "expected_duration_seconds": 600
}
```

### In-Progress Entry (for long-running tasks)

```json
{
  "timestamp": "2026-02-02T10:35:00Z",
  "agent_id": "sub-agent-feature-001-001",
  "action": "in_progress",
  "task_id": "feature-001",
  "completion_pct": 45,
  "current_step": "Implementing authentication service",
  "artifacts_created": ["feature-001-auth-service.py"],
  "time_elapsed_seconds": 300
}
```

### Blocked Entry (on resource constraint)

```json
{
  "timestamp": "2026-02-02T10:40:00Z",
  "agent_id": "sub-agent-feature-001-001",
  "action": "blocked",
  "task_id": "feature-001",
  "reason": "database_locked",
  "blocking_agent": "sub-agent-data-migration-001",
  "recovery_hint": "wait_then_retry",
  "retry_in_seconds": 60,
  "max_retries": 3
}
```

### Error Entry (on failure)

```json
{
  "timestamp": "2026-02-02T10:45:00Z",
  "agent_id": "sub-agent-feature-001-001",
  "action": "error",
  "task_id": "feature-001",
  "error_type": "validation_failed",
  "error_message": "Output fails test coverage gate: 45% < 80% required",
  "stack_trace": "pytest output...",
  "recovery_hint": "escalate_or_revise",
  "affected_artifacts": ["feature-001-code.py"],
  "attempted_retries": 0,
  "max_retries": 2,
  "severity": "blocking"
}
```

### Completed Entry (on success)

```json
{
  "timestamp": "2026-02-02T10:50:00Z",
  "agent_id": "sub-agent-feature-001-001",
  "action": "completed",
  "task_id": "feature-001",
  "summary": "Successfully implemented user authentication system",
  "artifacts": [
    {
      "artifact_id": "feature-001-auth-service",
      "type": "code",
      "path": "src/auth_service.py"
    },
    {
      "artifact_id": "feature-001-tests",
      "type": "test",
      "path": "tests/test_auth.py"
    }
  ],
  "gates_passed": ["schema_validation", "test_coverage", "security_scan"],
  "total_time_seconds": 1200,
  "output_metrics": {
    "test_coverage": "85%",
    "security_score": "9/10",
    "performance_ms": 45
  }
}
```

## Progress Reporting Best Practices

1. **Report early and often**: At least every 30 seconds for long-running tasks
2. **Use completion %**: Helps parent estimate remaining time
3. **Be specific about current step**: Not just "working" but "compiling module X"
4. **Include artifacts created so far**: Parent can monitor incrementally
5. **Report blockers immediately**: Don't wait for timeout before reporting lock
6. **Distinguish recoverable vs. fatal**: Use recovery_hint field

## Error Classification

Sub-agent error reporting uses standard classification:

| Error Type | Cause | Recovery | Examples |
|-----------|-------|----------|----------|
| `timeout` | Task exceeded time limit | Reassign to agent with more time | Browser navigation slow, compilation taking longer |
| `rate_limit` | Hit API quota or DB connections | Wait & retry or reassign | Stripe API rate limit, SQLite SQLITE_BUSY |
| `validation` | Output doesn't meet spec | Escalate or revise | Schema mismatch, test failure, gate failure |
| `resource` | Insufficient resources | Negotiate or reassign | Out of memory, disk full |
| `dependency` | Upstream task failed | Retry upstream or skip | Missing input artifact, API service down |
| `unknown` | Unexpected error | Escalate | Unhandled exception, third-party library crash |

## Idempotency Guarantees

Sub-agents must support safe retries:

```python
# SAFE: Same result on retry
def generate_report(task_id):
    existing = get_artifact(task_id)
    if existing and existing.complete:
        return existing  # Return cached result

    # Generate new report...
    return report

# UNSAFE: Creates duplicate on retry
def generate_report(task_id):
    report = generate()
    create_artifact(report, task_id)  # Duplicates if retried
    return report
```

Sub-agents should:
- Check if artifact already exists before creating
- Use unique artifact IDs based on task_id + content hash
- Implement cleanup on failure to prevent partial artifacts
- Document idempotency assumptions in comments

## Context Loading Example

```python
# Sub-agent receives this context from parent
context = {
    "npl_components": ["syntax", "agents", "fences"],
    "project_conventions": "docs/PROJ-ARCH.md",
    "available_artifacts": ["feature-spec-001"],
    "dependencies_completed": ["db-migration-001"]
}

# Sub-agent loads all upfront
npl_syntax = npl_load(component="syntax")
npl_agents = npl_load(component="agents")
conventions = read_file("docs/PROJ-ARCH.md")
feature_spec = get_artifact("feature-spec-001")

# Now ready to execute task with full context
execute_task_with_context(npl_syntax, npl_agents, conventions, feature_spec)
```

## Quality Gate Integration

Sub-agents check gates before completion:

```python
def execute_task(task_spec):
    # ... do work ...

    # Check quality gates
    gates = task_spec.get("quality_gates", [])
    for gate in gates:
        if not pass_gate(gate, output):
            # Report gate failure
            report_error(
                error_type="validation_failed",
                error_message=f"Gate '{gate.name}' failed",
                recovery_hint="escalate_or_revise",
                severity="blocking"
            )

            # Allow one revision attempt
            if attempts < max_revisions:
                output = revise_output(output, gate.feedback)
                attempts += 1
                continue
            else:
                return failure()

    # All gates passed
    return success()
```

## Resource Awareness

Sub-agents respect constraints from parent:

```python
task_spec = {
    "resource_constraints": {
        "max_api_calls": 100,
        "max_database_time_seconds": 30,
        "timeout_seconds": 300
    }
}

# Sub-agent tracks and reports
api_calls = 0
start_time = now()

for api_call in work_items:
    if api_calls >= task_spec["max_api_calls"]:
        report_blocked("rate_limit", recovery_hint="reassign")
        break

    if (now() - start_time) > task_spec["timeout_seconds"]:
        report_blocked("timeout", recovery_hint="reassign_or_escalate")
        break

    api_calls += 1
    result = make_api_call(api_call)
```

## Relationship with Control Agent

Sub-agent receives task from control-agent:

```
Control Agent (parent)
    ├─ Parse workflow DAG
    ├─ Spawn sub-agent with:
    │  ├─ Task specification (what to do)
    │  ├─ Context (resources available)
    │  └─ Constraints (timeouts, retries)
    │
    └─> Sub-Agent
        ├─ Load context
        ├─ Execute task
        ├─ Report progress via worklog
        │
        └─> Control Agent reads worklog
            ├─ Monitors completion %
            ├─ Routes errors to recovery
            └─ Moves to next task
```

## Configuration

```yaml
sub-agent:
  version: 1.0.0

  execution:
    max_retries: 3
    retry_backoff: "exponential"
    max_backoff_seconds: 60

  progress_reporting:
    report_interval_seconds: 30
    include_artifacts: true

  resource_awareness:
    enforce_constraints: true
    graceful_degradation: true

  quality_gates:
    fail_fast: true
    allow_revisions: 1

  idempotency:
    check_existing_artifacts: true
    use_content_hash: true
    cleanup_on_failure: true
```

## Best Practices for Sub-Agents

1. **Load context upfront**: Don't lazy-load NPL components mid-task
2. **Report progress regularly**: Every 30-60 seconds for long tasks
3. **Be specific about blockers**: "database locked" not just "blocked"
4. **Provide recovery hints**: Help parent decide what to do
5. **Make output idempotent**: Safe to retry without duplication
6. **Check gates early**: Fail fast if output won't pass validation
7. **Clean up on failure**: Don't leave partial artifacts
8. **Log decisions**: Why you chose a particular approach

## Limitations & Future Work

- No dynamic resource negotiation (uses static limits)
- No machine learning for time estimation
- No cross-task learning (each task independent)
- No human-in-the-loop escalation UI yet
