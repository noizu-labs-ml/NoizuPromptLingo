# PRD-002: Artifact Management

**Version**: 1.0
**Status**: Implemented
**Author**: npl-prd-editor
**Created**: 2026-02-02
**Updated**: 2026-02-02

## Overview

The Artifact Management system provides version-controlled storage for files and documents with automatic revision tracking, metadata generation, and web URLs. Supports any file type with numbered versions (0, 1, 2, ...) stored in `data/artifacts/{name}/`. Designed for multi-persona collaboration with full revision history and web-based access.

## Goals

1. Enable version-controlled storage of any file type with automatic revision tracking
2. Provide web URLs for artifact sharing and collaboration
3. Maintain complete revision history with metadata and notes
4. Support multi-persona workflows with creator attribution
5. Enable artifact linking to tasks and sessions

## Non-Goals

- Real-time collaborative editing of artifacts
- Advanced file format conversion or processing
- Built-in file preview/rendering (delegated to web UI)
- File compression or optimization

---

## User Stories

Reference stories from global `project-management/user-stories/` directory.

| ID | Title | Persona |
|----|-------|---------|
| [US-008](../../user-stories/US-008-create-versioned-artifact.md) | Create versioned artifact | P-001 |
| [US-009](../../user-stories/US-009-review-artifact-history.md) | Review artifact revision history | P-002 |
| [US-017](../../user-stories/US-017-link-artifact-to-task.md) | Link artifact to task | P-001 |
| [US-004](../../user-stories/US-004-share-artifact-chat.md) | Share artifact in chat room | P-003 |

Use MCP tools to load full story details:
- **get-story**: Load story by ID
- **edit-story**: Modify story content
- **update-story**: Update story metadata

---

## Functional Requirements

All functional requirements are detailed in `./functional-requirements/` directory.

See [functional-requirements/index.yaml](./functional-requirements/index.yaml) for complete list.

Key requirements:
- **[FR-001](./functional-requirements/FR-001-artifact-creation.md)**: Artifact Creation
- **[FR-002](./functional-requirements/FR-002-revision-management.md)**: Revision Management
- **[FR-003](./functional-requirements/FR-003-artifact-retrieval.md)**: Artifact Retrieval

---

## Data Model

**Database Tables**:

**artifacts**:
- `id` (PRIMARY KEY)
- `name` (TEXT)
- `type` (TEXT)
- `current_revision_id` (FOREIGN KEY -> revisions.id)
- `session_id` (FOREIGN KEY -> sessions.id, NULLABLE)
- `created_at` (TIMESTAMP)

**revisions**:
- `id` (PRIMARY KEY)
- `artifact_id` (FOREIGN KEY -> artifacts.id)
- `revision_num` (INTEGER)
- `filename` (TEXT)
- `file_path` (TEXT)
- `meta_path` (TEXT)
- `created_by` (TEXT)
- `purpose` (TEXT, NULLABLE)
- `notes` (TEXT, NULLABLE)
- `created_at` (TIMESTAMP)

**Relationships**:
- artifacts (1) -> (N) revisions
- artifacts.current_revision_id -> revisions.id

**File Storage**:
- Files: `data/artifacts/{name}/revision-{num}-{filename}`
- Metadata: `data/artifacts/{name}/revision-{num}.meta.md` (YAML frontmatter)

---

## Non-Functional Requirements

| ID | Requirement | Metric | Target |
|----|-------------|--------|--------|
| NFR-1 | Test coverage | Line coverage | >= 80% |
| NFR-2 | Response time | API latency | < 200ms |
| NFR-3 | File size support | Max file size | 100MB |
| NFR-4 | Concurrent revisions | Race condition handling | Atomic increment |

---

## Error Handling

| Error Condition | Error Type | User Message |
|-----------------|------------|--------------|
| Invalid artifact_id | NotFoundError | "Artifact with ID {id} not found" |
| Invalid base64 content | ValidationError | "File content must be valid base64" |
| Empty artifact name | ValidationError | "Artifact name cannot be empty" |
| Missing file | FileNotFoundError | "Artifact file not found at {path}" |
| Invalid revision number | ValidationError | "Revision {num} does not exist for artifact {id}" |

---

## Acceptance Tests

All acceptance tests detailed in `./acceptance-tests/` directory.

See [acceptance-tests/index.yaml](./acceptance-tests/index.yaml) for test plan.

Test coverage summary:
- **AT-001**: Create artifact basic flow ✅ Passing
- **AT-002**: Add revision to existing artifact ✅ Passing
- **AT-003**: Retrieve artifact by ID ✅ Passing
- **AT-004**: List all artifacts ⚠️ Not started (critical gap)
- **AT-005**: Web route artifact access ⚠️ Not started

---

## Success Criteria

1. All user stories implemented with acceptance criteria passing
2. Test coverage >= 80% for all new code (current: 53%)
3. All acceptance tests passing (3/5 currently passing)
4. Clear and actionable error messages
5. Web routes functional for artifact access
6. Revision history complete and accurate

---

## Out of Scope

- File format conversion (e.g., image resizing, document format changes)
- Built-in file preview rendering (UI responsibility)
- File compression or deduplication
- Access control or permissions (handled at session level)
- Real-time collaborative editing

---

## Dependencies

**Internal**:
- **Database (C-01)**: SQLite backend for artifacts and revisions tables
- **Sessions (C-05)**: Session association for artifact grouping

**External**:
- `base64`: For file content encoding/decoding
- `pathlib`: For file path management
- `datetime`: For timestamp generation
- `FastAPI`: For web routes

---

## Implementation Status

**Current Coverage**: 53%
**Implementation**: ✅ Complete in worktrees/main/mcp-server
**Test Files**: `tests/test_basic.py`

**Key Tests Implemented**:
- `test_create_artifact` ✅
- `test_add_revision` ✅

**Critical Gaps**:
- `list_artifacts` tool: 0% coverage
- Web route testing: Not started
- Edge case coverage: Incomplete

---

## Open Questions

- [ ] Should artifacts support soft delete or hard delete?
- [ ] What is the maximum file size limit for production?
- [ ] Should revision numbering support branching/tags?
- [ ] How to handle concurrent revision creation races?
