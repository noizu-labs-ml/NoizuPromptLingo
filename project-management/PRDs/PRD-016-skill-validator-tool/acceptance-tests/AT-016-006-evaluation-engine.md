# AT-016-006: Evaluation Engine

**Category**: Unit
**Related FR**: FR-016-006
**Status**: Not Started

## Description

Validates that evaluation engine correctly scores examples against rubric criteria and identifies low-quality examples.

## Test Implementation

```python
def test_evaluate_example_high_quality():
    """Test evaluation engine scores high-quality example correctly."""
    example = {
        "prompt": "What is Python?",
        "response": "Python is a high-level programming language..."
    }
    rubric = create_test_rubric()

    score = evaluate_example(example, rubric)

    assert score.total_score >= 3.0
    assert score.passed

def test_evaluate_example_low_quality():
    """Test evaluation engine identifies low-quality examples."""
    example = {
        "prompt": "What is Python?",
        "response": "idk"
    }
    rubric = create_test_rubric()

    score = evaluate_example(example, rubric)

    assert score.total_score < 2.5
    assert not score.passed

def test_evaluate_dataset_sampling():
    """Test dataset evaluation samples intelligently."""
    examples = [create_example() for _ in range(150)]
    rubric = create_test_rubric()

    evaluation = evaluate_dataset(examples, rubric, sample_size=20)

    assert evaluation.total_evaluated == 20
    assert evaluation.low_quality_count >= 0
```

## Acceptance Criteria

- [ ] Scores examples per dimension
- [ ] Calculates overall score with weights
- [ ] Identifies examples below 3.0/4.0 threshold
- [ ] Samples large datasets efficiently
