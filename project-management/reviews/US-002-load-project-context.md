# Review: Load Project-Specific Context

- **Story**: `project-management/user-stories/US-002-load-project-context.md`
- **Status**: Not Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

No project-context loading exists in the codebase. The story's planned tools — `npl_load_project`, `npl_detect_project_type`, `npl_merge_context` — appear nowhere in `src/` or `tests/` (targeted greps return nothing). The only NPL loading path, `NPLLoad` (`src/npl_mcp/launcher.py:237-291`), hardcodes a single conventions directory resolved relative to the MCP server install root (`launcher.py:286-288`) and performs no discovery of `.npl/`, `npl.yaml`, or `.npl.yaml`, no project-type detection, no style/convention document loading, and no structured metadata result. The `npl/` package (`src/npl_mcp/npl/`: parser, resolver, layout, loader, filters, exceptions) is purely expression-DSL machinery with no project-awareness. Confidence: high — this is a broad negative, but every named tool and mechanism was searched for directly.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Discover and load project NPL config from standard locations (`.npl/`, `npl.yaml`, `.npl.yaml`) | Not Met | No config discovery code; `NPLLoad` hardcodes `conventions/` (`src/npl_mcp/launcher.py:286-288`) — no evidence found |
| Load project-specific syntax extensions and merge with core syntax | Not Met | Resolver supports only the fixed conventions dir (`src/npl_mcp/npl/loader.py:87`); no extension/merge mechanism — no evidence found |
| Load project coding style guides (`.npl/style.md`, `.npl/conventions.md`) | Not Met | No evidence found |
| Identify project type from file extensions and load language-specific conventions | Not Met | No project-type detection code anywhere in `src/` — no evidence found |
| Return structured metadata (config file list, syntax extensions, style guides, project types, load timestamp) | Not Met | `NPLLoad` returns a bare markdown string (`src/npl_mcp/npl/loader.py:94`); no metadata structure — no evidence found |
| Handle missing optional components gracefully without errors | Not Met | No project-component loading exists to be graceful about — no evidence found |
| Log warnings for expected-but-missing configuration files | Not Met | No evidence found |
| Successfully merge project context with core context from US-001 | Not Met | No merge logic — no evidence found |

## Gaps / Risks

- Entire feature area absent: schema discovery, project-type detection, context merging, metadata reporting, and the three planned MCP tools would all need to be built from scratch.
- The existing `NPLLoad` design (fixed conventions dir at install root) actively conflicts with per-project loading — a project in a different checkout cannot load its own conventions today.
- Story's Open Questions (env-specific overrides, cross-session caching strategy) are unresolved; both should be settled before implementation since they shape the tool signature.
- Dependencies listed (US-001 core loading) are only partially satisfied (see review of US-001-load-npl-core), so even the foundation is incomplete.

## BDD Scenario

```gherkin
Feature: Load project-specific NPL context

  Scenario: Load context for a Python project with .npl directory
    Given a project root containing ".npl/config.yaml", ".npl/style.md", and "pyproject.toml"
    And core NPL context has been loaded via US-001
    When the agent calls npl_load_project with the project root
    Then configuration files are discovered in precedence order
    And the project type is detected as "python"
    And project style guides and syntax extensions are merged over core defaults
    And the result includes structured metadata: config file paths, active extensions, active style guides, detected project types, and a load timestamp

  Scenario: Project without NPL configuration
    Given a project root with no ".npl/" directory or npl.yaml file
    When the agent calls npl_load_project with the project root
    Then initialization does not fail
    And a warning is logged for the expected-but-missing configuration files
    And core context alone remains active
```
