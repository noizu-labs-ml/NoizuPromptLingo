# AT-002: Consensus Pattern Execution

**Category**: Integration
**Related FR**: FR-005, FR-001
**Status**: Not Started

## Description

Validates end-to-end consensus pattern execution with 3 analysts and synthesizer.

## Test Implementation

```python
def test_consensus_pattern_with_three_analysts():
    """Test consensus pattern with technical, marketing, security perspectives."""
    config = {
        "pattern": "consensus",
        "name": "Feature Assessment",
        "analysts": [
            {"agent": "npl-technical-writer", "perspective": "technical", "weight": 1.0},
            {"agent": "npl-marketing-writer", "perspective": "marketing", "weight": 0.8},
            {"agent": "npl-threat-modeler", "perspective": "security", "weight": 1.2},
        ],
        "synthesizer": {"agent": "npl-thinker", "mode": "synthesis"},
        "decision": {"format": "recommendation", "include_dissent": True},
    }
    engine = OrchestrationEngine()
    result = engine.execute(PatternConfig(config), ExecutionContext())

    assert result.status == "completed"
    assert len(result.analyst_reports) == 3
    assert result.synthesis is not None
    assert "confidence_score" in result.synthesis
```

## Acceptance Criteria

- [ ] All 3 analysts execute in parallel
- [ ] Individual analyst reports collected
- [ ] Synthesizer produces unified recommendation
- [ ] Confidence score included in output
- [ ] Dissenting opinions captured

## Coverage

Covers:
- Consensus pattern end-to-end
- Parallel analyst execution
- Synthesis logic
