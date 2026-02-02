# AT-006: Hierarchical Decomposition and Aggregation

**Category**: Integration
**Related FR**: FR-007, FR-001
**Status**: Not Started

## Description

Validates hierarchical pattern with coordinator decomposing problem, teams executing, and results aggregated.

## Test Implementation

```python
def test_hierarchical_pattern_with_teams():
    """Test hierarchical decomposition with 3 teams."""
    config = {
        "pattern": "hierarchical",
        "coordinator": "npl-thinker",
        "teams": [
            {"name": "arch", "agents": ["npl-system-analyzer"], "focus": "architecture"},
            {"name": "impl", "agents": ["tdd-driven-builder"], "focus": "implementation"},
            {"name": "docs", "agents": ["npl-technical-writer"], "focus": "documentation"},
        ],
        "aggregation": {"strategy": "structured_merge"},
    }

    engine = OrchestrationEngine()
    result = engine.execute(PatternConfig(config), ExecutionContext())

    assert result.status == "completed"
    assert len(result.team_outputs) == 3
    assert result.aggregated_output is not None
```

## Acceptance Criteria

- [ ] Coordinator decomposes problem into subtasks
- [ ] All 3 teams execute in parallel
- [ ] Team outputs collected
- [ ] Results aggregated via structured merge
- [ ] Conflicts resolved

## Coverage

Covers:
- Hierarchical decomposition
- Team coordination
- Result aggregation
