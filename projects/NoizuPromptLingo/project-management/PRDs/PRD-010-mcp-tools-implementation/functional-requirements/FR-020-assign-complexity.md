# FR-020: assign_complexity Tool

**Status**: Draft

## Description

Score task complexity using Fibonacci-like scale.

## Interface

```python
async def assign_complexity(
    task_id: str,
    complexity: int,
    rationale: str | None = None,
    factors: dict | None = None,
    ctx: Context
) -> ComplexityRecord:
    """Score task complexity."""
```

## Behavior

- **Given** task ID and complexity score (1-13)
- **When** assign_complexity is invoked
- **Then**
  - Validates complexity is in valid range (1, 2, 3, 5, 8, 13)
  - Records scoring rationale for reference
  - Updates task estimated effort
  - Recalculates queue metrics
  - Returns ComplexityRecord with score, factors, scored_at

## Edge Cases

- **Invalid score**: Reject with validation error
- **Non-existent task**: Return not found error
- **Rescore existing**: Update score, maintain history
- **Score without rationale**: Allow but recommend providing

## Related User Stories

- US-046-060

## Test Coverage

Expected test count: 10-12 tests
Target coverage: 100% for this FR
