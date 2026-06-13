# User Story: Review Artifact Revision History

**ID**: US-009
**Persona**: P-002 (Product Manager)
**Priority**: Medium
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As a **product manager**,
I want to **view the revision history of an artifact**,
So that **I can understand how a deliverable evolved, track changes over time, and audit who made specific modifications**.

## Acceptance Criteria

### History Retrieval
- [ ] Can retrieve complete revision history for any artifact by ID
- [ ] Revisions returned in reverse chronological order (newest first)
- [ ] Empty history returns appropriate response (not error) for new artifacts

### Revision Metadata
- [ ] Each revision includes: revision number, timestamp (ISO 8601), author/creator ID, optional notes/purpose
- [ ] Revision numbers are sequential and immutable
- [ ] Author information includes persona type or user identifier

### Content Access
- [ ] Can retrieve full content of any specific revision by revision number
- [ ] Most recent revision content accessible without specifying revision number
- [ ] Historical revision content matches original at time of creation (immutable)

### Comparison Features
- [ ] Can request diff/comparison between any two revisions
- [ ] Diff shows additions, deletions, and modifications
- [ ] Comparison format suitable for both text and binary artifacts (metadata for binary)
- [ ] Can compare current version against any historical revision

### Data Integrity
- [ ] Revision history persists even when new revisions are added
- [ ] Cannot modify or delete historical revisions (immutable audit trail)
- [ ] Artifact deletion handling documented (archive vs. hard delete)

## Test Scenarios

### Scenario 1: View Complete History
**Given** an artifact with 3 revisions
**When** user requests history
**Then** returns 3 revisions with metadata in reverse chronological order

### Scenario 2: Access Specific Revision
**Given** an artifact with revisions 1, 2, 3
**When** user requests revision 2 content
**Then** returns content exactly as it was in revision 2

### Scenario 3: Compare Revisions
**Given** artifact revision 1 with content "Hello World" and revision 2 with "Hello NPL"
**When** user compares revisions 1 and 2
**Then** diff shows "World" deleted and "NPL" added

### Scenario 4: New Artifact History
**Given** newly created artifact with only 1 revision
**When** user requests history
**Then** returns single revision with creation metadata

### Scenario 5: Immutability Check
**Given** artifact with historical revision
**When** new revision is added
**Then** historical revision content and metadata remain unchanged

### Scenario 6: Invalid Revision Number
**Given** artifact with 3 revisions
**When** user requests revision 99
**Then** returns error indicating revision not found

## Technical Notes

### Storage Requirements
- Revisions stored as immutable records in database
- Each revision includes full content snapshot (not deltas)
- Revision metadata stored separately from content for efficient querying

### History Tracking
- Revision numbers auto-increment starting from 1
- Timestamp captures creation time in UTC
- Author captured from request context (persona/user session)

### Comparison Implementation
- Text artifacts: line-based diff (unified diff format)
- Binary artifacts: metadata comparison (size, hash, type changes)
- Large artifacts: consider lazy-loading full content

### Audit Trail
- History provides complete audit trail for compliance
- Immutability ensures forensic integrity
- Supports regulatory requirements for change tracking

## Dependencies

- **US-008**: Create Versioned Artifact (must exist to have history)
- Artifact storage system with revision tracking capability
- Database schema supporting artifact versioning

## Open Questions

- **Diff Visualization**: Should comparison output be plain text (unified diff), structured JSON, or both?
- **Revision Deletion**: Should revisions ever be deletable? Proposal: No deletion, only artifact-level archival
- **Performance**: For artifacts with 100+ revisions, should history be paginated?
- **Branching**: Do artifacts need branching/merging support, or is linear history sufficient?
- **Retention Policy**: Should very old revisions be archived/compressed after N days?

## Implementation Status

**Status**: ✅ Implemented in mcp-server worktree

### MCP Tools
- `get_artifact_history(artifact_id)` - Returns chronological list of all revisions
- `get_artifact(artifact_id, revision)` - Retrieve specific or current revision
- `add_revision(artifact_id, file_content_base64, filename, created_by, purpose, notes)` - Create new revision

### Database Tables
- `revisions` - Stores all revision metadata and file paths
- `artifacts` - Tracks current_revision_id pointer

### Web Routes
- `GET /artifact/{id}` - Shows current revision by default
- `GET /artifact/{id}?revision={num}` - View specific revision number

### Source Files
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/artifacts/manager.py`
- Database: `worktrees/main/mcp-server/src/npl_mcp/storage/schema.sql`
- Tests: `worktrees/main/mcp-server/tests/test_basic.py::test_add_revision`

### Test Coverage
53% (artifacts module)

### Example Usage
```python
# Get artifact history
history = await get_artifact_history(artifact_id=1)
# Returns: [{"revision_num": 2, "created_by": "...", "purpose": "...", "filename": "...", "created_at": "..."}, ...]

# Get specific revision
old_version = await get_artifact(artifact_id=1, revision=0)
```

### Notes
- Revisions numbered 0-indexed (revision 0, 1, 2, ...)
- History returned newest first
- Each revision immutable after creation
- Comparison/diff features not yet implemented

### Documentation
- Category Brief: `.tmp/mcp-server/categories/02-artifact-management.md`
- README: `worktrees/main/mcp-server/README.md`
- USAGE: `worktrees/main/mcp-server/USAGE.md`

## Related Commands

### Artifact Tools (Future Implementation)
- `get_artifact_history(artifact_id)` - Retrieve all revisions for an artifact
- `get_artifact_revision(artifact_id, revision_number)` - Get specific revision content
- `compare_artifact_revisions(artifact_id, revision_a, revision_b)` - Generate diff between revisions
- `get_artifact(artifact_id)` - Get current/latest artifact (from US-008)

### Implementation Reference
See `src/npl_mcp/artifacts/` (future module) for artifact versioning system.
