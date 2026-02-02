# Category: Artifact Management

**Category ID**: C-02
**Tool Count**: 5
**Status**: Documented
**Source**: worktrees/main/mcp-server
**Documentation Source Date**: 2026-02-02

## Overview

The Artifact Management system provides version-controlled storage for files and documents created during collaborative development. It supports any file type with automatic revision tracking, metadata generation, and web-accessible URLs. Each artifact maintains a complete revision history with numbered versions (0, 1, 2, ...) and stores files in an organized directory structure under `data/artifacts/{name}/`.

This system is designed for multi-persona collaboration where team members (designers, developers, product managers) create, iterate, and review versioned work products like design mockups, specifications, code files, and reports.

## Features Implemented

### Feature 1: Artifact Creation
**Description**: Create new artifacts with an initial revision (revision 0). Each artifact has a unique name and type classification (e.g., "image", "document", "code").

**MCP Tools**:
- `create_artifact(name, artifact_type, file_content_base64, filename, created_by, purpose)` - Creates artifact with metadata and returns artifact ID and web URL

**Database Tables**:
- `artifacts` - Stores artifact metadata (id, name, type, current_revision_id, created_at)
- `revisions` - Stores revision metadata (id, artifact_id, revision_num, filename, created_by, purpose, notes, created_at)

**Web Routes**:
- `GET /artifact/{id}` - View artifact in web UI

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/artifacts/manager.py`
- Database: `worktrees/main/mcp-server/src/npl_mcp/storage/schema.sql`
- Tests: `worktrees/main/mcp-server/tests/test_basic.py::test_create_artifact`

**Test Coverage**: 53%

**Example Usage**:
```python
artifact = await create_artifact(
    name="design-mockup-v1",
    artifact_type="image",
    file_content_base64=base64_encoded_image,
    filename="mockup.png",
    created_by="sarah-designer",
    purpose="Initial design concept for dashboard"
)
# Returns: {"artifact_id": 1, "revision_num": 0, ...}
```

### Feature 2: Revision Management
**Description**: Add new revisions to existing artifacts, maintaining a complete version history. Each revision increments the version number and updates the artifact's current revision pointer.

**MCP Tools**:
- `add_revision(artifact_id, file_content_base64, filename, created_by, purpose, notes)` - Creates new revision and updates current revision pointer
- `get_artifact_history(artifact_id)` - Returns chronological list of all revisions

**Database Tables**:
- `revisions` - Stores all revision metadata
- `artifacts` - Tracks current_revision_id

**Web Routes**:
- `GET /artifact/{id}` - Shows current revision by default
- `GET /artifact/{id}?revision={num}` - View specific revision

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/artifacts/manager.py`
- Database: `worktrees/main/mcp-server/src/npl_mcp/storage/schema.sql`
- Tests: `worktrees/main/mcp-server/tests/test_basic.py::test_add_revision`

**Test Coverage**: 53%

**Example Usage**:
```python
revision = await add_revision(
    artifact_id=1,
    file_content_base64=base64_encoded_updated_image,
    filename="mockup-v2.png",
    created_by="sarah-designer",
    purpose="Updated colors per feedback",
    notes="Changed primary color to #3498db"
)
# Returns: {"revision_id": 2, "revision_num": 1, ...}
```

### Feature 3: Artifact Retrieval
**Description**: Retrieve artifacts with their content and metadata. Supports fetching current revision (default) or any historical revision by number.

**MCP Tools**:
- `get_artifact(artifact_id, revision)` - Retrieves artifact metadata and file content
- `list_artifacts()` - Lists all artifacts with summary metadata

**Database Tables**:
- `artifacts` - Artifact metadata
- `revisions` - Revision metadata and file paths

**Web Routes**:
- `GET /artifact/{id}` - Web viewer for artifact
- `GET /api/artifact/{id}` - JSON API endpoint

**Source Files**:
- Implementation: `worktrees/main/mcp-server/src/npl_mcp/artifacts/manager.py`
- Database: `worktrees/main/mcp-server/src/npl_mcp/storage/schema.sql`
- Tests: `worktrees/main/mcp-server/tests/test_basic.py::test_create_artifact`

**Test Coverage**: 53%

**Example Usage**:
```python
# Get current artifact
current = await get_artifact(artifact_id=1)

# Get specific revision
old_version = await get_artifact(artifact_id=1, revision=0)
```

## MCP Tools Reference

### Tool Signatures

```python
create_artifact(
    name: str,
    artifact_type: str,
    file_content_base64: str,
    filename: str,
    created_by: Optional[str] = None,
    purpose: Optional[str] = None
) -> dict

add_revision(
    artifact_id: int,
    file_content_base64: str,
    filename: str,
    created_by: Optional[str] = None,
    purpose: Optional[str] = None,
    notes: Optional[str] = None
) -> dict

get_artifact(
    artifact_id: int,
    revision: Optional[int] = None
) -> dict

list_artifacts() -> list

get_artifact_history(artifact_id: int) -> list
```

### Tool Descriptions

#### `create_artifact`
Create a new artifact with initial revision. Stores file in `data/artifacts/{name}/revision-0-{filename}` and creates metadata file with YAML frontmatter. Returns artifact ID, revision ID, revision number (0), and web URL.

**Parameters**:
- `name` - Unique artifact name (hyphenated, e.g., "design-mockup-v1")
- `artifact_type` - Type classification (e.g., "image", "document", "code")
- `file_content_base64` - Base64-encoded file content
- `filename` - Original filename
- `created_by` - Optional persona/user identifier
- `purpose` - Optional description of artifact purpose

**Returns**: `{"artifact_id": int, "revision_id": int, "revision_num": 0, "web_url": str}`

#### `add_revision`
Add a new revision to an existing artifact. Increments revision number, stores new file, creates metadata, and updates artifact's current_revision_id.

**Parameters**:
- `artifact_id` - ID of artifact to update
- `file_content_base64` - Base64-encoded file content
- `filename` - New filename (can differ from original)
- `created_by` - Optional persona/user identifier
- `purpose` - Optional description of changes
- `notes` - Optional detailed notes about revision

**Returns**: `{"revision_id": int, "revision_num": int, "web_url": str}`

#### `get_artifact`
Retrieve artifact metadata and file content. Returns current revision by default or specified revision if provided.

**Parameters**:
- `artifact_id` - ID of artifact to retrieve
- `revision` - Optional specific revision number (defaults to current)

**Returns**: `{"artifact_id": int, "name": str, "artifact_type": str, "revision_num": int, "filename": str, "content_base64": str, "created_by": str, "purpose": str, "created_at": str}`

#### `list_artifacts`
List all artifacts with summary metadata (no file content).

**Parameters**: None

**Returns**: `[{"artifact_id": int, "name": str, "artifact_type": str, "current_revision": int, "created_at": str}, ...]`

#### `get_artifact_history`
Get chronological revision history for an artifact (newest first).

**Parameters**:
- `artifact_id` - ID of artifact

**Returns**: `[{"revision_num": int, "created_by": str, "purpose": str, "filename": str, "created_at": str}, ...]`

## Database Model

### Tables

**artifacts**:
- `id` (INTEGER PRIMARY KEY) - Artifact ID
- `name` (TEXT UNIQUE) - Artifact name
- `artifact_type` (TEXT) - Type classification
- `current_revision_id` (INTEGER) - Foreign key to current revision
- `created_at` (TEXT) - ISO timestamp

**revisions**:
- `id` (INTEGER PRIMARY KEY) - Revision ID
- `artifact_id` (INTEGER) - Foreign key to artifact
- `revision_num` (INTEGER) - Sequential revision number (0-indexed)
- `filename` (TEXT) - Stored filename
- `created_by` (TEXT) - Creator persona/user
- `purpose` (TEXT) - Revision purpose
- `notes` (TEXT) - Detailed notes
- `created_at` (TEXT) - ISO timestamp

### Relationships

- `artifacts.current_revision_id` → `revisions.id` (current version)
- `revisions.artifact_id` → `artifacts.id` (all versions)

## User Stories Mapping

This category addresses:
- US-001: Create versioned artifacts
- US-002: Track artifact revision history
- US-003: Retrieve artifact versions
- US-004: Collaborate on versioned documents
- US-005: View artifact metadata

## Suggested PRD Mapping

- PRD-1: Artifact Version Control System
- PRD-2: Multi-Persona Collaboration

## API Documentation

### MCP Tools

All tools return structured dictionaries with success/error status. File content is base64-encoded for binary safety.

### Web Endpoints

- `GET /artifact/{artifact_id}` - HTML viewer
- `GET /artifact/{artifact_id}?revision={num}` - HTML viewer for specific revision
- `GET /api/artifact/{artifact_id}` - JSON metadata
- `GET /api/artifact/{artifact_id}/revision/{num}` - JSON for specific revision

## Dependencies

### Internal
- Storage layer (`npl_mcp.storage.db`) - Database connection and queries
- Web layer (`npl_mcp.web.app`) - Web UI routes

### External
- SQLite 3.35+ - Database with JSON support
- Python standard library (base64, pathlib, datetime)

## Testing

### Test Files
- `worktrees/main/mcp-server/tests/test_basic.py`

### Coverage
53% overall for artifact management module

### Key Test Cases
- `test_create_artifact` - Validates artifact creation, file storage, metadata generation
- `test_add_revision` - Validates revision addition, numbering, current revision update
- `test_artifact_sharing_in_chat` - Integration test with chat system

## Documentation References

- **README**: worktrees/main/mcp-server/README.md (Artifact Management section, lines 63-68)
- **USAGE**: worktrees/main/mcp-server/USAGE.md (Artifact Management Workflow, lines 33-71)
- **PRD**: worktrees/main/mcp-server/docs/PRD.md (if exists)
- **Status**: worktrees/main/mcp-server/PROJECT_STATUS.md (Artifact Management section, lines 44-52)

## Implementation Notes

### File Storage Convention
- Files stored at: `data/artifacts/{artifact_name}/revision-{num}-{filename}`
- Metadata stored at: `data/artifacts/{artifact_name}/revision-{num}.meta.md`

### Metadata Format
YAML frontmatter with markdown notes:
```yaml
---
revision: 1
artifact_name: design-mockup-v1
created_by: sarah-designer
created_at: 2025-10-09T14:30:00
purpose: Updated colors per feedback
filename: mockup-v2.png
---

# Notes

Changed primary color to #3498db based on brand guidelines.
```

### Best Practices
- Use descriptive hyphenated names (e.g., `user-dashboard-v2`)
- Always provide `purpose` field for context
- Create new revisions rather than overwriting files
- Use consistent `created_by` persona identifiers

### Limitations
- No built-in diff support between revisions
- No automatic conflict detection
- No revision branching (linear history only)
- No bulk operations (import/export multiple artifacts)
