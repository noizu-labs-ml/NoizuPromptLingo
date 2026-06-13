# Category: Review System

**Category ID**: C-03
**Tool Count**: 6
**Status**: Documented
**Source**: worktrees/main/mcp-server
**Documentation Source Date**: 2026-02-02

## Overview

The Review System enables collaborative artifact reviews with inline comments and image annotations. Multiple reviewers can independently review the same artifact revision, add location-specific comments (line numbers for text files, x/y coordinates for images), and generate annotated versions with footnote references. The system supports multi-reviewer workflows where each reviewer's comments are tracked separately and can be compiled into a unified annotated artifact with per-reviewer comment files.

This category provides structured feedback mechanisms for versioned artifacts, enabling distributed teams to provide detailed, location-specific critiques with clear attribution. Reviews are linked to specific artifact revisions, ensuring feedback remains contextually relevant even as artifacts evolve.

## Features Implemented

### Feature 1: Multi-Reviewer Workflow
**Description**: Independent review creation for the same artifact revision by multiple personas, with per-reviewer comment tracking and consolidated feedback generation.

**MCP Tools**:
- `create_review(artifact_id, revision_id, reviewer_persona)` - Start a new review session
- `get_review(review_id)` - Retrieve review with all comments
- `complete_review(review_id, overall_comment)` - Mark review as completed

**Database Tables**:
- `reviews` - Review metadata (artifact_id, revision_id, reviewer_persona, status, overall_comment)
- `inline_comments` - Location-specific comments (review_id, location, comment, persona)

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/artifacts/reviews.py`
- Database: `worktrees/main/mcp-server/src/npl_mcp/storage/schema.sql`
- Tests: `worktrees/main/mcp-server/tests/test_basic.py`

**Test Coverage**: 25%

**Example Usage**:
```python
# Create review for artifact revision
review = await create_review(
    artifact_id=1,
    revision_id=2,
    reviewer_persona="mike-developer"
)
# Returns: {"review_id": 1, "status": "in_progress", ...}
```

### Feature 2: Inline Text Comments
**Description**: Add location-specific comments to text files using line number references.

**MCP Tools**:
- `add_inline_comment(review_id, location, comment, persona)` - Add comment at specific location

**Database Tables**:
- `inline_comments` - Stores location string (e.g., "line:58") and comment text

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/artifacts/reviews.py` (lines 71-117)
- Tests: `worktrees/main/mcp-server/tests/test_basic.py::test_review_workflow`

**Test Coverage**: Covered by basic workflow tests

**Example Usage**:
```python
# Add comment at line 58
comment = await add_inline_comment(
    review_id=1,
    location="line:58",
    comment="This section needs refactoring for better readability",
    persona="mike-developer"
)
# Returns: {"comment_id": 1, "location": "line:58", ...}
```

### Feature 3: Image Overlay Annotations
**Description**: Add x/y coordinate-based annotations to image artifacts for visual feedback.

**MCP Tools**:
- `add_overlay_annotation(review_id, x, y, comment, persona)` - Add annotation at image coordinates

**Database Tables**:
- `inline_comments` - Stores location as "@x:100,y:200" format

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/artifacts/reviews.py` (lines 119-140)
- Tests: `worktrees/main/mcp-server/tests/test_basic.py::test_review_workflow`

**Test Coverage**: Covered by basic workflow tests

**Example Usage**:
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
```

### Feature 4: Annotated Artifact Generation
**Description**: Generate unified annotated version of artifact with all reviewers' comments as footnotes, plus per-reviewer comment files.

**MCP Tools**:
- `generate_annotated_artifact(artifact_id, revision_id)` - Generate annotated version with all comments

**Database Tables**:
- `reviews` - Query all reviews for revision
- `inline_comments` - Extract all comments grouped by reviewer

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/artifacts/reviews.py` (lines 193-327)
- Tests: Not yet tested (implemented but untested)

**Test Coverage**: 0% (implemented, needs tests)

**Example Usage**:
```python
# Generate annotated artifact with multi-reviewer comments
annotated = await generate_annotated_artifact(
    artifact_id=1,
    revision_id=2
)
# Returns:
# {
#   "annotated_content": "...with [^mike-developer-1], [^ceo-2] markers",
#   "reviewer_files": {
#     "mike-developer": "# Inline Comments by @mike-developer\n...",
#     "ceo": "# Inline Comments by @ceo\n..."
#   },
#   "total_comments": 5,
#   "reviewers": ["mike-developer", "ceo"]
# }
```

### Feature 5: Review Completion
**Description**: Mark reviews as completed with optional overall summary comment.

**MCP Tools**:
- `complete_review(review_id, overall_comment)` - Finalize review with summary

**Database Tables**:
- `reviews` - Update status to 'completed', store overall_comment

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/artifacts/reviews.py` (lines 329-366)
- Tests: Not yet tested

**Test Coverage**: 0% (implemented, needs tests)

**Example Usage**:
```python
# Complete review with overall assessment
result = await complete_review(
    review_id=1,
    overall_comment="Great work! Just minor adjustments needed."
)
# Returns: {"review_id": 1, "status": "completed", "overall_comment": "..."}
```

## MCP Tools Reference

### Tool Signatures

```python
async def create_review(artifact_id: int, revision_id: int, reviewer_persona: str) -> dict

async def add_inline_comment(review_id: int, location: str, comment: str, persona: str) -> dict

async def add_overlay_annotation(review_id: int, x: int, y: int, comment: str, persona: str) -> dict

async def get_review(review_id: int) -> dict

async def generate_annotated_artifact(artifact_id: int, revision_id: int) -> dict

async def complete_review(review_id: int, overall_comment: Optional[str] = None) -> dict
```

### Tool Descriptions

**create_review**: Start a new review for an artifact revision. Verifies the artifact and revision exist, creates a review record with "in_progress" status, and returns the review ID along with metadata.

**add_inline_comment**: Add an inline comment to a review at a specific location. Location format is "line:N" for text files or "@x:X,y:Y" for coordinates. Validates the review exists before adding the comment.

**add_overlay_annotation**: Convenience method for adding image annotations. Converts x/y coordinates to "@x:X,y:Y" format and calls add_inline_comment internally.

**get_review**: Get a review with all its comments. Returns review metadata joined with artifact name, revision number, and all inline comments ordered by creation time.

**generate_annotated_artifact**: Generate an annotated version of an artifact with all review comments as footnotes. Processes all reviews for the revision, groups comments by reviewer, inserts footnote markers at line locations, and generates per-reviewer comment files. Only works with text files (raises ValueError for binary files).

**complete_review**: Mark a review as completed with an optional overall comment. Updates the review status to "completed" and stores the summary comment.

## Database Model

### Tables

- `reviews`: Stores review sessions (id, artifact_id, revision_id, reviewer_persona, status, overall_comment, created_at)
- `inline_comments`: Stores location-specific comments (id, review_id, location, comment, persona, created_at)

### Relationships

- `reviews.artifact_id` → `artifacts.id` (FK)
- `reviews.revision_id` → `revisions.id` (FK)
- `inline_comments.review_id` → `reviews.id` (FK)

### Location Format

- Text file comments: `"line:58"` (line number)
- Image annotations: `"@x:100,y:200"` (pixel coordinates)

## User Stories Mapping

This category addresses:
- US-XXX: Multi-persona artifact review
- US-XXX: Inline code/document commenting
- US-XXX: Visual design feedback with image annotations
- US-XXX: Consolidated multi-reviewer feedback

## Suggested PRD Mapping

- PRD-03: Review and Annotation System
- PRD-04: Multi-Reviewer Collaboration Workflows

## API Documentation

### MCP Tools

**create_review**
- **Parameters**:
  - `artifact_id: int` - ID of artifact to review
  - `revision_id: int` - Specific revision ID
  - `reviewer_persona: str` - Persona slug of reviewer (e.g., "mike-developer")
- **Returns**: Dict with review_id, artifact_id, revision_id, revision_num, reviewer_persona, status
- **Raises**: ValueError if artifact/revision not found

**add_inline_comment**
- **Parameters**:
  - `review_id: int` - ID of review
  - `location: str` - Location string ("line:N" or "@x:X,y:Y")
  - `comment: str` - Comment text
  - `persona: str` - Persona making comment
- **Returns**: Dict with comment_id, review_id, location, comment, persona
- **Raises**: ValueError if review not found

**add_overlay_annotation**
- **Parameters**:
  - `review_id: int` - ID of review
  - `x: int` - X coordinate
  - `y: int` - Y coordinate
  - `comment: str` - Annotation text
  - `persona: str` - Persona making annotation
- **Returns**: Dict with annotation details (same as add_inline_comment)

**get_review**
- **Parameters**:
  - `review_id: int` - ID of review
- **Returns**: Dict with review metadata, artifact_name, artifact_type, revision_num, and list of comments
- **Raises**: ValueError if review not found

**generate_annotated_artifact**
- **Parameters**:
  - `artifact_id: int` - ID of artifact
  - `revision_id: int` - ID of revision
- **Returns**: Dict with annotated_content (string with footnotes), reviewer_files (dict mapping persona to comment file), total_comments, reviewers list
- **Raises**: ValueError if not found or binary file

**complete_review**
- **Parameters**:
  - `review_id: int` - ID of review
  - `overall_comment: Optional[str]` - Summary comment
- **Returns**: Dict with review_id, status="completed", overall_comment
- **Raises**: ValueError if review not found

## Dependencies

- **Internal**: Artifact Management (C-02) - Reviews depend on artifacts and revisions
- **Internal**: Database Layer (storage module)
- **External**: None (pure Python implementation)

## Testing

- **Test Files**: `worktrees/main/mcp-server/tests/test_basic.py::test_review_workflow`
- **Coverage**: 25%
- **Key Test Cases**:
  - Create review for artifact revision ✅
  - Add inline comment to review ✅
  - Add overlay annotation ✅
  - Get review with comments (implemented, untested) ❌
  - Generate annotated artifact (implemented, untested) ❌
  - Complete review (implemented, untested) ❌

## Documentation References

- **README**: worktrees/main/mcp-server/README.md (section "Review System")
- **USAGE**: worktrees/main/mcp-server/USAGE.md (section "2. Collaborative Review Workflow" and "Multi-Reviewer Scenario")
- **Status**: worktrees/main/mcp-server/PROJECT_STATUS.md (section "Review System" coverage: 25%)

## Implementation Notes

### Location String Format
The system uses a flexible location string format:
- `"line:N"` for text file line numbers
- `"@x:X,y:Y"` for image pixel coordinates

This allows the same `inline_comments` table to handle both text and image annotations.

### Footnote Generation Algorithm
The `generate_annotated_artifact` method:
1. Reads original file content
2. Extracts all comments grouped by line number
3. Inserts footnote markers (`[^persona-N]`) at referenced lines
4. Appends footnote definitions at end of file
5. Generates separate per-reviewer comment files

### Multi-Reviewer Support
Multiple reviewers can independently review the same revision. Each review gets a unique review_id, and comments are associated with both the review_id and the persona. The `generate_annotated_artifact` consolidates all comments from all reviews.

### Binary File Handling
The system raises `ValueError` when attempting to annotate binary files (detected via `UnicodeDecodeError`). Only UTF-8 text files can be annotated.

### Test Coverage Gap
Advanced features (annotated artifact generation, multi-reviewer scenarios, review completion) are implemented but lack dedicated tests. The current 25% coverage reflects basic workflow testing only.
