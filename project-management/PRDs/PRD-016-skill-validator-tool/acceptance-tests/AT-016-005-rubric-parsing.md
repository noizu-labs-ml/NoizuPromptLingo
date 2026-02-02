# AT-016-005: EVAL Rubric Parsing

**Category**: Unit
**Related FR**: FR-016-005
**Status**: Not Started

## Description

Validates that rubric parser correctly extracts dimensions, scales, weights, and criteria from EVAL/rubric.md files.

## Test Implementation

```python
def test_parse_rubric_valid():
    """Test rubric parser with valid rubric file."""
    rubric_md = """
    # Evaluation Rubric

    ## Dimension 1: Accuracy (40%)
    - 0: Incorrect
    - 2: Partially correct
    - 4: Fully correct

    ## Dimension 2: Completeness (30%)
    ...

    Pass threshold: 2.5/4.0
    """

    rubric = parse_rubric("rubric.md")

    assert len(rubric.dimensions) == 2
    assert rubric.dimensions[0].name == "Accuracy"
    assert rubric.weights["Accuracy"] == 0.4
    assert rubric.pass_threshold == 2.5

def test_parse_rubric_invalid_weights():
    """Test rubric parser normalizes weights that don't sum to 100%."""
    rubric = parse_rubric("invalid-weights-rubric.md")
    total_weight = sum(rubric.weights.values())
    assert abs(total_weight - 1.0) < 0.01  # Normalized to 100%
```

## Acceptance Criteria

- [ ] Extracts all dimensions with correct names
- [ ] Parses 0-4 scale criteria
- [ ] Validates weights sum to 100%
- [ ] Identifies pass threshold
