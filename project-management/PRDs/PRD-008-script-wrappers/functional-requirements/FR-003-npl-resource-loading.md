# FR-003: NPL Resource Loading

**Status**: Implemented

## Description

Provide MCP tool to load NPL framework resources (components, meta, styles) with tracking to prevent redundant loading.

## Interface

```python
async def npl_load(
    resource_type: str,
    items: str = "",
    skip: str = ""
) -> str:
    """Load NPL resources with redundancy prevention.

    Args:
        resource_type: 'c' (component), 'm' (meta), 's' (style)
        items: Comma-separated list of resources
        skip: Comma-separated list to skip (already loaded)

    Returns:
        NPL content with tracking flags
    """
```

## Behavior

- **Given** a resource type and items list
- **When** npl_load is invoked
- **Then** NPL content is returned with resources not in skip list

## Edge Cases

- **Empty items**: Returns empty or default content
- **All items skipped**: Returns minimal content
- **Invalid resource type**: Script error handling

## Related User Stories

- US-001
- US-002

## Test Coverage

Expected test count: 10-12 tests
Target coverage: N/A (external script)
