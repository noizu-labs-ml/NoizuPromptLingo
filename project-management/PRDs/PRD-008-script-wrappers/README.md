# PRD-008: Script Wrappers

**Version**: 1.0
**Status**: Implemented
**Author**: npl-prd-editor
**Created**: 2026-02-02
**Updated**: 2026-02-02

## Overview

MCP tool wrappers for existing NPL command-line scripts enabling codebase exploration, content aggregation, and NPL framework resource loading. All tools enforce absolute path requirements to prevent ambiguity across different working directories.

## Goals

1. Provide MCP tools for file content aggregation and directory visualization
2. Enable NPL resource loading with redundancy prevention
3. Support web content fetching as markdown for external documentation
4. Enforce absolute path requirements for filesystem operations
5. Integrate existing bash/Python scripts into MCP ecosystem

## Non-Goals

- Replacing existing command-line scripts (wrappers only)
- Supporting relative path operations
- Implementing new script functionality

---

## User Stories

Reference stories from global `project-management/user-stories/` directory.

| ID | Title | Persona |
|----|-------|---------|
| US-001 | [Load NPL Core Components](../../user-stories/US-001-load-npl-core.md) | P-001 |
| US-002 | [Load Project-Specific Context](../../user-stories/US-002-load-project-context.md) | P-001 |
| US-003 | [Fetch Web Content as Markdown](../../user-stories/US-003-fetch-web-as-markdown.md) | P-003 |
| US-025 | [Explore Project File Structure](../../user-stories/US-025-explore-project-structure.md) | P-001 |
| US-047 | [View Database Schema Documentation](../../user-stories/US-047-view-database-schema-documentation.md) | P-003 |

Use MCP tools to load full story details:
- **get-story**: Load story by ID
- **edit-story**: Modify story content
- **update-story**: Update story metadata

---

## Functional Requirements

All functional requirements are detailed in `./functional-requirements/` directory.

See `functional-requirements/index.yaml` for complete list.

Key requirements:
- **FR-001**: [File Content Aggregation](./functional-requirements/FR-001-file-content-aggregation.md)
- **FR-002**: [Directory Tree Visualization](./functional-requirements/FR-002-directory-tree-visualization.md)
- **FR-003**: [NPL Resource Loading](./functional-requirements/FR-003-npl-resource-loading.md)
- **FR-004**: [Web to Markdown Conversion](./functional-requirements/FR-004-web-to-markdown.md)

---

## Non-Functional Requirements

| ID | Requirement | Metric | Target |
|----|-------------|--------|--------|
| NFR-1 | Test coverage | Line coverage | >= 80% (for testable components) |
| NFR-2 | Script discovery | Search paths | Project root + cwd |
| NFR-3 | Error messages | Clarity | Actionable guidance for users |
| NFR-4 | Path enforcement | Validation | Reject all relative paths |

---

## Error Handling

| Error Condition | Error Type | User Message |
|-----------------|------------|--------------|
| Relative path provided | ValueError | "Path must be absolute. Use `pwd` to get current directory." |
| Script not found | FileNotFoundError | "Script {name} not found in standard locations" |
| Web fetch timeout | TimeoutException | "Request timed out after {timeout}s" |
| Network error | HTTPError | "Failed to fetch URL: {error}" |

---

## Acceptance Tests

All acceptance tests detailed in `./acceptance-tests/` directory.

See `acceptance-tests/index.yaml` for test plan.

Key tests:
- **AT-001**: Dump files basic functionality
- **AT-002**: Absolute path validation
- **AT-003**: NPL load skip parameter
- **AT-004**: Web to markdown timeout handling
- **AT-005**: Git tree directory visualization

---

## Success Criteria

1. All user stories implemented with acceptance criteria passing
2. Test coverage >= 80% for testable components (httpx calls)
3. All acceptance tests passing
4. Clear and actionable error messages for common failures
5. Script discovery works across different project layouts

---

## Out of Scope

- Modifying underlying bash/Python scripts
- Adding new script functionality
- Supporting relative paths
- Cross-platform script compatibility (beyond Linux/macOS)

---

## Dependencies

- **Internal**: subprocess module, httpx library
- **External**: dump-files (bash), git-tree (bash), git-tree-depth (bash), npl-load (Python), Jina Reader API
- **Environment**: JINA_API_KEY (optional for web_to_md)

---

## Implementation Notes

### Script Discovery Strategy

Tools search for scripts in two locations:
1. `Path(__file__).parents[4] / "core" / "scripts" / script_name`
2. `Path.cwd() / "core" / "scripts" / script_name`

### Absolute Path Enforcement

All filesystem tools validate paths before execution:
```python
if path.startswith('.'):
    raise ValueError("Path must be absolute. Use `pwd` to get current directory.")
```

### NPL Resource Loading

The `--skip` parameter is critical for preventing redundant resource loading when agents already have context injected. Resources are tracked across multiple invocations.

---

## Documentation References

- **Implementation Status**: ✅ Complete in mcp-server worktree
- **Category Brief**: `.tmp/mcp-server/categories/08-script-wrappers.md`
- **Tool Spec**: `.tmp/mcp-server/tools/by-category/script-tools.yaml`

---

## Open Questions

- [ ] Should script discovery include user home directory (~/.npl/scripts)?
- [ ] Should we add caching for web_to_md results?
- [ ] Should dump_files support recursive directory traversal?
