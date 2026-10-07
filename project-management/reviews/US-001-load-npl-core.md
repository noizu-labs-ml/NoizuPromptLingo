# Review: Load NPL Core Components

- **Story**: `project-management/user-stories/US-001-load-npl-core.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

Core loading is well implemented: the `NPLLoad` MCP tool (`src/npl_mcp/launcher.py:237-291`) exposes the expression DSL over `conventions/*.yaml` (the single source of truth — syntax, declarations, directives, prefixes, prompt-sections, special-sections, pumps), via `load_npl` in `src/npl_mcp/npl/loader.py:17-101`, with priority filters, subtraction, skip terms, and three layouts. Extensive tests cover it (`tests/test_npl_loading.py`, ~30 test cases). However, three story requirements are not met: there is no loading of agent communication protocols (no path exposes `docs/arch/agent-orchestration.md` through `NPLLoad`; `conventions/` contains only YAML sections), no style-guide/convention document loading beyond YAML syntax definitions, and error handling for missing components raises `NPLResolveError` rather than degrading gracefully (only subtractions of nonexistent components warn — `tests/test_npl_loading.py:550`). Caching of loaded components (story Notes) is also absent. Confidence: high; `conventions/` directory contents and loader were inspected directly.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| `npl_load` loads core NPL syntax definitions, returns structured content | Met | `src/npl_mcp/npl/loader.py:17-101` resolves `conventions/*.yaml`; `src/npl_mcp/launcher.py:237-291` exposes as MCP tool; `tests/test_npl_loading.py:324+` |
| `npl_load` loads agent communication protocols (e.g., agent-orchestration.md) | Not Met | `conventions/` contains only YAML files (syntax, directives, pumps, …); no tool or loader path returns agent-orchestration protocols — no evidence found |
| `npl_load` loads standard conventions and style guides | Partially Met | NPL syntax/directive conventions load, but no style-guide documents are loadable; no evidence of style-guide files or their loading |
| Loaded content returned in markdown or JSON suitable for LLM context injection | Met | Markdown output via `NPLLayoutEngine` (`src/npl_mcp/npl/layout.py`); structured variant available via `NPLSpec` (`src/npl_mcp/launcher.py:195-231`) |
| Optional parameters to selectively load specific component types | Met | Expression DSL with sections, `#component`, `:+priority`, subtraction, and `skip` param — `src/npl_mcp/npl/loader.py:29-41`, `src/npl_mcp/launcher.py:277-282` |
| Gracefully handles missing optional components without errors | Partially Met | Subtracting a nonexistent component warns (`tests/test_npl_loading.py:550`), but requesting a missing additive component raises `NPLResolveError` (`src/npl_mcp/npl/loader.py:96-98` re-raises) — no graceful-skip option |

## Gaps / Risks

- No caching layer: every `NPLLoad` call re-parses and re-resolves YAML from disk (story Notes expect caching to avoid repeated loading).
- Story Notes mention "loading from both local files and remote repositories" — remote loading is unimplemented; `NPLLoad` hardcodes the repo-root `conventions/` dir (`src/npl_mcp/launcher.py:286-288`).
- No default-vs-minimal/full loading preset; story Open Question ("minimal vs full") remains open and unimplemented.
- "Structured content" is markdown-only on the `NPLLoad` path; JSON/structured output only via the separate `NPLSpec` tool.

## BDD Scenario

```gherkin
Feature: Load NPL core components for agent context

  Scenario: Load the full syntax section
    Given the NPL MCP server is running with conventions/ YAML files present
    When the agent calls NPLLoad with expression "syntax"
    Then markdown-formatted syntax definitions are returned
    And the content is suitable for direct LLM context injection

  Scenario: Selectively load one component with priority filter
    Given the NPL MCP server is running
    When the agent calls NPLLoad with expression "pumps#chain-of-thought:+2"
    Then only the chain-of-thought pump and its priority-≤2 examples are returned

  Scenario: Request a missing optional component
    Given the NPL MCP server is running
    When the agent calls NPLLoad with an expression naming a component that does not exist
    Then the load completes without a hard error for optional components
    And a warning identifies the skipped component
```
