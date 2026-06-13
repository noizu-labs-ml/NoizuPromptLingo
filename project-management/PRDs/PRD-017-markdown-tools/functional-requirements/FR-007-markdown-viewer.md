# FR-007: Markdown Viewer

**Status**: Completed

## Description

View markdown with collapsible sections and optional filtering. Supports pipeline operations for filtering then collapsing content.

## Interface

```python
class MarkdownViewer:
    def view(
        self,
        content: str,
        filter: Optional[str] = None,
        collapsed_depth: Optional[int] = None,
        filtered_only: bool = False
    ) -> str:
        """View markdown with optional filtering and collapsing."""
```

## Behavior Pipeline

1. Apply filter if specified (via `apply_filter()`)
2. If `filtered_only=True`, return filtered content directly
3. If `collapsed_depth` specified, collapse sections below that depth
4. Return processed markdown

## Collapse Algorithm

- Parse lines, detect headings by `^#{1,6}\s+` pattern
- Track heading level and compare to depth threshold
- Replace collapsed content with `### [Collapsed]` marker
- Emit single marker for consecutive collapsed sections

## Valid Depth Values

1-6 (returns original if out of range)

## Edge Cases

- No filter: Return original or collapsed content
- Filter with no collapse: Return filtered content
- Filter with collapse: Apply filter first, then collapse result
- Invalid depth: Return original content

## Related User Stories

- US-212: Collapse Markdown Sections Below Depth Level
- US-213: Combine Filtering and Collapsing in Pipeline

## Test Coverage

Expected test count: 18 tests
Target coverage: 100% for this FR
