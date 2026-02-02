# AT-010: Error Recovery and Retry

**Category**: Integration
**Related FR**: FR-001, FR-003
**Status**: Not Started

## Description

Validates orchestration recovers gracefully from agent failures using retry strategies.

## Test Implementation

```python
def test_orchestration_recovers_from_agent_failure():
    """Test orchestration retries failed agent and recovers."""
    config = {
        "pattern": "pipeline",
        "stages": [
            {"name": "stage1", "agent": "agent-a", "retry": {"max_attempts": 3}},
            {"name": "stage2", "agent": "agent-b"},
        ],
    }

    # Mock agent-a to fail twice, succeed on third attempt
    with mock_agent_failure("agent-a", fail_count=2):
        engine = OrchestrationEngine()
        result = engine.execute(PatternConfig(config), ExecutionContext())

    assert result.status == "completed"
    assert result.retry_count == 2
    assert result.stages[0].attempts == 3
```

## Acceptance Criteria

- [ ] Agent failure detected
- [ ] Retry strategy applied
- [ ] Success after retries
- [ ] Retry count tracked
- [ ] State restored correctly

## Coverage

Covers:
- Error detection
- Retry logic
- State recovery
