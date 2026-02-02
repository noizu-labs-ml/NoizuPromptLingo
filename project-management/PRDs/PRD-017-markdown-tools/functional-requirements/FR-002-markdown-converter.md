# FR-002: Markdown Converter

**Status**: Completed

## Description

Convert various sources to markdown with automatic caching and YAML metadata headers.

## Interface

```python
class MarkdownConverter:
    def __init__(self, cache: Optional[MarkdownCache] = None):
        """Initialize converter with optional cache."""

    async def convert(
        self,
        source: str,
        force_refresh: bool = False,
        timeout: int = 30
    ) -> str:
        """Convert source to markdown with caching."""
```

## Source Type Detection

| Pattern | Type | Handler |
|---------|------|---------|
| `http://` or `https://` | URL | Jina API via `r.jina.ai` |
| `.png`, `.jpg`, `.jpeg`, `.gif`, `.svg` | Image | Phase 3 (stub) |
| `.pdf` | PDF | Phase 2 (stub) |
| `.docx`, `.doc` | Word | Phase 2 (stub) |
| Other | Text/Markdown | Direct read |

## Response Format

```yaml
success: true
source: {original_source}
source_type: url | file
cached: true | false
cache_file: {path_to_cache}
content_length: {length}
---
{markdown_content}
```

## Error Handling

| Error Condition | Error Type | Behavior |
|-----------------|------------|----------|
| File not found | `FileNotFoundError` | Propagate with message |
| Jina API failure | `httpx.HTTPError` | Propagate with status |
| PDF conversion (Phase 1) | `NotImplementedError` | Return stub message |
| DOCX conversion (Phase 1) | `NotImplementedError` | Return stub message |
| Image conversion (Phase 1) | `NotImplementedError` | Return stub message |

## Related User Stories

- US-206: Convert Documentation Sources to Markdown
- US-207: Cache Converted Files with Hybrid Strategy

## Test Coverage

Expected test count: 10 tests
Target coverage: 100% for this FR
