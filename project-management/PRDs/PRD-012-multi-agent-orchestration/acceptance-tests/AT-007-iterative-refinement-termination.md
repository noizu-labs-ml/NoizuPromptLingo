# AT-007: Iterative Refinement Termination

**Category**: Integration
**Related FR**: FR-008, FR-001
**Status**: Not Started

## Description

Validates iterative pattern terminates when quality threshold met or max iterations reached.

## Test Implementation

```python
def test_iterative_pattern_terminates_on_threshold():
    """Test iterative pattern stops when quality threshold met."""
    config = {
        "pattern": "iterative",
        "initial": {"agent": "npl-technical-writer", "output": "draft.md"},
        "iterations": {
            "max": 5,
            "stages": [
                {"name": "analyze", "agent": "npl-grader", "mode": "gap_analysis"},
                {"name": "enhance", "agent": "npl-technical-writer"},
                {"name": "evaluate", "agent": "npl-grader", "threshold": 0.85},
            ],
        },
    }

    # Mock evaluator to return increasing quality scores
    with mock_quality_scores([0.6, 0.75, 0.88]):
        engine = OrchestrationEngine()
        result = engine.execute(PatternConfig(config), ExecutionContext())

    assert result.status == "completed"
    assert result.iteration_count == 3  # Stopped after threshold met
    assert result.final_quality >= 0.85
```

## Acceptance Criteria

- [ ] Initial draft produced
- [ ] Iterations loop through analyze/enhance/evaluate
- [ ] Loop terminates when quality >= 0.85
- [ ] Final artifact returned
- [ ] Iteration count tracked

## Coverage

Covers:
- Iterative refinement loop
- Quality-based termination
- Iteration tracking
