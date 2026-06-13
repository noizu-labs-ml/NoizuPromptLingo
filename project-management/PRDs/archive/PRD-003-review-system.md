# PRD: Review System

**PRD ID**: PRD-003
**Version**: 1.0
**Status**: Documented
**Documentation Source**: worktrees/main/mcp-server
**Last Updated**: 2026-02-02

## Executive Summary

The Review System enables collaborative artifact reviews with inline comments and image annotations. Multiple reviewers can independently review the same revision, add location-specific feedback, and generate annotated versions with footnotes.

**Implementation Status**: ✅ Complete in mcp-server worktree

## Features Documented

### User Stories Addressed
- **US-010**: Add inline review comment
- **US-011**: Annotate screenshot with overlay
- **US-023**: Complete review with summary
- **US-063**: Multi-perspective artifact review

## Functional Requirements

### FR-001: Multi-Reviewer Workflow
**MCP Tools**: `create_review(artifact_id, revision_id, reviewer_persona)`, `get_review(review_id)`, `complete_review(review_id, overall_comment)`
**Test Coverage**: 25%

### FR-002: Inline Text Comments
**MCP Tools**: `add_inline_comment(review_id, location, comment, persona)`
**Location Format**: "line:58" for text files
**Test Coverage**: 25%

### FR-003: Image Overlay Annotations
**MCP Tools**: `add_overlay_annotation(review_id, x, y, comment, persona)`
**Location Format**: "@x:100,y:200" for coordinates
**Test Coverage**: 25%

### FR-004: Annotated Artifact Generation
**MCP Tools**: `generate_annotated_artifact(artifact_id, revision_id)`
**Returns**: annotated_content with footnotes, reviewer_files dict, total_comments
**Test Coverage**: 0% (implemented, untested)

## Data Model

**reviews**: id, artifact_id, revision_id, reviewer_persona, status, overall_comment, created_at
**inline_comments**: id, review_id, location, comment, persona, created_at
**review_overlays**: id, review_id, overlay_file, created_at

**Relationships**: reviews -> artifacts, reviews -> revisions, inline_comments -> reviews

## API Specification

### create_review
```python
review = await create_review(
    artifact_id=1,
    revision_id=2,
    reviewer_persona="mike-developer"
)
```

### add_inline_comment
```python
await add_inline_comment(
    review_id=1,
    location="line:58",
    comment="This needs refactoring",
    persona="mike-developer"
)
```

### generate_annotated_artifact
```python
result = await generate_annotated_artifact(
    artifact_id=1,
    revision_id=2
)
# Returns: {annotated_content, reviewer_files, total_comments, reviewers}
```

## Dependencies
- **Internal**: Artifact Management (C-02)
- **External**: None (pure Python)

## Testing
- **Files**: tests/test_basic.py::test_review_workflow
- **Coverage**: 25%

## Documentation References
- **Category Brief**: `.tmp/mcp-server/categories/03-review-system.md`
- **Tool Spec**: `.tmp/mcp-server/tools/by-category/review-tools.yaml`
