# FR-016-006: Evaluation Engine

**Status**: Draft

## Description

The system must provide an evaluation engine that scores examples (fine-tuning data, multi-shot examples) against rubric criteria, calculating dimension scores and overall quality metrics.

## Interface

```python
def evaluate_example(example: dict, rubric: Rubric) -> EvaluationScore:
    """Score single example against rubric dimensions.

    Returns:
        EvaluationScore with dimension scores, total score, and pass/fail
    """

def evaluate_dataset(examples: list[dict], rubric: Rubric, sample_size: int = 20) -> DatasetEvaluation:
    """Evaluate dataset quality by sampling examples."""
```

## Behavior

- **Given** examples and a rubric
- **When** evaluation is performed
- **Then** each example is scored per dimension and aggregated into quality metrics

## Edge Cases

- **Ambiguous examples**: Provides score ranges when example quality is unclear
- **Missing content**: Assigns 0 score for missing response fields
- **Large datasets**: Samples intelligently (stratified sampling) for efficiency
- **Edge score boundaries**: Clear handling of 2.5+ threshold edge cases

## Related User Stories

- US-016-002

## Test Coverage

Expected test count: 12-15 tests
Target coverage: 100% for this FR
