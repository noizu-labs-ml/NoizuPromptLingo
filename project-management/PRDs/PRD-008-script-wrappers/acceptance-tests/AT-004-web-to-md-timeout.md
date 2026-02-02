# AT-004: Web to Markdown Timeout Handling

**Category**: Integration
**Related FR**: FR-004
**Status**: Not Started

## Description

Validates that web_to_md handles timeouts gracefully and raises appropriate exceptions.

## Test Implementation

```python
async def test_web_to_md_timeout():
    """Test timeout handling for slow endpoints."""
    # Setup: Mock slow endpoint
    # Action: Call web_to_md with short timeout
    # Assert: TimeoutException raised
```

## Acceptance Criteria

- [ ] Timeout parameter respected
- [ ] TimeoutException raised on timeout
- [ ] No hanging requests

## Coverage

Covers:
- Timeout configuration
- Exception handling
- Network resilience
