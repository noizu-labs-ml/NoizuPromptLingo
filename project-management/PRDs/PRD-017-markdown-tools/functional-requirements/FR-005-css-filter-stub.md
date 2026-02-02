# FR-005: CSS Filter (Stub)

**Status**: Draft

## Description

Placeholder for Phase 2 CSS selector filtering. Convert markdown to HTML, apply CSS selector, convert back to markdown.

## Interface

```python
class CSSFilter:
    def filter(self, content: str, selector: str) -> str:
        """Apply CSS selector to markdown content (Phase 2)."""
```

## Behavior

- **Given** a CSS selector
- **When** filter is called in Phase 1
- **Then** raises `NotImplementedError` with message explaining Phase 2 implementation plan

## Future Design

1. Convert markdown to HTML
2. Apply CSS selector using BeautifulSoup
3. Convert matching HTML back to markdown
4. Return filtered markdown

## Edge Cases

- Phase 1: All calls raise `NotImplementedError`

## Related User Stories

- US-209: Filter Markdown by Heading Path (future enhancement)

## Test Coverage

Expected test count: 2 tests (stub behavior)
Target coverage: 100% for stub
