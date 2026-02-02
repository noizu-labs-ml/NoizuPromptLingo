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

## Related Commands

**Review Tools:**
- `add_overlay_annotation` - Add x,y coordinate annotation with comment to review
- `get_review` - Retrieve review with all comments and annotations
- `generate_annotated_artifact` - Generate annotated image with all annotations rendered
- `create_review` - Create review for artifact (prerequisite)
