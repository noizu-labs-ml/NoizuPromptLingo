# FR-006: XPath Filter (Stub)

**Status**: Draft

## Description

Placeholder for Phase 2 XPath filtering. Convert markdown to HTML, apply XPath expression, convert back to markdown.

## Interface

```python
class XPathFilter:
    def filter(self, content: str, selector: str) -> str:
        """Apply XPath expression to markdown content (Phase 2)."""
```

## Behavior

- **Given** an XPath expression
- **When** filter is called in Phase 1
- **Then** raises `NotImplementedError` with message explaining Phase 2 implementation plan

## Future Design

1. Convert markdown to HTML
2. Apply XPath expression using lxml
3. Convert matching HTML back to markdown
4. Return filtered markdown

## Edge Cases

- Phase 1: All calls raise `NotImplementedError`

## Related User Stories

- US-209: Filter Markdown by Heading Path (future enhancement)

## Test Coverage

Expected test count: 2 tests (stub behavior)
Target coverage: 100% for stub
