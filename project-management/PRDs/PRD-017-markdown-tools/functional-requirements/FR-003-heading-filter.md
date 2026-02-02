# FR-003: Heading Filter

**Status**: Completed

## Description

Filter markdown content by heading paths and level selectors with hierarchical navigation.

## Interface

```python
class HeadingFilter:
    def filter(self, content: str, selector: str) -> str:
        """Apply heading selector to markdown content."""
```

## Selector Syntax

| Pattern | Description | Example |
|---------|-------------|---------|
| `heading-name` | Match by text (case-insensitive) | `"API Reference"` |
| `parent > child` | Nested path navigation | `"Overview > Installation"` |
| `parent > *` | All children of parent | `"API > *"` |
| `h1` - `h6` | Match by heading level | `"h2"` |

## Parsing Algorithm

1. Parse markdown into hierarchical section tree
2. Each section tracks: level, text, content lines, children
3. Navigate selector path through tree
4. Return matched section with full content

## Error Cases

- No sections found: Return `"# Error: No sections found in content"`
- Section not found: Return `"# Error: Section not found: {name}"`

## Related User Stories

- US-209: Filter Markdown by Heading Path
- US-210: Filter Markdown by Heading Level Selectors

## Test Coverage

Expected test count: 15 tests
Target coverage: 100% for this FR
