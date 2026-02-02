# AT-003: Pipeline with Gate Failure

**Category**: Integration
**Related FR**: FR-006, FR-001
**Status**: Not Started

## Description

Validates pipeline pattern behavior when quality gate fails and triggers rework loop.

## Test Implementation

```python
def test_pipeline_gate_failure_triggers_rework():
    """Test pipeline with failing gate and retry_previous strategy."""
    config = {
        "pattern": "pipeline",
        "stages": [
            {"name": "research", "agent": "gopher-scout", "output": "research.md"},
            {"name": "validate", "agent": "npl-grader", "criteria": ["completeness"], "threshold": 0.8, "on_fail": "retry_previous"},
            {"name": "design", "agent": "npl-author", "input": "research.md"},
        ],
    }

    # Mock grader to fail on first try, pass on second
    with mock_agent_failure("npl-grader", fail_count=1):
        engine = OrchestrationEngine()
        result = engine.execute(PatternConfig(config), ExecutionContext())

    assert result.status == "completed"
    assert result.retry_count > 0
    assert result.timeline[-1].stage == "design"
```

## Acceptance Criteria

- [ ] Gate failure detected
- [ ] Previous stage re-executed with feedback
- [ ] Second attempt passes gate
- [ ] Pipeline completes successfully
- [ ] Retry count tracked

## Coverage

Covers:
- Pipeline gate validation
- Rework loop logic
- Retry tracking
