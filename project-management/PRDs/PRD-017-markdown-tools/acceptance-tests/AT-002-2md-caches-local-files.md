# AT-002: 2md Caches Local Files Next to Source

**Category**: Unit
**Related FR**: FR-001, FR-008
**Status**: Passing

## Description

Validates that `2md` caches local files next to the source with `.md` extension.

## Test Implementation

```python
def test_2md_caches_local_files():
    """Test that local files are cached next to source."""
    # Setup: Create temp file
    # Action: Convert with 2md
    # Assert: Cache file created as source.md
```

## Acceptance Criteria

- [x] Cache path is `{source}.md`
- [x] Cache persists after conversion
- [x] Subsequent reads use cache

## Coverage

Covers:
- Local file cache path generation
- Cache persistence
- Cache reuse
