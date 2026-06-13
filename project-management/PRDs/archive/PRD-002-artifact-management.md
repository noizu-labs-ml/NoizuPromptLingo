# PRD: Artifact Management

**PRD ID**: PRD-002
**Version**: 1.0
**Status**: Documented
**Documentation Source**: worktrees/main/mcp-server
**Last Updated**: 2026-02-02

## Executive Summary

The Artifact Management system provides version-controlled storage for files and documents with automatic revision tracking, metadata generation, and web URLs. Supports any file type with numbered versions (0, 1, 2, ...) stored in `data/artifacts/{name}/`. Designed for multi-persona collaboration.

**Implementation Status**: ✅ Complete in mcp-server worktree

## Features Documented

### User Stories Addressed
- **US-008**: Create versioned artifact
- **US-009**: Review artifact revision history
- **US-017**: Link artifact to task
- **US-004**: Share artifact in chat room

## Functional Requirements

### FR-001: Artifact Creation
**MCP Tools**: `create_artifact(name, artifact_type, file_content_base64, filename, created_by, purpose)`
**Database Tables**: artifacts, revisions
**Returns**: artifact_id, revision_num=0, web_url
**Test Coverage**: 53%

### FR-002: Revision Management
**MCP Tools**: `add_revision(artifact_id, file_content_base64, filename, created_by, purpose, notes)`, `get_artifact_history(artifact_id)`
**Database Tables**: revisions, artifacts
**Test Coverage**: 53%

### FR-003: Artifact Retrieval
**MCP Tools**: `get_artifact(artifact_id, revision)`, `list_artifacts()`
**Database Tables**: artifacts, revisions
**Web Routes**: GET /artifact/{id}, GET /api/artifact/{id}
**Test Coverage**: 0% (list_artifacts untested)

## Data Model

**artifacts**: id, name, type, current_revision_id, session_id, created_at
**revisions**: id, artifact_id, revision_num, filename, file_path, meta_path, created_by, purpose, notes, created_at

**Relationships**: artifacts (1) -> (N) revisions, artifacts.current_revision_id -> revisions.id

## API Specification

### create_artifact
```python
await create_artifact(
    name="design-mockup-v1",
    artifact_type="image",
    file_content_base64=base64_data,
    filename="mockup.png",
    created_by="sarah-designer"
)
```

### add_revision
```python
await add_revision(
    artifact_id=1,
    file_content_base64=base64_data,
    filename="mockup-v2.png",
    notes="Updated colors"
)
```

## Implementation Notes

**File Storage**: `data/artifacts/{name}/revision-{num}-{filename}`
**Metadata**: `data/artifacts/{name}/revision-{num}.meta.md` (YAML frontmatter)

## Dependencies
- **Internal**: Database (C-01), Sessions (C-05)
- **External**: base64, pathlib, datetime

## Testing
- **Files**: tests/test_basic.py
- **Coverage**: 53%
- **Key Tests**: test_create_artifact, test_add_revision

## Documentation References
- **Category Brief**: `.tmp/mcp-server/categories/02-artifact-management.md`
- **Tool Spec**: `.tmp/mcp-server/tools/by-category/artifact-tools.yaml`
