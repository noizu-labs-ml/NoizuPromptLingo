# AT-009: Pattern Composition

**Category**: Integration
**Related FR**: FR-010, FR-001
**Status**: Not Started

## Description

Validates composite pattern with multiple sub-patterns chained together with data flow.

## Test Implementation

```python
def test_composite_pattern_with_dependencies():
    """Test composite pattern with 2 sub-patterns and data flow."""
    config = {
        "pattern": "composite",
        "stages": [
            {
                "name": "assessment",
                "pattern": "consensus",
                "analysts": [...],
            },
            {
                "name": "implementation",
                "pattern": "pipeline",
                "depends_on": ["assessment"],
                "stages": [...],
            },
        ],
        "data_flow": {
            "assessment.output": "implementation.input",
        },
    }

    engine = OrchestrationEngine()
    result = engine.execute(PatternConfig(config), ExecutionContext())

    assert result.status == "completed"
    assert len(result.stage_results) == 2
    assert result.stage_results[1].inputs["assessment_output"] is not None
```

## Acceptance Criteria

- [ ] Dependency graph validated (no cycles)
- [ ] Stages execute in correct order
- [ ] Data flows between stages
- [ ] All sub-patterns complete
- [ ] Aggregated result returned

## Coverage

Covers:
- Pattern composition
- Dependency ordering
- Data flow mapping
