# AT-001: 2md Converts URLs to Markdown

**Category**: Integration
**Related FR**: FR-002, FR-008
**Status**: Passing

## Description

Validates that the `2md` CLI tool successfully converts URLs to markdown via Jina API.

## Test Implementation

```python
def test_2md_converts_urls():
    """Test that 2md converts URLs to markdown."""
    # Setup: Mock Jina API response
    # Action: Run 2md with URL
    # Assert: Markdown returned with metadata
```

## Acceptance Criteria

- [x] URL is passed to Jina API
- [x] Markdown content is returned
- [x] YAML metadata header included
- [x] Cache file created

## Coverage

Covers:
- Normal URL conversion path
- Jina API integration
- Metadata header formatting
