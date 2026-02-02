# AT-001: Dump Files Basic Functionality

**Category**: Integration
**Related FR**: FR-001
**Status**: Not Started

## Description

Validates that dump_files correctly aggregates file contents with headers.

## Test Implementation

```python
async def test_dump_files_basic():
    """Test basic file aggregation with glob filter."""
    # Setup: Create test directory with files
    # Action: Call dump_files with glob pattern
    # Assert: Verify concatenated output with headers
```

## Acceptance Criteria

- [ ] Returns concatenated content
- [ ] Includes file headers
- [ ] Respects glob filtering

## Coverage

Covers:
- Normal aggregation flow
- Glob pattern filtering
- Header formatting
