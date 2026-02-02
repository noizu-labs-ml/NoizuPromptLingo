# AT-003: Fabric Pattern Application

**Category**: Integration
**Related FR**: FR-002
**Status**: Not Started

## Description

Validates Fabric CLI integration for pattern application to content.

## Test Implementation

```python
def test_fabric_pattern_application():
    """Test applying Fabric patterns to content."""
    # Setup
    content = """
    Error: Connection timeout at line 45
    Retrying connection...
    Error: Connection timeout at line 45
    Fatal: Unable to connect after 3 retries
    """

    # Action: Apply analyze_logs pattern
    result = apply_fabric_pattern(content, "analyze_logs")

    # Assert: Analysis returned
    assert result["success"] is True
    assert "analysis" in result
    assert len(result["analysis"]) > 0

    # Action: Apply non-existent pattern
    result = apply_fabric_pattern(content, "nonexistent_pattern")

    # Assert: Error returned with available patterns
    assert result["success"] is False
    assert "available_patterns" in result["error"]


def test_fabric_not_installed():
    """Test graceful fallback when Fabric not installed."""
    # Setup: Mock find_fabric to return None
    with patch('npl_mcp.executors.fabric.find_fabric', return_value=None):
        # Action: Apply pattern
        result = apply_fabric_pattern("test content", "summarize")

        # Assert: Graceful error
        assert result["success"] is False
        assert "not installed" in result["error"].lower()
```

## Acceptance Criteria

- [ ] Valid pattern applied successfully
- [ ] Invalid pattern returns error with available patterns
- [ ] Fabric not installed returns graceful error
- [ ] Timeout handled without hanging

## Coverage

Covers:
- Pattern application
- Error handling
- Fallback behavior
- Timeout protection
