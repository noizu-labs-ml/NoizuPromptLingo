# FR-024: compare_screenshots Tool

**Status**: Draft

## Description

Compare two screenshots for visual differences with diff generation.

## Interface

```python
async def compare_screenshots(
    baseline_id: str,
    comparison_id: str,
    threshold: float | None = None,
    ignore_regions: list[dict] | None = None,
    ctx: Context
) -> ComparisonResult:
    """Compare two screenshots for visual differences."""
```

## Behavior

- **Given** baseline and comparison artifact IDs
- **When** compare_screenshots is invoked
- **Then**
  - Loads both screenshot artifacts
  - Performs pixel-by-pixel comparison
  - Generates diff image highlighting changes
  - Reports match status based on threshold
  - Returns ComparisonResult with match, diff_percentage, diff_artifact_id

## Edge Cases

- **Non-existent artifacts**: Return not found error
- **Non-image artifacts**: Return type validation error
- **Different dimensions**: Resize to match or return error
- **Threshold out of range**: Clamp to [0.0, 1.0]

## Related User Stories

- US-061-077

## Test Coverage

Expected test count: 12-15 tests
Target coverage: 100% for this FR
