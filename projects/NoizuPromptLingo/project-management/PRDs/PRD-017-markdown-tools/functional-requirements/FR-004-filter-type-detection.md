# FR-004: Filter Type Detection

**Status**: Completed

## Description

Auto-detect and route to appropriate filter implementation (heading, CSS, XPath).

## Interface

```python
class FilterType(Enum):
    HEADING = "heading"
    CSS = "css"
    XPATH = "xpath"

def detect_filter_type(selector: str) -> FilterType
def apply_filter(content: str, selector: str) -> str
```

## Detection Rules

| Prefix/Pattern | Detected Type |
|----------------|---------------|
| `xpath:` | XPATH |
| `css:` | CSS |
| Contains `>`, `:`, `[`, `]` | HEADING |
| Default | HEADING |

## Behavior

- **Given** a filter selector string
- **When** `detect_filter_type()` is called
- **Then** appropriate filter type is returned based on syntax

## Edge Cases

- Empty selector: Default to HEADING
- Ambiguous patterns: Prefer heading filter for Phase 1

## Related User Stories

- US-209: Filter Markdown by Heading Path
- US-210: Filter Markdown by Heading Level Selectors

## Test Coverage

Expected test count: 8 tests
Target coverage: 100% for this FR
