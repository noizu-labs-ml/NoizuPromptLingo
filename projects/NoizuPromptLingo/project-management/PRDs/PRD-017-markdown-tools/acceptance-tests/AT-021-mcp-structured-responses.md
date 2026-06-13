# AT-021: MCP Tools Return Structured Responses

**Category**: Integration
**Related FR**: FR-011, FR-012
**Status**: Not Started

## Description

Validates that MCP tools return structured responses with metadata.

## Test Implementation

```python
def test_mcp_structured_response():
    """Test that MCP tools return structured responses."""
    # Setup: Mock conversion
    # Action: Call to_markdown MCP tool
    # Assert: Response includes metadata
```

## Acceptance Criteria

- [ ] Responses include metadata
- [ ] Metadata format consistent
- [ ] Content properly formatted

## Coverage

Covers:
- MCP response structure
- Metadata inclusion
- Format consistency
