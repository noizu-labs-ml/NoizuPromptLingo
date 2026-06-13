# User Story: Annotate Screenshot with Overlay

**ID**: US-011
**Persona**: P-002 (Product Manager)
**Priority**: Medium
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a **product manager**,
I want to **add overlay annotations to screenshots at specific coordinates**,
So that **I can point out visual issues or provide feedback on UI designs**.

## Acceptance Criteria

- [ ] Can add annotation at x,y coordinates on image artifact
- [ ] Annotation includes comment text
- [ ] Annotations attributed to reviewer_persona
- [ ] Can retrieve review with all annotations via `get_review`
- [ ] Can generate annotated version of artifact with all annotations visible
- [ ] Annotations do not modify original image artifact
- [ ] Multiple annotations supported per review
- [ ] Annotated images are accessible via file path

## Notes

- Essential for UI review workflows
- Generated annotated images are saved as new files and accessible via returned file path
- Current implementation uses coordinate-based overlay annotations
- Consider future support for different annotation types (circle, arrow, highlight, boxes)

## Open Questions

- What annotation shapes/types to support?
- Should annotations be color-coded by reviewer?

## Implementation Status

**Status**: ✅ Implemented in mcp-server worktree

### MCP Tools
- `add_overlay_annotation(review_id, x, y, comment, persona)` - Add annotation at coordinates
- `generate_annotated_artifact(artifact_id, revision_id)` - Generate annotated version
- `get_review(review_id)` - Retrieve review with annotations
- `create_review(artifact_id, revision_id, reviewer_persona)` - Start review

### Database Tables
- `inline_comments` - Stores annotations with location as "@x:X,y:Y" format
- `reviews` - Review metadata
- `review_overlays` - Not actively used (implementation uses inline_comments)

### Web Routes
- No dedicated web routes (API-only via MCP tools)

### Source Files
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/artifacts/reviews.py` (lines 119-140, 193-327)
- Database: `worktrees/main/mcp-server/src/npl_mcp/storage/schema.sql`
- Tests: `worktrees/main/mcp-server/tests/test_basic.py::test_review_workflow`

### Test Coverage
25% (review system module)

### Example Usage
```python
# Add annotation at pixel coordinates
annotation = await add_overlay_annotation(
    review_id=1,
    x=100,
    y=200,
    comment="Button placement seems off-center here",
    persona="mike-developer"
)
# Returns: {"comment_id": 2, "location": "@x:100,y:200", ...}

# Generate annotated artifact
annotated = await generate_annotated_artifact(
    artifact_id=1,
    revision_id=2
)
# Returns: {"annotated_content": "...", "reviewer_files": {...}, "total_comments": 5}
```

### Notes
- Annotations stored same as inline comments (location format "@x:X,y:Y")
- Multi-reviewer support (consolidates all annotations)
- Text files only (raises error for binary files)
- Generates footnote-style annotations

### Documentation
- Category Brief: `.tmp/mcp-server/categories/03-review-system.md`
- README: `worktrees/main/mcp-server/README.md`
- USAGE: `worktrees/main/mcp-server/USAGE.md`

## Related Commands

**Review Tools:**
- `add_overlay_annotation` - Add x,y coordinate annotation with comment to review
- `get_review` - Retrieve review with all comments and annotations
- `generate_annotated_artifact` - Generate annotated image with all annotations rendered
- `create_review` - Create review for artifact (prerequisite)
