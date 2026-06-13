# User Story: Add Inline Review Comment

**ID**: US-010
**Persona**: P-002 (Product Manager)
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z
**Updated**: 2026-02-02

## Story

As a **product manager**,
I want to **add inline comments to specific locations in an artifact**,
So that **I can provide precise, contextual feedback on documents or code without ambiguity**.

## Acceptance Criteria

### Comment Creation
- [ ] Can add comment to existing review by review ID
- [ ] Can specify location using one of these formats:
  - Line number: `{"type": "line", "line": 42}`
  - Line range: `{"type": "line_range", "start_line": 10, "end_line": 15}`
  - Character offset: `{"type": "char_range", "start": 100, "end": 250}`
  - Coordinates (for images): `{"type": "coordinate", "x": 120, "y": 340, "width": 50, "height": 30}`
- [ ] Comment includes text content (markdown supported)
- [ ] Comment attributed to reviewer persona with timestamp
- [ ] Returns unique comment ID

### Threading & Replies
- [ ] Can reply to existing comment by specifying parent comment ID
- [ ] Replies inherit location context from parent
- [ ] Comment hierarchy maintained (parent-child relationships)
- [ ] Can retrieve full thread for a given comment

### Visibility & Retrieval
- [ ] Comments visible when retrieving review via `get_review`
- [ ] Comments grouped by location in review view
- [ ] Thread structure preserved in retrieval (replies nested under parents)
- [ ] Can add multiple independent comments to same review
- [ ] Can add multiple comments at same location (e.g., different reviewers)

## Technical Notes

### Comment Data Model
```python
{
  "comment_id": "c-uuid",
  "review_id": "r-uuid",
  "artifact_revision_id": "rev-uuid",
  "parent_comment_id": "c-uuid" | null,  # null for top-level comments
  "author_persona": "P-002",
  "location": {
    "type": "line" | "line_range" | "char_range" | "coordinate",
    # Additional fields based on type
  },
  "content": "Markdown text...",
  "created_at": "2026-02-02T10:30:00Z",
  "updated_at": "2026-02-02T10:30:00Z"
}
```

### Threading Model
- Top-level comments have `parent_comment_id: null`
- Replies reference parent via `parent_comment_id`
- Replies inherit location from parent (no separate location specified)
- Thread depth unlimited but UI may paginate deep threads

### Location Context
- Line-based locations suitable for text/code artifacts
- Character ranges enable precise selection within lines
- Coordinates support spatial feedback on images/screenshots
- Location type should match artifact type but not enforced

## Dependencies

- Review must exist for the artifact revision (implies `create_review` tool)
- US-008: Create Versioned Artifact (artifact and revision must exist)
- US-009: Review Artifact History (to understand revision context)

## Open Questions

- **Comment editing**: Can comments be edited after creation, or are they immutable?
  - Recommendation: Allow editing within time window (e.g., 15 min) with edit history
- **Comment deletion**: Can comments be deleted, or only marked as resolved?
  - Recommendation: Soft delete (mark as deleted, preserve in DB for audit)
- **Resolution status**: Should individual comments have a "resolved" flag?
  - Use case: Track which feedback has been addressed
- **Notification**: Should comment authors be notified when replies are added?
- **Batch operations**: Support for adding multiple comments in one API call?
- **Max thread depth**: Should there be a limit on reply nesting?

## Related Commands

### Primary
- `add_inline_comment(review_id, location, content, parent_comment_id?)` - Create comment or reply
- `get_review(review_id)` - Retrieve review with all comments and threads

### Supporting
- `create_review(artifact_id, revision_id)` - Start review before commenting
- `get_comment_thread(comment_id)` - Retrieve full thread for a comment
- `update_comment(comment_id, content)` - Edit comment (if allowed)
- `resolve_comment(comment_id)` - Mark comment as resolved (if implemented)

## Examples

### Adding a line comment
```python
add_inline_comment(
  review_id="r-abc123",
  location={"type": "line", "line": 42},
  content="This function should validate input before processing"
)
```

### Replying to a comment
```python
add_inline_comment(
  review_id="r-abc123",
  parent_comment_id="c-def456",
  content="Good catch! I'll add validation in the next revision."
)
```

### Adding coordinate-based feedback on screenshot
```python
add_inline_comment(
  review_id="r-abc123",
  location={"type": "coordinate", "x": 120, "y": 340, "width": 50, "height": 30},
  content="This button alignment is off by 5px"
)
```

## Implementation Status

**Status**: ✅ Implemented in mcp-server worktree

### MCP Tools
- `create_review(artifact_id, revision_id, reviewer_persona)` - Start review
- `add_inline_comment(review_id, location, comment, persona)` - Add comment at location
- `get_review(review_id)` - Retrieve review with all comments
- `complete_review(review_id, overall_comment)` - Mark review complete

### Database Tables
- `reviews` - Review metadata (artifact_id, revision_id, reviewer_persona, status, overall_comment)
- `inline_comments` - Location-specific comments (review_id, location, comment, persona, created_at)

### Web Routes
- No dedicated web routes (API-only via MCP tools)

### Source Files
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/artifacts/reviews.py` (lines 71-117)
- Database: `worktrees/main/mcp-server/src/npl_mcp/storage/schema.sql`
- Tests: `worktrees/main/mcp-server/tests/test_basic.py::test_review_workflow`

### Test Coverage
25% (review system module)

### Location Format
- Text files: `"line:58"` (line number)
- Images: `"@x:100,y:200"` (pixel coordinates)

### Example Usage
```python
# Create review
review = await create_review(
    artifact_id=1,
    revision_id=2,
    reviewer_persona="mike-developer"
)

# Add comment at line 58
comment = await add_inline_comment(
    review_id=1,
    location="line:58",
    comment="This section needs refactoring",
    persona="mike-developer"
)
# Returns: {"comment_id": 1, "location": "line:58", ...}
```

### Notes
- Location string format differs from spec (simplified implementation)
- No threading/reply support yet
- Comments are immutable
- Multi-reviewer workflows supported

### Documentation
- Category Brief: `.tmp/mcp-server/categories/03-review-system.md`
- README: `worktrees/main/mcp-server/README.md`
- USAGE: `worktrees/main/mcp-server/USAGE.md` (Multi-Reviewer Scenario)
