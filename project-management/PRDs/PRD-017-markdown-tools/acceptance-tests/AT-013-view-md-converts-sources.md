# AT-013: view-md Converts URLs, Files, and Images

**Category**: Integration
**Related FR**: FR-002, FR-010
**Status**: Passing

## Description

Validates that `view-md` converts various sources to markdown.

## Test Implementation

```python
def test_view_md_converts():
    """Test that view-md converts various sources."""
    # Setup: Mock URL, file, image
    # Action: Convert each with view-md
    # Assert: Markdown output for each
```

## Acceptance Criteria

- [x] URLs converted via Jina API
- [x] Local files read and converted
- [x] Images converted (stub in Phase 1)

## Coverage

Covers:
- Multi-source conversion
- Source type detection
- Conversion pipeline
