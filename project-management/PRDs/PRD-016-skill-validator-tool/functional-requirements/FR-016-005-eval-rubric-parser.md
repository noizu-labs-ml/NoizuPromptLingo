# FR-016-005: EVAL Rubric Parser

**Status**: Draft

## Description

The system must parse EVAL/rubric.md files into structured rubric objects with dimensions, scales, weights, and criteria that can be used for evaluation.

## Interface

```python
def parse_rubric(rubric_path: str) -> Rubric:
    """Parse EVAL rubric markdown into structured format.

    Returns:
        Rubric object with dimensions, scales (0-4), weights, and pass threshold
    """

@dataclass
class Rubric:
    dimensions: list[Dimension]
    pass_threshold: float
    weights: dict[str, float]
```

## Behavior

- **Given** a rubric markdown file
- **When** parsing is performed
- **Then** structured rubric object is created with all dimensions, scales, and criteria

## Edge Cases

- **Malformed rubric**: Reports specific sections that don't match expected format
- **Invalid weights**: Validates weights sum to 100% or normalizes them
- **Missing dimensions**: Requires minimum 3 dimensions to be valid
- **Inconsistent scales**: Ensures all dimensions use 0-4 scale

## Related User Stories

- US-016-002

## Test Coverage

Expected test count: 8-10 tests
Target coverage: 100% for this FR
