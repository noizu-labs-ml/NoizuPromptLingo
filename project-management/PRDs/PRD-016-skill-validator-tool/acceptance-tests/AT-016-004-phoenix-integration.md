# AT-016-004: Arize Phoenix Integration

**Category**: Integration
**Related FR**: FR-016-004
**Status**: Not Started

## Description

Validates that Arize Phoenix integration correctly evaluates examples and generates dashboards.

## Test Implementation

```python
def test_phoenix_project_setup():
    """Test Phoenix project initialization."""
    project = setup_phoenix_project("test-skill")
    assert project.name == "test-skill"
    assert project.metrics_enabled

def test_phoenix_evaluation():
    """Test Phoenix evaluates examples with rubric."""
    examples = [{"prompt": "test", "response": "output"}]
    rubric = Rubric(dimensions=[...])

    evaluation = evaluate_with_phoenix(examples, rubric)

    assert evaluation.total_examples == 1
    assert evaluation.avg_score >= 0

def test_phoenix_dashboard_generation():
    """Test Phoenix dashboard URL generation."""
    evaluation = mock_evaluation()
    dashboard_url = generate_phoenix_dashboard(evaluation)
    assert dashboard_url.startswith("http")
```

## Acceptance Criteria

- [ ] Phoenix project initialized successfully
- [ ] Examples evaluated with rubric metrics
- [ ] Dashboard generated with quality scores
- [ ] Falls back gracefully if Phoenix unavailable
