# FR-006: annotate_screenshot Tool

**Status**: Draft

## Description

Add visual annotations to a captured screenshot artifact.

## Interface

```python
async def annotate_screenshot(
    artifact_id: str,
    annotations: list[Annotation],
    ctx: Context
) -> AnnotatedArtifact:
    """Add annotations to a screenshot artifact.

    Annotation structure:
    {
        "type": "box" | "arrow" | "text" | "highlight",
        "coordinates": {"x": int, "y": int, "width": int, "height": int},
        "content": str  # text or style properties
    }
    """
```

## Behavior

- **Given** screenshot artifact ID and annotations array
- **When** annotate_screenshot is invoked
- **Then**
  - Validates artifact is image type
  - Stores annotations as separate layer (non-destructive)
  - Supports multiple annotation versions
  - Generates preview with annotations composited
  - Returns AnnotatedArtifact with annotation_layer_id

## Edge Cases

- **Non-image artifact**: Return type validation error
- **Invalid coordinates**: Reject with validation error
- **Empty annotations**: Accept but log warning
- **Overlapping annotations**: Allow, render in order

## Related User Stories

- US-008-030

## Test Coverage

Expected test count: 8-10 tests
Target coverage: 100% for this FR
