# FR-004: Content Extraction

**Status**: Active

## Description

Provide content extraction capabilities including text, HTML, element queries, and JavaScript evaluation. Four tools enable comprehensive page content access.

**Tools**: `browser_get_text`, `browser_get_html`, `browser_query_elements`, `browser_evaluate` (4 tools)

## Interface

```python
async def browser_get_text(
    selector: str,
    session_id: str = None
) -> dict:
    """Extract text content from element.

    Returns: {text: str}
    """

async def browser_get_html(
    selector: str = None,  # null = full page HTML
    session_id: str = None
) -> dict:
    """Extract HTML content.

    Returns: {html: str}
    """

async def browser_query_elements(
    selector: str,
    session_id: str = None,
    limit: int = 100
) -> dict:
    """Query multiple elements and return metadata.

    Returns: {
        selector: str,
        count: int,
        elements: [{
            tag: str,
            text: str,
            visible: bool,
            bounding_box: {x, y, width, height},
            attributes: dict
        }]
    }
    """

async def browser_evaluate(
    script: str,
    session_id: str = None
) -> dict:
    """Execute JavaScript in page context and return result.

    Returns: {result: any}
    """
```

## Behavior

- **Given** a selector matching text content
- **When** browser_get_text is called
- **Then** visible text content is extracted and returned

- **Given** a selector or no selector
- **When** browser_get_html is called
- **Then** HTML content of element or full page is returned

- **Given** a selector matching multiple elements
- **When** browser_query_elements is called with limit
- **Then** up to limit elements are returned with metadata (tag, text, visibility, bounds, attributes)

- **Given** JavaScript code as string
- **When** browser_evaluate is called
- **Then** script executes in page context and return value is serialized

## Edge Cases

- **Selector matches no elements**: Return empty result with count=0
- **Script execution error**: Return error with script line/column
- **Limit exceeded**: Return first N elements with count showing total
- **Non-serializable return value**: Return error for functions/DOM nodes
- **Security context**: Evaluate runs in page context with same origin restrictions

## Related User Stories

- US-021
- US-029

## Test Coverage

Expected test count: 12-15 tests
Target coverage: 100% for this FR

**Test scenarios**:
- Get text from single element
- Get text from non-existent element
- Get full page HTML
- Get element-specific HTML
- Query multiple elements with metadata
- Query with limit enforcement
- Evaluate simple JavaScript expression
- Evaluate script returning object
- Evaluate script with syntax error
- Security context restrictions
