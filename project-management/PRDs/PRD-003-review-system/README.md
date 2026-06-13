# PRD-003: Review System

**Version**: 1.0
**Status**: Implemented
**Author**: npl-prd-editor
**Created**: 2026-02-02
**Updated**: 2026-02-02

## Overview

The Review System enables collaborative artifact reviews with inline comments and image annotations. Multiple reviewers can independently review the same revision, add location-specific feedback, and generate annotated versions with footnotes.

**Implementation Status**: ✅ Complete in mcp-server worktree

## Goals

1. Enable multi-reviewer collaborative feedback workflow
2. Support location-specific comments for text and images
3. Generate annotated artifacts with all feedback compiled
4. Track reviewer identity and perspective throughout process

## Non-Goals

- Real-time collaborative editing
- Video or audio artifact review
- Automated code review suggestions
- Review approval workflows or permissions

---

## User Stories

Reference stories from global `project-management/user-stories/` directory.

| ID | Title | Persona |
|----|-------|---------|
| US-010 | [Add Inline Review Comment](../../user-stories/US-010-add-inline-comment.md) | P-002 |
| US-011 | [Annotate Screenshot with Overlay](../../user-stories/US-011-annotate-screenshot.md) | P-002 |
| US-023 | [Complete Review with Summary](../../user-stories/US-023-complete-review.md) | P-002 |
| US-063 | [Multi-Perspective Artifact Review](../../user-stories/US-063-multi-perspective-artifact-review.md) | P-003 |

Use MCP tools to load full story details:
- **get-story**: Load story by ID
- **edit-story**: Modify story content
- **update-story**: Update story metadata

---

## Functional Requirements

All functional requirements are detailed in `./functional-requirements/` directory.

See `functional-requirements/index.yaml` for complete list.

Key requirements:
- **FR-001**: [Multi-Reviewer Workflow](./functional-requirements/FR-001-multi-reviewer-workflow.md)
- **FR-002**: [Inline Text Comments](./functional-requirements/FR-002-inline-text-comments.md)
- **FR-003**: [Image Overlay Annotations](./functional-requirements/FR-003-image-overlay-annotations.md)
- **FR-004**: [Annotated Artifact Generation](./functional-requirements/FR-004-annotated-artifact-generation.md)

---

## Non-Functional Requirements

| ID | Requirement | Metric | Target |
|----|-------------|--------|--------|
| NFR-1 | Test coverage | Line coverage | >= 80% |
| NFR-2 | Response time | Review creation | < 100ms |
| NFR-3 | Storage efficiency | Comment size | < 10KB per comment |
| NFR-4 | Concurrent reviews | Simultaneous reviewers | Up to 10 per revision |

---

## Error Handling

| Error Condition | Error Type | User Message |
|-----------------|------------|--------------|
| Invalid review_id | ValueError | "Review not found" |
| Empty comment text | ValidationError | "Comment text required" |
| Invalid location format | ValueError | "Location must be 'line:N' or '@x:N,y:N'" |
| Artifact not found | NotFoundError | "Artifact or revision not found" |
| Overlay generation fails | IOError | "Failed to create overlay image" |

---

## Acceptance Tests

All acceptance tests detailed in `./acceptance-tests/` directory.

See `acceptance-tests/index.yaml` for test plan.

---

## Success Criteria

1. All user stories implemented with acceptance criteria passing
2. Test coverage >= 80% for all new code
3. All acceptance tests passing (4/5 currently passing)
4. Clear and actionable error messages
5. Multi-reviewer workflow validated with real-world scenario

---

## Out of Scope

- Review approval workflows (assign/approve/reject)
- Permissions and access control for reviewers
- Review templates or checklists
- Integration with external review tools
- Notification system for review updates

---

## Dependencies

- **Internal**: Artifact Management (PRD-002) - requires artifact and revision APIs
- **External**: None (pure Python)

---

## Data Model

**Tables**:
- **reviews**: id, artifact_id, revision_id, reviewer_persona, status, overall_comment, created_at
- **inline_comments**: id, review_id, location, comment, persona, created_at
- **review_overlays**: id, review_id, overlay_file, created_at

**Relationships**:
- reviews -> artifacts (many-to-one)
- reviews -> revisions (many-to-one)
- inline_comments -> reviews (many-to-one)
- review_overlays -> reviews (many-to-one)

---

## Open Questions

- [ ] Should we support review templates or comment categories?
- [ ] What is the retention policy for completed reviews?
- [ ] Should overlay images be versioned or stored per-review?
