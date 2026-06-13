# AT-003: 2md Caches URLs in .tmp/cache/markdown/

**Category**: Unit
**Related FR**: FR-001, FR-008
**Status**: Passing

## Description

Validates that `2md` caches URLs in `.tmp/cache/markdown/` with hashed filenames.

## Test Implementation

```python
def test_2md_caches_urls():
    """Test that URLs are cached in .tmp/cache/markdown/."""
    # Setup: Mock URL
    # Action: Convert with 2md
    # Assert: Cache in .tmp/cache/markdown/{domain}.{path}.{hash}.md
```

## Acceptance Criteria

- [x] Cache directory is `.tmp/cache/markdown/`
- [x] Filename includes domain, path, and hash
- [x] Hash is MD5 truncated to 8 characters
- [x] Cache is deterministic (same URL → same path)

## Coverage

Covers:
- URL cache path generation
- Hashing algorithm
- Cache directory structure
