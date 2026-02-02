# PRD-017: Project Management MCP Tools

**Version**: 1.0
**Status**: Draft
**Author**: npl-prd-editor
**Created**: 2026-02-02
**Updated**: 2026-02-02

---

## Overview

Implement a suite of MCP tools that provide programmatic access to project management artifacts stored in the `project-management/` directory structure. These tools enable TDD workflow agents to read user stories, PRDs, functional requirements, acceptance tests, and personas - supporting the automated test generation and code implementation pipeline.

### Goals

1. Provide read access to user stories with structured metadata extraction
2. Provide read access to PRD documents with navigation to FRs and ATs
3. Enable listing and filtering of stories, PRDs, and personas
4. Support metadata updates to track implementation progress
5. Achieve 80%+ test coverage for all new code
6. Maintain backward compatibility with existing launcher stubs

### Non-Goals

- Modifying markdown content of user stories or PRDs (out of scope)
- Creating new user stories or PRDs programmatically
- Version control integration (git operations)
- Real-time collaboration or locking mechanisms

---

## User Stories

User stories for this PRD are defined in separate files for clarity and reusability:

| ID | Title | File | Priority | Status |
|---|---|---|---|---|
| US-226 | Read User Story by ID | `project-management/user-stories/US-226-read-user-story-by-id.md` | Critical | draft |
| US-227 | List and Filter User Stories | `project-management/user-stories/US-227-list-and-filter-user-stories.md` | High | draft |
| US-228 | Read PRD Content by ID | `project-management/user-stories/US-228-read-prd-content-by-id.md` | Critical | draft |
| US-229 | Access PRD Functional Requirements | `project-management/user-stories/US-229-access-prd-functional-requirements.md` | High | draft |
| US-230 | Access PRD Acceptance Tests | `project-management/user-stories/US-230-access-prd-acceptance-tests.md` | Critical | draft |
| US-231 | Update User Story Metadata | `project-management/user-stories/US-231-update-user-story-metadata.md` | High | draft |
| US-232 | List and Access Personas | `project-management/user-stories/US-232-list-and-access-personas.md` | Medium | draft |

**To load a user story**: Use the MCP tool `get_story {story-id}`

```bash
# Example: Load a specific story
get_story US-226

# Then filter stories by PRD group:
list_stories --prd_group pm_mcp_tools
```

---

## Functional Requirements

Functional requirements are defined in separate files for modularity and versioning:

### FR Registry

See `project-management/PRDs/PRD-017-pm-mcp-tools/functional-requirements/index.yaml` for complete list.

| ID | Title | File |
|---|---|---|
| FR-001 | User Story Reader | `functional-requirements/FR-001-user-story-reader.md` |
| FR-002 | User Story Lister | `functional-requirements/FR-002-user-story-lister.md` |
| FR-003 | PRD Reader | `functional-requirements/FR-003-prd-reader.md` |
| FR-004 | Functional Requirement Accessor | `functional-requirements/FR-004-functional-requirement-accessor.md` |
| FR-005 | Acceptance Test Accessor | `functional-requirements/FR-005-acceptance-test-accessor.md` |
| FR-006 | Story Metadata Updater | `functional-requirements/FR-006-story-metadata-updater.md` |
| FR-007 | Persona Accessor | `functional-requirements/FR-007-persona-accessor.md` |

**To load a functional requirement**: Use the file path or MCP tools:

```bash
# Load specific FR
view_markdown project-management/PRDs/PRD-017-pm-mcp-tools/functional-requirements/FR-001-user-story-reader.md

# Get PRD FR via tool
get_prd_functional_requirement PRD-017 FR-001
```

---

## Non-Functional Requirements

| ID | Requirement | Metric | Target |
|----|-------------|--------|--------|
| NFR-1 | Test coverage for new code | Line coverage | >= 80% |
| NFR-2 | Critical path coverage | Branch coverage | 100% |
| NFR-3 | Index YAML parse performance | Time | < 50ms |
| NFR-4 | Single item retrieval performance | Time | < 100ms |
| NFR-5 | List operation performance | Time | < 200ms for 200+ items |
| NFR-6 | Error message quality | Contains context | Always |
| NFR-7 | Atomic file operations | Data integrity | No corruption on failure |

---

## Error Handling

| Error Condition | Error Type | User Message |
|-----------------|------------|--------------|
| Story not found | NotFoundError | "User story '{id}' not found in index" |
| PRD not found | NotFoundError | "PRD '{id}' not found" |
| FR not found | NotFoundError | "Functional requirement '{id}' not found in PRD '{prd_id}'" |
| AT not found | NotFoundError | "Acceptance test '{id}' not found in PRD '{prd_id}'" |
| Persona not found | NotFoundError | "Persona '{id}' not found" |
| Invalid story ID format | ValidationError | "Invalid story ID format: '{id}'. Expected 'US-XXX' or numeric ID" |
| Invalid PRD ID format | ValidationError | "Invalid PRD ID format: '{id}'. Expected 'PRD-XXX' or numeric ID" |
| Index file missing | FileNotFoundError | "Index file not found: {path}" |
| YAML parse error | ParseError | "Failed to parse YAML in {file}: {details}" |
| Invalid metadata key | ValidationError | "Invalid metadata key '{key}'. Valid keys: status, priority, prds, related_stories, related_personas" |
| Invalid metadata value | ValidationError | "Invalid value '{value}' for key '{key}'. {allowed_values}" |
| File write error | IOError | "Failed to write to {file}: {details}" |

---

## Acceptance Tests

Acceptance tests are defined in separate files for easier test suite generation:

### AT Registry

See `project-management/PRDs/PRD-017-pm-mcp-tools/acceptance-tests/index.yaml` for complete list.

| ID | Title | File |
|---|---|---|
| AT-001 | Get Story Basic Tests | `acceptance-tests/AT-001-get-story-basic.md` |
| AT-002 | Get Story Edge Cases | `acceptance-tests/AT-002-get-story-edge-cases.md` |
| AT-003 | List Stories Tests | `acceptance-tests/AT-003-list-stories.md` |
| AT-004 | Get PRD Tests | `acceptance-tests/AT-004-get-prd.md` |
| AT-005 | Get Functional Requirement Tests | `acceptance-tests/AT-005-get-functional-requirement.md` |
| AT-006 | Get Acceptance Test Tests | `acceptance-tests/AT-006-get-acceptance-test.md` |
| AT-007 | Update Story Metadata Tests | `acceptance-tests/AT-007-update-story-metadata.md` |
| AT-008 | Persona Access Tests | `acceptance-tests/AT-008-persona-access.md` |
| AT-009 | Error Handling Tests | `acceptance-tests/AT-009-error-handling.md` |
| AT-010 | Integration Tests | `acceptance-tests/AT-010-integration.md` |

**To generate test suite**: Pass this PRD to `npl-tdd-tester` agent

```bash
# TDD Workflow:
1. npl-idea-to-spec -> Creates personas + user stories (done)
2. npl-prd-editor -> Creates this PRD (you are here)
3. npl-tdd-tester -> Reads acceptance-tests/ to generate test_*.py
4. npl-tdd-coder -> Implements code to pass tests
5. npl-tdd-debugger -> Fixes any test failures
```

---

## Success Criteria

1. **All 7 user stories fully implemented** with all acceptance criteria passing
2. **Test coverage >= 80%** for all new code (measured by `mise run test-coverage`)
3. **Critical paths have 100% coverage**: get_story, get_prd, update_story_metadata
4. **All existing tests still pass** (no regressions)
5. **All MCP tools register correctly** in the FastMCP server
6. **Error messages are clear and actionable** with context
7. **Performance meets targets**: parse < 50ms, retrieve < 100ms, list < 200ms

---

## Implementation Notes

### Directory Structure

```
src/npl_mcp/
    pm_tools/
        __init__.py
        stories.py          # FR-001, FR-002, FR-006
        prds.py             # FR-003, FR-004, FR-005
        personas.py         # FR-007
        utils.py            # Common utilities (YAML parsing, path resolution)
        exceptions.py       # Custom exceptions
    launcher.py             # Register tools with FastMCP

tests/pm_tools/
    test_stories.py
    test_prds.py
    test_personas.py
    test_utils.py
    test_integration.py
```

### Data Sources

| Data Type | Index File | Content Files |
|-----------|------------|---------------|
| User Stories | `project-management/user-stories/index.yaml` | `project-management/user-stories/US-XXX-*.md` |
| PRDs | `project-management/PRDs/index.yaml` (if exists) | `project-management/PRDs/PRD-XXX-*.md` |
| Functional Requirements | `project-management/PRDs/PRD-XXX-name/functional-requirements/index.yaml` | `FR-XXX-*.md` |
| Acceptance Tests | `project-management/PRDs/PRD-XXX-name/acceptance-tests/index.yaml` | `AT-XXX-*.md` |
| Personas | `project-management/personas/index.yaml` | `project-management/personas/*.md`, `agents/*.md`, `additional-agents/**/*.md` |

### MCP Tool Signatures

```python
# Story Tools
@mcp.tool()
async def get_story(story_id: str) -> str:
    """Load a user story by ID."""

@mcp.tool()
async def list_stories(
    status: str | None = None,
    priority: str | None = None,
    persona: str | None = None,
    prd_group: str | None = None,
    prd: str | None = None,
    limit: int = 50,
    offset: int = 0
) -> str:
    """List and filter user stories."""

@mcp.tool()
async def update_story_metadata(
    story_id: str,
    key: str,
    value: str
) -> str:
    """Update user story metadata."""

# PRD Tools
@mcp.tool()
async def get_prd(prd_id: str) -> str:
    """Load a PRD by ID."""

@mcp.tool()
async def get_prd_functional_requirement(
    prd_id: str,
    fr_id: str = "*"
) -> str:
    """Access PRD functional requirements."""

@mcp.tool()
async def get_prd_acceptance_test(
    prd_id: str,
    at_id: str = "*",
    fr_id: str | None = None
) -> str:
    """Access PRD acceptance tests."""

# Persona Tools
@mcp.tool()
async def get_persona(persona_id: str) -> str:
    """Load a persona by ID."""

@mcp.tool()
async def list_personas(
    tags: str | None = None,
    category: str | None = None
) -> str:
    """List and filter personas."""
```

### YAML Update Strategy (yq v3.4.3)

Per CLAUDE.md guidelines, use `yq` for YAML updates:

```bash
# Update story status
yq -y '.stories |= map(if .id == "US-226" then .status = "in-progress" else . end)' \
  project-management/user-stories/index.yaml > temp.yaml && \
  mv temp.yaml project-management/user-stories/index.yaml

# Append to array
yq -y '.stories |= map(if .id == "US-226" then .prds = (.prds + ["PRD-017"]) else . end)' \
  project-management/user-stories/index.yaml > temp.yaml && \
  mv temp.yaml project-management/user-stories/index.yaml
```

---

## Out of Scope

- Creating new user stories or PRDs via MCP tools
- Editing markdown content (only metadata updates)
- Git integration (commits, branches)
- Real-time collaboration features
- PRD index.yaml creation (discovery by file glob pattern instead)
- Acceptance criteria completion tracking (separate feature)

---

## Dependencies

- PyYAML for YAML parsing
- pathlib for file path operations
- FastMCP for tool registration
- pytest for testing
- pytest-cov for coverage reporting
- yq v3.4.3 for YAML updates (system dependency)

---

## Open Questions

- [ ] Q1: Should we create a PRD index.yaml or discover PRDs by glob pattern?
- [ ] Q2: Should list_stories support "OR" logic for filters?
- [ ] Q3: Should acceptance criteria completion sync from markdown or index?
- [ ] Q4: Should we expose PRD listing with similar filtering to list_stories?
- [ ] Q5: How should we handle nested persona categories (Core, Infrastructure, Marketing, etc.)?

---

## References

- User Stories: `project-management/user-stories/US-22{6-32}-*.md`
- Functional Requirements: `project-management/PRDs/PRD-017-pm-mcp-tools/functional-requirements/`
- Acceptance Tests: `project-management/PRDs/PRD-017-pm-mcp-tools/acceptance-tests/`
- Architecture: `/docs/PROJ-ARCH.md`
- Existing stubs: `src/npl_mcp/launcher.py` (lines 124-180+)
- YAML guidelines: `CLAUDE.md` (yq v3.4.3 section)
- Story index: `project-management/user-stories/index.yaml`
- Persona index: `project-management/personas/index.yaml`

---

## How to Use This PRD

### For TDD Agent Workflow

1. **Phase 1 - Specification** (done)
   - User stories extracted to `project-management/user-stories/`
   - Each story references this PRD via prd_group: pm_mcp_tools

2. **Phase 2 - Test Generation**
   - Run: `npl-tdd-tester --prd project-management/PRDs/PRD-017-pm-mcp-tools.md`
   - Agent reads acceptance tests from `acceptance-tests/` directory
   - Generates: `tests/pm_tools/test_*.py` with full test suite

3. **Phase 3 - Implementation**
   - Run: `npl-tdd-coder --prd project-management/PRDs/PRD-017-pm-mcp-tools.md`
   - Coder reads FRs from `functional-requirements/` directory
   - Implements code matching FRs and passing acceptance tests

4. **Phase 4 - Validation**
   - All tests pass: `mise run test-status`
   - Coverage >= 80%: `mise run test-coverage`
   - PRD requirements satisfied

### For Manual Implementation

- Reference the individual FR files for detailed specifications
- Use acceptance test files as test plan
- Follow the directory structure suggested in Implementation Notes
- Use existing stubs in `src/npl_mcp/launcher.py` as starting point

---

**Last Updated**: 2026-02-02
**PRD Status**: Ready for Test Suite Generation
