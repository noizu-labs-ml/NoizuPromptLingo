# User Story: Compare Screenshots for Visual Regression

**ID**: US-013
**Persona**: P-001 (AI Agent)
**Priority**: Medium
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As an **AI agent**,
I want to **compare two screenshots to detect visual differences**,
So that **I can verify UI changes have not introduced unintended regressions**.

## Acceptance Criteria

- [ ] Can compare two screenshot artifacts by artifact ID
- [ ] Generates diff image highlighting changes in red overlay
- [ ] Returns diff percentage (0-100%, pixel-based comparison)
- [ ] Supports configurable threshold for pass/fail (default: 0.1%, range: 0-100%)
- [ ] Diff image saved as new artifact with PNG format
- [ ] Reports status (passed/failed) based on threshold
- [ ] Stores comparison metadata: source artifact IDs, diff percentage, threshold, timestamp
- [ ] Handles dimension mismatches (resize to larger, or fail with clear error)
- [ ] Returns artifact ID of diff image and comparison report

## Notes

- Essential for automated visual regression testing
- Threshold should allow for minor rendering differences (anti-aliasing, font rendering)
- Consider pixel-perfect vs perceptual comparison modes
- Diff image format: PNG with red overlay on changed regions, original as base
- Comparison modes to consider:
  - **Pixel-perfect**: Exact RGB comparison (fast, strict)
  - **Perceptual**: Structural similarity (SSIM) accounting for minor variations
- Default threshold of 0.1% accommodates minor browser rendering differences

## Technical Specifications

### Input Parameters
- `baseline_artifact_id`: Artifact ID of reference screenshot (string)
- `comparison_artifact_id`: Artifact ID of screenshot to compare (string)
- `threshold`: Optional pass/fail threshold percentage (float, default: 0.1, range: 0-100)
- `mode`: Optional comparison mode (string, default: "pixel", options: "pixel", "perceptual")

### Output Format
```json
{
  "status": "passed" | "failed",
  "diff_percentage": 0.05,
  "threshold": 0.1,
  "diff_artifact_id": "art_abc123",
  "metadata": {
    "baseline_artifact_id": "art_xyz789",
    "comparison_artifact_id": "art_def456",
    "dimensions": {"width": 1920, "height": 1080},
    "mode": "pixel",
    "timestamp": "2026-02-02T10:00:00Z"
  }
}
```

### Diff Image Specification
- **Format**: PNG with RGBA channels
- **Visual encoding**:
  - Unchanged pixels: Original baseline image (100% opacity)
  - Changed pixels: Red overlay (#FF0000) at 70% opacity
  - Background: Baseline image as reference
- **File naming**: `diff_{baseline_id}_vs_{comparison_id}_{timestamp}.png`

### Error Handling
- `DimensionMismatchError`: Screenshots have different dimensions
- `ArtifactNotFoundError`: One or both artifact IDs invalid
- `InvalidFormatError`: Artifact is not a supported image format
- `ComparisonFailedError`: Image processing error during comparison

## Open Questions

- What diff algorithm to use (pixel, perceptual)?
  - Initial implementation: pixel-perfect RGB comparison
  - Future: add perceptual mode using SSIM or similar
- How to handle different viewport sizes?
  - Option 1: Fail fast with clear error message
  - Option 2: Resize to larger dimensions (may introduce artifacts)
  - Option 3: Crop to smaller dimensions (loses information)
  - Recommended: Option 1 initially, with explicit resize parameter later
- Should comparison support selective regions (bounding boxes)?
- Library choice: Pillow (PIL), opencv-python, or pixelmatch equivalent?

## Related Commands

- `screenshot_diff` (Screenshot Tools) - main comparison command
- `get_artifact` (Artifact Tools) - retrieve source screenshots
- `create_artifact` (Artifact Tools) - save diff image
