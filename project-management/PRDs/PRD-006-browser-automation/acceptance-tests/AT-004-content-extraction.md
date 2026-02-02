# AT-004: Content Extraction

**Category**: Integration
**Related FR**: FR-004
**Status**: Not Started

## Description

Validates content extraction including text, HTML, element queries, and JavaScript evaluation.

## Test Implementation

```python
def test_browser_get_text():
    """Extract text content from element."""
    await browser_navigate(url="https://example.com", session_id="text")

    result = await browser_get_text(
        selector="h1",
        session_id="text"
    )
    assert "text" in result
    assert len(result["text"]) > 0

def test_browser_get_html():
    """Extract HTML content."""
    await browser_navigate(url="https://example.com", session_id="html")

    # Get full page HTML
    page_result = await browser_get_html(session_id="html")
    assert "<!DOCTYPE" in page_result["html"] or "<html" in page_result["html"]

    # Get element HTML
    element_result = await browser_get_html(
        selector=".header",
        session_id="html"
    )
    assert "html" in element_result

def test_browser_query_elements():
    """Query multiple elements with metadata."""
    await browser_navigate(url="https://example.com/products", session_id="query")

    result = await browser_query_elements(
        selector=".product-card",
        session_id="query",
        limit=20
    )
    assert result["count"] > 0
    assert len(result["elements"]) <= 20

    for elem in result["elements"]:
        assert "tag" in elem
        assert "text" in elem
        assert "visible" in elem
        assert "bounding_box" in elem
        assert "attributes" in elem

def test_browser_evaluate():
    """Execute JavaScript and return result."""
    await browser_navigate(url="https://example.com", session_id="eval")

    # Simple expression
    expr_result = await browser_evaluate(
        script="document.title",
        session_id="eval"
    )
    assert "result" in expr_result

    # Complex script returning object
    obj_result = await browser_evaluate(
        script="({url: window.location.href, width: window.innerWidth})",
        session_id="eval"
    )
    assert "result" in obj_result
    assert "url" in obj_result["result"]
```

## Acceptance Criteria

- [ ] Get text extracts visible text content
- [ ] Get HTML returns full page or element HTML
- [ ] Query elements returns metadata for all matches
- [ ] Query elements respects limit parameter
- [ ] Element metadata includes tag, text, visibility, bounds, attributes
- [ ] Evaluate executes JavaScript in page context
- [ ] Evaluate returns serialized results
- [ ] Script errors handled with clear messages
- [ ] Non-existent selectors return appropriate errors

## Coverage

Covers:
- Text extraction
- HTML extraction (full page and element)
- Multi-element queries
- Element metadata
- JavaScript evaluation
- Error handling
