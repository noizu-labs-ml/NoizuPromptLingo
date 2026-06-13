# FR-016-004: Arize Phoenix Integration

**Status**: Draft

## Description

The system must integrate with Arize Phoenix to evaluate skill quality, creating dashboards and metrics for fine-tuning datasets and multi-shot examples.

## Interface

```python
def setup_phoenix_project(skill_name: str) -> PhoenixProject:
    """Initialize Arize Phoenix project for skill evaluation."""

def evaluate_with_phoenix(examples: list[dict], rubric: Rubric) -> PhoenixEvaluation:
    """Run Phoenix evaluation on examples using rubric metrics."""

def generate_phoenix_dashboard(evaluation: PhoenixEvaluation) -> DashboardURL:
    """Generate Phoenix dashboard with quality metrics."""
```

## Behavior

- **Given** skill examples and an EVAL rubric
- **When** Phoenix evaluation is run
- **Then** metrics are tracked and a dashboard is generated with quality scores

## Edge Cases

- **Phoenix unavailable**: Falls back to local evaluation if Phoenix server is down
- **Large datasets**: Samples examples if dataset too large for Phoenix
- **Missing rubric dimensions**: Uses default metrics if rubric incomplete
- **API rate limits**: Implements retry logic with exponential backoff

## Related User Stories

- US-016-002

## Test Coverage

Expected test count: 10-12 tests
Target coverage: 95% for this FR (Phoenix integration may have mocked tests)
