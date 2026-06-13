# User Story: Create Versioned Artifact

**ID**: US-008
**Persona**: P-001 (AI Agent)
**Priority**: High
**Status**: Draft
**Created**: 2026-02-02T10:00:00Z

## Story

As an **AI agent**,
I want to **create a versioned artifact to store my work output**,
So that **my deliverables are persisted, tracked, and available for review**.

## Acceptance Criteria

### Creation
- [ ] Can create artifact with required fields: name (string), type (enum), content (base64)
- [ ] Artifact assigned unique UUID on creation
- [ ] Creator persona ID recorded for attribution
- [ ] Creation timestamp recorded in ISO 8601 format
- [ ] Optional session ID for organizational grouping

### Content Handling
- [ ] Content accepted as base64-encoded string
- [ ] Base64 validation performed before storage
- [ ] Maximum content size: 10MB per artifact (configurable)
- [ ] Empty content rejected with validation error

### Versioning
- [ ] First revision (v1) automatically created on artifact creation
- [ ] Revision numbering follows integer sequence: v1, v2, v3, ...
- [ ] Each revision is immutable after creation
- [ ] Revision includes: version number, timestamp, content hash, creator

### Type Support
- [ ] Supports artifact types: `markdown`, `code`, `image`, `json`, `yaml`, `text`, `binary`
- [ ] Type validation against allowed enum values
- [ ] Optional auto-detection from filename extension (`.md` → `markdown`, `.py` → `code`, etc.)
- [ ] Invalid type rejected with clear error message

### Response
- [ ] Returns artifact object with: ID (UUID), name, type, created timestamp, first revision details
- [ ] Returns web URL in format: `/sessions/{session_id}/artifacts/{artifact_id}` or `/artifacts/{artifact_id}`
- [ ] Includes revision ID and version number (v1) in response

## Technical Details

### Versioning Semantics
- **Version Numbering**: Integer-based sequential versioning (v1, v2, v3, ...)
- **Revision vs Version**: Terms used interchangeably in this system
- **Immutability**: Revisions cannot be modified once created
- **New Versions**: Use `add_revision` command to create new versions (see US-009)

### Artifact Creation Workflow
1. Agent/user calls `create_artifact` with name, type, content (base64)
2. System validates: type enum, base64 encoding, size limit
3. System generates: UUID, timestamp, content hash
4. System creates artifact record in database
5. System creates first revision (v1) with content
6. System returns: artifact ID, web URL, revision details

### Storage
- Artifact metadata stored in SQLite database (`storage/Database`)
- Content stored as base64 in revision record
- Content hash (SHA-256) stored for integrity verification

### Error Scenarios
- Invalid base64 encoding → `400 Bad Request: Invalid base64 content`
- Content exceeds size limit → `413 Payload Too Large: Max 10MB`
- Invalid artifact type → `400 Bad Request: Type must be one of [...]`
- Missing required fields → `400 Bad Request: Missing required field: {field}`

## Notes

- All significant agent outputs should be artifacts (not just ephemeral messages)
- Artifacts enable review workflows and history tracking
- Type auto-detection from filename extension is convenience feature, explicit type takes precedence

## Dependencies

- Database system initialized (`npl_mcp.storage.Database`)
- None required for basic artifact creation (standalone)
- Optional: Session ID for organizational grouping (see US-005)

## Open Questions

- Should artifacts support tags or categories for filtering?
- Should we implement artifact templates for common types?
- Should creation trigger chat room notification if session-linked?

## Implementation Status

**Status**: ✅ Implemented in mcp-server worktree

### MCP Tools
- `create_artifact(name, artifact_type, file_content_base64, filename, created_by?, purpose?)`
- `get_artifact(artifact_id, revision?)`
- `list_artifacts()`

### Database Tables
- `artifacts` - Artifact metadata (id, name, type, current_revision_id, created_at)
- `revisions` - Revision metadata (id, artifact_id, revision_num, filename, created_by, purpose, notes, created_at)

### Web Routes
- `GET /artifact/{id}` - View artifact in web UI
- `GET /api/artifact/{id}` - JSON API endpoint

### Source Files
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/artifacts/manager.py`
- Database: `worktrees/main/mcp-server/src/npl_mcp/storage/schema.sql`
- Tests: `worktrees/main/mcp-server/tests/test_basic.py::test_create_artifact`

### Test Coverage
53% (artifacts module)

### Example Usage
```python
artifact = await create_artifact(
    name="design-mockup-v1",
    artifact_type="image",
    file_content_base64=base64_encoded_image,
    filename="mockup.png",
    created_by="sarah-designer",
    purpose="Initial design concept for dashboard"
)
# Returns: {"artifact_id": 1, "revision_num": 0, "web_url": "..."}
```

### Documentation
- Category Brief: `.tmp/mcp-server/categories/02-artifact-management.md`
- README: `worktrees/main/mcp-server/README.md` (Artifact Management section)
- USAGE: `worktrees/main/mcp-server/USAGE.md` (Artifact Management Workflow)

## Related Commands

**Primary**:
- `create_artifact(name, type, content_base64, creator_persona_id, session_id?)` - Create new artifact with v1

**Related**:
- `add_revision(artifact_id, content_base64, notes?)` - Add new version (see US-009)
- `get_artifact(artifact_id, revision?)` - Retrieve artifact and specific/latest revision
- `get_artifact_history(artifact_id)` - View all revisions (see US-009)
