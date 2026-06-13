# PRD-014: CLI Utilities Implementation

**Version**: 1.0
**Status**: Draft
**Author**: npl-prd-editor
**Created**: 2026-02-02
**Updated**: 2026-02-02

## Overview

The NPL framework documents 7 CLI utilities for resource loading, persona management, session coordination, and codebase exploration. Currently 0 utilities are implemented, blocking all workflows that depend on hierarchical resource loading or cross-agent coordination. This PRD defines complete implementation specifications for all CLI utilities.

**Current State**:
- 7 CLI utilities documented
- 0 utilities implemented
- Resource loading blocked
- Session coordination unavailable

**Target State**:
- All 7 utilities implemented and tested
- Hierarchical path resolution working
- Integration with MCP server tools
- Documentation with usage examples

## Goals

1. Implement all 7 CLI utilities with complete functionality
2. Enable hierarchical resource loading across all path levels
3. Provide persistent persona state management
4. Enable cross-agent coordination through worklogs
5. Support codebase exploration with Git awareness
6. Validate NPL syntax with actionable error reporting
7. Verify NPL installation health

## Non-Goals

- GUI interfaces for CLI utilities
- Remote resource loading over network
- Real-time collaboration features
- IDE plugins or integrations
- Windows-specific implementations (focus on Unix-like systems)

---

## User Stories

Reference stories from global `project-management/user-stories/` directory.

| ID | Title | Persona | Priority |
|----|-------|---------|----------|
| US-001 | [Load NPL Core Components](../../user-stories/US-001-load-npl-core.md) | P-001 | critical |
| US-002 | [Load Project-Specific Context](../../user-stories/US-002-load-project-context.md) | P-001 | critical |
| US-085 | [Implement CLI Utilities](../../user-stories/US-085-implement-cli-utilities.md) | P-005 | high |
| US-025 | [Explore Project File Structure](../../user-stories/US-025-explore-project-structure.md) | P-001 | medium |
| US-224 | [Skip Already-Loaded Resources Using Flags](../../user-stories/US-224-skip-loaded-resources-flag.md) | P-005 | medium |
| US-225 | [Cross-Agent Communication Through Shared Worklogs](../../user-stories/US-225-cross-agent-worklog-communication.md) | P-005 | high |

Use MCP tools to load full story details:
- **get-story**: Load story by ID
- **edit-story**: Modify story content
- **update-story**: Update story metadata

---

## Functional Requirements

All functional requirements are detailed in `./functional-requirements/` directory.

See `functional-requirements/index.yaml` for complete list.

Key requirements:
- **FR-001**: [npl-load Hierarchical Resource Loader](./functional-requirements/FR-001-npl-load-hierarchical-resource-loader.md)
- **FR-002**: [npl-persona Lifecycle Manager](./functional-requirements/FR-002-npl-persona-lifecycle-manager.md)
- **FR-003**: [npl-session Worklog Coordinator](./functional-requirements/FR-003-npl-session-worklog-coordinator.md)
- **FR-004**: [dump-files Content Extractor](./functional-requirements/FR-004-dump-files-content-extractor.md)
- **FR-005**: [git-tree Directory Viewer](./functional-requirements/FR-005-git-tree-directory-viewer.md)
- **FR-006**: [npl-syntax Validator](./functional-requirements/FR-006-npl-syntax-validator.md)
- **FR-007**: [npl-check Health Utility](./functional-requirements/FR-007-npl-check-health-utility.md)

---

## Non-Functional Requirements

| ID | Requirement | Metric | Target |
|----|-------------|--------|--------|
| NFR-1 | Test coverage | Line coverage | >= 90% |
| NFR-2 | Response time | Operation completion | < 1s for typical use |
| NFR-3 | Error handling | Clear messages | 100% of error conditions |
| NFR-4 | Documentation | Usage examples | All utilities documented |
| NFR-5 | Platform support | OS compatibility | Linux, macOS |

---

## Error Handling

| Error Condition | Error Type | User Message |
|-----------------|------------|--------------|
| Missing resource | FileNotFoundError | "Resource '{name}' not found in any search path" |
| Invalid skip expression | ValueError | "Skip expression '{expr}' is invalid: {reason}" |
| Duplicate persona | ValueError | "Persona '{id}' already exists" |
| No active session | RuntimeError | "No active session. Run 'npl-session init' first" |
| Corrupt journal | IOError | "Journal file corrupted. Backup: {path}" |
| Validation failure | SyntaxError | "Line {n}, col {c}: {message}" |
| Server unreachable | ConnectionError | "MCP server unreachable at {url}" |

---

## Acceptance Tests

All acceptance tests detailed in `./acceptance-tests/` directory.

See `acceptance-tests/index.yaml` for test plan.

Test categories:
- **Unit tests**: Individual component functionality
- **Integration tests**: Multi-component workflows
- **End-to-end tests**: Complete user scenarios

---

## Success Criteria

1. All 7 CLI utilities implemented with complete functionality
2. >90% test coverage across all utilities
3. Hierarchical path resolution working at all levels (env → project → user → system)
4. All utilities integrate with MCP server
5. Documentation includes man pages and usage examples
6. Performance targets met (< 1s for typical operations)
7. Clear, actionable error messages for all error conditions

---

## Out of Scope

- GUI or web interfaces for CLI utilities
- Remote resource loading over network protocols
- Real-time collaboration features
- IDE-specific plugins or integrations
- Windows-native implementations (PowerShell versions)
- Authentication or authorization systems
- Resource encryption or security features

---

## Dependencies

| Dependency | Version | Purpose |
|------------|---------|---------|
| Python | >= 3.11 | Runtime environment |
| Click | >= 8.0 | CLI framework |
| PyYAML | >= 6.0 | YAML parsing |
| GitPython | >= 3.1 | Git integration |
| pytest | >= 7.0 | Testing framework |

---

## Hierarchical Loading System

All CLI utilities respect the hierarchical path resolution:

```
Priority (highest to lowest):
1. Environment variables ($NPL_HOME, $NPL_AGENTS, etc.)
2. Project-local (./.npl/)
3. User-global (~/.npl/)
4. System-wide (/etc/npl/)
```

**Resolution Rules**:
- First match wins (higher priority shadows lower)
- Missing directories are skipped (not errors)
- Resources can be merged from multiple levels
- Explicit `--path` overrides all resolution

**Environment Variables**:
| Variable | Purpose |
|----------|---------|
| `NPL_HOME` | Base path for all NPL resources |
| `NPL_AGENTS` | Path to agent definitions |
| `NPL_PERSONAS` | Path to persona storage |
| `NPL_SESSIONS` | Path to session worklogs |
| `NPL_META` | Path to metadata files |

---

## Testing Strategy

### Unit Tests
- Path resolution at each hierarchy level
- Individual subcommand functionality
- Output format correctness
- Error condition handling

### Integration Tests
- Full workflows (init → use → cleanup)
- Cross-utility integration (session + persona)
- MCP server interaction
- .gitignore pattern respect

### End-to-End Tests
- Complete resource loading scenarios
- Multi-persona team coordination
- Session-based agent handoffs
- Syntax validation workflows

Target coverage: **>90% for all utilities**

---

## Open Questions

- [ ] Should npl-load support remote resource URLs?
- [ ] Should persona state support encryption?
- [ ] Should session worklogs support compression for long sessions?
- [ ] Should git-tree support color output for better visibility?
- [ ] Should npl-check support auto-fix mode for common issues?

---

## Legacy Reference

- **Scripts Summary**: `.tmp/docs/scripts/summary.brief.md`
- **npl-load**: `.tmp/docs/scripts/npl-load.brief.md`
- **npl-persona**: `.tmp/docs/scripts/npl-persona.brief.md`
- **npl-session**: `.tmp/docs/scripts/npl-session.brief.md`
- **dump-files**: `.tmp/docs/scripts/dump-files.brief.md`
- **git-tree**: `.tmp/docs/scripts/git-tree.brief.md`
