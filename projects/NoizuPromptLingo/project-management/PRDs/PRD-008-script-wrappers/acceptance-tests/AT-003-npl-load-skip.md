# AT-003: NPL Load Skip Parameter

**Category**: Integration
**Related FR**: FR-003
**Status**: Not Started

## Description

Validates that npl_load correctly skips already-loaded resources using the --skip parameter.

## Test Implementation

```python
async def test_npl_load_skip_resources():
    """Test skip parameter prevents redundant loading."""
    # Setup: Define resource list and skip list
    # Action: Call npl_load with skip parameter
    # Assert: Verify skipped resources not in output
```

## Acceptance Criteria

- [ ] Skip parameter honored
- [ ] Only non-skipped resources loaded
- [ ] Tracking flags present

## Coverage

Covers:
- Skip parameter functionality
- Resource filtering
- Redundancy prevention
